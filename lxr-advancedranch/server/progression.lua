local Config = require("shared.config")
local Utils = require("shared.utils")
local Storage = require("server.storage")
local RanchManager = require("server.ranch_manager")

local Progression = {}
Progression.Data = Storage.Progression:Get("ranches") or {}

local function save()
    Storage.Progression:Set("ranches", Progression.Data)
end

local function thresholds()
    return Config.Progression.LevelThresholds
end

local function ensure(ranchId)
    if not Progression.Data[ranchId] then
        Progression.Data[ranchId] = {
            xp = 0,
            level = 1,
            skills = {},
            achievements = {},
            legacy = {}
        }
    end
    return Progression.Data[ranchId]
end

function Progression.AddXP(ranchId, amount, reason)
    local profile = ensure(ranchId)
    profile.xp = (profile.xp or 0) + amount
    local levels = thresholds()
    for index = #levels, 1, -1 do
        if profile.xp >= levels[index] then
            profile.level = index
            break
        end
    end
    save()
    TriggerClientEvent("ranch:progression:update", -1, ranchId, profile)
    RanchManager.AppendHistory(ranchId, { type = "xp_gain", amount = amount, reason = reason })
    return profile.level
end

function Progression.UnlockSkill(ranchId, tree, perk)
    local profile = ensure(ranchId)
    profile.skills[tree] = profile.skills[tree] or {}
    table.insert(profile.skills[tree], perk)
    save()
    TriggerClientEvent("ranch:progression:update", -1, ranchId, profile)
end

function Progression.AwardAchievement(ranchId, key)
    local profile = ensure(ranchId)
    profile.achievements[key] = Utils.Timestamp()
    save()
    TriggerClientEvent("ranch:progression:achievement", -1, ranchId, key)
end

function Progression.RecordLegacy(ranchId, data)
    local profile = ensure(ranchId)
    table.insert(profile.legacy, data)
    if #profile.legacy > Config.Progression.Legacy.heirCount then
        table.remove(profile.legacy, 1)
    end
    save()
end

RegisterNetEvent("ranch:progression:requestSync", function(ranchId)
    local src = source
    TriggerClientEvent("ranch:progression:update", src, ranchId, ensure(ranchId))
end)

return Progression
