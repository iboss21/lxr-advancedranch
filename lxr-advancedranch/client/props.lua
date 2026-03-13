local Config = require("shared.config")

local propList = {}

local function serializeProps()
    local payload = {}
    for i, entry in ipairs(propList) do
        payload[i] = {
            model = entry.model,
            coords = entry.coords,
            heading = entry.heading
        }
    end
    return payload
end

local function notify(message)
    TriggerEvent("chat:addMessage", { args = { "Ranch", message } })
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
    end
    return true
end

local function spawnProp(modelName)
    local model = GetHashKey(modelName)
    if not loadModel(model) then
        notify("Invalid prop model: " .. modelName)
        return nil
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local entity = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(entity, GetEntityHeading(ped))
    PlaceObjectOnGroundProperly(entity)
    FreezeEntityPosition(entity, true)
    return entity
end

local function addProp(ranchId, modelName)
    local entity = spawnProp(modelName)
    if not entity then return end
    local coords = GetEntityCoords(entity)
    local entry = {
        model = modelName,
        entity = entity,
        coords = { x = coords.x, y = coords.y, z = coords.z },
        heading = GetEntityHeading(entity)
    }
    table.insert(propList, entry)
    TriggerServerEvent("ranch:props:save", ranchId, serializeProps())
    notify("Prop placed: " .. modelName)
end

local function clearProps(ranchId, skipServer)
    for _, entry in ipairs(propList) do
        if entry.entity and DoesEntityExist(entry.entity) then
            DeleteEntity(entry.entity)
        end
    end
    propList = {}
    if not skipServer then
        TriggerServerEvent("ranch:props:save", ranchId, serializeProps())
        notify("Props cleared for " .. ranchId)
    end
end

RegisterCommand(Config.Props.PlacerCommand, function(_, args)
    local modelName = args[1]
    local ranchId = args[2] or "global"
    if not modelName then
        notify("Usage: /" .. Config.Props.PlacerCommand .. " <model> [ranchId]")
        return
    end
    if Config.Props.UsableProps[modelName] then
        addProp(ranchId, modelName)
    else
        notify("Model not whitelisted. Update Config.Props.UsableProps to allow it.")
    end
end, false)

RegisterCommand(Config.Props.RemoverCommand, function(_, args)
    local ranchId = args[1] or "global"
    clearProps(ranchId, false)
end, false)

AddEventHandler("ranch:props:updated", function(ranchId, props)
    clearProps(ranchId, true)
    for _, prop in ipairs(props or {}) do
        local entity = spawnProp(prop.model)
        if entity then
            SetEntityCoords(entity, prop.coords.x, prop.coords.y, prop.coords.z)
            SetEntityHeading(entity, prop.heading or 0.0)
            FreezeEntityPosition(entity, true)
            table.insert(propList, {
                model = prop.model,
                entity = entity,
                coords = prop.coords,
                heading = prop.heading
            })
        end
    end
end)
