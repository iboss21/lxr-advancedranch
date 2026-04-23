--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Progression Engine (Server)

    XP and level progression across five skill trees, tier-unlock bonuses,
    achievement tracking, and the legacy/heir carry-forward mechanic. One
    progression record per identifier — carries across ranches.

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

function RanchCore.LoadAllProgression()
    RanchCore.Progression = {}
    if DB.Mode() == 'mysql' then
        local rows = DB.Query(('SELECT * FROM `%s`'):format(DB.Table('progression')))
        for i = 1, #(rows or {}) do
            local p = rows[i]
            RanchCore.Progression[p.identifier] = {
                identifier    = p.identifier,
                skills        = (p.skills and p.skills ~= '' and json.decode(p.skills)) or {},
                achievements  = (p.achievements and p.achievements ~= '' and json.decode(p.achievements)) or {},
                stats         = (p.stats and p.stats ~= '' and json.decode(p.stats)) or {},
                updated_at    = tonumber(p.updated_at) or os.time()
            }
        end
    else
        local store = DB.Json.Get('progression') or {}
        for ident, rec in pairs(store) do RanchCore.Progression[ident] = rec end
    end
end

local function persistProgression(ident)
    local p = RanchCore.Progression[ident]
    if not p then return end
    p.updated_at = os.time()
    if DB.Mode() == 'mysql' then
        local exists = DB.Scalar(('SELECT COUNT(1) FROM `%s` WHERE identifier=?'):format(DB.Table('progression')), { ident })
        if (tonumber(exists) or 0) > 0 then
            DB.Update(
                ('UPDATE `%s` SET skills=?,achievements=?,stats=?,updated_at=? WHERE identifier=?')
                    :format(DB.Table('progression')),
                { json.encode(p.skills or {}), json.encode(p.achievements or {}),
                  json.encode(p.stats or {}), p.updated_at, ident }
            )
        else
            DB.Insert(
                ('INSERT INTO `%s` (identifier,skills,achievements,stats,updated_at) VALUES (?,?,?,?,?)')
                    :format(DB.Table('progression')),
                { ident, json.encode(p.skills or {}), json.encode(p.achievements or {}),
                  json.encode(p.stats or {}), p.updated_at }
            )
        end
    else
        local store = DB.Json.Get('progression') or {}
        store[ident] = p
        DB.Json.Set('progression', store)
    end
end

local function getOrCreate(ident)
    if not ident then return nil end
    if not RanchCore.Progression[ident] then
        RanchCore.Progression[ident] = {
            identifier   = ident,
            skills       = {},
            achievements = {},
            stats        = {},
            updated_at   = os.time()
        }
    end
    return RanchCore.Progression[ident]
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ XP & LEVELS ███████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Total XP required to reach level n from level 0.
-- Uses cumulative curve: base * sum(i^exp for i=1..n).
function RanchCore.XpForLevel(n)
    local base = Config.Progression.xpCurveBase or 100
    local exp  = Config.Progression.xpCurveExponent or 1.35
    local total = 0
    for i = 1, n do total = total + base * (i ^ exp) end
    return math.floor(total)
end

function RanchCore.SkillLevel(ident, skill)
    local p = RanchCore.Progression[ident]
    if not p or not p.skills or not p.skills[skill] then return 0 end
    local xp = p.skills[skill].xp or 0
    local max = Config.Progression.maxLevel or 100
    for n = max, 1, -1 do
        if xp >= RanchCore.XpForLevel(n) then return n end
    end
    return 0
end

