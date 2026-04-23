--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Workforce Management (Server)

    Full workforce lifecycle: hire, fire, role assignment, permissions, morale
    and fatigue mechanics, automated payday cycle, and optional Discord role
    synchronization. All state lives in RanchCore.Workforce[ranchId][ident].

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
-- ████████████████████████ PERSISTENCE ███████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.LoadAllWorkforce()
    RanchCore.Workforce = {}
    if DB.Mode() == 'mysql' then
        local rows = DB.Query(('SELECT * FROM `%s`'):format(DB.Table('workforce')))
        for i = 1, #(rows or {}) do
            local w = rows[i]
            RanchCore.Workforce[w.ranch_id] = RanchCore.Workforce[w.ranch_id] or {}
            RanchCore.Workforce[w.ranch_id][w.identifier] = {
                ranch_id   = w.ranch_id,
                identifier = w.identifier,
                name       = w.name,
                role       = w.role,
                morale     = tonumber(w.morale) or Config.Workforce.defaultMorale,
                fatigue    = tonumber(w.fatigue) or Config.Workforce.defaultFatigue,
                hired_at   = tonumber(w.hired_at) or os.time(),
                last_paid  = tonumber(w.last_paid) or 0,
                meta       = (w.meta and w.meta ~= '' and json.decode(w.meta)) or {}
            }
        end
    else
        local store = DB.Json.Get('workforce') or {}
        for ranchId, roster in pairs(store) do
            RanchCore.Workforce[ranchId] = roster
        end
    end
end

function RanchCore.PersistWorker(ranchId, ident)
    local w = RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][ident]
    if not w then return end
    if DB.Mode() == 'mysql' then
        local exists = DB.Scalar(
            ('SELECT COUNT(1) FROM `%s` WHERE ranch_id=? AND identifier=?'):format(DB.Table('workforce')),
            { ranchId, ident }
        )
        if (tonumber(exists) or 0) > 0 then
            DB.Update(
                ('UPDATE `%s` SET name=?,role=?,morale=?,fatigue=?,last_paid=?,meta=? WHERE ranch_id=? AND identifier=?')
                    :format(DB.Table('workforce')),
                { w.name, w.role, w.morale, w.fatigue, w.last_paid or 0,
                  json.encode(w.meta or {}), ranchId, ident }
            )
        else
            DB.Insert(
                ('INSERT INTO `%s` (ranch_id,identifier,name,role,morale,fatigue,hired_at,last_paid,meta) VALUES (?,?,?,?,?,?,?,?,?)')
                    :format(DB.Table('workforce')),
                { ranchId, ident, w.name, w.role, w.morale, w.fatigue,
                  w.hired_at or os.time(), w.last_paid or 0, json.encode(w.meta or {}) }
            )
        end
    else
        local store = DB.Json.Get('workforce') or {}
        store[ranchId] = RanchCore.Workforce[ranchId]
        DB.Json.Set('workforce', store)
    end
end

local function deleteWorkerDb(ranchId, ident)
    if DB.Mode() == 'mysql' then
        DB.Update(
            ('DELETE FROM `%s` WHERE ranch_id=? AND identifier=?'):format(DB.Table('workforce')),
            { ranchId, ident }
        )
    else
        local store = DB.Json.Get('workforce') or {}
        if store[ranchId] then store[ranchId][ident] = nil end
        DB.Json.Set('workforce', store)
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ HIRE / FIRE / ASSIGN ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function roleExists(role)
    return Config.Workforce.roles[role] ~= nil
end

local function rosterSize(ranchId)
    local n = 0
    if RanchCore.Workforce[ranchId] then
        for _ in pairs(RanchCore.Workforce[ranchId]) do n = n + 1 end
    end
    return n
end

