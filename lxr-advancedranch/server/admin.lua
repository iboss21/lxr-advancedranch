local function ensureAdmin(source)
    if not Utils.IsAdmin(source) then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "You do not have permission." } })
        return false
    end
    return true
end

local function resolveOwnerIdentifier(source, identifierArg)
    local args = {}
    if identifierArg then
        args[1] = identifierArg
    end
    local target = Utils.GetTargetIdentifier(args, source)
    if not target then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Unable to determine identifier." } })
        return nil
    end
    return target
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Ownership cache
-- Populated lazily from ranches.json and kept current via create/transfer events.
-- This avoids repeated disk reads for permission checks during a single session.
-- ─────────────────────────────────────────────────────────────────────────────

local ownershipCache    = nil   -- { [ranchId] = ownerIdentifier, ... }
local ownershipCacheAge = 0     -- timestamp of last full reload

local function refreshOwnershipCache(force)
    local now = os.time()
    -- Re-read from disk at most once per 60 seconds, or when forced.
    if not force and ownershipCache and (now - ownershipCacheAge) < 60 then
        return
    end
    local content = LoadResourceFile(GetCurrentResourceName(), Config.Storage.Files.Ranches)
    if not content then
        ownershipCache = ownershipCache or {}
        return
    end
    local ok, data = pcall(json.decode, content)
    if ok and data then
        local fresh = {}
        for id, ranch in pairs(data) do
            fresh[id] = ranch.owner
        end
        ownershipCache    = fresh
        ownershipCacheAge = now
    end
end

-- Update cache immediately when a ranch is created or transferred (no disk read).
local function cacheSetOwner(ranchId, identifier)
    if ownershipCache then
        ownershipCache[ranchId] = identifier
    end
end

local function cacheRemoveRanch(ranchId)
    if ownershipCache then
        ownershipCache[ranchId] = nil
    end
end

-- Check whether a player is admin OR owns the specified ranch.
local function isAdminOrOwner(src, ranchId)
    if Utils.IsAdmin(src) then return true end
    local identifier = Utils.FindIdentifier(src)
    if not identifier then return false end
    if ranchId then
        refreshOwnershipCache(false)
        if ownershipCache and ownershipCache[ranchId] == identifier then
            return true
        end
    end
    return false
end

