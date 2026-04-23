--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Client Admin Helpers

    Thin client companion for admin actions that require client-side context
    (coordinates at current position, notifications to admins only).

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

local resourceName = GetCurrentResourceName()

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ COORD HELPER ██████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterCommand('ranchcoord', function()
    local ped = PlayerPedId()
    local p = GetEntityCoords(ped)
    local h = GetEntityHeading(ped)
    local line = ('vector3(%.2f, %.2f, %.2f) heading %.1f'):format(p.x, p.y, p.z, h)
    print('^3[lxr-advancedranch]^7 ' .. line)
    Framework.Notify(line, 'info', 5000)
end, false)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG VISUALS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local debugRanches = false

RegisterCommand('ranchdebug', function()
    debugRanches = not debugRanches
    Framework.Notify(debugRanches and Framework.L('debug_on') or Framework.L('debug_off'), 'info')
end, false)

CreateThread(function()
    while true do
        if debugRanches and RanchClient and RanchClient.ranches then
            Wait(0)
            for _, r in ipairs(RanchClient.ranches) do
                if r.center_x then
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x6EB7D3BB,
                        r.center_x, r.center_y, r.center_z,
                        r.center_x, r.center_y, r.center_z + 10.0,
                        0.5, 0.0, 201, 168, 76, 160, false, true, 2, false, 0, 0, 0, false)
                end
            end
        else
            Wait(500)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
