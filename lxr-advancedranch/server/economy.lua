local Config = require("shared.config")
local Utils = require("shared.utils")
local Storage = require("server.storage")
local RanchManager = require("server.ranch_manager")
local Environment = require("server.environment")

local Economy = {}
Economy.Prices = Storage.Economy:Get("prices") or {}
Economy.Contracts = Storage.Economy:Get("contracts") or {}
Economy.Auctions = Storage.Economy:Get("auctions") or {}

local function save()
    Storage.Economy:Set("prices", Economy.Prices)
    Storage.Economy:Set("contracts", Economy.Contracts)
    Storage.Economy:Set("auctions", Economy.Auctions)
end

local function currentSeason()
    local state = Environment.GetState()
    return state.season or Config.Environment.SeasonSequence[1]
end

function Economy.GetPrice(product)
    local base = Config.Economy.DynamicPricing.baseDemand[product] or 1.0
    local season = currentSeason()
    local modifiers = Config.Economy.DynamicPricing.seasonalModifiers[season] or {}
    local modifier = modifiers[product] or 1.0
    local price = (Economy.Prices[product] or base) * modifier
    return Utils.Round(price, 2)
end

function Economy.RegisterSale(ranchId, product, quantity, quality)
    local price = Economy.GetPrice(product)
    local value = price * quantity * (quality or 1)
    Economy.Prices[product] = (Economy.Prices[product] or price) * 0.98 + price * 0.02
    save()
    RanchManager.AdjustLedger(ranchId, value, string.format("Sale: %s", product))
    TriggerClientEvent("ranch:economy:sale", -1, ranchId, product, quantity, value)
    return value
end

local function ensureContractList(town)
    Economy.Contracts[town] = Economy.Contracts[town] or {}
    return Economy.Contracts[town]
end

function Economy.GenerateContract()
    local towns = Config.Economy.Contracts.townBoards
    local town = towns[math.random(1, #towns)]
    local productKeys = {}
    for product in pairs(Config.Economy.DynamicPricing.baseDemand) do
        table.insert(productKeys, product)
    end
    local product = productKeys[math.random(1, #productKeys)]
    local quantity = math.random(5, 20)
    local expires = Utils.Timestamp() + (Config.Economy.Contracts.expiryHours * 60 * 60)
    local id = string.format("contract_%06d", math.random(0, 999999))
    local contract = {
        id = id,
        town = town,
        product = product,
        quantity = quantity,
        expiresAt = expires,
        reward = Economy.GetPrice(product) * quantity * 1.2,
        assignedRanch = nil
    }
    local list = ensureContractList(town)
    list[id] = contract
    save()
    TriggerClientEvent("ranch:economy:contracts", -1, Economy.Contracts)
    return contract
end

function Economy.AssignContract(town, contractId, ranchId)
    local list = ensureContractList(town)
    local contract = list[contractId]
    if not contract then return false, "Contract not found" end
    if contract.assignedRanch then return false, "Already assigned" end
    contract.assignedRanch = ranchId
    save()
    TriggerClientEvent("ranch:economy:contracts", -1, Economy.Contracts)
    return true
end

function Economy.CompleteContract(town, contractId, success)
    local list = ensureContractList(town)
    local contract = list[contractId]
    if not contract then return false, "Contract not found" end
    if not contract.assignedRanch then return false, "No ranch assigned" end
    if success then
        RanchManager.AdjustLedger(contract.assignedRanch, contract.reward, "Contract reward")
        RanchManager.AppendHistory(contract.assignedRanch, { type = "contract_completed", id = contractId })
    else
        RanchManager.AppendHistory(contract.assignedRanch, { type = "contract_failed", id = contractId })
    end
    list[contractId] = nil
    save()
    TriggerClientEvent("ranch:economy:contracts", -1, Economy.Contracts)
    return true
end

function Economy.Tick()
    Economy.GenerateContract()
    for town, contracts in pairs(Economy.Contracts) do
        for id, contract in pairs(contracts) do
            if contract.expiresAt < Utils.Timestamp() then
                contracts[id] = nil
            end
        end
    end
    save()
    TriggerClientEvent("ranch:economy:contracts", -1, Economy.Contracts)
end

CreateThread(function()
    while true do
        Wait(30 * 60 * 1000)
        Economy.Tick()
    end
end)

RegisterNetEvent("ranch:economy:requestSync", function()
    local src = source
    TriggerClientEvent("ranch:economy:update", src, {
        prices = Economy.Prices,
        contracts = Economy.Contracts,
        auctions = Economy.Auctions
    })
end)

return Economy
