local Config = require("shared.config")

local Utils = {}

local identifierMap = {
    license = "license:",
    steam = "steam:",
    discord = "discord:",
    cid = "cid:",
    citizenid = "cid:"
}

local function trim(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

local function tableCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = tableCopy(v)
    end
    return copy
end

function Utils.DeepCopy(value)
    return tableCopy(value)
end

function Utils.TableMerge(base, ...)
    local result = Utils.DeepCopy(base or {})
    for _, overlay in ipairs({ ... }) do
        if type(overlay) == "table" then
            for key, val in pairs(overlay) do
                if type(val) == "table" and type(result[key]) == "table" then
                    result[key] = Utils.TableMerge(result[key], val)
                else
                    result[key] = Utils.DeepCopy(val)
                end
            end
        end
    end
    return result
end

function Utils.Clamp(value, min, max)
    if min and value < min then return min end
    if max and value > max then return max end
    return value
end

function Utils.RandomRange(minValue, maxValue)
    if not minValue or not maxValue then return minValue or maxValue end
    if minValue == maxValue then return minValue end
    return minValue + math.random() * (maxValue - minValue)
end

function Utils.Round(value, decimals)
    local pow = 10 ^ (decimals or 0)
    return math.floor(value * pow + 0.5) / pow
end

function Utils.WeightedChoice(options)
    if type(options) ~= "table" then return nil end
    local total = 0
    for _, data in pairs(options) do
        local weight = data.weight or 0
        total = total + weight
    end
    if total <= 0 then return nil end
    local choice = math.random() * total
    for key, data in pairs(options) do
        choice = choice - (data.weight or 0)
        if choice <= 0 then
            return key, data
        end
    end
    return nil
end

function Utils.IsAdmin(source)
    if source <= 0 then return true end
    if Config.Admin.AcePermission and Config.Admin.AcePermission ~= "" then
        if IsPlayerAceAllowed(source, Config.Admin.AcePermission) then return true end
    end

    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if Config.Admin.Identifiers and Config.Admin.Identifiers[id] then return true end
    end
    return false
end

function Utils.FindIdentifier(source, preferred)
    local identifiers = source and GetPlayerIdentifiers(source) or {}
    local needle = preferred and identifierMap[preferred]

    if needle then
        for _, identifier in ipairs(identifiers) do
            if identifier:sub(1, #needle) == needle then
                return identifier
            end
        end
    end

    for _, key in ipairs(Config.IdentifierPriority) do
        local prefix = identifierMap[key]
        if prefix then
            for _, identifier in ipairs(identifiers) do
                if identifier:sub(1, #prefix) == prefix then
                    return identifier
                end
            end
        end
    end

    return identifiers[1]
end

function Utils.NormalizeIdentifier(value)
    if not value or value == "" then return nil end
    value = trim(value)
    for key, prefix in pairs(identifierMap) do
        if value:sub(1, #prefix) == prefix then
            return value
        end
    end

    if value:match("^%d+$") then
        return identifierMap.discord .. value
    end

    if value:match("^[A-Za-z0-9]+$") then
        return identifierMap.cid .. value
    end

    return value
end

function Utils.GetTargetIdentifier(args, source)
    local supplied = args and args[1]
    if supplied then
        local normalized = Utils.NormalizeIdentifier(supplied)
        if normalized then return normalized end
    end
    local allowFromSource = Config.AllowIdTransferFromSource
    if Config.Ranches and Config.Ranches.AllowIdTransferFromSource ~= nil then
        allowFromSource = Config.Ranches.AllowIdTransferFromSource
    end
    if allowFromSource and source and source > 0 then
        local sourceIdentifier = Utils.FindIdentifier(source)
        if sourceIdentifier then return sourceIdentifier end
    end
    return nil
end

function Utils.DebugLog(...)
    if not Config.Debug then return end
    print("[RanchSystem]", ...)
end

function Utils.GenerateRanchId()
    return ("ranch_%s"):format(math.random(100000, 999999))
end

function Utils.Timestamp()
    return os.time(os.date("!*t"))
end

function Utils.ParseSeason(season)
    if not season then return nil end
    local lower = season:lower()
    if Config.Environment.Seasons[lower] then
        return lower
    end
    return nil
end

function Utils.ToCitizenId(identifier)
    if not identifier then return nil end
    if identifier:find("cid:") == 1 then
        return identifier
    end
    if identifier:find("citizenid:") == 1 then
        return identifier
    end
    return identifierMap.cid .. identifier
end

function Utils.GetStorageKeys()
    local keys = {}
    for name in pairs(Config.Storage.Files) do
        table.insert(keys, name)
    end
    table.sort(keys)
    return keys
end

return Utils
