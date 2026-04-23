--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 lxr-advancedranch — Livestock Manager (Server)
     Animals, genetics, breeding, lifecycle, needs decay, product recurrence.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / The Lux Empire — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local EV = function(ns, n) return RanchCore.EventName(ns, n) end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 LOAD / PERSIST
-- ════════════════════════════════════════════════════════════════════════════════

local function hydrateAnimal(a)
    a.meta = (type(a.meta) == 'string' and pcall(json.decode, a.meta)) and json.decode(a.meta) or (a.meta or {})
    if type(a.traits) == 'string' and a.traits ~= '' then
        local t = {}
        for part in a.traits:gmatch('[^,]+') do t[#t + 1] = part end
        a._traitsList = t
    else
        a._traitsList = {}
    end
    return a
end

function RanchCore.LoadAllAnimals()
    RanchCore.Animals = {}
    if DB.Mode() == 'mysql' then
        local rows = DB.Query(('SELECT * FROM `%s`'):format(DB.Table('animals')))
        for _, a in ipairs(rows or {}) do
            RanchCore.Animals[a.id] = hydrateAnimal(a)
        end
    else
        local store = DB.Json.Get('animals') or {}
        for id, a in pairs(store) do
            RanchCore.Animals[id] = hydrateAnimal(a)
        end
    end
    RanchCore.Log('database', 'Loaded %d animals', LXRUtils.Count(RanchCore.Animals))
end

function RanchCore.PersistAnimal(id)
    local a = RanchCore.Animals[id]
    if not a then return end
    a.updated_at = os.time()
    local traitsCsv = table.concat(a._traitsList or {}, ',')
    if DB.Mode() == 'mysql' then
        DB.Update(
            ('UPDATE `%s` SET ranch_id=?,species=?,name=?,sex=?,health=?,hunger=?,thirst=?,cleanliness=?,trust=?,age_days=?,traits=?,bloodline=?,last_bred=?,pregnant_until=?,last_product_at=?,meta=?,updated_at=? WHERE id=?')
                :format(DB.Table('animals')),
            { a.ranch_id, a.species, a.name, a.sex, a.health, a.hunger, a.thirst,
              a.cleanliness, a.trust, a.age_days, traitsCsv, a.bloodline,
              a.last_bred or 0, a.pregnant_until, a.last_product_at or 0,
              json.encode(a.meta or {}), a.updated_at, a.id }
        )
    else
        local store = DB.Json.Get('animals') or {}
        store[id] = a
        DB.Json.Set('animals', store)
    end
end

local function insertAnimalDb(a)
    local traitsCsv = table.concat(a._traitsList or {}, ',')
    if DB.Mode() == 'mysql' then
        DB.Insert(
            ('INSERT INTO `%s` (id,ranch_id,species,name,sex,health,hunger,thirst,cleanliness,trust,age_days,born_at,traits,bloodline,last_bred,pregnant_until,last_product_at,meta,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)')
                :format(DB.Table('animals')),
            { a.id, a.ranch_id, a.species, a.name, a.sex, a.health, a.hunger, a.thirst,
              a.cleanliness, a.trust, a.age_days, a.born_at, traitsCsv, a.bloodline,
              a.last_bred or 0, a.pregnant_until, a.last_product_at or 0,
              json.encode(a.meta or {}), a.updated_at or os.time() }
        )
    else
        local store = DB.Json.Get('animals') or {}
        store[a.id] = a
        DB.Json.Set('animals', store)
    end
end

local function deleteAnimalDb(id)
    if DB.Mode() == 'mysql' then
        DB.Update(('DELETE FROM `%s` WHERE id=?'):format(DB.Table('animals')), { id })
    else
        local store = DB.Json.Get('animals') or {}
        store[id] = nil
        DB.Json.Set('animals', store)
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 TRAIT ROLL
-- ════════════════════════════════════════════════════════════════════════════════

local function rollTraits(parentA, parentB)
    local pool = Config.Breeding.possibleTraits or {}
    local inheritChance = Config.Breeding.traitInheritanceChance or 0.60
    local traits = {}

    if parentA and parentA._traitsList then
        for _, t in ipairs(parentA._traitsList) do
            if LXRUtils.Chance(inheritChance) and not LXRUtils.HasValue(traits, t) then
                traits[#traits + 1] = t
            end
        end
    end
    if parentB and parentB._traitsList then
        for _, t in ipairs(parentB._traitsList) do
            if LXRUtils.Chance(inheritChance) and not LXRUtils.HasValue(traits, t) then
                traits[#traits + 1] = t
            end
        end
    end
    -- New trait mutation
    if LXRUtils.Chance(0.10) and #pool > 0 then
        local t = LXRUtils.Pick(pool)
        if t and not LXRUtils.HasValue(traits, t) then
            traits[#traits + 1] = t
        end
    end
    return traits
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 CREATE / REMOVE
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.AddAnimal(ranchId, species, opts)
    opts = opts or {}
    local cfg = Config.Livestock[species]
    if not cfg then return nil, 'invalid_species' end
    local r = RanchCore.Ranches[ranchId]
    if not r then return nil, 'ranch_not_found' end

    local tierCfg = Config.Ranches.tiers[r.tier or 1]
    local current = 0
    for _, a in pairs(RanchCore.Animals) do if a.ranch_id == ranchId then current = current + 1 end end
    if tierCfg and current >= tierCfg.maxAnimals then return nil, 'ranch_at_capacity' end

    local id = LXRUtils.GenId('an', 10)
    local a = {
        id = id, ranch_id = ranchId, species = species,
        name        = opts.name or '',
        sex         = opts.sex or (LXRUtils.Chance(0.5) and 'm' or 'f'),
        health      = opts.health or 95 + math.random(-5, 5),
        hunger      = 10, thirst = 10, cleanliness = 90,
        trust       = opts.trust or (cfg.trustGainPerGroom and 40 or 60),
        age_days    = opts.age_days or 0,
        born_at     = os.time(),
        _traitsList = opts.traits or rollTraits(nil, nil),
        bloodline   = opts.bloodline or ('line_' .. LXRUtils.GenId('bl', 4)),
        last_bred   = 0, pregnant_until = nil, last_product_at = 0,
        meta        = opts.meta or {}, updated_at = os.time()
    }
    RanchCore.Animals[id] = a
    insertAnimalDb(a)
    RanchCore.LedgerWrite(ranchId, 'animal_added', 0,
        ('%s added (%s)'):format(cfg.label, a.sex), opts.actor or 'system')
    TriggerClientEvent(EV('server', 'animalAdded'), -1, a)
    return id
end

function RanchCore.RemoveAnimal(animalId, reason, actor)
    local a = RanchCore.Animals[animalId]
    if not a then return false end
    deleteAnimalDb(animalId)
    local ranchId = a.ranch_id
    RanchCore.Animals[animalId] = nil
    RanchCore.LedgerWrite(ranchId, 'animal_removed', 0, reason or 'removed', actor)
    TriggerClientEvent(EV('server', 'animalRemoved'), -1, animalId, ranchId)
    return true
end

function RanchCore.ListAnimals(ranchId)
    local out = {}
    for id, a in pairs(RanchCore.Animals) do
        if a.ranch_id == ranchId then out[id] = a end
    end
    return out
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 BREEDING
-- ════════════════════════════════════════════════════════════════════════════════

function RanchCore.Breed(animalIdA, animalIdB, actor)
    if not Config.Breeding.enabled then return false, 'disabled' end
    local a = RanchCore.Animals[animalIdA]
    local b = RanchCore.Animals[animalIdB]
    if not a or not b then return false, 'animal_not_found' end
    if a.ranch_id ~= b.ranch_id then return false, 'different_ranches' end
    if Config.Breeding.requireSameSpecies and a.species ~= b.species then
        return false, 'species_mismatch'
    end
    if Config.Breeding.requireDifferentSex and a.sex == b.sex then
        return false, 'sex_mismatch'
    end

    local cfg = Config.Livestock[a.species]
    if not cfg then return false, 'invalid_species' end

    local cdHours = cfg.breedingCooldownHours or 48
    if (os.time() - (a.last_bred or 0)) < cdHours * 3600 then return false, 'cooldown' end
    if (os.time() - (b.last_bred or 0)) < cdHours * 3600 then return false, 'cooldown' end

    local female = (a.sex == 'f') and a or b
    local male   = (a.sex == 'm') and a or b
    female.pregnant_until = os.time() + (cfg.gestationHours or 36) * 3600
    female.last_bred      = os.time()
    male.last_bred        = os.time()
    female.meta._sire     = male.id

    RanchCore.MarkAnimalDirty(female.id)
    RanchCore.MarkAnimalDirty(male.id)

    RanchCore.LedgerWrite(a.ranch_id, 'bred', 0, ('%s bred'):format(cfg.label), actor)
    TriggerClientEvent(EV('server', 'animalBred'), -1, female.id, male.id)
    return true
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 TICKER — needs decay, aging, pregnancy resolution, product recurrence
-- ════════════════════════════════════════════════════════════════════════════════

local function applyTraitModifier(a, key, base)
    local out = base or 1.0
    for _, t in ipairs(a._traitsList or {}) do
        local bonus = Config.Breeding.traitBonus[t]
        if bonus and bonus[key] then out = out * bonus[key] end
    end
    return out
end

local function resolvePregnancy(female)
    if not female.pregnant_until then return end
    if os.time() < female.pregnant_until then return end
    local cfg = Config.Livestock[female.species]
    if not cfg then return end
    local litterMin = cfg.litterMin or 1
    local litterMax = cfg.litterMax or 1
    local litter = math.random(litterMin, litterMax)
    female.pregnant_until = nil
    RanchCore.MarkAnimalDirty(female.id)

    local sire = female.meta and female.meta._sire and RanchCore.Animals[female.meta._sire] or nil
    for _ = 1, litter do
        local health = (Config.Breeding.offspringHealthBase or 80) +
            math.random(-(Config.Breeding.offspringHealthVariance or 15), (Config.Breeding.offspringHealthVariance or 15))
        RanchCore.AddAnimal(female.ranch_id, female.species, {
            health = LXRUtils.Clamp(health, 1, 100),
            age_days = 0,
            traits = rollTraits(female, sire),
            bloodline = female.bloodline,
            actor = 'system_breed'
        })
    end
    RanchCore.LedgerWrite(female.ranch_id, 'birth', 0, ('%d %s born'):format(litter, cfg.label), 'system')
end

local function produceFromAnimal(a, cfg)
    if not a.last_product_at then a.last_product_at = 0 end
    for _, prod in ipairs(cfg.products or {}) do
        if prod.recurring and (not prod.femaleOnly or a.sex == 'f') then
            local recurHours = prod.recurEveryHours or 12
            if (os.time() - (a.last_product_at or 0)) >= recurHours * 3600 then
                local yMin, yMax = table.unpack(prod.yield or { 1, 1 })
                local qty = math.random(yMin, yMax)
                -- Products are deposited to the ranch's virtual inventory / balance.
                -- For simplicity, convert to cash at base price × 0.5 and deposit to ranch balance.
                local cashValue = math.max(1, math.floor((cfg.baseSellPrice or 20) * 0.05 * qty))
                RanchCore.Deposit(a.ranch_id, cashValue, ('Recurring %s × %d'):format(prod.item, qty), 'system')
                a.last_product_at = os.time()
                RanchCore.MarkAnimalDirty(a.id)
                break
            end
        end
    end
end

function RanchCore.LivestockTick()
    local now = os.time()
    for id, a in pairs(RanchCore.Animals) do
        local cfg = Config.Livestock[a.species]
        if cfg then
            -- Needs decay per minute tick (decay per hour / 60)
            local mult = applyTraitModifier(a, 'needsDecayMult', 1.0)
            local decay = cfg.needsDecay or {}
            a.hunger      = LXRUtils.Clamp((a.hunger      or 0) + (decay.hunger      or 0) * mult, 0, 100)
            a.thirst      = LXRUtils.Clamp((a.thirst      or 0) + (decay.thirst      or 0) * mult, 0, 100)
            a.cleanliness = LXRUtils.Clamp((a.cleanliness or 100) - (decay.cleanliness or 0) * mult, 0, 100)

            -- Starvation / dehydration damage
            if a.hunger > 80 or a.thirst > 80 then
                a.health = LXRUtils.Clamp((a.health or 100) - 0.5, 0, 100)
            end

            -- Aging
            a.age_days = (a.age_days or 0) + (1 / 1440) -- +1 per real day (60 ticks/hr × 24)

            -- Death
            if a.health <= 0 or a.age_days >= (cfg.lifespanDays or 90) then
                RanchCore.LedgerWrite(a.ranch_id, 'death', 0,
                    ('%s died (%s)'):format(cfg.label, (a.health <= 0 and 'health' or 'old age')), 'system')
                deleteAnimalDb(id)
                RanchCore.Animals[id] = nil
                TriggerClientEvent(EV('server', 'animalRemoved'), -1, id, a.ranch_id)
            else
                -- Pregnancy
                if a.pregnant_until then resolvePregnancy(a) end
                -- Recurring product
                if a.age_days >= (cfg.adultAgeDays or 3) then
                    produceFromAnimal(a, cfg)
                end
                RanchCore.MarkAnimalDirty(id)
            end
        end
    end
end

function RanchCore.StartLivestockTicker()
    CreateThread(function()
        while true do
            Wait(Config.Performance.livestockTickInterval or 60000)
            local ok, err = pcall(RanchCore.LivestockTick)
            if not ok then
                print('^1[lxr-advancedranch] LivestockTick error: ' .. tostring(err) .. '^7')
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔧 PLAYER ACTIONS (feed/water/groom/milk/shear) — server authoritative
-- ════════════════════════════════════════════════════════════════════════════════

local function authPlayerOnRanch(src, ranchId)
    local ident = Framework.GetIdentifier(src)
    if RanchCore.PlayerIsOwner(ident, ranchId) then return true, ident end
    if RanchCore.Workforce[ranchId] and RanchCore.Workforce[ranchId][ident] then return true, ident end
    if Framework.IsAdmin(src) then return true, ident end
    return false, ident
end

RegisterNetEvent(EV('client', 'interactAnimal'), function(animalId, action)
    local src = source
    if not RanchCore.RateCheck(src, 'interact', 30) then return end
    local a = RanchCore.Animals[animalId]
    if not a then return end
    local ok, ident = authPlayerOnRanch(src, a.ranch_id)
    if not ok then
        Framework.Notify(src, Framework.L('no_permission'), 'error')
        return
    end

    if action == 'feed' then
        a.hunger = LXRUtils.Clamp((a.hunger or 0) - 40, 0, 100)
        RanchCore.AddXp(ident, 'Husbandry', Config.Progression.xpGains.feedAnimal)
    elseif action == 'water' then
        a.thirst = LXRUtils.Clamp((a.thirst or 0) - 45, 0, 100)
        RanchCore.AddXp(ident, 'Husbandry', Config.Progression.xpGains.waterAnimal)
    elseif action == 'groom' then
        a.cleanliness = LXRUtils.Clamp((a.cleanliness or 0) + 35, 0, 100)
        a.trust = LXRUtils.Clamp((a.trust or 50) + (Config.Livestock[a.species].trustGainPerGroom or 3), 0, 100)
        RanchCore.AddXp(ident, 'Husbandry', Config.Progression.xpGains.groomAnimal)
    elseif action == 'milk' and a.species == 'cattle' and a.sex == 'f' then
        RanchCore.Deposit(a.ranch_id, 22, 'Milk produced', ident)
        RanchCore.AddXp(ident, 'Husbandry', Config.Progression.xpGains.milkCow)
    elseif action == 'shear' and a.species == 'sheep' then
        RanchCore.Deposit(a.ranch_id, 14, 'Wool sheared', ident)
        RanchCore.AddXp(ident, 'Husbandry', Config.Progression.xpGains.shearSheep)
    elseif action == 'slaughter' then
        local cfg = Config.Livestock[a.species]
        if cfg then
            local price = math.floor((cfg.baseSellPrice or 50) * applyTraitModifier(a, 'sellPriceMult', 1.0))
            RanchCore.Deposit(a.ranch_id, price, ('Slaughtered %s'):format(cfg.label), ident)
            deleteAnimalDb(animalId)
            RanchCore.Animals[animalId] = nil
            TriggerClientEvent(EV('server', 'animalRemoved'), -1, animalId, a.ranch_id)
            RanchCore.AddXp(ident, 'Butcher', Config.Progression.xpGains.slaughter)
            return
        end
    end

    RanchCore.MarkAnimalDirty(animalId)
    TriggerClientEvent(EV('server', 'animalUpdated'), -1, a)
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
