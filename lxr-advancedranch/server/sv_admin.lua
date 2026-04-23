--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Administrative Commands (Server)

    Complete admin command surface. Every command gated by Framework.IsAdmin
    (ACE + identifier dual-check). All actions write to the ledger and emit
    Discord webhook notifications when Config.Discord.enabled.

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

local EV = function(ns, n) return RanchCore.EventName(ns, n) end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ HELPERS ███████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function requireAdmin(src)
    if not Framework.IsAdmin(src) then
        Framework.Notify(src, Framework.L('admin_only'), 'error')
        return false
    end
    return true
end

local function reply(src, msg)
    if src == 0 then
        print('^2[lxr-advancedranch]^7 ' .. tostring(msg))
    else
        Framework.Notify(src, tostring(msg), 'info')
    end
end

local function adminAudit(src, cmd, detail)
    local name = src == 0 and 'CONSOLE' or (GetPlayerName(src) or ('src:' .. src))
    local line = ('[admin] %s ran /%s %s'):format(name, cmd, detail or '')
    if Config.Admin.logToConsole then print('^3' .. line .. '^7') end
    if Config.Admin.logToWebhook and RanchCore.DiscordNotify then
        RanchCore.DiscordNotify(line, 0x9966cc)
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ RANCH MANAGEMENT ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchcreate', function(src, args)
    if not requireAdmin(src) then return end
    local label = args[1]
    if not label then reply(src, 'Usage: /ranchcreate <label> [ownerIdent]'); return end
    local ownerIdent = args[2] or ''
    local px, py, pz = 0.0, 0.0, 0.0
    if src ~= 0 then
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        px, py, pz = coords.x, coords.y, coords.z
    end
    local id, err = RanchCore.CreateRanch(label, vector3(px, py, pz), ownerIdent, 1)
    if not id then reply(src, 'Failed: ' .. tostring(err)); return end
    adminAudit(src, 'ranchcreate', ('%s at (%.1f,%.1f)'):format(label, px, py))
    reply(src, ('Created ranch `%s`'):format(id))
end, false)

RegisterCommand('ranchdelete', function(src, args)
    if not requireAdmin(src) then return end
    local id = args[1]
    if not id then reply(src, 'Usage: /ranchdelete <ranchId>'); return end
    local ok = RanchCore.DeleteRanch(id)
    if not ok then reply(src, 'Ranch not found'); return end
    adminAudit(src, 'ranchdelete', id)
    reply(src, 'Deleted ranch ' .. id)
end, false)

RegisterCommand('ranchtransfer', function(src, args)
    if not requireAdmin(src) then return end
    local id, newOwner = args[1], args[2]
    if not id or not newOwner then reply(src, 'Usage: /ranchtransfer <ranchId> <identifier>'); return end
    local ok = RanchCore.TransferRanch(id, newOwner)
    if not ok then reply(src, 'Transfer failed'); return end
    adminAudit(src, 'ranchtransfer', ('%s → %s'):format(id, newOwner))
    reply(src, 'Transferred')
end, false)

RegisterCommand('ranchupgrade', function(src, args)
    if not requireAdmin(src) then return end
    local id = args[1]
    if not id then reply(src, 'Usage: /ranchupgrade <ranchId>'); return end
    local ok, err = RanchCore.UpgradeRanch(id)
    if not ok then reply(src, 'Upgrade failed: ' .. tostring(err)); return end
    adminAudit(src, 'ranchupgrade', id)
    reply(src, 'Upgraded')
end, false)

RegisterCommand('ranchsetrole', function(src, args)
    if not requireAdmin(src) then return end
    local ranchId, roleId = args[1], args[2]
    if not ranchId or not roleId then reply(src, 'Usage: /ranchsetrole <ranchId> <discordRoleId>'); return end
    local r = RanchCore.Ranches[ranchId]
    if not r then reply(src, 'Ranch not found'); return end
    r.meta = r.meta or {}
    r.meta.discordRoleId = roleId
    RanchCore.MarkRanchDirty(ranchId)
    adminAudit(src, 'ranchsetrole', ('%s = %s'):format(ranchId, roleId))
    reply(src, 'Bound Discord role ' .. roleId)
end, false)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ENVIRONMENT ███████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchseason', function(src, args)
    if not requireAdmin(src) then return end
    local season = args[1]
    if not season then reply(src, 'Usage: /ranchseason <spring|summer|autumn|winter>'); return end
    local ok = RanchCore.SetSeason(season)
    if not ok then reply(src, 'Invalid season'); return end
    adminAudit(src, 'ranchseason', season)
    reply(src, 'Season set to ' .. season)
end, false)

RegisterCommand('ranchweather', function(src, args)
    if not requireAdmin(src) then return end
    if args[1] then
        RanchCore.SetWeather(args[1])
        reply(src, 'Weather set to ' .. args[1])
    else
        RanchCore.RollWeather()
        reply(src, 'Weather rerolled: ' .. RanchCore.Environment.weather)
    end
    adminAudit(src, 'ranchweather', args[1] or 'roll')
end, false)