-- Return a list of { id, name } tables for every ranch owned by identifier.
-- Ranch names are read from disk (the cache only tracks owner identifiers).
local function getOwnedRanches(identifier)
    if not identifier then return {} end
    local content = LoadResourceFile(GetCurrentResourceName(), Config.Storage.Files.Ranches)
    if not content then return {} end
    local ok, data = pcall(json.decode, content)
    if not ok or not data then return {} end
    -- Also refresh the ownership cache from this read to keep it warm.
    local fresh = {}
    local owned = {}
    for id, ranch in pairs(data) do
        fresh[id] = ranch.owner
        if ranch.owner == identifier then
            owned[#owned + 1] = { id = id, name = ranch.name or id }
        end
    end
    ownershipCache    = fresh
    ownershipCacheAge = os.time()
    return owned
end

RegisterCommand("ranchcreate", function(source, args)
    if not ensureAdmin(source) then return end
    local name = args[1]
    if not name then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchcreate <Name> [identifier]" } })
        return
    end
    local ownerIdentifier = resolveOwnerIdentifier(source, args[2])
    local ranch, err = RanchManager.CreateRanch(name, ownerIdentifier)
    if not ranch then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", err or "Failed to create ranch." } })
        return
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Created ranch %s (%s)"):format(ranch.name, ranch.id) } })
end, false)

RegisterCommand("ranchdelete", function(source, args)
    if not ensureAdmin(source) then return end
    local id = args[1]
    if not id then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchdelete <RanchId>" } })
        return
    end
    local success, err = RanchManager.DeleteRanch(id)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Deleted ranch %s"):format(id) or err } })
end, false)

RegisterCommand("ranchtransfer", function(source, args)
    if not ensureAdmin(source) then return end
    local id = args[1]
    if not id then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchtransfer <RanchId> <identifier>" } })
        return
    end
    local identifier = resolveOwnerIdentifier(source, args[2])
    if not identifier then return end
    local success, result = RanchManager.TransferOwnership(id, identifier)
    if not success then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", result or "Transfer failed" } })
        return
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Transferred %s to %s"):format(id, identifier) } })
end, false)

RegisterCommand("ranchsetrole", function(source, args)
    if not ensureAdmin(source) then return end
    local id, role = args[1], args[2]
    if not id or not role then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchsetrole <RanchId> <RoleId>" } })
        return
    end
    local success, err = RanchManager.SetDiscordRole(id, role)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Role %s assigned to %s"):format(role, id) or err } })
end, false)

RegisterCommand("ranchseason", function(source, args)
    if not ensureAdmin(source) then return end
    local season = args[1]
    if not season then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchseason <spring|summer|autumn|winter>" } })
        return
    end
    local success, err = Environment.SetSeason(season)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Season set to %s"):format(season) or err } })
end, false)

RegisterCommand("ranchweather", function(source)
    if not ensureAdmin(source) then return end
    Environment.RollWeather()
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Weather pattern rolled." } })
end, false)

RegisterCommand("ranchhazard", function(source, args)
    if not ensureAdmin(source) then return end
    local hazard = args[1]
    if not hazard then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchhazard <hazardKey> [ranchId]" } })
        return
    end
    local ranchId = args[2]
    local success, err = Environment.QueueHazard(hazard, { ranchId = ranchId, manual = true })
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Hazard %s queued."):format(hazard) or err } })
end, false)

RegisterCommand("ranchanimaladd", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, species, count = args[1], args[2], tonumber(args[3]) or 1
    if not ranchId or not species then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchanimaladd <RanchId> <species> [count]" } })
        return
    end
    local created = 0
    for i = 1, count do
        local success, result = Livestock.RegisterAnimal(ranchId, species, {})
        if success then created = created + 1 end
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Added %s %s to %s"):format(created, species, ranchId) } })
end, false)

RegisterCommand("ranchanimaldel", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, animalId = args[1], args[2]
    if not ranchId or not animalId then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchanimaldel <RanchId> <AnimalId>" } })
        return
    end
    local success, err = Livestock.RemoveAnimal(ranchId, animalId)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Removed %s"):format(animalId) or err } })
end, false)

RegisterCommand("ranchassign", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, identifier, role = args[1], args[2], args[3]
    if not ranchId or not identifier or not role then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchassign <RanchId> <Identifier> <Role>" } })
        return
    end
    Workforce.AssignWorker(ranchId, Utils.NormalizeIdentifier(identifier) or identifier, role)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Worker assigned." } })
end, false)

RegisterCommand("ranchtask", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, taskType = args[1], args[2]
    if not ranchId or not taskType then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchtask <RanchId> <TaskType>" } })
        return
    end
    local success, err = Workforce.CreateTask(ranchId, taskType, {})
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Task %s created"):format(taskType) or err } })
end, false)

RegisterCommand("ranchcontract", function(source, args)
    if not ensureAdmin(source) then return end
    local town, contractId, ranchId = args[1], args[2], args[3]
    if not town then
        local contract = Economy.GenerateContract()
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Generated contract %s for %s"):format(contract.id, contract.town) } })
        return
    end
    if town and contractId and ranchId then
        local success, err = Economy.AssignContract(town, contractId, ranchId)
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and "Contract assigned" or err } })
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchcontract <Town> <ContractId> <RanchId>" } })
    end
end, false)

