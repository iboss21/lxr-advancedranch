local Config = require("shared.config")

local propList       = {}
local placementActive = false

local function serializeProps()
    local payload = {}
    for i, entry in ipairs(propList) do
        payload[i] = {
            model   = entry.model,
            coords  = entry.coords,
            heading = entry.heading
        }
    end
    return payload
end

local function notify(message)
    if lib and lib.notify then
        lib.notify({ title = 'Ranch', description = message, type = 'inform' })
    else
        TriggerEvent("chat:addMessage", { args = { "Ranch", message } })
    end
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
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local entity = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(entity, GetEntityHeading(ped))
    PlaceObjectOnGroundProperly(entity)
    FreezeEntityPosition(entity, true)
    return entity
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Gyzmo / interactive placement mode
-- ─────────────────────────────────────────────────────────────────────────────

local function getGyzmoResource()
    return (Config.AdminMenu and Config.AdminMenu.GyzmoResource) or 'gyzmo'
end

local function gyzmoAvailable()
    return GetResourceState(getGyzmoResource()) == 'started'
end

-- Attempts to start the gyzmo handle.  Returns true on success.
local function tryStartGyzmo(entity)
    local res = getGyzmoResource()
    local ok  = pcall(function() exports[res]:start(entity) end)
    return ok
end

-- Stops the gyzmo handle (silently ignores errors).
local function tryStopGyzmo()
    local res = getGyzmoResource()
    pcall(function() exports[res]:stop() end)
end

--[[
    Interactive placement loop.
    • With gyzmo  — drag the entity with the gyzmo handle.
    • Without gyzmo — rotate / elevate with the arrow keys defined in Config.Props.
    ENTER  (control 191) to confirm placement.
    BACKSPACE (control 194) to cancel and delete the entity.
]]
local function interactivePlacement(ranchId, modelName, entity)
    FreezeEntityPosition(entity, false)

    local useGyzmo = Config.AdminMenu
        and Config.AdminMenu.Enabled
        and Config.AdminMenu.UseGyzmo
        and gyzmoAvailable()
        and tryStartGyzmo(entity)

    if useGyzmo then
        notify("Gyzmo active — position the prop, then press ENTER to confirm or BACKSPACE to cancel.")
    else
        notify("Use arrow keys to rotate / elevate. ENTER to confirm, BACKSPACE to cancel.")
    end

    placementActive = true

    Citizen.CreateThread(function()
        local ok, err = pcall(function()
            while placementActive do
                Citizen.Wait(0)

                -- Arrow-key fine controls (used when gyzmo is absent)
                if not useGyzmo then
                    local heading = GetEntityHeading(entity)
                    local coords  = GetEntityCoords(entity)

                    if IsControlPressed(0, Config.Props.RotateLeftKey) then
                        SetEntityHeading(entity, (heading - 2.0) % 360.0)
                    end
                    if IsControlPressed(0, Config.Props.RotateRightKey) then
                        SetEntityHeading(entity, (heading + 2.0) % 360.0)
                    end
                    if IsControlPressed(0, Config.Props.ElevateUpKey) then
                        SetEntityCoords(entity, coords.x, coords.y, coords.z + 0.02)
                    end
                    if IsControlPressed(0, Config.Props.ElevateDownKey) then
                        SetEntityCoords(entity, coords.x, coords.y, coords.z - 0.02)
                    end
                end

                -- Confirm: ENTER
                if IsControlJustPressed(0, 191) then
                    placementActive = false
                    if useGyzmo then tryStopGyzmo() end

                    FreezeEntityPosition(entity, true)
                    local final = GetEntityCoords(entity)
                    local entry = {
                        model   = modelName,
                        entity  = entity,
                        coords  = { x = final.x, y = final.y, z = final.z },
                        heading = GetEntityHeading(entity)
                    }
                    table.insert(propList, entry)
                    TriggerServerEvent("ranch:props:save", ranchId, serializeProps())
                    notify("Prop saved: " .. modelName)
                    return
                end

                -- Cancel: BACKSPACE
                if IsControlJustPressed(0, 194) then
                    placementActive = false
                    if useGyzmo then tryStopGyzmo() end
                    DeleteEntity(entity)
                    notify("Prop placement cancelled.")
                    return
                end
            end
        end)

        -- Ensure state is always cleaned up, even on unexpected errors.
        if not ok then
            placementActive = false
            if useGyzmo then tryStopGyzmo() end
            if DoesEntityExist(entity) then DeleteEntity(entity) end
            notify("Prop placement encountered an error and was cancelled.")
            print("[RanchProps] interactivePlacement error: " .. tostring(err))
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Core add / clear functions
-- ─────────────────────────────────────────────────────────────────────────────

local function addProp(ranchId, modelName)
    if placementActive then
        notify("Already placing a prop — confirm or cancel the current placement first.")
        return
    end

    local entity = spawnProp(modelName)
    if not entity then return end

    if Config.AdminMenu and Config.AdminMenu.Enabled and Config.AdminMenu.UseGyzmo then
        interactivePlacement(ranchId, modelName, entity)
    else
        -- Legacy behaviour: freeze immediately at spawn position
        local coords = GetEntityCoords(entity)
        local entry  = {
            model   = modelName,
            entity  = entity,
            coords  = { x = coords.x, y = coords.y, z = coords.z },
            heading = GetEntityHeading(entity)
        }
        table.insert(propList, entry)
        TriggerServerEvent("ranch:props:save", ranchId, serializeProps())
        notify("Prop placed: " .. modelName)
    end
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

-- ─────────────────────────────────────────────────────────────────────────────
-- Commands
-- ─────────────────────────────────────────────────────────────────────────────

RegisterCommand(Config.Props.PlacerCommand, function(_, args)
    local modelName = args[1]
    local ranchId   = args[2] or "global"
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

-- ─────────────────────────────────────────────────────────────────────────────
-- Event: triggered by the admin menu instead of a raw command
-- ─────────────────────────────────────────────────────────────────────────────

AddEventHandler("ranch:props:placeFromMenu", function(ranchId, modelName)
    if Config.Props.UsableProps[modelName] then
        addProp(ranchId, modelName)
    else
        notify("Model not whitelisted: " .. modelName)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Network sync
-- ─────────────────────────────────────────────────────────────────────────────

AddEventHandler("ranch:props:updated", function(ranchId, props)
    clearProps(ranchId, true)
    for _, prop in ipairs(props or {}) do
        local entity = spawnProp(prop.model)
        if entity then
            SetEntityCoords(entity, prop.coords.x, prop.coords.y, prop.coords.z)
            SetEntityHeading(entity, prop.heading or 0.0)
            FreezeEntityPosition(entity, true)
            table.insert(propList, {
                model   = prop.model,
                entity  = entity,
                coords  = prop.coords,
                heading = prop.heading
            })
        end
    end
end)