function RanchCore.AddXp(ident, skill, amount)
    if not ident or not Config.Progression.enabled then return end
    if not Config.Progression.skills[skill] then return end
    if not amount or amount <= 0 then return end

    local p = getOrCreate(ident)
    p.skills[skill] = p.skills[skill] or { xp = 0, level = 0 }

    local prevLevel = RanchCore.SkillLevel(ident, skill)
    p.skills[skill].xp = (p.skills[skill].xp or 0) + amount
    local newLevel = RanchCore.SkillLevel(ident, skill)
    p.skills[skill].level = newLevel

    persistProgression(ident)

    local src = RanchCore.FindOnlineSourceByIdent(ident)
    if src then
        TriggerClientEvent(EV('server', 'xpGained'), src, skill, amount, newLevel)
        if newLevel > prevLevel then
            Framework.Notify(src, Framework.L('skill_level_up', skill, newLevel), 'success')
            -- Announce bonus if one was unlocked at this tier
            local bonus = Config.Progression.skills[skill].bonuses
                and Config.Progression.skills[skill].bonuses[newLevel]
            if bonus then
                Framework.Notify(src, Framework.L('skill_unlock', bonus), 'info')
            end
        end
    end
end

function RanchCore.GetProgression(ident)
    return getOrCreate(ident)
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SKILL BONUSES (READ-ONLY) █████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Returns a table of active tier thresholds hit for a skill.
-- Example: husbandry level 30 → { [10] = bonusText, [25] = bonusText }
function RanchCore.ActiveBonuses(ident, skill)
    local lvl = RanchCore.SkillLevel(ident, skill)
    local defs = Config.Progression.skills[skill] and Config.Progression.skills[skill].bonuses or {}
    local active = {}
    for tier, text in pairs(defs) do
        if lvl >= tier then active[tier] = text end
    end
    return active
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ STATS & ACHIEVEMENTS ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.IncStat(ident, statKey, amount)
    if not ident then return end
    local p = getOrCreate(ident)
    p.stats[statKey] = (p.stats[statKey] or 0) + (amount or 1)
    persistProgression(ident)
    RanchCore.CheckAchievements(ident)
end

function RanchCore.CheckAchievements(ident)
    local p = RanchCore.Progression[ident]
    if not p then return end
    for key, def in pairs(Config.Progression.achievements or {}) do
        if not p.achievements[key] then
            local unlocked = true
            for statKey, needed in pairs(def.requirement or {}) do
                if (p.stats[statKey] or 0) < needed then
                    unlocked = false
                    break
                end
            end
            if unlocked then
                p.achievements[key] = os.time()
                persistProgression(ident)
                local src = RanchCore.FindOnlineSourceByIdent(ident)
                if src then
                    Framework.Notify(src, Framework.L('achievement_unlocked', def.label), 'success')
                    if def.reward and def.reward > 0 then
                        Framework.AddMoney(src, def.reward)
                    end
                    TriggerClientEvent(EV('server', 'achievement'), src, key, def)
                end
            end
        end
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LEGACY / HEIR SYSTEM ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Inherit a percentage of a predecessor's XP and achievements to a new
-- character identifier. Called when a player creates an heir via the
-- multicharacter flow (exposed as an export for the framework to wire in).
function RanchCore.InheritLegacy(fromIdent, toIdent)
    if not Config.Progression.legacySystem.enabled then return false end
    local src = RanchCore.Progression[fromIdent]
    if not src then return false end
    local pct = Config.Progression.legacySystem.inheritXpPct or 0.25

    local newRec = getOrCreate(toIdent)
    newRec.skills = newRec.skills or {}
    for skill, data in pairs(src.skills or {}) do
        newRec.skills[skill] = newRec.skills[skill] or { xp = 0, level = 0 }
        newRec.skills[skill].xp = math.floor((newRec.skills[skill].xp or 0) + (data.xp or 0) * pct)
        newRec.skills[skill].level = RanchCore.SkillLevel(toIdent, skill)
    end
    newRec.stats = newRec.stats or {}
    for k, v in pairs(src.stats or {}) do
        newRec.stats[k] = math.floor((newRec.stats[k] or 0) + (v or 0) * pct)
    end
    persistProgression(toIdent)
    return true
end

exports('InheritLegacy', RanchCore.InheritLegacy)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