RegisterCommand("ranchxp", function(source, args)
    if not ensureAdmin(source) then return end
    local ranchId, amount = args[1], tonumber(args[2])
    if not ranchId or not amount then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchxp <RanchId> <Amount>" } })
        return
    end
    local level = Progression.AddXP(ranchId, amount, "admin grant")
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Ranch %s now level %s"):format(ranchId, level) } })
end, false)

-- ─────────────────────────────────────────────────────────────────────────────
-- Net Events — Admin Menu (mirrors every command above for menu-driven access)
-- ─────────────────────────────────────────────────────────────────────────────

-- Permissions query: returns admin flag + list of owned ranches to the caller.
RegisterNetEvent("ranch:admin:getPermissions", function()
    local src        = source
    local admin      = Utils.IsAdmin(src)
    local identifier = Utils.FindIdentifier(src)
    local owned      = getOwnedRanches(identifier)
    TriggerClientEvent("ranch:admin:permissions", src, admin, owned)
end)

RegisterNetEvent("ranch:admin:create", function(name, ownerIdentifier)
    local src = source
    if not ensureAdmin(src) then return end
    if not name or name == "" then return end
    local identifier = (ownerIdentifier and ownerIdentifier ~= "") and ownerIdentifier or Utils.FindIdentifier(src)
    local ranch, err = RanchManager.CreateRanch(name, identifier)
    if ranch then
        -- Keep ownership cache current without waiting for the next disk refresh.
        cacheSetOwner(ranch.id, identifier)
        TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", ("Created ranch %s (%s)"):format(ranch.name, ranch.id) } })
    else
        TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", err or "Failed to create ranch." } })
    end
end)

RegisterNetEvent("ranch:admin:delete", function(id)
    local src = source
    if not ensureAdmin(src) then return end
    if not id or id == "" then return end
    local success, err = RanchManager.DeleteRanch(id)
    if success then cacheRemoveRanch(id) end
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", success and ("Deleted ranch %s"):format(id) or err } })
end)

RegisterNetEvent("ranch:admin:transfer", function(id, identifier)
    local src = source
    if not ensureAdmin(src) then return end
    if not id or id == "" or not identifier or identifier == "" then return end
    local success, result = RanchManager.TransferOwnership(id, identifier)
    if success then cacheSetOwner(id, identifier) end
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", success and ("Transferred %s to %s"):format(id, identifier) or result } })
end)

RegisterNetEvent("ranch:admin:setSeason", function(season)
    local src = source
    if not ensureAdmin(src) then return end
    if not season or season == "" then return end
    local success, err = Environment.SetSeason(season)
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", success and ("Season set to %s"):format(season) or err } })
end)

RegisterNetEvent("ranch:admin:rollWeather", function()
    local src = source
    if not ensureAdmin(src) then return end
    Environment.RollWeather()
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", "Weather pattern rolled." } })
end)

-- Accessible by server admins AND owners (for their own ranch).
RegisterNetEvent("ranch:admin:queueHazard", function(hazard, ranchId)
    local src = source
    if not isAdminOrOwner(src, ranchId) then
        TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", "You do not have permission." } })
        return
    end
    if not hazard or hazard == "" then return end
    local success, err = Environment.QueueHazard(hazard, { ranchId = ranchId, manual = true })
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", success and ("Hazard %s queued."):format(hazard) or err } })
end)

-- Accessible by server admins AND owners (for their own ranch).
RegisterNetEvent("ranch:admin:addAnimal", function(ranchId, species, count)
    local src = source
    if not isAdminOrOwner(src, ranchId) then
        TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", "You do not have permission." } })
        return
    end
    if not ranchId or ranchId == "" or not species or species == "" then return end
    -- Clamp to a sane batch limit to prevent server overload from malicious calls.
    count = math.max(1, math.min(tonumber(count) or 1, 99))
    local created = 0
    for _ = 1, count do
        local ok = Livestock.RegisterAnimal(ranchId, species, {})
        if ok then created = created + 1 end
    end
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", ("Added %s %s to %s"):format(created, species, ranchId) } })
end)

