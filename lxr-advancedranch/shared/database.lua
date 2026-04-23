--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 lxr-advancedranch — The Land of Wolves — Database Layer
     ═══════════════════════════════════════════════════════════════════════════
     MariaDB persistence with oxmysql. JSON fallback available for dev servers.
     Server-only module — do NOT client-require.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / The Lux Empire — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if not IsDuplicityVersion() then return end

DB = DB or {}
DB.Ready = false

local prefix = (Config and Config.Database and Config.Database.prefix) or 'lxr_ranch_'
local mode   = (Config and Config.Database and Config.Database.mode)   or 'mysql'

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 SCHEMA — auto-created on boot if Config.Database.autoMigrate
-- ═══════════════════════════════════════════════════════════════════════════════

local SCHEMA = {
    ranches = [[
        CREATE TABLE IF NOT EXISTS `%sranches` (
            `id` VARCHAR(40) NOT NULL PRIMARY KEY,
            `label` VARCHAR(80) NOT NULL,
            `owner_id` VARCHAR(80) DEFAULT NULL,
            `center_x` FLOAT NOT NULL,
            `center_y` FLOAT NOT NULL,
            `center_z` FLOAT NOT NULL,
            `heading` FLOAT DEFAULT 0,
            `radius` FLOAT DEFAULT 120.0,
            `tier` TINYINT DEFAULT 1,
            `balance` INT DEFAULT 0,
            `xp` INT DEFAULT 0,
            `discord_role_id` VARCHAR(40) DEFAULT NULL,
            `meta` LONGTEXT DEFAULT NULL,
            `created_at` INT NOT NULL,
            `updated_at` INT NOT NULL,
            INDEX `idx_owner` (`owner_id`),
            INDEX `idx_tier` (`tier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    animals = [[
        CREATE TABLE IF NOT EXISTS `%sanimals` (
            `id` VARCHAR(40) NOT NULL PRIMARY KEY,
            `ranch_id` VARCHAR(40) NOT NULL,
            `species` VARCHAR(32) NOT NULL,
            `name` VARCHAR(80) DEFAULT NULL,
            `sex` ENUM('m','f') NOT NULL DEFAULT 'f',
            `health` INT DEFAULT 100,
            `hunger` INT DEFAULT 0,
            `thirst` INT DEFAULT 0,
            `cleanliness` INT DEFAULT 100,
            `trust` INT DEFAULT 50,
            `age_days` INT DEFAULT 0,
            `born_at` INT NOT NULL,
            `traits` VARCHAR(255) DEFAULT NULL,
            `bloodline` VARCHAR(80) DEFAULT NULL,
            `last_bred` INT DEFAULT 0,
            `pregnant_until` INT DEFAULT NULL,
            `last_product_at` INT DEFAULT 0,
            `meta` LONGTEXT DEFAULT NULL,
            `updated_at` INT NOT NULL,
            INDEX `idx_ranch` (`ranch_id`),
            INDEX `idx_species` (`species`),
            CONSTRAINT `fk_animal_ranch` FOREIGN KEY (`ranch_id`)
                REFERENCES `%sranches` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    workforce = [[
        CREATE TABLE IF NOT EXISTS `%sworkforce` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `ranch_id` VARCHAR(40) NOT NULL,
            `identifier` VARCHAR(80) NOT NULL,
            `name` VARCHAR(80) DEFAULT NULL,
            `role` VARCHAR(40) NOT NULL,
            `morale` INT DEFAULT 70,
            `fatigue` INT DEFAULT 0,
            `hired_at` INT NOT NULL,
            `last_paid` INT DEFAULT 0,
            `meta` LONGTEXT DEFAULT NULL,
            INDEX `idx_ranch` (`ranch_id`),
            INDEX `idx_ident` (`identifier`),
            UNIQUE KEY `uq_ranch_ident` (`ranch_id`, `identifier`),
            CONSTRAINT `fk_workforce_ranch` FOREIGN KEY (`ranch_id`)
                REFERENCES `%sranches` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    contracts = [[
        CREATE TABLE IF NOT EXISTS `%scontracts` (
            `id` VARCHAR(40) NOT NULL PRIMARY KEY,
            `town` VARCHAR(40) NOT NULL,
            `good` VARCHAR(40) NOT NULL,
            `amount` INT NOT NULL,
            `reward` INT NOT NULL,
            `deadline` INT NOT NULL,
            `assigned` VARCHAR(80) DEFAULT NULL,
            `status` ENUM('open','active','completed','expired','failed') DEFAULT 'open',
            `created_at` INT NOT NULL,
            INDEX `idx_status` (`status`),
            INDEX `idx_assigned` (`assigned`),
            INDEX `idx_town` (`town`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    auctions = [[
        CREATE TABLE IF NOT EXISTS `%sauctions` (
            `id` VARCHAR(40) NOT NULL PRIMARY KEY,
            `ranch_id` VARCHAR(40) NOT NULL,
            `lot_type` VARCHAR(32) NOT NULL,
            `lot_ref` VARCHAR(80) NOT NULL,
            `seller` VARCHAR(80) NOT NULL,
            `start_bid` INT NOT NULL,
            `current_bid` INT NOT NULL,
            `high_bidder` VARCHAR(80) DEFAULT NULL,
            `deadline` INT NOT NULL,
            `status` ENUM('live','sold','unsold','void','cancelled') DEFAULT 'live',
            `meta` LONGTEXT DEFAULT NULL,
            `created_at` INT NOT NULL,
            INDEX `idx_status` (`status`),
            INDEX `idx_ranch` (`ranch_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    zones = [[
        CREATE TABLE IF NOT EXISTS `%szones` (
            `id` VARCHAR(40) NOT NULL PRIMARY KEY,
            `ranch_id` VARCHAR(40) NOT NULL,
            `zone_type` VARCHAR(32) NOT NULL,
            `vertices` LONGTEXT NOT NULL,
            `created_by` VARCHAR(80) DEFAULT NULL,
            `created_at` INT NOT NULL,
            INDEX `idx_ranch` (`ranch_id`),
            CONSTRAINT `fk_zone_ranch` FOREIGN KEY (`ranch_id`)
                REFERENCES `%sranches` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    props = [[
        CREATE TABLE IF NOT EXISTS `%sprops` (
            `id` VARCHAR(40) NOT NULL PRIMARY KEY,
            `ranch_id` VARCHAR(40) NOT NULL,
            `model` VARCHAR(80) NOT NULL,
            `x` FLOAT NOT NULL,
            `y` FLOAT NOT NULL,
            `z` FLOAT NOT NULL,
            `heading` FLOAT DEFAULT 0,
            `placed_by` VARCHAR(80) DEFAULT NULL,
            `placed_at` INT NOT NULL,
            INDEX `idx_ranch` (`ranch_id`),
            CONSTRAINT `fk_prop_ranch` FOREIGN KEY (`ranch_id`)
                REFERENCES `%sranches` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    environment = [[
        CREATE TABLE IF NOT EXISTS `%senvironment` (
            `k` VARCHAR(64) NOT NULL PRIMARY KEY,
            `v` LONGTEXT DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    progression = [[
        CREATE TABLE IF NOT EXISTS `%sprogression` (
            `identifier` VARCHAR(80) NOT NULL PRIMARY KEY,
            `skills` LONGTEXT DEFAULT NULL,
            `achievements` LONGTEXT DEFAULT NULL,
            `stats` LONGTEXT DEFAULT NULL,
            `updated_at` INT NOT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    ledger = [[
        CREATE TABLE IF NOT EXISTS `%sledger` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `ranch_id` VARCHAR(40) NOT NULL,
            `kind` VARCHAR(40) NOT NULL,
            `amount` INT NOT NULL,
            `description` VARCHAR(255) DEFAULT NULL,
            `actor` VARCHAR(80) DEFAULT NULL,
            `ts` INT NOT NULL,
            INDEX `idx_ranch` (`ranch_id`),
            INDEX `idx_kind` (`kind`),
            CONSTRAINT `fk_ledger_ranch` FOREIGN KEY (`ranch_id`)
                REFERENCES `%sranches` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 MIGRATION
-- ═══════════════════════════════════════════════════════════════════════════════

local function format2(sql, p)    return sql:format(p, p) end
local function format1(sql, p)    return sql:format(p) end

function DB.Migrate()
    if mode ~= 'mysql' then
        DB.Ready = true
        return true
    end

    if GetResourceState('oxmysql') ~= 'started' then
        print('^1[lxr-advancedranch] oxmysql is not started — falling back to JSON mode^7')
        mode = 'json'
        Config.Database.mode = 'json'
        DB.Ready = true
        return false
    end

    local function run(sql)
        local ok = pcall(function()
            MySQL.query.await(sql)
        end)
        return ok
    end

    local okAll = true
    okAll = run(format1(SCHEMA.ranches,     prefix)) and okAll
    okAll = run(format2(SCHEMA.animals,     prefix)) and okAll
    okAll = run(format2(SCHEMA.workforce,   prefix)) and okAll
    okAll = run(format1(SCHEMA.contracts,   prefix)) and okAll
    okAll = run(format1(SCHEMA.auctions,    prefix)) and okAll
    okAll = run(format2(SCHEMA.zones,       prefix)) and okAll
    okAll = run(format2(SCHEMA.props,       prefix)) and okAll
    okAll = run(format1(SCHEMA.environment, prefix)) and okAll
    okAll = run(format1(SCHEMA.progression, prefix)) and okAll
    okAll = run(format2(SCHEMA.ledger,      prefix)) and okAll

    DB.Ready = okAll
    if okAll then
        print('^2[lxr-advancedranch] Database schema ready (prefix: ' .. prefix .. ')^7')
    else
        print('^1[lxr-advancedranch] Database schema migration had errors^7')
    end
    return okAll
end

function DB.Table(name)
    return prefix .. name
end

function DB.Mode()
    return mode
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 QUERY WRAPPERS
-- ═══════════════════════════════════════════════════════════════════════════════

function DB.Query(sql, params)
    if mode ~= 'mysql' then return {} end
    local ok, result = pcall(function()
        return MySQL.query.await(sql, params or {})
    end)
    if not ok then
        print('^1[lxr-advancedranch] DB.Query error: ' .. tostring(result) .. '^7')
        return {}
    end
    return result or {}
end

function DB.Single(sql, params)
    if mode ~= 'mysql' then return nil end
    local ok, result = pcall(function()
        return MySQL.single.await(sql, params or {})
    end)
    if not ok then return nil end
    return result
end

function DB.Scalar(sql, params)
    if mode ~= 'mysql' then return nil end
    local ok, result = pcall(function()
        return MySQL.scalar.await(sql, params or {})
    end)
    if not ok then return nil end
    return result
end

function DB.Insert(sql, params)
    if mode ~= 'mysql' then return nil end
    local ok, id = pcall(function()
        return MySQL.insert.await(sql, params or {})
    end)
    if not ok then return nil end
    return id
end

function DB.Update(sql, params)
    if mode ~= 'mysql' then return 0 end
    local ok, affected = pcall(function()
        return MySQL.update.await(sql, params or {})
    end)
    if not ok then return 0 end
    return affected or 0
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 JSON FALLBACK STORE (dev servers / mode = 'json')
-- ═══════════════════════════════════════════════════════════════════════════════

DB.Json = {}

local jsonStore = {}

local function loadJsonFile(key)
    local rel = (Config.Database.jsonFallbackPath or 'data/') .. key .. '.json'
    local raw = LoadResourceFile(GetCurrentResourceName(), rel)
    if not raw or raw == '' then return {} end
    local ok, decoded = pcall(json.decode, raw)
    return ok and decoded or {}
end

local function saveJsonFile(key, data)
    local rel = (Config.Database.jsonFallbackPath or 'data/') .. key .. '.json'
    SaveResourceFile(GetCurrentResourceName(), rel, json.encode(data), -1)
end

function DB.Json.Get(key)
    if not jsonStore[key] then jsonStore[key] = loadJsonFile(key) end
    return jsonStore[key]
end

function DB.Json.Set(key, data)
    jsonStore[key] = data
    saveJsonFile(key, data)
end

function DB.Json.Flush()
    for k, v in pairs(jsonStore) do saveJsonFile(k, v) end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════