function RanchCore.HireWorker(ranchId, identifier, name, role, actor)
    if not RanchCore.Ranches[ranchId] then return false, 'ranch_not_found' end
    if not roleExists(role) then return false, 'invalid_role' end

    local r = RanchCore.Ranches[ranchId]
    local tier = Config.Ranches.tiers[r.tier] or Config.Ranches.tiers[1]
    local cap = math.min(Config.Workforce.maxWorkersPerRanch, tier.maxWorkers or 5)
    if rosterSize(ranchId) >= cap then return false, 'roster_full' end

    RanchCore.Workforce[ranchId] = RanchCore.Workforce[ranchId] or {}
    if RanchCore.Workforce[ranchId][identifier] then return false, 'already_hired' end

    RanchCore.Workforce[ranchId][identifier] = {
        ranch_id   = ranchId,
        identifier = identifier,
        name       = name or identifier,
        role       = role,
        morale     = Config.Workforce.defaultMorale,
        fatigue    = Config.Workforce.defaultFatigue,
        hired_at   = os.time(),
        last_paid  = os.time(),
        meta       = {}
    }
    RanchCore.PersistWorker(ranchId, identifier)
    RanchCore.LedgerWrite(ranchId, 'hire', 0, ('Hired %s as %s'):format(name or identifier, role), actor or 'system')

    if RanchCore.DiscordNotify then
        RanchCore.DiscordNotify(('Worker hired at `%s`: `%s` (%s)'):format(ranchId, identifier, role), 0x33cc66)
    end
    TriggerClientEvent(EV('server', 'workerHired'), -1, ranchId, RanchCore.Workforce[ranchId][identifier])
    return true
end

function RanchCore.FireWorker(ranchId, identifier, actor)
    if not RanchCore.Workforce[ranchId] or not RanchCore.Workforce[ranchId][identifier] then
        return false, 'not_found'
    end
    local w = RanchCore.Workforce[ranchId][identifier]
    RanchCore.Workforce[ranchId][identifier] = nil
    deleteWorkerDb(ranchId, identifier)
    RanchCore.LedgerWrite(ranchId, 'fire', 0, ('Fired %s (%s)'):format(w.name, w.role), actor or 'system')
    TriggerClientEvent(EV('server', 'workerFired'), -1, ranchId, identifier)
    return true
end

function RanchCore.AssignRole(ranchId, identifier, newRole, actor)
    if not roleExists(newRole) then return false, 'invalid_role' end
    if not RanchCore.Workforce[ranchId] or not RanchCore.Workforce[ranchId][identifier] then
        return false, 'not_found'
    end
    local w = RanchCore.Workforce[ranchId][identifier]
    local oldRole = w.role
    w.role = newRole
    RanchCore.PersistWorker(ranchId, identifier)
    RanchCore.LedgerWrite(ranchId, 'role_change', 0,
        ('Role change: %s → %s (%s)'):format(oldRole, newRole, w.name), actor or 'system')
    TriggerClientEvent(EV('server', 'workerRoleChanged'), -1, ranchId, identifier, newRole)
    return true
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PERMISSIONS ███████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.WorkerCan(ranchId, identifier, capability)
    if RanchCore.PlayerIsOwner(identifier, ranchId) then return true end
    local w = RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][identifier]
    if not w then return false end
    local roleDef = Config.Workforce.roles[w.role]
    if not roleDef then return false end
    if capability == nil then return true end
    return roleDef[capability] == true
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ MORALE / FATIGUE TICK █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.WorkforceTick()
    if not Config.Workforce.enabled then return end
    local dirtyRanches = {}
    for ranchId, roster in pairs(RanchCore.Workforce) do
        for ident, w in pairs(roster) do
            w.fatigue = LXRUtils.Clamp((w.fatigue or 0) - 3, 0, 100)        -- Passive recovery
            local moraleDecay = (Config.Workforce.moraleDecayPerDay or 5) / 24
            w.morale = LXRUtils.Clamp((w.morale or 70) - moraleDecay, 0, 100)
            dirtyRanches[ranchId] = true
        end
    end
    for ranchId in pairs(dirtyRanches) do
        for ident in pairs(RanchCore.Workforce[ranchId] or {}) do
            RanchCore.PersistWorker(ranchId, ident)
        end
    end
end

function RanchCore.AddFatigue(ranchId, identifier, amount)
    local w = RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][identifier]
    if not w then return end
    w.fatigue = LXRUtils.Clamp((w.fatigue or 0) + (amount or Config.Workforce.fatigueGainPerTask), 0, 100)
end