RegisterNetEvent("ranch:admin:deleteAnimal", function(ranchId, animalId)
    local src = source
    if not ensureAdmin(src) then return end
    if not ranchId or not animalId then return end
    local success, err = Livestock.RemoveAnimal(ranchId, animalId)
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", success and ("Removed %s"):format(animalId) or err } })
end)

-- Accessible by server admins AND owners (for their own ranch).
RegisterNetEvent("ranch:admin:grantXP", function(ranchId, amount)
    local src = source
    if not isAdminOrOwner(src, ranchId) then
        TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", "You do not have permission." } })
        return
    end
    if not ranchId or ranchId == "" then return end
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end
    local level = Progression.AddXP(ranchId, amount, "admin grant")
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", ("Ranch %s now level %s"):format(ranchId, level) } })
end)

RegisterNetEvent("ranch:admin:assignWorker", function(ranchId, identifier, role)
    local src = source
    if not ensureAdmin(src) then return end
    if not ranchId or ranchId == "" or not identifier or identifier == "" or not role or role == "" then return end
    Workforce.AssignWorker(ranchId, Utils.NormalizeIdentifier(identifier) or identifier, role)
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", "Worker assigned." } })
end)

RegisterNetEvent("ranch:admin:createTask", function(ranchId, taskType)
    local src = source
    if not ensureAdmin(src) then return end
    if not ranchId or ranchId == "" or not taskType or taskType == "" then return end
    local success, err = Workforce.CreateTask(ranchId, taskType, {})
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", success and ("Task %s created"):format(taskType) or err } })
end)

RegisterNetEvent("ranch:admin:generateContract", function()
    local src = source
    if not ensureAdmin(src) then return end
    local contract = Economy.GenerateContract()
    TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", ("Generated contract %s for %s"):format(contract.id, contract.town) } })
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Existing zone / prop net events
-- ─────────────────────────────────────────────────────────────────────────────

RegisterNetEvent("ranch:zones:save", function(zoneId, payload)
    if not ensureAdmin(source) then return end
    RanchManager.SaveVegetation(zoneId, payload)
end)

RegisterNetEvent("ranch:zones:assign", function(zoneId, ranchId)
    if not ensureAdmin(source) then return end
    RanchManager.AssignZone(zoneId, ranchId)
end)

-- Props can be saved by server admins OR by the owner of the target ranch.
RegisterNetEvent("ranch:props:save", function(ranchId, props)
    local src = source
    if not isAdminOrOwner(src, ranchId) then
        TriggerClientEvent("chat:addMessage", src, { args = { "Ranch", "You do not have permission to place props on this ranch." } })
        return
    end
    local ranch  = RanchManager.GetOrCreate(ranchId)
    ranch.props  = props
    TriggerClientEvent("ranch:props:update", -1, ranchId, props)
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    -- placeholder for Discord sync or role enforcement
end)

AddEventHandler("playerJoining", function(source)
    RanchManager.SyncAll(source)
    TriggerClientEvent("ranch:environment:update", source, Environment.GetState())
    TriggerClientEvent("ranch:economy:update", source, {
        prices = Economy.Prices,
        contracts = Economy.Contracts,
        auctions = Economy.Auctions
    })
    for ranchId, animals in pairs(Livestock.Animals) do
        TriggerClientEvent("ranch:livestock:update", source, ranchId, animals)
    end
    for ranchId, roster in pairs(Workforce.Rosters) do
        TriggerClientEvent("ranch:workforce:roster", source, ranchId, roster)
    end
    for ranchId, tasks in pairs(Workforce.Tasks) do
        TriggerClientEvent("ranch:workforce:tasks", source, ranchId, tasks)
    end
    for ranchId, profile in pairs(Progression.Data) do
        TriggerClientEvent("ranch:progression:update", source, ranchId, profile)
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    RanchManager.SyncAll(-1)
end)
