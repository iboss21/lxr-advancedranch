--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - NUI Controller

    Opens and closes the ranch journal NUI, routes NUI callbacks back to the
    server, handles keybindings (F5 to open, ESC to close — per wolves.land
    NUI spec), and relays real-time data updates into the browser layer.

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

local uiOpen = false

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ UI OPEN / CLOSE ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function OpenRanchUI(ranchId)
    if uiOpen then return end
    if not RanchClient or not RanchClient.bootstrapped then return end

    ranchId = ranchId or RanchClient.ranchId
    if not ranchId and Config.General.ownerOnlyUI then
        Framework.Notify(Framework.L('no_ranch'), 'error')
        return
    end

    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        ranchId = ranchId,
        defaultTab = Config.UI.defaultTab or 'dashboard',
        locale = Config.Locale.en,  -- seed; server will overwrite via later pull
        theme = Config.UI.theme,
        auctionUI = Config.UI.auctionUI,
        ledgerApp = Config.UI.enableLedgerApp,
        mapOverlay = Config.UI.mapOverlay,
        feedMaxEntries = Config.UI.feedMaxEntries
    })
    -- Immediately pull the dashboard tab
    TriggerServerEvent(EV('client', 'requestUIData'), Config.UI.defaultTab or 'dashboard', ranchId)
end

function CloseRanchUI()
    if not uiOpen then return end
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

exports('OpenRanchUI',  OpenRanchUI)
exports('CloseRanchUI', CloseRanchUI)
exports('IsUIOpen',     function() return uiOpen end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ KEY MAPPING ███████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchui', function(_, args)
    if uiOpen then CloseRanchUI() else OpenRanchUI(args[1]) end
end, false)

RegisterKeyMapping('ranchui', 'Open Ranch UI', 'keyboard', Config.Keys.mapOpenUI or 'F5')

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ NUI CALLBACKS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNUICallback('close', function(_, cb)
    CloseRanchUI()
    cb({ ok = true })
end)

RegisterNUICallback('pullTab', function(data, cb)
    local tab = data.tab or 'dashboard'
    TriggerServerEvent(EV('client', 'requestUIData'), tab, RanchClient.ranchId)
    cb({ ok = true })
end)

RegisterNUICallback('interactAnimal', function(data, cb)
    if not data.animalId or not data.action then cb({ ok = false }); return end
    TriggerServerEvent(EV('client', 'interactAnimal'), data.animalId, data.action)
    cb({ ok = true })
end)

RegisterNUICallback('breedAnimals', function(data, cb)
    if not data.animalA or not data.animalB then cb({ ok = false }); return end
    TriggerServerEvent(EV('client', 'breedAnimals'), data.animalA, data.animalB)
    cb({ ok = true })
end)

RegisterNUICallback('acceptContract', function(data, cb)
    if not data.contractId then cb({ ok = false }); return end
    TriggerServerEvent(EV('client', 'acceptContract'), data.contractId)
    cb({ ok = true })
end)

RegisterNUICallback('deliverContract', function(data, cb)
    if not data.contractId then cb({ ok = false }); return end
    TriggerServerEvent(EV('client', 'deliverContract'), data.contractId)
    cb({ ok = true })
end)

RegisterNUICallback('createAuction', function(data, cb)
    if not data.ranchId or not data.lotType or not data.lotRef or not data.startBid then
        cb({ ok = false }); return
    end
    TriggerServerEvent(EV('client', 'createAuction'), data.ranchId, data.lotType, data.lotRef, data.startBid)
    cb({ ok = true })
end)

RegisterNUICallback('placeBid', function(data, cb)
    if not data.auctionId or not data.amount then cb({ ok = false }); return end
    TriggerServerEvent(EV('client', 'placeBid'), data.auctionId, data.amount)
    cb({ ok = true })
end)

RegisterNUICallback('startProduction', function(data, cb)
    if not data.chainKey then cb({ ok = false }); return end
    TriggerServerEvent(EV('client', 'startProduction'), data.chainKey)
    cb({ ok = true })
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DATA RELAY ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent(EV('server', 'uiData'), function(tab, data, err)
    if not uiOpen then return end
    SendNUIMessage({
        action = 'tabData',
        tab    = tab,
        data   = data,
        error  = err
    })
end)

RegisterNetEvent(EV('server', 'animalAdded'), function(a)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'animalAdded', payload = a }) end
end)
RegisterNetEvent(EV('server', 'animalRemoved'), function(id, ranchId)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'animalRemoved', payload = { id = id, ranch_id = ranchId } }) end
end)
RegisterNetEvent(EV('server', 'animalUpdated'), function(a)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'animalUpdated', payload = a }) end
end)
RegisterNetEvent(EV('server', 'contractsRefreshed'), function()
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'contractsRefreshed' }) end
end)
RegisterNetEvent(EV('server', 'auctionCreated'), function(a)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'auctionCreated', payload = a }) end
end)
RegisterNetEvent(EV('server', 'auctionUpdated'), function(a)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'auctionUpdated', payload = a }) end
end)
RegisterNetEvent(EV('server', 'auctionSettled'), function(a)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'auctionSettled', payload = a }) end
end)
RegisterNetEvent(EV('server', 'xpGained'), function(skill, amount, level)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'xpGained', payload = { skill = skill, amount = amount, level = level } }) end
end)
RegisterNetEvent(EV('server', 'achievement'), function(key, def)
    if uiOpen then SendNUIMessage({ action = 'delta', kind = 'achievement', payload = { key = key, def = def } }) end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ESC CLOSE GUARANTEE ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Secondary backstop — the NUI itself listens for Escape and fires 'close',
-- but this ensures the UI always closes even if JS gets stuck.
CreateThread(function()
    while true do
        Wait(0)
        if uiOpen then
            if IsControlJustReleased(0, 0xCEFD9220) then   -- ESC
                CloseRanchUI()
            end
        else
            Wait(250)
        end
    end
end)

AddEventHandler('onClientResourceStop', function(res)
    if res == resourceName and uiOpen then
        SetNuiFocus(false, false)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