RegisterCommand('ranchhazard', function(src, args)
    if not requireAdmin(src) then return end
    local key, ranchId = args[1], args[2]
    if not key then reply(src, 'Usage: /ranchhazard <hazardKey> [ranchId]'); return end
    local ok = RanchCore.TriggerHazard(key, ranchId)
    if not ok then reply(src, 'Hazard failed — unknown key'); return end
    adminAudit(src, 'ranchhazard', ('%s %s'):format(key, ranchId or 'all'))
    reply(src, 'Hazard triggered')
end, false)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LIVESTOCK █████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchanimaladd', function(src, args)
    if not requireAdmin(src) then return end
    local ranchId, species, count = args[1], args[2], tonumber(args[3]) or 1
    if not ranchId or not species then
        reply(src, 'Usage: /ranchanimaladd <ranchId> <species> [count]'); return
    end
    if not Config.Livestock[species] then reply(src, 'Invalid species'); return end

    local added = 0
    for i = 1, count do
        local sex = (i % 2 == 0) and 'female' or 'male'
        local ok = RanchCore.AddAnimal(ranchId, species, { sex = sex })
        if ok then added = added + 1 end
    end
    adminAudit(src, 'ranchanimaladd', ('%s x%d @ %s'):format(species, added, ranchId))
    reply(src, ('Added %d %s'):format(added, species))
end, false)

RegisterCommand('ranchanimaldel', function(src, args)
    if not requireAdmin(src) then return end
    local ranchId, animalId = args[1], args[2]
    if not ranchId or not animalId then reply(src, 'Usage: /ranchanimaldel <ranchId> <animalId>'); return end
    local ok = RanchCore.RemoveAnimal(animalId)
    if not ok then reply(src, 'Remove failed'); return end
    adminAudit(src, 'ranchanimaldel', animalId)
    reply(src, 'Removed')
end, false)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WORKFORCE █████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchassign', function(src, args)
    if not requireAdmin(src) then return end
    local ranchId, ident, role = args[1], args[2], args[3]
    if not ranchId or not ident or not role then
        reply(src, 'Usage: /ranchassign <ranchId> <identifier> <role>'); return
    end
    local exists = RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][ident]
    local ok, err
    if exists then
        ok, err = RanchCore.AssignRole(ranchId, ident, role, 'admin')
    else
        ok, err = RanchCore.HireWorker(ranchId, ident, ident, role, 'admin')
    end
    if not ok then reply(src, 'Failed: ' .. tostring(err)); return end
    adminAudit(src, 'ranchassign', ('%s %s → %s'):format(ranchId, ident, role))
    reply(src, 'Assigned')
end, false)

RegisterCommand('ranchfire', function(src, args)
    if not requireAdmin(src) then return end
    local ranchId, ident = args[1], args[2]
    if not ranchId or not ident then reply(src, 'Usage: /ranchfire <ranchId> <identifier>'); return end
    local ok = RanchCore.FireWorker(ranchId, ident, 'admin')
    if not ok then reply(src, 'Worker not found'); return end
    adminAudit(src, 'ranchfire', ('%s %s'):format(ranchId, ident))
    reply(src, 'Fired')
end, false)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CONTRACTS / PROGRESSION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchcontract', function(src, args)
    if not requireAdmin(src) then return end
    RanchCore.RerollBoards()
    adminAudit(src, 'ranchcontract', 'reroll')
    reply(src, 'Boards rerolled')
end, false)

RegisterCommand('ranchxp', function(src, args)
    if not requireAdmin(src) then return end
    local ident, skill, amount = args[1], args[2], tonumber(args[3]) or 0
    if not ident or not skill then reply(src, 'Usage: /ranchxp <identifier> <skill> <amount>'); return end
    RanchCore.AddXp(ident, skill, amount)
    adminAudit(src, 'ranchxp', ('%s +%d %s'):format(ident, amount, skill))
    reply(src, 'XP granted')
end, false)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ZONING ████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('pzcreate', function(src, args)
    if not requireAdmin(src) then return end
    if src == 0 then reply(src, 'Must be run in-game'); return end
    TriggerClientEvent(EV('server', 'zoneEditorStart'), src, args[1] or ('zone_' .. os.time()))
    adminAudit(src, 'pzcreate', args[1] or 'new')
end, false)

RegisterCommand('pzsave', function(src, args)
    if not requireAdmin(src) then return end
    if src == 0 then reply(src, 'Must be run in-game'); return end
    TriggerClientEvent(EV('server', 'zoneEditorSave'), src)
end, false)

RegisterCommand('pzcancel', function(src, args)
    if not requireAdmin(src) then return end
    if src == 0 then return end
    TriggerClientEvent(EV('server', 'zoneEditorCancel'), src)
end, false)

