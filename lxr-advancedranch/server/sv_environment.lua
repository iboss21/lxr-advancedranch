--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Environment Engine (Server)

    Seasonal cycle, server-authoritative weather rolls, hazard triggers,
    soil/pasture regrowth, and optional wildlife predator attacks. All state
    is persisted in the `environment` key-value table so world state survives
    restarts.

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
-- ████████████████████████ STATE PERSISTENCE █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function kvGet(key)
    if DB.Mode() == 'mysql' then
        local row = DB.Single(('SELECT v FROM `%s` WHERE k=?'):format(DB.Table('environment')), { key })
        if row and row.v then
            local ok, decoded = pcall(json.decode, row.v)
            if ok then return decoded end
        end
        return nil
    else
        local store = DB.Json.Get('environment') or {}
        return store[key]
    end
end

local function kvSet(key, value)
    local encoded = json.encode(value)
    if DB.Mode() == 'mysql' then
        local exists = DB.Scalar(('SELECT COUNT(1) FROM `%s` WHERE k=?'):format(DB.Table('environment')), { key })
        if (tonumber(exists) or 0) > 0 then
            DB.Update(('UPDATE `%s` SET v=? WHERE k=?'):format(DB.Table('environment')), { encoded, key })
        else
            DB.Insert(('INSERT INTO `%s` (k,v) VALUES (?,?)'):format(DB.Table('environment')), { key, encoded })
        end
    else
        local store = DB.Json.Get('environment') or {}
        store[key] = value
        DB.Json.Set('environment', store)
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SEASON & WEATHER STATE ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.LoadEnvironmentState()
    RanchCore.Environment = kvGet('state') or {
        season          = Config.Environment.seasonSequence[1] or 'spring',
        season_started  = os.time(),
        weather         = 'clear',
        weather_started = os.time(),
        temp            = 18,
        active_hazards  = {},
        soil            = {},
        seasons_survived = 0
    }
    RanchCore.Environment.active_hazards = RanchCore.Environment.active_hazards or {}
    RanchCore.Environment.soil = RanchCore.Environment.soil or {}
end

local function persistEnv()
    kvSet('state', RanchCore.Environment)
end

