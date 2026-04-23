--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - NUI Data Router (Server)

    Single entry point for NUI data pulls. Client sends a tab key; server
    auth-checks, rate-limits, and returns a scoped payload. No bulk dumps —
    each tab fetches only what it needs.

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
-- ████████████████████████ TAB PAYLOADS ██████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function payloadDashboard(ranchId)
    local r = RanchCore.Ranches[ranchId]
    if not r then return nil end
    local tier = Config.Ranches.tiers[r.tier] or Config.Ranches.tiers[1]
    local counts = { cattle = 0, horse = 0, sheep = 0, pig = 0, chicken = 0, goat = 0 }
    local totalHealth, totalAnimals = 0, 0
    for _, a in pairs(RanchCore.Animals) do
        if a.ranch_id == ranchId then
            counts[a.species] = (counts[a.species] or 0) + 1
            totalHealth = totalHealth + (a.health or 0)
            totalAnimals = totalAnimals + 1
        end
    end
    local workerCount = 0
    if RanchCore.Workforce[ranchId] then
        for _ in pairs(RanchCore.Workforce[ranchId]) do workerCount = workerCount + 1 end
    end
    return {
        ranch        = r,
        tierLabel    = tier.label,
        tierCaps     = { animals = tier.maxAnimals, workers = tier.maxWorkers, props = tier.maxProps },
        livestock    = { counts = counts, total = totalAnimals, avgHealth = totalAnimals > 0 and math.floor(totalHealth / totalAnimals) or 0 },
        workers      = workerCount,
        balance      = r.balance or 0,
        environment  = RanchCore.EnvironmentSnapshot(),
        ledger       = RanchCore.LedgerRead(ranchId, 10)
    }
end

local function payloadLivestock(ranchId)
    return RanchCore.ListAnimals(ranchId) or {}
end

local function payloadWorkforce(ranchId)
    local out = {}
    if RanchCore.Workforce[ranchId] then
        for ident, w in pairs(RanchCore.Workforce[ranchId]) do
            table.insert(out, w)
        end
    end
    return out
end

local function payloadEconomy(ranchId, ident)
    local openContracts, myContracts = {}, {}
    for id, c in pairs(RanchCore.Contracts or {}) do
        if c.status == 'open' then
            table.insert(openContracts, c)
        elseif c.assigned == ident and c.status == 'active' then
            table.insert(myContracts, c)
        end
    end
    local liveAuctions = {}
    for _, a in pairs(RanchCore.Auctions or {}) do
        if a.status == 'live' then table.insert(liveAuctions, a) end
    end
    return {
        prices       = RanchCore.PriceTable(),
        openContracts = openContracts,
        myContracts  = myContracts,
        auctions     = liveAuctions,
        productionChains = Config.Economy.productionChains,
        ledger       = ranchId and RanchCore.LedgerRead(ranchId, 30) or {}
    }
end

local function payloadEnvironment()
    return {
        snapshot = RanchCore.EnvironmentSnapshot(),
        seasons  = Config.Environment.seasons,
        hazards  = Config.Environment.hazards
    }
end

local function payloadProgression(ident)
    if not ident then return {} end
    local p = RanchCore.GetProgression(ident)
    local out = { skills = {}, achievements = p.achievements, stats = p.stats }
    for name, def in pairs(Config.Progression.skills) do
        local rec = p.skills[name] or { xp = 0, level = 0 }
        local level = RanchCore.SkillLevel(ident, name)
        out.skills[name] = {
            label = def.label,
            description = def.description,
            level = level,
            xp = rec.xp or 0,
            nextLevelXp = RanchCore.XpForLevel(level + 1),
            currentLevelXp = RanchCore.XpForLevel(level),
            bonuses = def.bonuses,
            activeBonuses = RanchCore.ActiveBonuses(ident, name)
        }
    end
    return out
end

local function payloadAuction(ranchId)
    local lots = {}
    for _, a in pairs(RanchCore.Auctions or {}) do
        if a.status == 'live' then table.insert(lots, a) end
    end
    return { lots = lots }
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ NET HANDLER ███████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent(EV('client', 'requestUIData'), function(tab, ranchId)
    local src = source
    if not RanchCore.RateCheck(src, 'nui', Config.Security.nuiDataRateLimit or 12) then return end

    local ident = Framework.GetIdentifier(src)

    -- Auth: non-admin players can only fetch data for ranches they own or staff.
    if ranchId and not Framework.IsAdmin(src) then
        local isOwner = RanchCore.PlayerIsOwner(ident, ranchId)
        local isStaff = RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][ident]
        if not isOwner and not isStaff and Config.General.ownerOnlyUI then
            TriggerClientEvent(EV('server', 'uiData'), src, tab, nil, 'no_permission')
            return
        end
    end

    local data
    if tab == 'dashboard' then
        data = payloadDashboard(ranchId)
    elseif tab == 'livestock' then
        data = payloadLivestock(ranchId)
    elseif tab == 'workforce' then
        data = payloadWorkforce(ranchId)
    elseif tab == 'economy' then
        data = payloadEconomy(ranchId, ident)
    elseif tab == 'environment' then
        data = payloadEnvironment()
    elseif tab == 'progression' then
        data = payloadProgression(ident)
    elseif tab == 'auction' then
        data = payloadAuction(ranchId)
    else
        data = nil
    end

    TriggerClientEvent(EV('server', 'uiData'), src, tab, data)
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