RegisterNetEvent(EV('client', 'zoneSaved'), function(payload)
    local src = source
    if not Framework.IsAdmin(src) then return end
    if not payload or not payload.ranch_id or not payload.vertices then return end
    local zone = {
        id         = LXRUtils.GenId('zn'),
        ranch_id   = payload.ranch_id,
        zone_type  = payload.zone_type or 'pasture',
        vertices   = payload.vertices,
        created_by = Framework.GetIdentifier(src)
    }
    if DB.Mode() == 'mysql' then
        DB.Insert(
            ('INSERT INTO `%s` (id,ranch_id,zone_type,vertices,created_by,created_at) VALUES (?,?,?,?,?,?)')
                :format(DB.Table('zones')),
            { zone.id, zone.ranch_id, zone.zone_type, json.encode(zone.vertices), zone.created_by, os.time() }
        )
    else
        local store = DB.Json.Get('zones') or {}
        store[zone.id] = zone
        DB.Json.Set('zones', store)
    end
    TriggerClientEvent(EV('server', 'zoneAdded'), -1, zone)
    Framework.Notify(src, Framework.L('zone_saved'), 'success')
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PROPS █████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchprop', function(src, args)
    if not requireAdmin(src) then return end
    if src == 0 then reply(src, 'Must be run in-game'); return end
    local model, ranchId = args[1], args[2]
    if not model then reply(src, 'Usage: /ranchprop <model> [ranchId]'); return end
    if not LXRUtils.HasValue(Config.Props.whitelistedModels, model) then
        reply(src, 'Model not whitelisted'); return
    end
    TriggerClientEvent(EV('server', 'propEditorStart'), src, model, ranchId)
    adminAudit(src, 'ranchprop', ('%s @ %s'):format(model, ranchId or 'auto'))
end, false)

RegisterCommand('ranchpropdel', function(src, args)
    if not requireAdmin(src) then return end
    if src == 0 then return end
    TriggerClientEvent(EV('server', 'propEditorDelete'), src, args[1])
    adminAudit(src, 'ranchpropdel', args[1] or '')
end, false)

RegisterNetEvent(EV('client', 'propPlaced'), function(payload)
    local src = source
    if not Framework.IsAdmin(src) then return end
    if not payload or not payload.ranch_id or not payload.model or not payload.coords then return end
    if not LXRUtils.HasValue(Config.Props.whitelistedModels, payload.model) then return end

    local r = RanchCore.Ranches[payload.ranch_id]
    if not r then return end
    local tier = Config.Ranches.tiers[r.tier] or {}
    local cap = math.min(Config.Props.maxPerRanch or 200, tier.maxProps or 30)

    local count = 0
    if DB.Mode() == 'mysql' then
        count = tonumber(DB.Scalar(('SELECT COUNT(1) FROM `%s` WHERE ranch_id=?'):format(DB.Table('props')),
            { payload.ranch_id })) or 0
    else
        local store = DB.Json.Get('props') or {}
        for _, p in pairs(store) do if p.ranch_id == payload.ranch_id then count = count + 1 end end
    end
    if count >= cap then
        Framework.Notify(src, Framework.L('prop_cap_reached'), 'error'); return
    end

    local prop = {
        id        = LXRUtils.GenId('pr'),
        ranch_id  = payload.ranch_id,
        model     = payload.model,
        x         = payload.coords.x, y = payload.coords.y, z = payload.coords.z,
        heading   = payload.heading or 0.0,
        placed_by = Framework.GetIdentifier(src),
        placed_at = os.time()
    }
    if DB.Mode() == 'mysql' then
        DB.Insert(
            ('INSERT INTO `%s` (id,ranch_id,model,x,y,z,heading,placed_by,placed_at) VALUES (?,?,?,?,?,?,?,?,?)')
                :format(DB.Table('props')),
            { prop.id, prop.ranch_id, prop.model, prop.x, prop.y, prop.z, prop.heading, prop.placed_by, prop.placed_at }
        )
    else
        local store = DB.Json.Get('props') or {}
        store[prop.id] = prop
        DB.Json.Set('props', store)
    end
    TriggerClientEvent(EV('server', 'propAdded'), -1, prop)
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CONSOLE DEBUG DUMP ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchdump', function(src, args)
    if src ~= 0 and not Framework.IsAdmin(src) then return end
    local ranches, animals, workers = 0, 0, 0
    for _ in pairs(RanchCore.Ranches) do ranches = ranches + 1 end
    for _ in pairs(RanchCore.Animals) do animals = animals + 1 end
    for _, roster in pairs(RanchCore.Workforce) do
        for _ in pairs(roster) do workers = workers + 1 end
    end
    local contracts = 0
    for _ in pairs(RanchCore.Contracts or {}) do contracts = contracts + 1 end
    local auctions = 0
    for _ in pairs(RanchCore.Auctions or {}) do auctions = auctions + 1 end
    print('^3[lxr-advancedranch]^7 dump:')
    print(('  Ranches:   %d'):format(ranches))
    print(('  Animals:   %d'):format(animals))
    print(('  Workers:   %d'):format(workers))
    print(('  Contracts: %d'):format(contracts))
    print(('  Auctions:  %d'):format(auctions))
    print(('  Season:    %s'):format(RanchCore.Environment.season))
    print(('  Weather:   %s (%d°C)'):format(RanchCore.Environment.weather, RanchCore.Environment.temp or 0))
end, true)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
