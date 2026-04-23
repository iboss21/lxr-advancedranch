--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Framework Adapter Layer

    Unified interface for interacting with every supported framework (LXR, RSG,
    VORP, RedEM:RP, QBR, QR, standalone). Auto-detects the active framework at
    startup and dispatches every call through the correct adapter. Loaded as a
    shared_script; each function checks its environment (server vs client) at
    call time.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 1.0.0

    Framework Support:
    - LXR Core (Primary)        - Fully supported
    - RSG Core (Primary)        - Fully supported
    - VORP Core (Supported)     - Compatible
    - RedEM:RP (Optional)       - Compatible if detected
    - QBR Core (Optional)       - Compatible if detected
    - QR Core (Optional)        - Compatible if detected
    - Standalone (Fallback)     - Basic functionality only

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ENVIRONMENT DETECTION █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local IS_SERVER = IsDuplicityVersion()
local IS_CLIENT = not IS_SERVER
local resourceName = GetCurrentResourceName()

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK STATE ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Framework = {}
Framework.Type   = nil
Framework.Object = nil
Framework.Ready  = false

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK DETECTION ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function debugLog(msg)
    if Config and Config.Debug and Config.DebugChannels and Config.DebugChannels.framework then
        print('^3[' .. resourceName .. '] [framework]^7 ' .. tostring(msg))
    end
end

local function DetectFramework()
    if Config.Framework ~= 'auto' then
        Framework.Type = Config.Framework
        debugLog('Framework manually set to: ' .. Framework.Type)
        return Framework.Type
    end

    local detectionOrder = {
        'lxr-core',
        'rsg-core',
        'vorp_core',
        'redem_roleplay',
        'qbr-core',
        'qr-core'
    }

    for _, fw in ipairs(detectionOrder) do
        local state = GetResourceState(fw)
        if state == 'started' or state == 'starting' then
            Framework.Type = fw
            debugLog('Auto-detected framework: ' .. fw)
            return fw
        end
    end

    Framework.Type = 'standalone'
    debugLog('No framework detected — running in standalone mode')
    return 'standalone'
end

local function InitializeFramework()
    local fwType = DetectFramework()

    if fwType == 'lxr-core' then
        Framework.Object = exports['lxr-core']:GetCoreObject()
    elseif fwType == 'rsg-core' then
        Framework.Object = exports['rsg-core']:GetCoreObject()
    elseif fwType == 'vorp_core' then
        if IS_SERVER then
            Framework.Object = exports.vorp_core:GetCore()
        end
    elseif fwType == 'redem_roleplay' then
        Framework.Object = exports['redem_roleplay']:GetCoreObject()
    elseif fwType == 'qbr-core' then
        Framework.Object = exports['qbr-core']:GetCoreObject()
    elseif fwType == 'qr-core' then
        Framework.Object = exports['qr-core']:GetCoreObject()
    else
        Framework.Object = nil
    end

    Framework.Ready = true
    debugLog((IS_SERVER and '[SERVER] ' or '[CLIENT] ') .. 'Framework initialized: ' .. tostring(fwType))
end

CreateThread(function()
    Wait(200)
    InitializeFramework()
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LOCALE HELPER █████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function Framework.L(key, ...)
    local lang = Config.Lang or 'en'
    local t = Config.Locale and Config.Locale[lang] or {}
    local str = t[key] or (Config.Locale and Config.Locale.en and Config.Locale.en[key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ NOTIFY (DUAL ENVIRONMENT) ████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    CLIENT: Framework.Notify(message, type, duration)
    SERVER: Framework.Notify(source, message, type, duration)
]]

function Framework.Notify(a, b, c, d)
    if IS_CLIENT then
        local message  = a
        local nType    = b or 'info'
        local duration = c or 3000

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if GetResourceState('ox_lib') == 'started' then
                exports.ox_lib:notify({ type = nType, description = message, duration = duration })
            else
                TriggerEvent('ox_lib:notify', { type = nType, description = message, duration = duration })
            end
        elseif Framework.Type == 'vorp_core' then
            TriggerEvent('vorp:TipBottom', message, duration)
        elseif Framework.Type == 'redem_roleplay' then
            TriggerEvent('redem_roleplay:Notify', nType, message, duration)
        else
            print('^3[' .. resourceName .. '] [Notify]^7 ' .. tostring(message))
        end
    else
        local source   = a
        local message  = b
        local nType    = c or 'info'
        local duration = d or 3000

        if not source or type(source) ~= 'number' then return end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            TriggerClientEvent('ox_lib:notify', source, {
                type = nType, description = message, duration = duration
            })
        elseif Framework.Type == 'vorp_core' then
            TriggerClientEvent('vorp:TipBottom', source, message, duration)
        elseif Framework.Type == 'redem_roleplay' then
            TriggerClientEvent('redem_roleplay:Notify', source, nType, message, duration)
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '[Ranch]', message } })
        end
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER-ONLY ADAPTER ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