function RanchCore.AddMorale(ranchId, identifier, amount)
    local w = RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][identifier]
    if not w then return end
    w.morale = LXRUtils.Clamp((w.morale or 70) + (amount or 0), 0, 100)
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PAYDAY ████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.RunPayday()
    if not Config.Workforce.enabled then return end
    local now = os.time()
    local intervalSec = (Config.Workforce.paydayIntervalHours or 24) * 3600

    for ranchId, roster in pairs(RanchCore.Workforce) do
        local r = RanchCore.Ranches[ranchId]
        if r then
            local totalWages = 0
            local paidWorkers = {}

            for ident, w in pairs(roster) do
                if (now - (w.last_paid or 0)) >= intervalSec then
                    local roleDef = Config.Workforce.roles[w.role]
                    local wage = roleDef and roleDef.wage or 0
                    if wage > 0 then
                        local moraleMult = 0.75 + ((w.morale or 70) / 100) * 0.5   -- 0.75x @ 0 morale, 1.25x @ 100
                        wage = math.floor(wage * moraleMult)
                        totalWages = totalWages + wage
                        w.last_paid = now
                        paidWorkers[ident] = wage
                    end
                end
            end

            if totalWages > 0 then
                local ok = RanchCore.Withdraw(ranchId, totalWages, 'Payday payout', 'system')
                if ok then
                    for ident, wage in pairs(paidWorkers) do
                        local srcOnline = RanchCore.FindOnlineSourceByIdent(ident)
                        if srcOnline then
                            Framework.AddMoney(srcOnline, wage)
                            Framework.Notify(srcOnline, Framework.L('payday_received', wage), 'success')
                        end
                        RanchCore.PersistWorker(ranchId, ident)
                    end
                    RanchCore.LedgerWrite(ranchId, 'payday', -totalWages,
                        ('Payday: %d workers paid'):format(LXRUtils.Count(paidWorkers)), 'system')
                else
                    RanchCore.LedgerWrite(ranchId, 'payday_failed', 0,
                        ('Insufficient ranch funds: needed $%d'):format(totalWages), 'system')
                    for ident in pairs(paidWorkers) do
                        local w = roster[ident]
                        if w then w.morale = LXRUtils.Clamp((w.morale or 70) - 15, 0, 100) end
                    end
                end
            end
        end
    end
end

function RanchCore.FindOnlineSourceByIdent(ident)
    for src, data in pairs(RanchCore.PlayerIndex or {}) do
        if data.identifier == ident then return src end
    end
    return nil
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DISCORD ROLE SYNC █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Applies Discord role → workforce role based on Config.Discord.roleMapping.
-- This is called on playerJoining / rescan. Non-destructive — only hires or
-- promotes, never fires (to avoid losing data on Discord downtime).
function RanchCore.SyncDiscordRolesForPlayer(src, ranchId)
    if not Config.Discord.enabled then return end
    if not Config.Discord.syncRolesToWorkforce then return end
    if not RanchCore.Ranches[ranchId] then return end

    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(src) or {}) do
        if id:sub(1, 8) == 'discord:' then
            discordId = id:sub(9)
            break
        end
    end
    if not discordId then return end

    -- NOTE: actual Discord API role fetch requires a bot token.
    -- Buyers wire this to their own fetch via `Config.Discord.botToken`.
    -- This stub handles the mapping only; the bot-side fetch is external.
    local roleList = RanchCore._DiscordRoleCache and RanchCore._DiscordRoleCache[discordId]
    if not roleList then return end

    local ident = Framework.GetIdentifier(src)
    for roleId, workforceRole in pairs(Config.Discord.roleMapping or {}) do
        if LXRUtils.HasValue(roleList, roleId) then
            if RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][ident] then
                if RanchCore.Workforce[ranchId][ident].role ~= workforceRole then
                    RanchCore.AssignRole(ranchId, ident, workforceRole, 'discord-sync')
                end
            else
                RanchCore.HireWorker(ranchId, ident, Framework.GetName(src) or ident, workforceRole, 'discord-sync')
            end
        end
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ TICKERS ███████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.StartWorkforceTicker()
    -- Morale/fatigue hourly
    CreateThread(function()
        while true do
            Wait(60 * 60 * 1000)
            RanchCore.WorkforceTick()
        end
    end)
    -- Payday every 10 min (which is < smallest paydayInterval; per-worker check gates actual payout)
    CreateThread(function()
        while true do
            Wait(10 * 60 * 1000)
            RanchCore.RunPayday()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
