local Config = require("shared.config")
local Utils = require("shared.utils")
local Storage = require("server.storage")
local RanchManager = require("server.ranch_manager")

local Livestock = {}
Livestock.Animals = Storage.Animals:Get("data") or {}

local function generateId(species)
    return string.format("%s_%06d", species, math.random(0, 999999))
end

local function ensureRanchAnimals(ranchId)
    if not Livestock.Animals[ranchId] then
        Livestock.Animals[ranchId] = {}
    end
    return Livestock.Animals[ranchId]
end

local function save()
    Storage.Animals:Set("data", Livestock.Animals)
end

function Livestock.RegisterAnimal(ranchId, species, data)
    local speciesConfig = Config.Livestock.Species[species]
    if not speciesConfig then
        return false, "Unknown species"
    end
    local animals = ensureRanchAnimals(ranchId)
    local id = generateId(species)
    local now = Utils.Timestamp()
    local needs = {}
    for need, info in pairs(Config.Livestock.Needs) do
        needs[need] = { level = 1.0, decayPerTick = info.decayPerTick }
    end
    local entry = Utils.TableMerge({
        id = id,
        species = species,
        createdAt = now,
        ageDays = 0,
        nickname = data and data.nickname,
        genetics = speciesConfig.genetics,
        trust = 0.5,
        memory = {},
        needs = needs,
        breeding = { pregnant = false, dueAt = nil },
        outputs = {},
        owner = data and data.owner or RanchManager.GetOrCreate(ranchId).owner
    }, data or {})
    animals[id] = entry
    save()
    TriggerClientEvent("ranch:livestock:update", -1, ranchId, animals)
    RanchManager.AppendHistory(ranchId, { type = "animal_added", animalId = id, species = species })
    return true, entry
end

function Livestock.RemoveAnimal(ranchId, animalId)
    local animals = ensureRanchAnimals(ranchId)
    if not animals[animalId] then return false, "Animal not found" end
    animals[animalId] = nil
    save()
    TriggerClientEvent("ranch:livestock:update", -1, ranchId, animals)
    RanchManager.AppendHistory(ranchId, { type = "animal_removed", animalId = animalId })
    return true
end

function Livestock.AdjustTrust(ranchId, animalId, delta)
    local animals = ensureRanchAnimals(ranchId)
    local animal = animals[animalId]
    if not animal then return false, "Animal not found" end
    animal.trust = Utils.Clamp((animal.trust or 0.5) + delta, 0, 1)
    save()
    TriggerClientEvent("ranch:livestock:trust", -1, ranchId, animalId, animal.trust)
    return true, animal.trust
end

function Livestock.SetNickname(ranchId, animalId, nickname)
    local animals = ensureRanchAnimals(ranchId)
    local animal = animals[animalId]
    if not animal then return false, "Animal not found" end
    animal.nickname = nickname
    save()
    TriggerClientEvent("ranch:livestock:update", -1, ranchId, animals)
    return true, animal
end

local function decayNeeds(ranchId, animalId, animal)
    animal.needs = animal.needs or Utils.DeepCopy(Config.Livestock.Needs)
    for need, info in pairs(Config.Livestock.Needs) do
        local state = animal.needs[need]
        if type(state) == "table" then
            state.level = (state.level or 1) - (info.decayPerTick or 0.05)
            if state.level < 0 then state.level = 0 end
        end
    end
    if animal.trust then
        animal.trust = Utils.Clamp(animal.trust - 0.01, 0, 1)
    end
    if animal.memory then
        for key, moment in pairs(animal.memory) do
            if moment and moment.expiresAt and moment.expiresAt < Utils.Timestamp() then
                animal.memory[key] = nil
            end
        end
    end
    if animal.breeding and animal.breeding.dueAt and animal.breeding.dueAt < Utils.Timestamp() then
        Livestock.HandleBirth(ranchId, animalId, animal)
    end
end

function Livestock.Tick()
    for ranchId, animals in pairs(Livestock.Animals) do
        for animalId, animal in pairs(animals) do
            decayNeeds(ranchId, animalId, animal)
        end
    end
    save()
end

function Livestock.HandleBirth(ranchId, animalId, parent)
    parent.breeding = parent.breeding or {}
    parent.breeding.pregnant = false
    parent.breeding.dueAt = nil
    local success, offspring = Livestock.RegisterAnimal(ranchId, parent.species, {
        genetics = parent.genetics,
        trust = 0.6,
        pedigree = parent.pedigree or {},
        parentId = animalId
    })
    if success then
        RanchManager.AppendHistory(ranchId, { type = "birth", parent = animalId, child = offspring.id })
    end
end

function Livestock.InitiateBreeding(ranchId, animalId)
    local animals = ensureRanchAnimals(ranchId)
    local animal = animals[animalId]
    if not animal then return false, "Animal not found" end
    if animal.breeding and animal.breeding.pregnant then
        return false, "Already pregnant"
    end
    if (animal.trust or 0) < Config.Livestock.Breeding.minTrustForBreeding then
        return false, "Animal trust too low"
    end
    local gestation = Config.Livestock.Species[animal.species].gestationDays or 5
    animal.breeding = {
        pregnant = true,
        dueAt = Utils.Timestamp() + gestation * 60 * 60,
        startedAt = Utils.Timestamp()
    }
    save()
    TriggerClientEvent("ranch:livestock:update", -1, ranchId, animals)
    return true
end

function Livestock.ApplyTreatment(ranchId, animalId, treatment)
    local animals = ensureRanchAnimals(ranchId)
    local animal = animals[animalId]
    if not animal then return false, "Animal not found" end
    animal.treatments = animal.treatments or {}
    table.insert(animal.treatments, { treatment = treatment, at = Utils.Timestamp() })
    animal.trust = Utils.Clamp((animal.trust or 0.5) + 0.05, 0, 1)
    save()
    TriggerClientEvent("ranch:livestock:treated", -1, ranchId, animalId, treatment)
    return true
end

function Livestock.GetRanchAnimals(ranchId)
    return ensureRanchAnimals(ranchId)
end

CreateThread(function()
    local interval = Config.Livestock.NeedsTickMinutes or 15
    while true do
        Wait(interval * 60 * 1000)
        Livestock.Tick()
    end
end)

RegisterNetEvent("ranch:livestock:requestSync", function(ranchId)
    local src = source
    TriggerClientEvent("ranch:livestock:update", src, ranchId, ensureRanchAnimals(ranchId))
end)

return Livestock