function RanchCore.EnvironmentSnapshot()
    return {
        season          = RanchCore.Environment.season,
        season_started  = RanchCore.Environment.season_started,
        weather         = RanchCore.Environment.weather,
        weather_started = RanchCore.Environment.weather_started,
        temp            = RanchCore.Environment.temp,
        active_hazards  = RanchCore.Environment.active_hazards
    }
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SEASON CYCLE ██████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function advanceSeason()
    local seq = Config.Environment.seasonSequence
    local cur = RanchCore.Environment.season
    local idx = 1
    for i = 1, #seq do if seq[i] == cur then idx = i; break end end
    idx = (idx % #seq) + 1
    RanchCore.Environment.season = seq[idx]
    RanchCore.Environment.season_started = os.time()
    RanchCore.Environment.seasons_survived = (RanchCore.Environment.seasons_survived or 0) + 1

    -- Temperature reset to season midpoint
    local s = Config.Environment.seasons[RanchCore.Environment.season]
    if s and s.tempRange then
        RanchCore.Environment.temp = math.floor((s.tempRange[1] + s.tempRange[2]) / 2)
    end

    persistEnv()
    if RanchCore.DiscordNotify then
        RanchCore.DiscordNotify(('Season changed to **%s**'):format(RanchCore.Environment.season), 0x3b8686)
    end
    TriggerClientEvent(EV('server', 'seasonChanged'), -1, RanchCore.EnvironmentSnapshot())
end

function RanchCore.SetSeason(newSeason)
    if not Config.Environment.seasons[newSeason] then return false end
    RanchCore.Environment.season = newSeason
    RanchCore.Environment.season_started = os.time()
    local s = Config.Environment.seasons[newSeason]
    if s and s.tempRange then
        RanchCore.Environment.temp = math.floor((s.tempRange[1] + s.tempRange[2]) / 2)
    end
    persistEnv()
    TriggerClientEvent(EV('server', 'seasonChanged'), -1, RanchCore.EnvironmentSnapshot())
    return true
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WEATHER ROLL ██████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.RollWeather()
    local season = Config.Environment.seasons[RanchCore.Environment.season] or Config.Environment.seasons.spring
    local bias = season.weatherBias or { clear = 1.0 }
    local weighted = {}
    for weather, weight in pairs(bias) do
        table.insert(weighted, { value = weather, weight = weight })
    end
    local picked = LXRUtils.WeightedPick(weighted)
    RanchCore.Environment.weather = picked or 'clear'
    RanchCore.Environment.weather_started = os.time()

    -- Temperature drift (±3 per roll, clamped to season band)
    local drift = LXRUtils.Rand(-3, 3)
    local newTemp = (RanchCore.Environment.temp or 15) + drift
    if season.tempRange then
        newTemp = LXRUtils.Clamp(newTemp, season.tempRange[1], season.tempRange[2])
    end
    RanchCore.Environment.temp = newTemp

    persistEnv()
    TriggerClientEvent(EV('server', 'weatherChanged'), -1, RanchCore.EnvironmentSnapshot())

    RanchCore.RollHazards()
end

function RanchCore.SetWeather(kind)
    if not kind then return false end
    RanchCore.Environment.weather = kind
    RanchCore.Environment.weather_started = os.time()
    persistEnv()
    TriggerClientEvent(EV('server', 'weatherChanged'), -1, RanchCore.EnvironmentSnapshot())
    return true
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ HAZARDS ███████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.TriggerHazard(key, ranchId)
    local def = Config.Environment.hazards[key]
    if not def then return false end

    local affectedRanches = {}
    if ranchId then
        if RanchCore.Ranches[ranchId] then affectedRanches[ranchId] = true end
    else
        for id in pairs(RanchCore.Ranches) do affectedRanches[id] = true end
    end

    for rid in pairs(affectedRanches) do
        -- Livestock damage
        if def.damage and def.damage.livestock then
            local kills = 0
            for aid, a in pairs(RanchCore.Animals) do
                if a.ranch_id == rid then
                    a.health = LXRUtils.Clamp((a.health or 100) - def.damage.livestock, 0, 100)
                    if a.health <= 0 then kills = kills + 1 end
                    RanchCore.MarkAnimalDirty(aid)
                end
            end
            RanchCore.LedgerWrite(rid, 'hazard', 0, ('%s — %d animals affected'):format(def.label, kills), 'system')
        end

        -- Pasture damage
        if def.damage and def.damage.pasture then
            RanchCore.Environment.soil[rid] = RanchCore.Environment.soil[rid] or { fertility = Config.Environment.soil.defaultFertility }
            RanchCore.Environment.soil[rid].fertility = math.max(0,
                RanchCore.Environment.soil[rid].fertility - (def.damage.pasture * 100))
        end

        -- Mark hazard active briefly
        RanchCore.Environment.active_hazards[rid] = RanchCore.Environment.active_hazards[rid] or {}
        table.insert(RanchCore.Environment.active_hazards[rid], {
            key     = key,
            label   = def.label,
            started = os.time()
        })

        if RanchCore.DiscordNotify then
            RanchCore.DiscordNotify(('⚠️ Hazard triggered at `%s`: **%s**'):format(rid, def.label), 0xcc3333)
        end
    end
    persistEnv()
    TriggerClientEvent(EV('server', 'hazardTriggered'), -1, key, ranchId or 'all')
    return true
end

function RanchCore.RollHazards()
    local weather = RanchCore.Environment.weather
    for key, def in pairs(Config.Environment.hazards) do
        if def.allowedWeather and LXRUtils.HasValue(def.allowedWeather, weather) then
            if LXRUtils.Chance(def.chance or 0.01) then
                RanchCore.TriggerHazard(key, nil)
            end
        end
    end
    -- Decay active hazards after 10 minutes
    local now = os.time()
    for rid, list in pairs(RanchCore.Environment.active_hazards or {}) do
        for i = #list, 1, -1 do
            if now - (list[i].started or 0) > 600 then table.remove(list, i) end
        end
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SOIL / PASTURE ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.SoilTick()
    local soilCfg = Config.Environment.soil
    local season = Config.Environment.seasons[RanchCore.Environment.season] or {}
    local growthMult = season.pastureGrowth or 1.0

    for rid in pairs(RanchCore.Ranches) do
        RanchCore.Environment.soil[rid] = RanchCore.Environment.soil[rid] or {
            fertility = soilCfg.defaultFertility
        }
        local tile = RanchCore.Environment.soil[rid]
        tile.fertility = LXRUtils.Clamp((tile.fertility or 80) + (soilCfg.regrowthPerTick * growthMult), 0, 100)
    end
    persistEnv()
end

function RanchCore.GetSoil(ranchId)
    return RanchCore.Environment.soil[ranchId] or { fertility = Config.Environment.soil.defaultFertility }
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WILDLIFE PREDATORS ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.WildlifeTick()
    if not Config.Environment.wildlife or not Config.Environment.wildlife.enabled then return end
    local chance = Config.Environment.wildlife.predatorAttackChance or 0.03
    local dmgRange = Config.Environment.wildlife.predatorDamage or { 1, 4 }

    for rid in pairs(RanchCore.Ranches) do
        if LXRUtils.Chance(chance) then
            local killsTarget = LXRUtils.Rand(dmgRange[1], dmgRange[2])
            local kills = 0
            -- Iterate a copy of animal IDs for this ranch
            local ids = {}
            for aid, a in pairs(RanchCore.Animals) do
                if a.ranch_id == rid then ids[#ids + 1] = aid end
            end
            for i = 1, math.min(killsTarget, #ids) do
                local target = ids[LXRUtils.Rand(1, #ids)]
                local a = RanchCore.Animals[target]
                if a then
                    a.health = 0
                    kills = kills + 1
                    RanchCore.MarkAnimalDirty(target)
                end
            end
            if kills > 0 then
                local predator = LXRUtils.Pick(Config.Environment.wildlife.predators or { 'wolf' })
                RanchCore.LedgerWrite(rid, 'predator', 0,
                    ('%s attacked — %d livestock lost'):format(predator, kills), 'system')
                TriggerClientEvent(EV('server', 'predatorAttack'), -1, rid, predator, kills)
            end
        end
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ TICKERS ███████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.StartEnvironmentTicker()
    -- Season advance
    CreateThread(function()
        while true do
            Wait(60 * 1000)
            local now = os.time()
            local length = (Config.Environment.seasonLengthMinutes or 120) * 60
            if now - (RanchCore.Environment.season_started or now) >= length then
                advanceSeason()
            end
        end
    end)

    -- Weather roll
    CreateThread(function()
        while true do
            Wait((Config.Environment.weatherCycleMinutes or 30) * 60 * 1000)
            RanchCore.RollWeather()
        end
    end)

    -- Soil regrowth
    CreateThread(function()
        while true do
            Wait((Config.Environment.soil.tickIntervalMinutes or 10) * 60 * 1000)
            RanchCore.SoilTick()
        end
    end)

    -- Wildlife
    CreateThread(function()
        while true do
            Wait(15 * 60 * 1000)
            RanchCore.WildlifeTick()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
