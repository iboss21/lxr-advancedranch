--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Prop Placement (Client)

    Mapper tool for placing whitelisted world props on a ranch. Renders a
    ghost model in front of the player, Q/E rotate, scroll adjusts distance,
    ENTER confirms, BACKSPACE cancels.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

local resourceName = GetCurrentResourceName()
local function EV(ns, n) return resourceName .. ':' .. ns .. ':' .. n end

local placement = {
    active     = false,
    entity     = nil,
    model      = nil,
    ranchId    = nil,
    heading    = 0.0,
    distance   = 2.5
}

local spawnedProps = {}   -- id -> entity handle (for deletion)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ MODEL HELPERS █████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function loadModel(model)
    local hash = (type(model) == 'string') and GetHashKey(model) or model
    RequestModel(hash)
    local tries = 0
    while not HasModelLoaded(hash) and tries < 50 do
        Wait(50); tries = tries + 1
    end
    return hash
end

local function groundZ(x, y, z)
    local ok, ground = GetGroundZFor_3dCoord(x, y, z + 5.0, false)
    if ok then return ground end
    return z
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PLACEMENT LOOP ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function stopPlacement()
    if placement.entity and DoesEntityExist(placement.entity) then
        DeleteEntity(placement.entity)
    end
    placement.active = false
    placement.entity = nil
end

RegisterNetEvent(EV('server', 'propEditorStart'), function(model, ranchId)
    if placement.active then stopPlacement() end
    local hash = loadModel(model)
    if not HasModelLoaded(hash) then
        Framework.Notify(Framework.L('prop_model_failed'), 'error'); return
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local ent = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityAlpha(ent, 160, false)
    SetEntityCollision(ent, false, false)

    placement.active  = true
    placement.entity  = ent
    placement.model   = model
    placement.ranchId = ranchId or (RanchClient and RanchClient.insideRanch and RanchClient.insideRanch.id)
    placement.heading = GetEntityHeading(ped)
    placement.distance = 2.5
    Framework.Notify(Framework.L('prop_place_help'), 'info', 5000)
end)

RegisterNetEvent(EV('server', 'propEditorDelete'), function(propId)
    if propId and spawnedProps[propId] and DoesEntityExist(spawnedProps[propId]) then
        DeleteEntity(spawnedProps[propId])
        spawnedProps[propId] = nil
        Framework.Notify(Framework.L('prop_deleted'), 'success')
    else
        -- Delete nearest owned prop within 3m
        local ped = PlayerPedId()
        local p = GetEntityCoords(ped)
        local best, bestDist, bestId = nil, 9.0, nil
        for id, ent in pairs(spawnedProps) do
            if DoesEntityExist(ent) then
                local ep = GetEntityCoords(ent)
                local d = #(p - ep)
                if d < bestDist then best = ent; bestDist = d; bestId = id end
            end
        end
        if best then
            DeleteEntity(best); spawnedProps[bestId] = nil
            Framework.Notify(Framework.L('prop_deleted'), 'success')
        end
    end
end)

RegisterNetEvent(EV('server', 'propAdded'), function(prop)
    local hash = loadModel(prop.model)
    local ent = CreateObject(hash, prop.x, prop.y, prop.z, false, false, false)
    SetEntityHeading(ent, prop.heading or 0.0)
    FreezeEntityPosition(ent, true)
    spawnedProps[prop.id] = ent
end)

CreateThread(function()
    while true do
        Wait(0)
        if placement.active and placement.entity and DoesEntityExist(placement.entity) then
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local fwd = GetEntityForwardVector(ped)
            local tx = pCoords.x + fwd.x * placement.distance
            local ty = pCoords.y + fwd.y * placement.distance
            local tz = pCoords.z
            if Config.Props.snapToGround then tz = groundZ(tx, ty, pCoords.z) end

            SetEntityCoords(placement.entity, tx, ty, tz, false, false, false, false)
            SetEntityHeading(placement.entity, placement.heading)

            -- Q / E = rotate
            if IsControlPressed(0, 0xDE794E3E) then   -- Q
                placement.heading = (placement.heading - 1.5) % 360
            end
            if IsControlPressed(0, 0xCEFD9220) then   -- ESC (cancel placement, NOT the UI)
                -- Prefer a non-ESC cancel to avoid collision with UI close; use BACKSPACE instead
            end
            if IsControlPressed(0, 0x4CC0E2FE) then   -- E
                placement.heading = (placement.heading + 1.5) % 360
            end
            -- Scroll up / down = distance
            if IsControlJustReleased(0, 0x2A8F6981) then   -- Scroll wheel up
                placement.distance = math.min(10.0, placement.distance + 0.3)
            end
            if IsControlJustReleased(0, 0xDE516028) then   -- Scroll wheel down
                placement.distance = math.max(1.0, placement.distance - 0.3)
            end
            -- ENTER = confirm
            if IsControlJustReleased(0, 0xC7B5340A) then
                local ec = GetEntityCoords(placement.entity)
                local model = placement.model
                local ranchId = placement.ranchId
                TriggerServerEvent(EV('client', 'propPlaced'), {
                    ranch_id = ranchId,
                    model    = model,
                    coords   = { x = ec.x, y = ec.y, z = ec.z },
                    heading  = placement.heading
                })
                stopPlacement()
                Framework.Notify(Framework.L('prop_placed'), 'success')
            end
            -- BACKSPACE = cancel
            if IsControlJustReleased(0, 0x156F7119) then
                stopPlacement()
                Framework.Notify(Framework.L('prop_cancelled'), 'info')
            end
        else
            Wait(400)
        end
    end
end)

AddEventHandler('onClientResourceStop', function(res)
    if res == resourceName then
        stopPlacement()
        for id, ent in pairs(spawnedProps) do
            if DoesEntityExist(ent) then DeleteEntity(ent) end
        end
        spawnedProps = {}
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
