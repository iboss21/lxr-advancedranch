-- ─────────────────────────────────────────────────────────────────────────────
-- Ranch Admin Menu  (client/admin_menu.lua)
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Provides a unified ox_lib context-menu interface for:
--   • Server Admins  — create / delete / transfer ranches, set season / weather,
--                      generate contracts, assign workers, create tasks, grant XP.
--   • Ranch Owners   — manage their own ranches: place props (gyzmo), create zones,
--                      add livestock, queue hazards, grant XP to own ranch.
--
-- Opens via  /ranchadmin  command  or the configured keybind (default F6).
-- ─────────────────────────────────────────────────────────────────────────────

-- Guard: feature disabled in config
if not Config.AdminMenu or not Config.AdminMenu.Enabled then
    return
end

-- ── State ─────────────────────────────────────────────────────────────────────
local isAdmin          = false
local ownedRanches     = {}   -- { { id = '...', name = '...' }, ... }
local permissionsReady = false

-- Pre-computed species hint string for the Add Animal dialog (built once on load).
local speciesHint = (function()
    local s = {}
    if Config.Livestock and Config.Livestock.Species then
        for k in pairs(Config.Livestock.Species) do s[#s + 1] = k end
        table.sort(s)
    end
    return table.concat(s, " | ")
end)()

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function notify(msg, msgType)
    if lib and lib.notify then
        lib.notify({ title = 'Ranch', description = msg, type = msgType or 'inform' })
    else
        TriggerEvent("chat:addMessage", { args = { "Ranch", msg } })
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Server → client: receive permissions
-- ─────────────────────────────────────────────────────────────────────────────

RegisterNetEvent("ranch:admin:permissions", function(admin, ranches)
    isAdmin          = not not admin
    ownedRanches     = ranches or {}
    permissionsReady = true
end)

-- Request permissions shortly after spawn / resource start
Citizen.CreateThread(function()
    Citizen.Wait(4000)
    TriggerServerEvent("ranch:admin:getPermissions")
end)

AddEventHandler("onClientResourceStart", function(name)
    if name == GetCurrentResourceName() then
        Citizen.SetTimeout(4000, function()
            TriggerServerEvent("ranch:admin:getPermissions")
        end)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Sub-menus
-- ─────────────────────────────────────────────────────────────────────────────

local function openPropMenu(ranch)
    local opts = {}

    for model, info in pairs(Config.Props.UsableProps) do
        local m, r = model, ranch   -- capture for closure
        table.insert(opts, {
            title       = info.label or m,
            description = "Model: " .. m .. "  |  Type: " .. (info.type or "prop"),
            icon        = "cubes",
            onSelect    = function()
                TriggerEvent("ranch:props:placeFromMenu", r.id, m)
                notify("Spawning " .. (info.label or m) .. " — use gyzmo / arrow keys to position.")
            end
        })
    end

    table.sort(opts, function(a, b) return a.title < b.title end)

    table.insert(opts, {
        title       = "Clear All Props",
        description = "Remove every prop placed on this ranch",
        icon        = "trash",
        onSelect    = function()
            ExecuteCommand(Config.Props.RemoverCommand .. " " .. ranch.id)
        end
    })

    lib.registerContext({
        id      = "ranch_prop_menu_" .. ranch.id,
        title   = "🪵 Place Prop — " .. ranch.name,
        menu    = "ranch_owner_menu_" .. ranch.id,
        options = opts
    })
    lib.showContext("ranch_prop_menu_" .. ranch.id)
end

local function openAnimalMenu(ranch, adminOverride)
    local opts   = {}
    local ranchId = ranch.id

    for species, info in pairs(Config.Livestock.Species) do
        local s, label = species, (info.label or species)
        table.insert(opts, {
            title       = label,
            description = "Add 1 " .. label .. " to " .. ranch.name,
            icon        = "paw",
            onSelect    = function()
                TriggerServerEvent("ranch:admin:addAnimal", ranchId, s, 1)
                notify("Adding " .. label .. " to " .. ranch.name .. "…")
            end
        })
    end

    table.sort(opts, function(a, b) return a.title < b.title end)

    local parentId = adminOverride
        and "ranch_admin_menu"
        or  "ranch_owner_menu_" .. ranch.id

    lib.registerContext({
        id      = "ranch_animal_menu_" .. ranchId,
        title   = "🐄 Add Animal — " .. ranch.name,
        menu    = parentId,
        options = opts
    })
    lib.showContext("ranch_animal_menu_" .. ranchId)
end

local function openSeasonMenu()
    lib.registerContext({
        id      = "ranch_season_menu",
        title   = "🌿 Set Season",
        menu    = "ranch_admin_menu",
        options = {
            { title = "Spring", icon = "seedling",  onSelect = function() TriggerServerEvent("ranch:admin:setSeason", "spring") end },
            { title = "Summer", icon = "sun",        onSelect = function() TriggerServerEvent("ranch:admin:setSeason", "summer") end },
            { title = "Autumn", icon = "leaf",       onSelect = function() TriggerServerEvent("ranch:admin:setSeason", "autumn") end },
            { title = "Winter", icon = "snowflake",  onSelect = function() TriggerServerEvent("ranch:admin:setSeason", "winter") end },
        }
    })
    lib.showContext("ranch_season_menu")
end

local function openHazardMenu(ranch, parentMenuId)
    local opts = {}

    for key, info in pairs(Config.Environment.Hazards) do
        local k = key
        table.insert(opts, {
            title       = k:sub(1, 1):upper() .. k:sub(2),
            description = info.notification or k,
            icon        = "bolt",
            onSelect    = function()
                TriggerServerEvent("ranch:admin:queueHazard", k, ranch and ranch.id or nil)
                notify("Hazard queued: " .. k)
            end
        })
    end

    table.sort(opts, function(a, b) return a.title < b.title end)

    lib.registerContext({
        id      = "ranch_hazard_menu",
        title   = "⚡ Queue Hazard" .. (ranch and (" — " .. ranch.name) or ""),
        menu    = parentMenuId or "ranch_admin_menu",
        options = opts
    })
    lib.showContext("ranch_hazard_menu")
end

-- Per-ranch owner actions menu
local function openOwnerMenu(ranch)
    local opts = {
        {
            title       = "Open Ranch UI",
            description = "Open the full ranch management dashboard",
            icon        = "chart-bar",
            onSelect    = function()
                ExecuteCommand("ranchui " .. ranch.id)
            end
        },
        {
            title       = "Place Prop",
            description = "Spawn and interactively position a ranch prop" .. (Config.AdminMenu.UseGyzmo and " (gyzmo)" or " (arrow keys)"),
            icon        = "cubes",
            onSelect    = function()
                openPropMenu(ranch)
            end
        },
        {
            title       = "Create Zone",
            description = "Begin zone-creation for this ranch (Left-Alt to mark points)",
            icon        = "draw-polygon",
            onSelect    = function()
                ExecuteCommand("pzcreate " .. ranch.id)
                notify("Zone creation started for " .. ranch.name .. ". Left-Alt = add point, Enter = save.")
            end
        },
        {
            title       = "Add Animal",
            description = "Add a livestock animal to this ranch",
            icon        = "paw",
            onSelect    = function()
                openAnimalMenu(ranch, false)
            end
        },
        {
            title       = "Queue Hazard",
            description = "Manually trigger an environmental hazard on this ranch",
            icon        = "bolt",
            onSelect    = function()
                openHazardMenu(ranch, "ranch_owner_menu_" .. ranch.id)
            end
        },
        {
            title       = "Grant XP",
            description = "Award experience points to this ranch",
            icon        = "star",
            onSelect    = function()
                local input = lib.inputDialog("Grant XP — " .. ranch.name, {
                    { type = "number", label = "XP Amount", required = true, min = 1, max = 9999 }
                })
                if input and input[1] then
                    TriggerServerEvent("ranch:admin:grantXP", ranch.id, tonumber(input[1]))
                    notify("Granting " .. input[1] .. " XP to " .. ranch.name)
                end
            end
        },
    }

    lib.registerContext({
        id      = "ranch_owner_menu_" .. ranch.id,
        title   = "🏡 " .. ranch.name,
        menu    = "ranch_admin_menu",
        options = opts
    })
    lib.showContext("ranch_owner_menu_" .. ranch.id)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Main admin menu
-- ─────────────────────────────────────────────────────────────────────────────

local function openRanchAdminMenu()
    if not permissionsReady then
        -- Trigger a background refresh and inform the player to retry.
        TriggerServerEvent("ranch:admin:getPermissions")
        notify("Loading permissions — please try again in a moment.", "warning")
        return
    end

    if not isAdmin and #ownedRanches == 0 then
        notify("You do not have permission to access the Ranch Admin menu.", "error")
        return
    end

    local opts = {}

    -- ── Server Admin actions ─────────────────────────────────────────────────
    if isAdmin then
        table.insert(opts, {
            title    = "── Admin Actions ──",
            disabled = true
        })

        -- Create Ranch
        table.insert(opts, {
            title       = "Create Ranch",
            description = "Register a new ranch, optionally assigned to a player",
            icon        = "plus",
            onSelect    = function()
                local input = lib.inputDialog("Create Ranch", {
                    { type = "input", label = "Ranch Name",                  required = true  },
                    { type = "input", label = "Owner Identifier (optional)", required = false }
                })
                if input and input[1] and input[1] ~= "" then
                    local ownerArg = (input[2] and input[2] ~= "") and input[2] or nil
                    TriggerServerEvent("ranch:admin:create", input[1], ownerArg)
                    notify("Creating ranch: " .. input[1])
                end
            end
        })

        -- Delete Ranch
        table.insert(opts, {
            title       = "Delete Ranch",
            description = "Permanently remove a ranch and all its data",
            icon        = "trash",
            onSelect    = function()
                local input = lib.inputDialog("Delete Ranch", {
                    { type = "input", label = "Ranch ID", required = true }
                })
                if input and input[1] and input[1] ~= "" then
                    TriggerServerEvent("ranch:admin:delete", input[1])
                    notify("Deleting ranch: " .. input[1])
                end
            end
        })

        -- Transfer Ranch
        table.insert(opts, {
            title       = "Transfer Ranch",
            description = "Transfer ownership of a ranch to another player",
            icon        = "exchange-alt",
            onSelect    = function()
                local input = lib.inputDialog("Transfer Ranch", {
                    { type = "input", label = "Ranch ID",             required = true },
                    { type = "input", label = "New Owner Identifier", required = true }
                })
                if input and input[1] and input[1] ~= "" and input[2] and input[2] ~= "" then
                    TriggerServerEvent("ranch:admin:transfer", input[1], input[2])
                    notify("Transferring " .. input[1] .. " to " .. input[2])
                end
            end
        })

        -- Set Season
        table.insert(opts, {
            title       = "Set Season",
            description = "Change the current season for all ranches",
            icon        = "calendar-alt",
            onSelect    = openSeasonMenu
        })

        -- Roll Weather
        table.insert(opts, {
            title       = "Roll Weather",
            description = "Randomise the current weather pattern",
            icon        = "cloud-sun-rain",
            onSelect    = function()
                TriggerServerEvent("ranch:admin:rollWeather")
                notify("Weather pattern rolled.")
            end
        })

        -- Queue Hazard (global / no specific ranch)
        table.insert(opts, {
            title       = "Queue Hazard",
            description = "Trigger an environmental hazard (server-wide or targeted)",
            icon        = "bolt",
            onSelect    = function()
                openHazardMenu(nil, "ranch_admin_menu")
            end
        })

        -- Add Animal (specify ranch by ID)
        table.insert(opts, {
            title       = "Add Animal",
            description = "Add livestock to any ranch by ID",
            icon        = "paw",
            onSelect    = function()
                local input = lib.inputDialog("Add Animal", {
                    { type = "input",  label = "Ranch ID",  required = true },
                    { type = "input",  label = "Species",   required = true,
                      description = speciesHint },
                    { type = "number", label = "Count",     required = false, min = 1, max = 99 }
                })
                if input and input[1] ~= "" and input[2] ~= "" then
                    TriggerServerEvent("ranch:admin:addAnimal", input[1], input[2], tonumber(input[3]) or 1)
                    notify("Adding " .. (input[3] or 1) .. "x " .. input[2] .. " to " .. input[1])
                end
            end
        })

        -- Assign Worker
        table.insert(opts, {
            title       = "Assign Worker",
            description = "Add a player to a ranch workforce roster",
            icon        = "user-plus",
            onSelect    = function()
                local input = lib.inputDialog("Assign Worker", {
                    { type = "input", label = "Ranch ID",              required = true },
                    { type = "input", label = "Player Identifier",     required = true },
                    { type = "input", label = "Role",                  required = true,
                      description = "Owner | Foreman | Hand | Wrangler | Dairyman | Butcher | Vet | Teamster" }
                })
                if input and input[1] ~= "" and input[2] ~= "" and input[3] ~= "" then
                    TriggerServerEvent("ranch:admin:assignWorker", input[1], input[2], input[3])
                    notify("Worker assigned to " .. input[1])
                end
            end
        })

        -- Create Task
        table.insert(opts, {
            title       = "Create Task",
            description = "Post a task on a ranch task board",
            icon        = "tasks",
            onSelect    = function()
                local input = lib.inputDialog("Create Task", {
                    { type = "input", label = "Ranch ID",  required = true },
                    { type = "input", label = "Task Type", required = true,
                      description = "feeding | watering | mucking | milking | fenceRepair | herding" }
                })
                if input and input[1] ~= "" and input[2] ~= "" then
                    TriggerServerEvent("ranch:admin:createTask", input[1], input[2])
                    notify("Task created for " .. input[1])
                end
            end
        })

        -- Generate Contract
        table.insert(opts, {
            title       = "Generate Contract",
            description = "Immediately generate a new trade contract",
            icon        = "file-contract",
            onSelect    = function()
                TriggerServerEvent("ranch:admin:generateContract")
                notify("Contract generation requested.")
            end
        })

        -- Grant XP (by ranch ID)
        table.insert(opts, {
            title       = "Grant XP",
            description = "Award experience to any ranch by ID",
            icon        = "star",
            onSelect    = function()
                local input = lib.inputDialog("Grant XP", {
                    { type = "input",  label = "Ranch ID", required = true },
                    { type = "number", label = "XP Amount", required = true, min = 1, max = 99999 }
                })
                if input and input[1] ~= "" and input[2] then
                    TriggerServerEvent("ranch:admin:grantXP", input[1], tonumber(input[2]))
                    notify("Granting " .. input[2] .. " XP to " .. input[1])
                end
            end
        })
    end

    -- ── Owned Ranch section ──────────────────────────────────────────────────
    if #ownedRanches > 0 then
        table.insert(opts, {
            title    = "── My Ranches ──",
            disabled = true
        })

        for _, ranch in ipairs(ownedRanches) do
            local r = ranch  -- capture for closure
            table.insert(opts, {
                title       = r.name,
                description = "Ranch ID: " .. r.id,
                icon        = "home",
                onSelect    = function()
                    openOwnerMenu(r)
                end
            })
        end
    end

    lib.registerContext({
        id      = "ranch_admin_menu",
        title   = "🐺 Ranch Admin",
        options = opts
    })
    lib.showContext("ranch_admin_menu")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Command + keybind
-- ─────────────────────────────────────────────────────────────────────────────

RegisterCommand(Config.AdminMenu.Command, function()
    openRanchAdminMenu()
end, false)

RegisterKeyMapping(
    Config.AdminMenu.Command,
    "Open Ranch Admin Menu",
    "keyboard",
    Config.AdminMenu.Keybind
)
