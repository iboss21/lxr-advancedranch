local Config = require("shared.config")
local Utils = require("shared.utils")
local RanchManager = require("server.ranch_manager")
local Environment = require("server.environment")
local Livestock = require("server.livestock")
local Workforce = require("server.workforce")
local Economy = require("server.economy")
local Progression = require("server.progression")

local function ensureAdmin(source)
    if not Utils.IsAdmin(source) then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "You do not have permission." } })
        return false
    end
    return true
end

local function resolveOwnerIdentifier(source, identifierArg)
    local args = {}
    if identifierArg then
        args[1] = identifierArg
    end
    local target = Utils.GetTargetIdentifier(args, source)
    if not target then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Unable to determine identifier." } })
        return nil
    end
    return target
end

RegisterCommand("ranchcreate", function(source, args)
    if not ensureAdmin(source) then return end
    local name = args[1]
    if not name then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchcreate <Name> [identifier]" } })
        return
    end
    local ownerIdentifier = resolveOwnerIdentifier(source, args[2])
    local ranch, err = RanchManager.CreateRanch(name, ownerIdentifier)
    if not ranch then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", err or "Failed to create ranch." } })
        return
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Created ranch %s (%s)"):format(ranch.name, ranch.id) } })
end, false)

RegisterCommand("ranchdelete", function(source, args)
    if not ensureAdmin(source) then return end
    local id = args[1]
    if not id then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchdelete <RanchId>" } })
        return
    end
    local success, err = RanchManager.DeleteRanch(id)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Deleted ranch %s"):format(id) or err } })
end, false)

RegisterCommand("ranchtransfer", function(source, args)
    if not ensureAdmin(source) then return end
    local id = args[1]
    if not id then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchtransfer <RanchId> <identifier>" } })
        return
    end
    local identifier = resolveOwnerIdentifier(source, args[2])
    if not identifier then return end
    local success, result = RanchManager.TransferOwnership(id, identifier)
    if not success then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", result or "Transfer failed" } })
        return
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Transferred %s to %s"):format(id, identifier) } })
end, false)

RegisterCommand("ranchsetrole", function(source, args)
    if not ensureAdmin(source) then return end
    local id, role = args[1], args[2]
    if not id or not role then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchsetrole <RanchId> <RoleId>" } })
        return
    end
    local success, err = RanchManager.SetDiscordRole(id, role)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Role %s assigned to %s"):format(role, id) or err } })
end, false)

RegisterCommand("ranchseason", function(source, args)
    if not ensureAdmin(source) then return end
    local season = args[1]
    if not season then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchseason <spring|summer|autumn|winter>" } })
        return
    end
    local success, err = Environment.SetSeason(season)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Season set to %s"):format(season) or err } })
end, false)

RegisterCommand("ranchweather", function(source)
    if not ensureAdmin(source) then return end
    Environment.RollWeather()
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Weather pattern rolled." } })
end, false)

RegisterCommand("ranchhazard", function(source, args)
    if not ensureAdmin(source) then return end
    local hazard = args[1]
    if not hazard then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchhazard <hazardKey> [ranchId]" } })
        return
    end
    local ranchId = args[2]
    local success, err = Environment.QueueHazard(hazard, { ranchId = ranchId, manual = true })
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Hazard %s queued."):format(hazard) or err } })
end, false)

RegisterCommand("ranchanimaladd", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, species, count = args[1], args[2], tonumber(args[3]) or 1
    if not ranchId or not species then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchanimaladd <RanchId> <species> [count]" } })
        return
    end
    local created = 0
    for i = 1, count do
        local success, result = Livestock.RegisterAnimal(ranchId, species, {})
        if success then created = created + 1 end
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Added %s %s to %s"):format(created, species, ranchId) } })
end, false)

RegisterCommand("ranchanimaldel", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, animalId = args[1], args[2]
    if not ranchId or not animalId then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchanimaldel <RanchId> <AnimalId>" } })
        return
    end
    local success, err = Livestock.RemoveAnimal(ranchId, animalId)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Removed %s"):format(animalId) or err } })
end, false)

RegisterCommand("ranchassign", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, identifier, role = args[1], args[2], args[3]
    if not ranchId or not identifier or not role then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchassign <RanchId> <Identifier> <Role>" } })
        return
    end
    Workforce.AssignWorker(ranchId, Utils.NormalizeIdentifier(identifier) or identifier, role)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Worker assigned." } })
end, false)

RegisterCommand("ranchtask", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, taskType = args[1], args[2]
    if not ranchId or not taskType then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchtask <RanchId> <TaskType>" } })
        return
    end
    local success, err = Workforce.CreateTask(ranchId, taskType, {})
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Task %s created"):format(taskType) or err } })
end, false)

RegisterCommand("ranchcontract", function(source, args)
    if not ensureAdmin(source) then return end
    local town, contractId, ranchId = args[1], args[2], args[3]
    if not town then
        local contract = Economy.GenerateContract()
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Generated contract %s for %s"):format(contract.id, contract.town) } })
        return
    end
    if town and contractId and ranchId then
        local success, err = Economy.AssignContract(town, contractId, ranchId)
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and "Contract assigned" or err } })
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchcontract <Town> <ContractId> <RanchId>" } })
    end
end, false)

RegisterCommand("ranchxp", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, amount = args[1], tonumber(args[2])
    if not ranchId or not amount then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchxp <RanchId> <Amount>" } })
        return
    end
    local level = Progression.AddXP(ranchId, amount, "admin grant")
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Ranch %s now level %s"):format(ranchId, level) } })
end, false)

RegisterNetEvent("ranch:zones:save", function(zoneId, payload)
    if not ensureAdmin(source) then return end
    RanchManager.SaveVegetation(zoneId, payload)
end)

RegisterNetEvent("ranch:zones:assign", function(zoneId, ranchId)
    if not ensureAdmin(source) then return end
    RanchManager.AssignZone(zoneId, ranchId)
end)

RegisterNetEvent("ranch:props:save", function(ranchId, props)
    if not ensureAdmin(source) then return end
    local ranch = RanchManager.GetOrCreate(ranchId)
    ranch.props = props
    TriggerClientEvent("ranch:props:update", -1, ranchId, props)
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    -- placeholder for Discord sync or role enforcement
end)

AddEventHandler("playerJoining", function(source)
    RanchManager.SyncAll(source)
    TriggerClientEvent("ranch:environment:update", source, Environment.GetState())
    TriggerClientEvent("ranch:economy:update", source, {
        prices = Economy.Prices,
        contracts = Economy.Contracts,
        auctions = Economy.Auctions
    })
    for ranchId, animals in pairs(Livestock.Animals) do
        TriggerClientEvent("ranch:livestock:update", source, ranchId, animals)
    end
    for ranchId, roster in pairs(Workforce.Rosters) do
        TriggerClientEvent("ranch:workforce:roster", source, ranchId, roster)
    end
    for ranchId, tasks in pairs(Workforce.Tasks) do
        TriggerClientEvent("ranch:workforce:tasks", source, ranchId, tasks)
    end
    for ranchId, profile in pairs(Progression.Data) do
        TriggerClientEvent("ranch:progression:update", source, ranchId, profile)
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    RanchManager.SyncAll(-1)
end)
