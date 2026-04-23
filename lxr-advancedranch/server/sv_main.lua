--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Server Bootstrap

    This file performs: resource-name guard (anti-rename piracy), DB migration,
    seed-ranch population, event namespace setup, shared player-state cache,
    rate-limit ledger, cross-module pub/sub helpers. Every other server script
    imports helpers from this file via the RanchCore global.

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ RESOURCE NAME GUARD ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local EXPECTED_NAME = 'lxr-advancedranch'

local function nameMatches()
    local actual = GetCurrentResourceName()
    local expected = Config.Security.resourceNameGuard or EXPECTED_NAME
    return actual == expected
end

CreateThread(function()
    Wait(500)
    if Config.Security and Config.Security.enabled and not nameMatches() then
        local actual = GetCurrentResourceName()
        print('^1═══════════════════════════════════════════════════════════════════════════════^7')
        print('^1[lxr-advancedranch] RESOURCE NAME GUARD TRIPPED^7')
        print(('^1[lxr-advancedranch] Expected: %s  |  Actual: %s^7'):format(EXPECTED_NAME, actual))
        print('^1[lxr-advancedranch] Rename the resource folder back to "lxr-advancedranch" to continue.^7')
        print('^1═══════════════════════════════════════════════════════════════════════════════^7')
        if Config.Security.kickOnNameMismatch then
            StopResource(GetCurrentResourceName())
        end
    end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CORE STATE ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RanchCore = {
    Ranches       = {},   -- [ranchId] = ranch row (with cached extras)
    Animals       = {},   -- [animalId] = animal row
    Workforce     = {},   -- [ranchId][identifier] = workforce row
    Contracts     = {},   -- [contractId] = contract row
    Auctions      = {},   -- [auctionId] = auction row
    Progression   = {},   -- [identifier] = progression row
    Environment   = {     -- Current environment snapshot
        season        = 'spring',
        seasonStarted = os.time(),
        weather       = 'clear',
        weatherAt     = os.time(),
        tempC         = 20,
        activeHazard  = nil
    },
    PlayerIndex   = {},   -- [source] = { identifier, ranchId, lastNuiPull }
    DirtyRanches  = {},
    DirtyAnimals  = {},
    Cache         = {
        prices = {}
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ EVENT NAME BUILDERS ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local RES = GetCurrentResourceName()

function RanchCore.EventName(ns, name)
    return ('%s:%s:%s'):format(RES, ns, name)
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG LOGGING █████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.Log(channel, msg, ...)
    if not Config.Debug then return end
    if not Config.DebugChannels[channel] then return end
    if select('#', ...) > 0 then
        print(('^3[lxr-advancedranch] [%s]^7 ' .. tostring(msg)):format(...)
              :format(channel))
    else
        print(('^3[lxr-advancedranch] [%s]^7 %s'):format(channel, tostring(msg)))
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ RATE LIMITING ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function rateKey(source, tag) return ('%s:%s'):format(tostring(source), tag) end

function RanchCore.RateCheck(source, tag, maxPerMinute)
    maxPerMinute = maxPerMinute or Config.Security.maxActionsPerMinute or 60
    local ok = LXRUtils.RateLimit(rateKey(source, tag), maxPerMinute, 60000)
    if not ok and Config.Security.logSuspiciousActivity then
        print(('^3[lxr-advancedranch] rate-limit: src=%s tag=%s^7'):format(source, tag))
    end
    return ok
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PLAYER LIFECYCLE █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

AddEventHandler('playerJoining', function()
    local src = source
    RanchCore.PlayerIndex[src] = {
        identifier   = nil,
        ranchId      = nil,
        lastNuiPull  = 0,
        joinedAt     = os.time()
    }
end)

AddEventHandler('playerDropped', function()
    local src = source
    RanchCore.PlayerIndex[src] = nil
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    -- Flush dirty data
    if RanchCore.FlushDirty then RanchCore.FlushDirty() end
    if DB and DB.Mode() == 'json' and DB.Json and DB.Json.Flush then
        DB.Json.Flush()
    end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DIRTY-FLAG SAVE ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

function RanchCore.MarkRanchDirty(id)   RanchCore.DirtyRanches[id] = true end
function RanchCore.MarkAnimalDirty(id)  RanchCore.DirtyAnimals[id] = true end

function RanchCore.FlushDirty()
    local flushed = 0
    for id, _ in pairs(RanchCore.DirtyRanches) do
        if RanchCore.PersistRanch then RanchCore.PersistRanch(id) end
        flushed = flushed + 1
    end
    RanchCore.DirtyRanches = {}

    for id, _ in pairs(RanchCore.DirtyAnimals) do
        if RanchCore.PersistAnimal then RanchCore.PersistAnimal(id) end
        flushed = flushed + 1
    end
    RanchCore.DirtyAnimals = {}

    if flushed > 0 then
        RanchCore.Log('database', 'Flushed %d dirty records', flushed)
    end
end

CreateThread(function()
    while true do
        Wait(Config.General.autoSaveInterval or 300000)
        RanchCore.FlushDirty()
    end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ STARTUP SEQUENCE █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

CreateThread(function()
    Wait(1500)

    -- DB migrate
    if Config.Database.autoMigrate then
        DB.Migrate()
    end

    -- Seed ranches
    if RanchCore.SeedRanches then
        RanchCore.SeedRanches()
    end

    -- Load persistent state
    if RanchCore.LoadAllRanches      then RanchCore.LoadAllRanches()      end
    if RanchCore.LoadAllAnimals      then RanchCore.LoadAllAnimals()      end
    if RanchCore.LoadAllWorkforce    then RanchCore.LoadAllWorkforce()    end
    if RanchCore.LoadAllContracts    then RanchCore.LoadAllContracts()    end
    if RanchCore.LoadAllAuctions     then RanchCore.LoadAllAuctions()     end
    if RanchCore.LoadAllProgression  then RanchCore.LoadAllProgression()  end
    if RanchCore.LoadEnvironmentState then RanchCore.LoadEnvironmentState() end

    -- Start subsystem tickers
    if RanchCore.StartLivestockTicker   then RanchCore.StartLivestockTicker()   end
    if RanchCore.StartEnvironmentTicker then RanchCore.StartEnvironmentTicker() end
    if RanchCore.StartAuctionTicker     then RanchCore.StartAuctionTicker()     end
    if RanchCore.StartContractTicker    then RanchCore.StartContractTicker()    end
    if RanchCore.StartWorkforceTicker   then RanchCore.StartWorkforceTicker()   end

    TriggerEvent(RanchCore.EventName('core', 'ready'))
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SHARED CALLBACK: GET BOOTSTRAP ████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent(RanchCore.EventName('client', 'requestBootstrap'), function()
    local src = source
    if not RanchCore.RateCheck(src, 'bootstrap', 6) then return end

    local ident = Framework.GetIdentifier(src)
    RanchCore.PlayerIndex[src] = RanchCore.PlayerIndex[src] or {}
    RanchCore.PlayerIndex[src].identifier = ident

    -- Determine which ranch the player belongs to (owner or worker)
    local myRanchId = nil
    for rid, r in pairs(RanchCore.Ranches) do
        if r.owner_id == ident then myRanchId = rid; break end
    end
    if not myRanchId then
        for rid, roster in pairs(RanchCore.Workforce) do
            if roster[ident] then myRanchId = rid; break end
        end
    end
    RanchCore.PlayerIndex[src].ranchId = myRanchId

    TriggerClientEvent(RanchCore.EventName('server', 'bootstrap'), src, {
        ranchId     = myRanchId,
        environment = RanchCore.Environment,
        time        = os.time(),
        ranches     = RanchCore.PublicRanchList and RanchCore.PublicRanchList() or {}
    })
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
