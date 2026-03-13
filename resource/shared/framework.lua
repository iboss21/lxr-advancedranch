--[[
    ═══════════════════════════════════════════════════════════════════════════════
    🐺 LXR Ranch System — Framework Bridge
    ═══════════════════════════════════════════════════════════════════════════════
    This file is ESCROW PROTECTED. Buyers cannot view or edit its contents.

    Implements the Adapter/Bridge pattern for multi-framework compatibility.
    Detection priority: LXR-Core → RSG-Core → VORP-Core → optional → standalone

    Exposed interface:
        Framework.Notify(source, message, type)
        Framework.GetPlayer(source)
        Framework.GetIdentifier(source)
        Framework.GetJob(source)
        Framework.AddItem(source, item, count)
        Framework.RemoveItem(source, item, count)
        Framework.HasItem(source, item, count)
        Framework.GetMoney(source)
        Framework.AddMoney(source, amount)
        Framework.RemoveMoney(source, amount)

    wolves.land — The Land of Wolves
    © 2026 iBoss21 / The Lux Empire | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

Framework = {}
local _detected = nil

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DETECTION ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function detectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end

    -- Detection order: LXR → RSG → VORP → RedEM → QBR → QR → standalone
    local checks = {
        { name = 'lxr-core',        resource = 'lxr-core'        },
        { name = 'rsg-core',        resource = 'rsg-core'        },
        { name = 'vorp_core',       resource = 'vorp_core'       },
        { name = 'redem_roleplay',  resource = 'redem_roleplay'  },
        { name = 'qbr-core',        resource = 'qbr-core'        },
        { name = 'qr-core',         resource = 'qr-core'         },
    }

    for _, check in ipairs(checks) do
        if GetResourceState(check.resource) == 'started' then
            if Config.Dev and Config.Dev.LogFrameworkInit then
                print(('[LXR Ranch] Framework detected: %s'):format(check.name))
            end
            return check.name
        end
    end

    return 'standalone'
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ADAPTERS ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local adapters = {}

-- ─── LXR Core ────────────────────────────────────────────────────────────────
adapters['lxr-core'] = {
    GetPlayer = function(source)
        local Core = exports['lxr-core']:GetCoreObject()
        return Core.Functions.GetPlayer(source)
    end,
    GetIdentifier = function(source)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.citizenid or nil
    end,
    GetJob = function(source)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name or nil
    end,
    AddItem = function(source, item, count)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.AddItem(item, count) end
    end,
    RemoveItem = function(source, item, count)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.RemoveItem(item, count) end
    end,
    HasItem = function(source, item, count)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if not player then return false end
        local inv = player.Functions.GetItemByName(item)
        return inv and inv.amount >= (count or 1)
    end,
    GetMoney = function(source)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.Functions.GetMoney('cash') or 0
    end,
    AddMoney = function(source, amount)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.AddMoney('cash', amount) end
    end,
    RemoveMoney = function(source, amount)
        local Core = exports['lxr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.RemoveMoney('cash', amount) end
    end,
    Notify = function(source, message, ntype)
        TriggerClientEvent('ox_lib:notify', source, { title = 'Ranch', description = message, type = ntype or 'inform' })
    end
}

-- ─── RSG Core ────────────────────────────────────────────────────────────────
adapters['rsg-core'] = {
    GetPlayer = function(source)
        local Core = exports['rsg-core']:GetCoreObject()
        return Core.Functions.GetPlayer(source)
    end,
    GetIdentifier = function(source)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.citizenid or nil
    end,
    GetJob = function(source)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name or nil
    end,
    AddItem = function(source, item, count)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.AddItem(item, count) end
    end,
    RemoveItem = function(source, item, count)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.RemoveItem(item, count) end
    end,
    HasItem = function(source, item, count)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if not player then return false end
        local inv = player.Functions.GetItemByName(item)
        return inv and inv.amount >= (count or 1)
    end,
    GetMoney = function(source)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.Functions.GetMoney('cash') or 0
    end,
    AddMoney = function(source, amount)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.AddMoney('cash', amount) end
    end,
    RemoveMoney = function(source, amount)
        local Core = exports['rsg-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        if player then player.Functions.RemoveMoney('cash', amount) end
    end,
    Notify = function(source, message, ntype)
        TriggerClientEvent('ox_lib:notify', source, { title = 'Ranch', description = message, type = ntype or 'inform' })
    end
}

-- ─── VORP Core ───────────────────────────────────────────────────────────────
adapters['vorp_core'] = {
    GetPlayer = function(source)
        return exports['vorp_core']:getUser(source)
    end,
    GetIdentifier = function(source)
        local user = exports['vorp_core']:getUser(source)
        return user and tostring(user.getIdentifier()) or nil
    end,
    GetJob = function(source)
        local user = exports['vorp_core']:getUser(source)
        return user and tostring(user.getJob()) or nil
    end,
    AddItem = function(source, item, count)
        exports['vorp_inventory']:addItem(source, item, count)
    end,
    RemoveItem = function(source, item, count)
        exports['vorp_inventory']:subItem(source, item, count)
    end,
    HasItem = function(source, item, count)
        local inv = exports['vorp_inventory']:getUserItem(source, item)
        return inv and inv.count >= (count or 1)
    end,
    GetMoney = function(source)
        local user = exports['vorp_core']:getUser(source)
        return user and user.getMoney() or 0
    end,
    AddMoney = function(source, amount)
        local user = exports['vorp_core']:getUser(source)
        if user then user.addCurrency(0, amount) end
    end,
    RemoveMoney = function(source, amount)
        local user = exports['vorp_core']:getUser(source)
        if user then user.removeCurrency(0, amount) end
    end,
    Notify = function(source, message, ntype)
        TriggerClientEvent('vorp:TipRight', source, message, 4000)
    end
}

-- ─── RedEM:RP ─────────────────────────────────────────────────────────────────
adapters['redem_roleplay'] = {
    GetPlayer = function(source)
        return exports['redem_roleplay']:getUser(source)
    end,
    GetIdentifier = function(source)
        local user = exports['redem_roleplay']:getUser(source)
        return user and user.getIdentifier() or nil
    end,
    GetJob = function(source)
        local user = exports['redem_roleplay']:getUser(source)
        return user and user.getJob() or nil
    end,
    AddItem    = function(source, item, count) exports['redem_roleplay']:addItem(source, item, count) end,
    RemoveItem = function(source, item, count) exports['redem_roleplay']:removeItem(source, item, count) end,
    HasItem    = function(source, item, count)
        local inv = exports['redem_roleplay']:getItem(source, item)
        return inv and inv.count >= (count or 1)
    end,
    GetMoney    = function(source) return exports['redem_roleplay']:getMoney(source) or 0 end,
    AddMoney    = function(source, amount) exports['redem_roleplay']:addMoney(source, amount) end,
    RemoveMoney = function(source, amount) exports['redem_roleplay']:removeMoney(source, amount) end,
    Notify      = function(source, message, ntype)
        TriggerClientEvent('redem_roleplay:client:notify', source, message)
    end
}

-- ─── QBR Core ────────────────────────────────────────────────────────────────
adapters['qbr-core'] = {
    GetPlayer = function(source)
        local Core = exports['qbr-core']:GetCoreObject()
        return Core.Functions.GetPlayer(source)
    end,
    GetIdentifier = function(source)
        local Core = exports['qbr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.citizenid or nil
    end,
    GetJob = function(source)
        local Core = exports['qbr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name or nil
    end,
    AddItem    = function(source, item, count) exports['qbr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.AddItem(item, count) end,
    RemoveItem = function(source, item, count) exports['qbr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.RemoveItem(item, count) end,
    HasItem    = function(source, item, count)
        local p = exports['qbr-core']:GetCoreObject().Functions.GetPlayer(source)
        local inv = p and p.Functions.GetItemByName(item)
        return inv and inv.amount >= (count or 1)
    end,
    GetMoney    = function(source) local p = exports['qbr-core']:GetCoreObject().Functions.GetPlayer(source); return p and p.Functions.GetMoney('cash') or 0 end,
    AddMoney    = function(source, amount) exports['qbr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.AddMoney('cash', amount) end,
    RemoveMoney = function(source, amount) exports['qbr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.RemoveMoney('cash', amount) end,
    Notify      = function(source, message, ntype)
        TriggerClientEvent('ox_lib:notify', source, { title = 'Ranch', description = message, type = ntype or 'inform' })
    end
}

-- ─── QR Core ─────────────────────────────────────────────────────────────────
adapters['qr-core'] = {
    GetPlayer = function(source)
        local Core = exports['qr-core']:GetCoreObject()
        return Core.Functions.GetPlayer(source)
    end,
    GetIdentifier = function(source)
        local Core = exports['qr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.citizenid or nil
    end,
    GetJob = function(source)
        local Core = exports['qr-core']:GetCoreObject()
        local player = Core.Functions.GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name or nil
    end,
    AddItem    = function(source, item, count) exports['qr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.AddItem(item, count) end,
    RemoveItem = function(source, item, count) exports['qr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.RemoveItem(item, count) end,
    HasItem    = function(source, item, count)
        local p = exports['qr-core']:GetCoreObject().Functions.GetPlayer(source)
        local inv = p and p.Functions.GetItemByName(item)
        return inv and inv.amount >= (count or 1)
    end,
    GetMoney    = function(source) local p = exports['qr-core']:GetCoreObject().Functions.GetPlayer(source); return p and p.Functions.GetMoney('cash') or 0 end,
    AddMoney    = function(source, amount) exports['qr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.AddMoney('cash', amount) end,
    RemoveMoney = function(source, amount) exports['qr-core']:GetCoreObject().Functions.GetPlayer(source).Functions.RemoveMoney('cash', amount) end,
    Notify      = function(source, message, ntype)
        TriggerClientEvent('ox_lib:notify', source, { title = 'Ranch', description = message, type = ntype or 'inform' })
    end
}

-- ─── Standalone fallback ──────────────────────────────────────────────────────
adapters['standalone'] = {
    GetPlayer     = function(source) return { source = source } end,
    GetIdentifier = function(source) return GetPlayerIdentifiers(source) and GetPlayerIdentifiers(source)[1] or tostring(source) end,
    GetJob        = function(source) return nil end,
    AddItem       = function(source, item, count) print(('[LXR Ranch] [Standalone] AddItem: player=%s item=%s count=%s'):format(source, item, count)) end,
    RemoveItem    = function(source, item, count) print(('[LXR Ranch] [Standalone] RemoveItem: player=%s item=%s count=%s'):format(source, item, count)) end,
    HasItem       = function(source, item, count) return false end,
    GetMoney      = function(source) return 0 end,
    AddMoney      = function(source, amount) print(('[LXR Ranch] [Standalone] AddMoney: player=%s amount=%s'):format(source, amount)) end,
    RemoveMoney   = function(source, amount) print(('[LXR Ranch] [Standalone] RemoveMoney: player=%s amount=%s'):format(source, amount)) end,
    Notify        = function(source, message, ntype) TriggerClientEvent('chat:addMessage', source, { args = { '[Ranch]', message } }) end
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BRIDGE INITIALISATION █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function initBridge()
    local name = detectFramework()
    local adapter = adapters[name]

    if not adapter then
        error(string.format(
            '\n═══════════════════════════════════════════════════════════════════════════════\n' ..
            '❌ LXR Ranch System — Framework Bridge Failure\n' ..
            '═══════════════════════════════════════════════════════════════════════════════\n' ..
            'No valid framework adapter found for: "%s"\n' ..
            'Supported: lxr-core, rsg-core, vorp_core, redem_roleplay, qbr-core, qr-core, standalone\n' ..
            'Set Config.Framework = "standalone" to run without a framework.\n' ..
            '🐺 wolves.land — The Land of Wolves\n' ..
            '═══════════════════════════════════════════════════════════════════════════════\n',
            name
        ))
    end

    _detected = name

    print(('[LXR Ranch] Framework bridge initialised: %s'):format(name))
    return adapter
end

local _adapter = initBridge()

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PUBLIC INTERFACE ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function Framework.GetDetected()
    return _detected
end

function Framework.Notify(source, message, ntype)
    return _adapter.Notify(source, message, ntype)
end

function Framework.GetPlayer(source)
    return _adapter.GetPlayer(source)
end

function Framework.GetIdentifier(source)
    return _adapter.GetIdentifier(source)
end

function Framework.GetJob(source)
    return _adapter.GetJob(source)
end

function Framework.AddItem(source, item, count)
    return _adapter.AddItem(source, item, count)
end

function Framework.RemoveItem(source, item, count)
    return _adapter.RemoveItem(source, item, count)
end

function Framework.HasItem(source, item, count)
    return _adapter.HasItem(source, item, count)
end

function Framework.GetMoney(source)
    return _adapter.GetMoney(source)
end

function Framework.AddMoney(source, amount)
    return _adapter.AddMoney(source, amount)
end

function Framework.RemoveMoney(source, amount)
    return _adapter.RemoveMoney(source, amount)
end

-- ████████████████████████████████████████████████████████████████████████████████
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire | All Rights Reserved
-- ████████████████████████████████████████████████████████████████████████████████

return Framework
