local Config = require("shared.config")
local Utils = require("shared.utils")
local Storage = require("server.storage")
local RanchManager = require("server.ranch_manager")

local Environment = {}
Environment.State = {}

local function defaultState()
    local firstSeason = Config.Environment.SeasonSequence[1]
    local now = Utils.Timestamp()
    return {
        season = firstSeason,
        seasonStartedAt = now,
        seasonEndsAt = now + (Config.Environment.SeasonLengthMinutes * 60),
        weather = {
            pattern = "clear",
            endsAt = now + (Config.Environment.UpdateIntervals.WeatherMinutes * 60)
        },
        activeHazards = {},
        modifiers = {
            drought = 0,
            flood = 0,
            fertility = 1.0
        }
    }
end

local function save()
    Storage.Environment:Set("state", Environment.State)
end

local function broadcast()
    TriggerClientEvent("ranch:environment:update", -1, Environment.State)
end

function Environment.Initialize()
    local stored = Storage.Environment:Get("state")
    if stored then
        Environment.State = Utils.TableMerge(defaultState(), stored)
    else
        Environment.State = defaultState()
        save()
    end
    broadcast()

    CreateThread(function()
        while true do
            Wait(Config.Environment.UpdateIntervals.WeatherMinutes * 60 * 1000)
            Environment.RollWeather()
        end
    end)

    CreateThread(function()
        while true do
            Wait(Config.Environment.UpdateIntervals.HazardMinutes * 60 * 1000)
            Environment.TryHazard()
        end
    end)

    CreateThread(function()
        while true do
            Wait(60 * 1000)
            Environment.CheckSeason()
        end
    end)
end

local function calculateWeatherDuration(entry)
    local range = entry.duration or { min = 10, max = 20 }
    return Utils.Timestamp() + math.floor(Utils.RandomRange(range.min, range.max) * 60)
end

function Environment.RollWeather()
    local key, data = Utils.WeightedChoice(Config.Environment.WeatherPatterns)
    if not key then return end
    Environment.State.weather = {
        pattern = key,
        endsAt = calculateWeatherDuration(data)
    }
    save()
    broadcast()
    if data.hazard then
        Environment.QueueHazard(data.hazard, { automatic = true })
    end
end

function Environment.CheckSeason()
    if Environment.State.seasonEndsAt and Environment.State.seasonEndsAt > Utils.Timestamp() then return end
    Environment.AdvanceSeason()
end

function Environment.AdvanceSeason()
    local sequence = Config.Environment.SeasonSequence
    local currentIndex = 1
    for idx, season in ipairs(sequence) do
        if season == Environment.State.season then
            currentIndex = idx
            break
        end
    end
    local nextIndex = currentIndex % #sequence + 1
    Environment.SetSeason(sequence[nextIndex])
end

function Environment.SetSeason(season)
    local parsed = Utils.ParseSeason(season)
    if not parsed then return false, "Invalid season" end
    local now = Utils.Timestamp()
    Environment.State.season = parsed
    Environment.State.seasonStartedAt = now
    Environment.State.seasonEndsAt = now + (Config.Environment.SeasonLengthMinutes * 60)
    Environment.State.seasonEffects = Config.Environment.Seasons[parsed]
    save()
    broadcast()
    return true
end

local function hazardConfig(hazardKey)
    return Config.Environment.Hazards[hazardKey]
        or (Config.Hazards and Config.Hazards.NaturalEvents and Config.Hazards.NaturalEvents[hazardKey])
        or (Config.Hazards and Config.Hazards.Predators and Config.Hazards.Predators[hazardKey])
end

function Environment.QueueHazard(hazardKey, metadata)
    local hazard = hazardConfig(hazardKey)
    if not hazard then return false, "Unknown hazard" end
    local entry = {
        key = hazardKey,
        metadata = metadata or {},
        triggeredAt = Utils.Timestamp()
    }
    table.insert(Environment.State.activeHazards, entry)
    if hazard.notification then
        TriggerClientEvent("ranch:environment:notify", -1, hazard.notification)
    end
    if metadata and metadata.ranchId then
        RanchManager.AppendHistory(metadata.ranchId, {
            type = "hazard",
            hazard = hazardKey,
            impact = metadata.impact or hazard
        })
    end
    save()
    broadcast()
    return true
end

function Environment.TryHazard()
    local hazards = Config.Environment.Hazards
    for key, hazard in pairs(hazards) do
        local chance = hazard.randomChance or 0
        if chance > 0 and math.random() < chance then
            Environment.QueueHazard(key, { automatic = true })
        end
    end
end

function Environment.ApplyModifier(key, amount)
    Environment.State.modifiers[key] = (Environment.State.modifiers[key] or 0) + amount
    save()
    broadcast()
end

function Environment.GetState()
    return Environment.State
end

RegisterNetEvent("ranch:environment:requestSync", function()
    local src = source
    TriggerClientEvent("ranch:environment:update", src, Environment.State)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Environment.Initialize()
end)

return Environment
