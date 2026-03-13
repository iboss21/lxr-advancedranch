--[[
    ═══════════════════════════════════════════════════════════════════════════════
    🐺 LXR Ranch System — Server Core (ESCROW PROTECTED)
    ═══════════════════════════════════════════════════════════════════════════════
    wolves.land — The Land of Wolves
    © 2026 iBoss21 / The Lux Empire | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ RESOURCE NAME GUARD ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
-- This protection lives in server-side escrow-encrypted code so that it cannot
-- be bypassed by buyers or redistributors. The check runs before any logic loads.
-- ████████████████████████████████████████████████████████████████████████████████

local _REQUIRED_NAME = 'lxr-ranch-system'
local _CURRENT_NAME  = GetCurrentResourceName()

if not (Config.Dev and Config.Dev.SkipNameGuard) and _CURRENT_NAME ~= _REQUIRED_NAME then
    error(string.format(
        '\n\n' ..
        '═══════════════════════════════════════════════════════════════════════════════\n' ..
        '❌  CRITICAL: RESOURCE NAME MISMATCH  ❌\n' ..
        '═══════════════════════════════════════════════════════════════════════════════\n' ..
        '\n' ..
        '  Expected resource name : %s\n' ..
        '  Current resource name  : %s\n' ..
        '\n' ..
        '  This resource is escrow-protected and must keep its original name.\n' ..
        '  Rename the resource folder to "%s" and restart.\n' ..
        '\n' ..
        '  🐺 wolves.land — The Land of Wolves\n' ..
        '  © 2026 iBoss21 / The Lux Empire | All Rights Reserved\n' ..
        '\n' ..
        '═══════════════════════════════════════════════════════════════════════════════\n',
        _REQUIRED_NAME, _CURRENT_NAME, _REQUIRED_NAME
    ))
end

-- ████████████████████████████████████████████████████████████████████████████████

local Config = require("shared.config")
local Utils = require("shared.utils")
local Storage = require("server.storage")

local RanchManager = {}
RanchManager.Ranches = Storage.Ranches:Get() or {}
RanchManager.Vegetation = Storage.Vegetation:Get() or {}

local function hydrateMetadata(existing)
    local defaults = Utils.DeepCopy(Config.Ranches.DefaultMetadata or {})
    if not existing then return defaults end
    return Utils.TableMerge(defaults, existing)
end

local function ensureRanch(id)
    if not RanchManager.Ranches[id] then
        RanchManager.Ranches[id] = {
            id = id,
            name = "",
            owner = nil,
            members = {},
            parcels = {},
            props = {},
            metadata = hydrateMetadata(nil),
            discordRoleId = nil,
            createdAt = Utils.Timestamp(),
            history = {},
            achievements = {}
        }
    else
        RanchManager.Ranches[id].metadata = hydrateMetadata(RanchManager.Ranches[id].metadata)
    end
    return RanchManager.Ranches[id]
end

local function save()
    Storage.Ranches:Persist()
    Storage.Vegetation:Persist()
end

function RanchManager.CreateRanch(name, ownerIdentifier, metadata)
    if not name or name == "" then return nil, "Name required" end
    local id = Utils.GenerateRanchId()
    while RanchManager.Ranches[id] do
        id = Utils.GenerateRanchId()
    end
    local ranch = ensureRanch(id)
    ranch.name = name
    ranch.owner = ownerIdentifier
    ranch.metadata = hydrateMetadata(metadata)
    RanchManager.Ranches[id] = ranch
    save()
    return ranch
end

function RanchManager.DeleteRanch(id)
    if not RanchManager.Ranches[id] then
        return false, "Ranch not found"
    end
    RanchManager.Ranches[id] = nil
    Storage.Ranches:Delete(id)
    return true
end

function RanchManager.TransferOwnership(id, newOwner)
    local ranch = RanchManager.Ranches[id]
    if not ranch then return false, "Ranch not found" end
    ranch.owner = newOwner
    save()
    TriggerEvent("ranch:ownershipChanged", id, newOwner)
    return true, ranch
end

function RanchManager.SetDiscordRole(id, roleId)
    local ranch = RanchManager.Ranches[id]
    if not ranch then return false, "Ranch not found" end
    ranch.discordRoleId = roleId
    save()
    return true, ranch
end

function RanchManager.UpdateMetadata(id, path, value)
    local ranch = ensureRanch(id)
    local node = ranch.metadata
    local parts = {}
    for segment in string.gmatch(path, "[^%.]+") do
        table.insert(parts, segment)
    end
    for i = 1, #parts - 1 do
        local key = parts[i]
        node[key] = node[key] or {}
        node = node[key]
    end
    node[parts[#parts]] = value
    save()
    return ranch
end

function RanchManager.AppendHistory(id, entry)
    local ranch = ensureRanch(id)
    ranch.history = ranch.history or {}
    entry.timestamp = entry.timestamp or Utils.Timestamp()
    table.insert(ranch.history, entry)
    if #ranch.history > 200 then
        table.remove(ranch.history, 1)
    end
    save()
    return ranch.history
end

function RanchManager.RecordAchievement(id, key)
    local ranch = ensureRanch(id)
    ranch.achievements = ranch.achievements or {}
    ranch.achievements[key] = Utils.Timestamp()
    save()
    return ranch.achievements
end

function RanchManager.AdjustLedger(id, delta, reason)
    local ranch = ensureRanch(id)
    ranch.metadata = ranch.metadata or hydrateMetadata()
    ranch.metadata.ledger = ranch.metadata.ledger or {}
    ranch.metadata.ledger.balance = (ranch.metadata.ledger.balance or 0) + delta
    ranch.metadata.ledger.lastTransaction = { amount = delta, reason = reason, at = Utils.Timestamp() }
    save()
    return ranch.metadata.ledger.balance
end

function RanchManager.GetOrCreate(id)
    return ensureRanch(id)
end

function RanchManager.Get(id)
    return RanchManager.Ranches[id]
end

function RanchManager.UpdateParcels(id, parcels)
    local ranch = ensureRanch(id)
    ranch.parcels = parcels
    save()
    TriggerClientEvent("ranch:zones:sync", -1, id, parcels)
end

function RanchManager.List()
    return RanchManager.Ranches
end

-- Vegetation & zoning

local function ensureZone(zoneId)
    if not RanchManager.Vegetation[zoneId] then
        RanchManager.Vegetation[zoneId] = {
            id = zoneId,
            vegetation = Config.ZoneDefaults.VegetationState,
            wildlife = Config.ZoneDefaults.WildlifeDensity,
            fertility = Config.ZoneDefaults.SoilFertility,
            points = {},
            ranchId = nil
        }
    end
    return RanchManager.Vegetation[zoneId]
end

function RanchManager.SaveVegetation(zoneId, data)
    local zone = ensureZone(zoneId)
    for key, value in pairs(data or {}) do
        zone[key] = value
    end
    save()
    TriggerClientEvent("ranch:vegetation:update", -1, zoneId, zone)
    return zone
end

function RanchManager.AssignZone(zoneId, ranchId)
    local zone = ensureZone(zoneId)
    zone.ranchId = ranchId
    save()
    return zone
end

function RanchManager.GetZone(zoneId)
    return RanchManager.Vegetation[zoneId]
end

function RanchManager.AllZones()
    return RanchManager.Vegetation
end

function RanchManager.SyncAll(source)
    local target = source or -1
    for id, data in pairs(RanchManager.Ranches) do
        TriggerClientEvent("ranch:zones:sync", target, id, data.parcels or {})
        if data.props then
            TriggerClientEvent("ranch:props:update", target, id, data.props)
        end
    end
    TriggerClientEvent("ranch:vegetation:bulk", target, RanchManager.Vegetation)
end

-- Discord bridging (placeholder HTTP integration)
local function dispatchDiscord(eventName, payload)
    if Config.Discord.WebhookUrl == "" then return end
    PerformHttpRequest(Config.Discord.WebhookUrl, function(err, text, headers)
        if err ~= 200 then
            print("[RanchSystem] Discord webhook error", err, text or "")
        end
    end, "POST", json.encode({ username = "Ranch System", embeds = { payload } }), { ["Content-Type"] = "application/json" })
end

AddEventHandler("ranch:ownershipChanged", function(ranchId, ownerIdentifier)
    if not Config.Discord.UseRoles then return end
    local ranch = RanchManager.Ranches[ranchId]
    if not ranch then return end
    local embed = {
        title = "Ranch Ownership Updated",
        description = ("Ranch **%s** now owned by `%s`"):format(ranch.name, ownerIdentifier or "Unknown"),
        color = 65280,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    dispatchDiscord("ownershipChanged", embed)
end)

return RanchManager
