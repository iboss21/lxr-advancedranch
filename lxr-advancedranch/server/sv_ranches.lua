--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 lxr-advancedranch — Ranch Manager (Server)
     Deed creation, ownership transfer, tier upgrades, balance ledger, persistence.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / The Lux Empire — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local EV = function(ns, n) return RanchCore.EventName(ns, n) end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 SEED RANCHES (first boot)
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.SeedRanches()
    if DB.Mode() == 'mysql' then
        local existing = DB.Query(('SELECT `id` FROM `%s`'):format(DB.Table('ranches')))
        if existing and #existing > 0 then return end

        for id, seed in pairs(Config.Ranches.seeds) do
            DB.Insert(
                ('INSERT INTO `%s` (id,label,owner_id,center_x,center_y,center_z,heading,radius,tier,balance,xp,meta,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,0,0,?,?,?)')
                    :format(DB.Table('ranches')),
                {
                    id, seed.label, (seed.owner ~= '' and seed.owner) or nil,
                    seed.center.x, seed.center.y, seed.center.z,
                    seed.heading or 0.0, seed.radius or 120.0, seed.tier or 1,
                    json.encode({}), os.time(), os.time()
                }
            )
        end
        print('^2[lxr-advancedranch] Seeded ' .. LXRUtils.Count(Config.Ranches.seeds) .. ' default ranches.^7')
    else
        local store = DB.Json.Get('ranches') or {}
        if LXRUtils.Count(store) > 0 then return end
        for id, seed in pairs(Config.Ranches.seeds) do
            store[id] = {
                id = id, label = seed.label,
                owner_id = (seed.owner ~= '' and seed.owner) or nil,
                center_x = seed.center.x, center_y = seed.center.y, center_z = seed.center.z,
                heading = seed.heading or 0.0, radius = seed.radius or 120.0,
                tier = seed.tier or 1, balance = 0, xp = 0,
                meta = {}, created_at = os.time(), updated_at = os.time()
            }
        end
        DB.Json.Set('ranches', store)
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 LOAD / PERSIST
-- ════════════════════════════════════════════════════════════════════════════════

local function hydrate(row)
    if type(row.meta) == 'string' then
        local ok, decoded = pcall(json.decode, row.meta)
        row.meta = ok and decoded or {}
    end
    row.meta = row.meta or {}
    return row
end

function RanchCore.LoadAllRanches()
    RanchCore.Ranches = {}
    if DB.Mode() == 'mysql' then
        local rows = DB.Query(('SELECT * FROM `%s`'):format(DB.Table('ranches')))
        for _, r in ipairs(rows or {}) do
            RanchCore.Ranches[r.id] = hydrate(r)
        end
    else
        local store = DB.Json.Get('ranches') or {}
        for id, r in pairs(store) do
            RanchCore.Ranches[id] = hydrate(r)
        end
    end
    RanchCore.Log('database', 'Loaded %d ranches', LXRUtils.Count(RanchCore.Ranches))
end

function RanchCore.PersistRanch(id)
    local r = RanchCore.Ranches[id]
    if not r then return end
    r.updated_at = os.time()
    if DB.Mode() == 'mysql' then
        DB.Update(
            ('UPDATE `%s` SET label=?,owner_id=?,center_x=?,center_y=?,center_z=?,heading=?,radius=?,tier=?,balance=?,xp=?,discord_role_id=?,meta=?,updated_at=? WHERE id=?')
                :format(DB.Table('ranches')),
            {
                r.label, r.owner_id, r.center_x, r.center_y, r.center_z,
                r.heading, r.radius, r.tier, r.balance, r.xp,
                r.discord_role_id, json.encode(r.meta or {}), r.updated_at, r.id
            }
        )
    else
        local store = DB.Json.Get('ranches') or {}
        store[id] = r
        DB.Json.Set('ranches', store)
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 CRUD
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.CreateRanch(label, coords, ownerId, tier)
    local id = LXRUtils.GenId('ranch', 8)
    local r = {
        id = id, label = label,
        owner_id = ownerId or nil,
        center_x = coords.x, center_y = coords.y, center_z = coords.z,
        heading = 0.0, radius = Config.General.defaultBoundaryRadius or 120.0,
        tier = tier or 1, balance = 0, xp = 0,
        discord_role_id = nil, meta = {},
        created_at = os.time(), updated_at = os.time()
    }
    RanchCore.Ranches[id] = r

    if DB.Mode() == 'mysql' then
        DB.Insert(
            ('INSERT INTO `%s` (id,label,owner_id,center_x,center_y,center_z,heading,radius,tier,balance,xp,meta,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)')
                :format(DB.Table('ranches')),
            { r.id, r.label, r.owner_id, r.center_x, r.center_y, r.center_z,
              r.heading, r.radius, r.tier, r.balance, r.xp,
              json.encode(r.meta), r.created_at, r.updated_at }
        )
    else
        local store = DB.Json.Get('ranches') or {}
        store[id] = r
        DB.Json.Set('ranches', store)
    end

    TriggerClientEvent(EV('server', 'ranchAdded'), -1, r)
    return id
