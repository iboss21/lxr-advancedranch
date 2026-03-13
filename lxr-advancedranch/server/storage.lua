local Config = require("shared.config")
local Utils = require("shared.utils")

local Storage = {}
Storage.__index = Storage

local function loadJson(path, fallback)
    local jsonData = LoadResourceFile(GetCurrentResourceName(), path)
    if jsonData then
        local success, decoded = pcall(json.decode, jsonData)
        if success and decoded then
            return decoded
        end
    end
    return fallback or {}
end

local function saveJson(path, payload)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(payload, { indent = true }), -1)
end

function Storage.new(path, defaults)
    local self = setmetatable({}, Storage)
    self.path = path
    self.cache = loadJson(path, Utils.DeepCopy(defaults))
    return self
end

function Storage:Get(key)
    if not key then return self.cache end
    return self.cache[key]
end

function Storage:Set(key, value)
    if not key then return end
    self.cache[key] = value
    self:Persist()
end

function Storage:Delete(key)
    if not key then return end
    self.cache[key] = nil
    self:Persist()
end

function Storage:Persist()
    saveJson(self.path, self.cache)
end

function Storage:All()
    return self.cache
end

local stores = {}
for name, path in pairs(Config.Storage.Files) do
    stores[name] = Storage.new(path)
end

if Config.Storage.AutoPersistInterval and Config.Storage.AutoPersistInterval > 0 then
    CreateThread(function()
        while true do
            Wait(Config.Storage.AutoPersistInterval * 1000)
            for _, store in pairs(stores) do
                store:Persist()
            end
        end
    end)
end

local api = { Storage = Storage }
for name, store in pairs(stores) do
    api[name] = store
end

function api.GetStore(name)
    return stores[name]
end

return api