if IS_SERVER then

    function Framework.GetPlayer(source)
        if not source or source == 0 then return nil end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if Framework.Object and Framework.Object.Functions then
                return Framework.Object.Functions.GetPlayer(source)
            end
        elseif Framework.Type == 'vorp_core' then
            if Framework.Object and Framework.Object.getUser then
                return Framework.Object.getUser(source)
            end
        elseif Framework.Type == 'redem_roleplay' then
            if Framework.Object and Framework.Object.GetPlayer then
                return Framework.Object.GetPlayer(source)
            end
        end

        return {
            source     = source,
            identifier = GetPlayerIdentifier(source, 0) or 'unknown',
            PlayerData = {
                source     = source,
                citizenid  = GetPlayerIdentifier(source, 0) or 'unknown',
                identifier = GetPlayerIdentifier(source, 0) or 'unknown'
            }
        }
    end

    function Framework.GetIdentifier(source)
        if not source or source == 0 then return 'console' end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            local player = Framework.GetPlayer(source)
            if player and player.PlayerData then
                return player.PlayerData.citizenid or player.PlayerData.identifier
            end
        elseif Framework.Type == 'vorp_core' then
            local user = Framework.GetPlayer(source)
            if user then
                local char = user.getUsedCharacter
                if char then
                    return char.identifier or char.charIdentifier or GetPlayerIdentifier(source, 0)
                end
            end
        end

        return GetPlayerIdentifier(source, 0) or ('source:' .. tostring(source))
    end

    function Framework.GetName(source)
        local player = Framework.GetPlayer(source)
        if not player then return GetPlayerName(source) or 'Unknown' end

        if player.PlayerData and player.PlayerData.charinfo then
            local ci = player.PlayerData.charinfo
            return (ci.firstname or '') .. ' ' .. (ci.lastname or '')
        end
        if player.getUsedCharacter then
            local c = player.getUsedCharacter
            return (c.firstname or '') .. ' ' .. (c.lastname or '')
        end
        return GetPlayerName(source) or 'Unknown'
    end

    function Framework.HasItem(source, item, count)
        count = count or 1
        local player = Framework.GetPlayer(source)
        if not player then return false end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if player.Functions and player.Functions.GetItemByName then
                local data = player.Functions.GetItemByName(item)
                return data and data.amount and data.amount >= count
            end
        elseif Framework.Type == 'vorp_core' then
            local amt = exports.vorp_inventory:getItemCount(source, nil, item)
            return amt and amt >= count
        elseif Framework.Type == 'redem_roleplay' then
            if player.getItem then
                local i = player.getItem(item)
                return i and i.amount and i.amount >= count
            end
        end
        return false
    end

    function Framework.AddItem(source, item, count, meta)
        count = count or 1
        local player = Framework.GetPlayer(source)
        if not player then return false end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if player.Functions and player.Functions.AddItem then
                return player.Functions.AddItem(item, count, false, meta)
            end
        elseif Framework.Type == 'vorp_core' then
            exports.vorp_inventory:addItem(source, item, count, meta)
            return true
        elseif Framework.Type == 'redem_roleplay' and player.addItem then
            player.addItem(item, count)
            return true
        end
        return false
    end

    function Framework.RemoveItem(source, item, count)
        count = count or 1
        local player = Framework.GetPlayer(source)
        if not player then return false end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if player.Functions and player.Functions.RemoveItem then
                return player.Functions.RemoveItem(item, count)
            end
        elseif Framework.Type == 'vorp_core' then
            exports.vorp_inventory:subItem(source, item, count)
            return true
        elseif Framework.Type == 'redem_roleplay' and player.removeItem then
            player.removeItem(item, count)
            return true
        end
        return false
    end

    function Framework.AddMoney(source, amount, reason)
        amount = tonumber(amount) or 0
        if amount <= 0 then return false end
        local player = Framework.GetPlayer(source)
        if not player then return false end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if player.Functions and player.Functions.AddMoney then
                return player.Functions.AddMoney('cash', amount, reason or 'lxr-advancedranch')
            end
        elseif Framework.Type == 'vorp_core' then
            if player.addCurrency then
                player.addCurrency(0, amount) -- 0 = dollars
                return true
            end
        elseif Framework.Type == 'redem_roleplay' and player.addMoney then
            player.addMoney(amount)
            return true
        end
        return false
    end

    function Framework.RemoveMoney(source, amount, reason)
        amount = tonumber(amount) or 0
        if amount <= 0 then return false end
        local player = Framework.GetPlayer(source)
        if not player then return false end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if player.Functions and player.Functions.RemoveMoney then
                return player.Functions.RemoveMoney('cash', amount, reason or 'lxr-advancedranch')
            end
        elseif Framework.Type == 'vorp_core' then
            if player.removeCurrency then
                player.removeCurrency(0, amount)
                return true
            end
        elseif Framework.Type == 'redem_roleplay' and player.removeMoney then
            player.removeMoney(amount)
            return true
        end
        return false
    end

    function Framework.GetMoney(source)
        local player = Framework.GetPlayer(source)
        if not player then return 0 end

        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if player.PlayerData and player.PlayerData.money then
                return player.PlayerData.money.cash or 0
            end
        elseif Framework.Type == 'vorp_core' then
            if player.getUsedCharacter then
                return player.getUsedCharacter.money or 0
            end
        elseif Framework.Type == 'redem_roleplay' and player.getMoney then
            return player.getMoney() or 0
        end
        return 0
    end

    function Framework.RegisterUsableItem(item, cb)
        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if Framework.Object and Framework.Object.Functions and Framework.Object.Functions.CreateUseableItem then
                Framework.Object.Functions.CreateUseableItem(item, cb)
            end
        elseif Framework.Type == 'vorp_core' then
            exports.vorp_inventory:registerUsableItem(item, cb)
        elseif Framework.Type == 'redem_roleplay' then
            local ev = 'RegisterUsableItem:' .. item
            RegisterServerEvent(ev)
            AddEventHandler(ev, function() cb(source) end)
        end
    end

    function Framework.Log(source, event, message, data)
        if not Config.Debug then return end
        local name = GetPlayerName(source) or 'Unknown'
        print(('^3[%s] [%s] %s: %s^7'):format(resourceName, name, event, message))
        if data then print('^3Data:^7 ' .. json.encode(data)) end
    end

    function Framework.IsAdmin(source)
        if not Config.Admin.enabled and Config.Admin.useAce then
            if IsPlayerAceAllowed(source, Config.Admin.acePermission) then
                return true
            end
        end
        if Config.Admin.useAce and IsPlayerAceAllowed(source, Config.Admin.acePermission) then
            return true
        end
        if Config.Admin.useIdentifiers then
            local idents = GetPlayerIdentifiers(source) or {}
            for _, id in ipairs(idents) do
                if Config.Admin.identifiers[id] then return true end
            end
        end
        return false
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CLIENT-ONLY ADAPTER ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

if IS_CLIENT then

    function Framework.GetPlayerData()
        if Framework.Type == 'lxr-core' or Framework.Type == 'rsg-core'
        or Framework.Type == 'qbr-core' or Framework.Type == 'qr-core' then
            if Framework.Object and Framework.Object.Functions then
                return Framework.Object.Functions.GetPlayerData()
            end
        elseif Framework.Type == 'vorp_core' then
            -- VORP exposes character via events; return a stub
            return LocalPlayer and LocalPlayer.state and LocalPlayer.state.Character or {}
        end
        return {}
    end
end

_G.Framework = Framework

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════