end

function RanchCore.DeleteRanch(id)
    if not RanchCore.Ranches[id] then return false end
    RanchCore.Ranches[id] = nil

    if DB.Mode() == 'mysql' then
        DB.Update(('DELETE FROM `%s` WHERE id=?'):format(DB.Table('ranches')), { id })
    else
        local store = DB.Json.Get('ranches') or {}
        store[id] = nil
        DB.Json.Set('ranches', store)
    end

    if Config.Discord.enabled and Config.Discord.notifyOnRanchDelete then
        RanchCore.DiscordNotify('Ranch deleted: `' .. tostring(id) .. '`', 0xaa3333)
    end
    TriggerClientEvent(EV('server', 'ranchRemoved'), -1, id)
    return true
end

function RanchCore.TransferRanch(id, newOwnerId)
    local r = RanchCore.Ranches[id]
    if not r then return false end
    local oldOwner = r.owner_id
    r.owner_id = newOwnerId
    RanchCore.LedgerWrite(id, 'transfer', 0, 'Ownership: ' .. tostring(oldOwner) .. ' -> ' .. tostring(newOwnerId), newOwnerId)
    RanchCore.MarkRanchDirty(id)

    if Config.Discord.enabled and Config.Discord.notifyOnTransfer then
        RanchCore.DiscordNotify(
            ('Ranch **%s** transferred: `%s` → `%s`'):format(r.label, tostring(oldOwner), tostring(newOwnerId)),
            0xc9a84c
        )
    end
    TriggerEvent(EV('core', 'ownershipChanged'), id, oldOwner, newOwnerId)
    TriggerClientEvent(EV('server', 'ranchUpdated'), -1, r)
    return true
end

function RanchCore.UpgradeRanch(id)
    local r = RanchCore.Ranches[id]
    if not r then return false, 'ranch_not_found' end
    local currentTier = r.tier or 1
    local nextTier = currentTier + 1
    local nextTierCfg = Config.Ranches.tiers[nextTier]
    if not nextTierCfg then return false, 'max_tier' end
    local cost = Config.Ranches.tiers[currentTier].upgradeCost or 0
    if r.balance < cost then return false, 'insufficient_funds' end
    r.balance = r.balance - cost
    r.tier = nextTier
    RanchCore.LedgerWrite(id, 'upgrade', -cost, 'Tier upgrade to ' .. nextTierCfg.label, nil)
    RanchCore.MarkRanchDirty(id)
    TriggerClientEvent(EV('server', 'ranchUpdated'), -1, r)
    return true
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 LEDGER
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.LedgerWrite(ranchId, kind, amount, description, actor)
    if DB.Mode() == 'mysql' then
        DB.Insert(
            ('INSERT INTO `%s` (ranch_id,kind,amount,description,actor,ts) VALUES (?,?,?,?,?,?)')
                :format(DB.Table('ledger')),
            { ranchId, kind, amount or 0, description or '', actor or 'system', os.time() }
        )
    else
        local store = DB.Json.Get('ledger') or {}
        store[#store + 1] = {
            ranch_id = ranchId, kind = kind,
            amount = amount or 0, description = description, actor = actor or 'system',
            ts = os.time()
        }
        DB.Json.Set('ledger', store)
    end
