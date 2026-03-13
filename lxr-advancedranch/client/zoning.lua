local Config = require("shared.config")

local creatingZone = false
local zonePoints = {}
local zoneId = nil

local function notify(msg)
    TriggerEvent("chat:addMessage", { args = { "Ranch", msg } })
end

local function reset()
    creatingZone = false
    zonePoints = {}
    zoneId = nil
end

local function startZoneCreation(id)
    if creatingZone then
        notify("Already creating a zone. Use /" .. Config.Zoning.CancelCommand .. " to reset.")
        return
    end
    creatingZone = true
    zoneId = id or ("zone_%s"):format(math.random(1000, 9999))
    zonePoints = {}
    notify("Zone creation started. Use Left Alt to capture points, Enter to save, Backspace to cancel.")
end

local function saveZone()
    if #zonePoints < 3 then
        notify("Need at least 3 points for a zone.")
        return
    end
    TriggerServerEvent("ranch:zones:save", zoneId, {
        id = zoneId,
        points = zonePoints,
        vegetation = Config.ZoneDefaults.VegetationState,
        wildlife = Config.ZoneDefaults.WildlifeDensity,
        fertility = Config.ZoneDefaults.SoilFertility,
        irrigation = Config.ZoneDefaults.IrrigationLevel,
        pest = Config.ZoneDefaults.PestPressure,
        rotation = Config.ZoneDefaults.GrazingRotationDays
    })
    notify("Zone saved: " .. zoneId)
    reset()
end

local function cancelZone()
    notify("Zone creation cancelled.")
    reset()
end

local function addPoint()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    table.insert(zonePoints, { x = coords.x, y = coords.y, z = coords.z })
    notify("Point added (#" .. #zonePoints .. ")")
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if creatingZone then
            if IsControlJustPressed(0, 19) then -- Left Alt
                addPoint()
            elseif IsControlJustPressed(0, 191) then -- Enter
                saveZone()
            elseif IsControlJustPressed(0, 177) then -- Backspace
                cancelZone()
            end
        end
    end
end)

RegisterCommand(Config.Zoning.CreatorCommand, function(_, args)
    startZoneCreation(args[1])
end, false)

RegisterCommand(Config.Zoning.CancelCommand, function()
    cancelZone()
end, false)

RegisterCommand(Config.Zoning.SaveCommand, function()
    saveZone()
end, false)
