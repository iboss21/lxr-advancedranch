local Config = require("shared.config")

local RanchClient = {
    ranches = {},
    zones = {},
    vegetation = {},
    props = {},
    environment = {},
    livestock = {},
    workforce = {},
    economy = {},
    progression = {}
}

local function debugPrint(...)
    if not Config.Debug then return end
    print("[RanchClient]", ...)
end

RegisterNetEvent("ranch:zones:sync", function(ranchId, parcels)
    debugPrint("Received parcel sync", ranchId)
    RanchClient.zones[ranchId] = parcels
    TriggerEvent("ranch:zones:updated", ranchId, parcels)
end)

RegisterNetEvent("ranch:vegetation:update", function(zoneId, payload)
    RanchClient.vegetation[zoneId] = payload
    TriggerEvent("ranch:vegetation:updated", zoneId, payload)
end)

RegisterNetEvent("ranch:vegetation:bulk", function(payload)
    RanchClient.vegetation = payload or {}
    TriggerEvent("ranch:vegetation:bulkUpdated", payload)
end)

RegisterNetEvent("ranch:props:update", function(ranchId, props)
    RanchClient.props[ranchId] = props
    TriggerEvent("ranch:props:updated", ranchId, props)
end)

RegisterNetEvent("ranch:environment:update", function(state)
    RanchClient.environment = state
    TriggerEvent("ranch:environment:updated", state)
end)

RegisterNetEvent("ranch:environment:notify", function(message)
    TriggerEvent("chat:addMessage", { args = { "Ranch", message } })
end)

RegisterNetEvent("ranch:livestock:update", function(ranchId, animals)
    RanchClient.livestock[ranchId] = animals
    TriggerEvent("ranch:livestock:updated", ranchId, animals)
end)

RegisterNetEvent("ranch:livestock:trust", function(ranchId, animalId, trust)
    RanchClient.livestock[ranchId] = RanchClient.livestock[ranchId] or {}
    RanchClient.livestock[ranchId][animalId] = RanchClient.livestock[ranchId][animalId] or {}
    RanchClient.livestock[ranchId][animalId].trust = trust
    TriggerEvent("ranch:livestock:trustUpdated", ranchId, animalId, trust)
end)

RegisterNetEvent("ranch:livestock:treated", function(ranchId, animalId, treatment)
    TriggerEvent("ranch:livestock:treatedLocal", ranchId, animalId, treatment)
end)

RegisterNetEvent("ranch:workforce:roster", function(ranchId, roster)
    RanchClient.workforce[ranchId] = RanchClient.workforce[ranchId] or {}
    RanchClient.workforce[ranchId].roster = roster
    TriggerEvent("ranch:workforce:rosterUpdated", ranchId, roster)
end)

RegisterNetEvent("ranch:workforce:tasks", function(ranchId, tasks)
    RanchClient.workforce[ranchId] = RanchClient.workforce[ranchId] or {}
    RanchClient.workforce[ranchId].tasks = tasks
    TriggerEvent("ranch:workforce:tasksUpdated", ranchId, tasks)
end)

RegisterNetEvent("ranch:economy:update", function(payload)
    RanchClient.economy = payload
    TriggerEvent("ranch:economy:updated", payload)
end)

RegisterNetEvent("ranch:economy:contracts", function(contracts)
    RanchClient.economy.contracts = contracts
    TriggerEvent("ranch:economy:contractsUpdated", contracts)
end)

RegisterNetEvent("ranch:economy:sale", function(ranchId, product, quantity, value)
    TriggerEvent("chat:addMessage", { args = { "Ledger", ("%s sold %sx %s for $%0.2f"):format(ranchId, quantity, product, value) } })
end)

RegisterNetEvent("ranch:progression:update", function(ranchId, profile)
    RanchClient.progression[ranchId] = profile
    TriggerEvent("ranch:progression:updated", ranchId, profile)
end)

RegisterNetEvent("ranch:progression:achievement", function(ranchId, key)
    TriggerEvent("chat:addMessage", { args = { "Ranch", ("Ranch %s earned achievement %s"):format(ranchId, key) } })
end)

Citizen.CreateThread(function()
    Wait(5000)
    TriggerServerEvent("ranch:environment:requestSync")
    TriggerServerEvent("ranch:economy:requestSync")
end)

exports("GetRanchZones", function()
    return RanchClient.zones
end)

exports("GetVegetation", function()
    return RanchClient.vegetation
end)

exports("GetProps", function()
    return RanchClient.props
end)

exports("GetEnvironment", function()
    return RanchClient.environment
end)

exports("GetLivestock", function()
    return RanchClient.livestock
end)

exports("GetWorkforce", function()
    return RanchClient.workforce
end)

exports("GetEconomy", function()
    return RanchClient.economy
end)

exports("GetProgression", function()
    return RanchClient.progression
end)

return RanchClient