end

function RanchCore.LedgerRead(ranchId, limit)
    limit = limit or 50
    if DB.Mode() == 'mysql' then
        return DB.Query(
            ('SELECT * FROM `%s` WHERE ranch_id=? ORDER BY id DESC LIMIT ?')
                :format(DB.Table('ledger')),
            { ranchId, limit }
        )
    else
        local store = DB.Json.Get('ledger') or {}
        local out = {}
        for i = #store, 1, -1 do
            if store[i].ranch_id == ranchId then
                out[#out + 1] = store[i]
                if #out >= limit then break end
            end
        end
        return out
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 BALANCE
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.Deposit(ranchId, amount, reason, actor)
    local r = RanchCore.Ranches[ranchId]
    if not r or amount <= 0 then return false end
    r.balance = (r.balance or 0) + amount
    RanchCore.LedgerWrite(ranchId, 'deposit', amount, reason or 'deposit', actor)
    RanchCore.MarkRanchDirty(ranchId)
    return true
end

function RanchCore.Withdraw(ranchId, amount, reason, actor)
    local r = RanchCore.Ranches[ranchId]
    if not r or amount <= 0 or (r.balance or 0) < amount then return false end
    r.balance = r.balance - amount
    RanchCore.LedgerWrite(ranchId, 'withdraw', -amount, reason or 'withdraw', actor)
    RanchCore.MarkRanchDirty(ranchId)
    return true
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 PUBLIC QUERIES
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.PublicRanchList()
    local out = {}
    for id, r in pairs(RanchCore.Ranches) do
        out[#out + 1] = {
            id = id, label = r.label, tier = r.tier,
            center = { x = r.center_x, y = r.center_y, z = r.center_z },
            radius = r.radius, hasOwner = r.owner_id ~= nil
        }
    end
    return out
end

function RanchCore.GetRanch(id) return RanchCore.Ranches[id] end

function RanchCore.FindRanchAt(x, y, z)
    for id, r in pairs(RanchCore.Ranches) do
        local d = LXRUtils.Distance2D(x, y, r.center_x, r.center_y)
        if d <= (r.radius or 120.0) then
            return id, r
        end
    end
end

function RanchCore.PlayerIsOwner(ident, ranchId)
    local r = RanchCore.Ranches[ranchId]
    return r and r.owner_id == ident
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 DISCORD WEBHOOK
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.DiscordNotify(message, color)
    if not Config.Discord.enabled then return end
    local url = Config.Discord.webhookUrl
    if not url or url == '' then return end
    local payload = json.encode({
        username = 'wolves.land Ranch',
        embeds = { {
            description = message,
            color       = color or 0xc9a84c,
            footer      = { text = 'wolves.land — The Land of Wolves' },
            timestamp   = os.date('!%Y-%m-%dT%H:%M:%SZ')
        } }
    })
    PerformHttpRequest(url, function() end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 NET EVENTS
-- ════════════════════════════════════════════════════════════════════════════════

RegisterNetEvent(EV('client', 'requestRanchDetail'), function(ranchId)
    local src = source
    if not RanchCore.RateCheck(src, 'rdetail', 20) then return end
    local r = RanchCore.Ranches[ranchId]
    if not r then return end

    local ident = Framework.GetIdentifier(src)
    local isOwner = RanchCore.PlayerIsOwner(ident, ranchId)
    local isAdmin = Framework.IsAdmin(src)
    local isStaff = false
    if RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][ident] then
        isStaff = true
    end
    if not (isOwner or isAdmin or isStaff) and Config.General.ownerOnlyUI then return end

    local payload = {
        ranch     = r,
        animals   = RanchCore.ListAnimals and RanchCore.ListAnimals(ranchId) or {},
        workforce = RanchCore.Workforce[ranchId] or {},
        ledger    = RanchCore.LedgerRead(ranchId, 30),
        isOwner   = isOwner,
        isStaff   = isStaff,
        isAdmin   = isAdmin
    }
    TriggerClientEvent(EV('server', 'ranchDetail'), src, payload)
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
