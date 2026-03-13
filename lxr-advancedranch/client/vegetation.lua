local Config = require("shared.config")

local function applyVegetation(zone)
    if not zone or not zone.points then return end
    local density = zone.vegetation or Config.ZoneDefaults.VegetationState
    local fertility = zone.fertility or Config.ZoneDefaults.SoilFertility

    -- Placeholder vegetation adjustments, to be swapped with server-specific natives
    SetForceVehicleTrails(false)
    Citizen.InvokeNative(0xAA6A47A573ABB75A, density) -- SET_GRASS_CULL_SPHERICAL_RADIUS fallback
    Citizen.InvokeNative(0xD6BD313CFA41E57A, fertility) -- _SET_SNOW_COVERAGE_TYPE fallback
end

AddEventHandler("ranch:vegetation:updated", function(_, zone)
    applyVegetation(zone)
end)

AddEventHandler("ranch:vegetation:bulkUpdated", function(zones)
    for _, zone in pairs(zones or {}) do
        applyVegetation(zone)
    end
end)
