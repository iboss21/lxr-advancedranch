--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - Polygon Zone Editor (Client)

    In-world polygon zone drafting tool used by administrators. ENTER drops a
    vertex at the player's current position, BACKSPACE removes the last,
    F9 commits the zone to the server. Active draft is rendered as a wireframe.

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
local function EV(ns, n) return resourceName .. ':' .. ns .. ':' .. n end

local editor = { active = false, id = nil, vertices = {}, zoneType = 'pasture' }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ RENDERING █████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local function drawVertex(v, r, g, b)
    Citizen.InvokeNative(0x2A32FAA57B937173, 0x6EB7D3BB, v.x, v.y, v.z + 1.0,
        v.x, v.y, v.z + 2.0, 0.25, 0.0, r, g, b, 200, false, true, 2, false, 0, 0, 0, false)
end

local function drawLine(a, b, r, g, bl)
    Citizen.InvokeNative(0x2A32FAA57B937173, 0x6EB7D3BB, a.x, a.y, a.z + 0.5,
        b.x, b.y, b.z + 0.5, 0.1, 0.0, r, g, bl, 200, false, true, 2, false, 0, 0, 0, false)
end

CreateThread(function()
    while true do
        if editor.active and #editor.vertices > 0 then
            Wait(0)
            for i = 1, #editor.vertices do drawVertex(editor.vertices[i], 201, 168, 76) end
            for i = 1, #editor.vertices - 1 do
                drawLine(editor.vertices[i], editor.vertices[i + 1], 201, 168, 76)
            end
            if #editor.vertices >= 3 then
                drawLine(editor.vertices[#editor.vertices], editor.vertices[1], 201, 168, 76)
            end
        else
            Wait(500)
        end
    end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ INPUT HANDLER █████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

CreateThread(function()
    while true do
        Wait(0)
        if editor.active then
            -- ENTER = place vertex
            if IsControlJustReleased(0, 0xC7B5340A) then
                local ped = PlayerPedId()
                local p = GetEntityCoords(ped)
                if #editor.vertices < (Config.Zoning.maxVerticesPerZone or 32) then
                    table.insert(editor.vertices, vector3(p.x, p.y, p.z))
                    Framework.Notify(Framework.L('zone_vertex_added', #editor.vertices), 'info')
                else
                    Framework.Notify(Framework.L('zone_vertex_cap'), 'error')
                end
            end
            -- BACKSPACE = pop
            if IsControlJustReleased(0, 0x156F7119) then
                if #editor.vertices > 0 then
                    table.remove(editor.vertices)
                    Framework.Notify(Framework.L('zone_vertex_removed'), 'info')
                end
            end
        else
            Wait(400)
        end
    end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER EVENTS █████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent(EV('server', 'zoneEditorStart'), function(zoneId)
    editor.active = true
    editor.id = zoneId
    editor.vertices = {}
    editor.zoneType = 'pasture'
    Framework.Notify(Framework.L('zone_editor_started'), 'success')
end)

RegisterNetEvent(EV('server', 'zoneEditorSave'), function()
    if not editor.active then return end
    if #editor.vertices < (Config.Zoning.minVerticesPerZone or 3) then
        Framework.Notify(Framework.L('zone_too_few_verts'), 'error')
        return
    end
    local currentRanch = (RanchClient and RanchClient.insideRanch) or nil
    if not currentRanch then
        Framework.Notify(Framework.L('zone_not_on_ranch'), 'error')
        return
    end
    TriggerServerEvent(EV('client', 'zoneSaved'), {
        ranch_id  = currentRanch.id,
        zone_type = editor.zoneType,
        vertices  = editor.vertices
    })
    editor.active = false
    editor.vertices = {}
end)

RegisterNetEvent(EV('server', 'zoneEditorCancel'), function()
    editor.active = false
    editor.vertices = {}
    Framework.Notify(Framework.L('zone_editor_cancelled'), 'info')
end)

RegisterNetEvent(EV('server', 'zoneAdded'), function(_)
    -- Rendering of saved zones is opt-in — skip at client level unless admin toggle is on.
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
