-- Ranch System UI Client Handler
-- Handles NUI interactions and UI display for RedM

local Config = require("shared.config")
local UIOpen = false
local currentRanchId = nil

-- Debug function
local function debugPrint(...)
    if not Config.Debug then return end
    print("[RanchUI]", ...)
end

-- Open the ranch UI
local function openRanchUI(ranchId)
    if UIOpen then return end
    
    UIOpen = true
    currentRanchId = ranchId
    
    -- Get ranch data from exports
    local RanchClient = exports['ranch-system-omni']
    local ranchData = {
        ranchId = ranchId,
        ranchName = "Circle T Ranch", -- Default name
        balance = 0,
        level = 1,
        totalAnimals = 0,
        totalWorkers = 0,
        cleanliness = 0.75,
        morale = 0.80,
        integrity = 0.90,
        livestock = {},
        workforce = {},
        economy = {},
        environment = {},
        progression = {}
    }
    
    -- Try to get actual data if available
    if RanchClient then
        local livestock = RanchClient:GetLivestock()
        if livestock and livestock[ranchId] then
            ranchData.livestock = livestock[ranchId]
            ranchData.totalAnimals = #livestock[ranchId]
        end
        
        local workforce = RanchClient:GetWorkforce()
        if workforce and workforce[ranchId] then
            ranchData.workforce = workforce[ranchId].roster or {}
            ranchData.totalWorkers = #ranchData.workforce
            ranchData.morale = workforce[ranchId].morale or 0.80
        end
        
        local economy = RanchClient:GetEconomy()
        if economy then
            ranchData.economy = economy
        end
        
        local environment = RanchClient:GetEnvironment()
        if environment then
            ranchData.environment = environment
        end
        
        local progression = RanchClient:GetProgression()
        if progression and progression[ranchId] then
            ranchData.progression = progression[ranchId]
            ranchData.level = progression[ranchId].level or 1
        end
    end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        ranchData = ranchData
    })
    
    debugPrint("UI Opened for ranch:", ranchId)
end

-- Close the ranch UI
local function closeRanchUI()
    if not UIOpen then return end
    
    UIOpen = false
    currentRanchId = nil
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
    
    debugPrint("UI Closed")
end

-- Update ranch data in UI
local function updateUIData(dataType, data)
    if not UIOpen then return end
    
    SendNUIMessage({
        action = 'update' .. dataType:gsub("^%l", string.upper),
        [dataType] = data
    })
end

-- NUI Callbacks
RegisterNUICallback('uiOpened', function(data, cb)
    debugPrint("UI Opened callback received")
    cb('ok')
end)

RegisterNUICallback('uiClosed', function(data, cb)
    closeRanchUI()
    cb('ok')
end)

RegisterNUICallback('adminAction', function(data, cb)
    debugPrint("Admin action:", data.action)
    
    -- Send admin command to server based on action
    local actionMap = {
        createRanch = '/ranchcreate',
        transferOwnership = '/ranchtransfer',
        setSeason = '/ranchseason',
        triggerHazard = '/ranchhazard',
        addAnimal = '/ranchanimaladd',
        grantXP = '/ranchxp'
    }
    
    if actionMap[data.action] then
        -- Close UI and show command help
        TriggerEvent('chat:addMessage', {
            args = { "Ranch Admin", "Use " .. actionMap[data.action] .. " command to perform this action" }
        })
    end
    
    cb('ok')
end)

RegisterNUICallback('showHireDialog', function(data, cb)
    TriggerEvent('chat:addMessage', {
        args = { "Ranch", "Use /ranchassign command to assign workers" }
    })
    cb('ok')
end)

RegisterNUICallback('viewAnimalDetails', function(data, cb)
    debugPrint("Viewing animal:", data.animalId)
    TriggerEvent('chat:addMessage', {
        args = { "Ranch", "Animal details: ID " .. tostring(data.animalId) }
    })
    cb('ok')
end)

RegisterNUICallback('getAdminLogs', function(data, cb)
    -- Return dummy logs for now - can be extended to fetch real logs
    local logs = {
        { time = "5 min ago", message = "Ranch system initialized" },
        { time = "10 min ago", message = "Admin accessed ranch controls" }
    }
    cb(logs)
end)

-- Animal action callbacks
RegisterNUICallback('feedAnimal', function(data, cb)
    debugPrint("Feeding animal:", data.animalId)
    TriggerServerEvent('ranch:livestock:feed', currentRanchId, data.animalId)
    cb('ok')
end)

RegisterNUICallback('treatAnimal', function(data, cb)
    debugPrint("Treating animal:", data.animalId)
    TriggerServerEvent('ranch:livestock:treat', currentRanchId, data.animalId)
    cb('ok')
end)

RegisterNUICallback('breedAnimal', function(data, cb)
    debugPrint("Breeding animal:", data.animalId)
    TriggerServerEvent('ranch:livestock:breed', currentRanchId, data.animalId)
    cb('ok')
end)

RegisterNUICallback('sellAnimal', function(data, cb)
    debugPrint("Selling animal:", data.animalId)
    TriggerServerEvent('ranch:livestock:sell', currentRanchId, data.animalId)
    cb('ok')
end)

RegisterNUICallback('placeBid', function(data, cb)
    debugPrint("Placing bid:", data.auctionId, data.amount)
    TriggerServerEvent('ranch:auction:bid', data.auctionId, data.amount)
    cb('ok')
end)

-- Command to open UI
RegisterCommand('ranchui', function(source, args)
    local ranchId = args[1] or "default_ranch"
    openRanchUI(ranchId)
end, false)

-- Key mapping to toggle UI (F5 by default)
RegisterKeyMapping('ranchui', 'Open Ranch UI', 'keyboard', 'F5')

-- Event handlers for data updates
RegisterNetEvent("ranch:livestock:updated", function(ranchId, animals)
    if UIOpen and ranchId == currentRanchId then
        updateUIData('livestock', animals)
    end
end)

RegisterNetEvent("ranch:workforce:rosterUpdated", function(ranchId, roster)
    if UIOpen and ranchId == currentRanchId then
        updateUIData('workforce', roster)
    end
end)

RegisterNetEvent("ranch:economy:updated", function(payload)
    if UIOpen then
        updateUIData('economy', payload)
    end
end)

RegisterNetEvent("ranch:environment:updated", function(state)
    if UIOpen then
        updateUIData('environment', state)
        
        -- Also update header info
        SendNUIMessage({
            action = 'updateEnvironment',
            environment = state
        })
    end
end)

RegisterNetEvent("ranch:progression:updated", function(ranchId, profile)
    if UIOpen and ranchId == currentRanchId then
        updateUIData('progression', profile)
    end
end)

-- Activity notifications
RegisterNetEvent("ranch:ui:addActivity", function(activity)
    if UIOpen then
        SendNUIMessage({
            action = 'addActivity',
            activity = activity
        })
    end
end)

-- Show notification in UI
RegisterNetEvent("ranch:ui:notify", function(message, type)
    if UIOpen then
        SendNUIMessage({
            action = 'showNotification',
            message = message,
            type = type or 'info'
        })
    end
end)

-- Export UI functions
exports('OpenRanchUI', openRanchUI)
exports('CloseRanchUI', closeRanchUI)
exports('IsUIOpen', function() return UIOpen end)

debugPrint("Ranch UI Client loaded successfully")
