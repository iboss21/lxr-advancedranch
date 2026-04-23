--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Client Core

    Bootstrap on player spawn, ranch blip rendering on the minimap/world,
    proximity detection to trigger interaction prompts, and continuous
    environment snapshot consumption.

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

RanchClient = {}
RanchClient.ranchId     = nil
RanchClient.ranches     = {}
RanchClient.environment = {}
RanchClient.blips       = {}
RanchClient.insideRanch = nil
RanchClient.bootstrapped = false

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BOOTSTRAP █████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function requestBootstrap()
    TriggerServerEvent(EV('client', 'requestBootstrap'))
end

RegisterNetEvent(EV('server', 'bootstrap'), function(payload)
    if not payload then return end
    RanchClient.ranchId     = payload.ranchId
    RanchClient.environment = payload.environment or {}
    RanchClient.ranches     = payload.ranches or {}
    RanchClient.bootstrapped = true
    RanchClient.RefreshBlips()
end)

AddEventHandler('playerSpawned', function()
    SetTimeout(1500, requestBootstrap)
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= resourceName then return end
    SetTimeout(2000, requestBootstrap)
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BLIPS █████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchClient.ClearBlips()
    for _, blipHandle in pairs(RanchClient.blips) do
        if DoesBlipExist(blipHandle) then RemoveBlip(blipHandle) end
    end
    RanchClient.blips = {}
end

function RanchClient.RefreshBlips()
    RanchClient.ClearBlips()
    for _, r in ipairs(RanchClient.ranches or {}) do
        if r.center_x and r.center_y then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, r.center_x + 0.0, r.center_y + 0.0, r.center_z + 0.0)
            SetBlipSprite(blip, -1749618580, true)   -- Stable / ranch icon
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, r.label or 'Ranch')
            RanchClient.blips[r.id] = blip
        end
    end
end

RegisterNetEvent(EV('server', 'ranchAdded'), function(r)
    table.insert(RanchClient.ranches, r)
    RanchClient.RefreshBlips()
end)

RegisterNetEvent(EV('server', 'ranchDeleted'), function(id)
    for i, r in ipairs(RanchClient.ranches) do
        if r.id == id then table.remove(RanchClient.ranches, i); break end
    end
    RanchClient.RefreshBlips()
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PROXIMITY / INSIDE RANCH ██████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function findContainingRanch(px, py, pz)
    for _, r in ipairs(RanchClient.ranches or {}) do
        if r.center_x and r.radius then
            local dx, dy = px - r.center_x, py - r.center_y
            if (dx * dx + dy * dy) <= (r.radius * r.radius) then return r end
        end
    end
    return nil
end

CreateThread(function()
    while true do
        Wait(1500)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local cur = findContainingRanch(coords.x, coords.y, coords.z)
        if cur then
            if not RanchClient.insideRanch or RanchClient.insideRanch.id ~= cur.id then
                RanchClient.insideRanch = cur
                TriggerEvent(EV('client', 'enterRanch'), cur)
            end
        else
            if RanchClient.insideRanch then
                TriggerEvent(EV('client', 'leaveRanch'), RanchClient.insideRanch)
                RanchClient.insideRanch = nil
            end
        end
    end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ENVIRONMENT SNAPSHOT ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent(EV('server', 'seasonChanged'), function(snap)
    RanchClient.environment = snap
    TriggerEvent(EV('client', 'envUpdated'), snap)
end)

RegisterNetEvent(EV('server', 'weatherChanged'), function(snap)
    RanchClient.environment = snap
    TriggerEvent(EV('client', 'envUpdated'), snap)
end)

RegisterNetEvent(EV('server', 'hazardTriggered'), function(key, ranchId)
    local def = (Config.Environment.hazards or {})[key]
    local label = def and def.label or key
    -- Notify only if near the affected ranch or if global
    if not RanchClient.insideRanch then return end
    if ranchId ~= 'all' and RanchClient.insideRanch.id ~= ranchId then return end
    Framework.Notify(Framework.L('hazard_near', label), 'warn', 5000)
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ EXPORTS ███████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

exports('GetRanchId',       function() return RanchClient.ranchId end)
exports('GetRanches',       function() return RanchClient.ranches end)
exports('GetEnvironment',   function() return RanchClient.environment end)
exports('IsInsideAnyRanch', function() return RanchClient.insideRanch ~= nil end)
exports('GetCurrentRanch',  function() return RanchClient.insideRanch end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
