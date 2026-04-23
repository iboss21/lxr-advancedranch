-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 lxr-advancedranch — wolves.land / The Lux Empire
-- Standalone SQL schema — use only if you disable `Config.Database.autoMigrate`
-- and wish to create tables manually.
--
-- Adjust the `lxr_ranch_` prefix below to match `Config.Database.prefix`.
--
-- MariaDB 10.4+ / MySQL 8+ / InnoDB / utf8mb4
-- © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════

-- ═════════════════════════════════════════════════════════════
--  RANCHES
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_ranches` (
    `id`              VARCHAR(40)  NOT NULL PRIMARY KEY,
    `label`           VARCHAR(80)  NOT NULL,
    `owner_id`        VARCHAR(80)  DEFAULT NULL,
    `center_x`        FLOAT        NOT NULL,
    `center_y`        FLOAT        NOT NULL,
    `center_z`        FLOAT        NOT NULL,
    `heading`         FLOAT        DEFAULT 0,
    `radius`          FLOAT        DEFAULT 120.0,
    `tier`            TINYINT      DEFAULT 1,
    `balance`         INT          DEFAULT 0,
    `xp`              INT          DEFAULT 0,
    `discord_role_id` VARCHAR(40)  DEFAULT NULL,
    `meta`            LONGTEXT     DEFAULT NULL,
    `created_at`      INT          NOT NULL,
    `updated_at`      INT          NOT NULL,
    INDEX `idx_owner` (`owner_id`),
    INDEX `idx_tier`  (`tier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  ANIMALS
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_animals` (
    `id`              VARCHAR(40)  NOT NULL PRIMARY KEY,
    `ranch_id`        VARCHAR(40)  NOT NULL,
    `species`         VARCHAR(32)  NOT NULL,
    `name`            VARCHAR(80)  DEFAULT NULL,
    `sex`             ENUM('m','f') NOT NULL DEFAULT 'f',
    `health`          INT          DEFAULT 100,
    `hunger`          INT          DEFAULT 0,
    `thirst`          INT          DEFAULT 0,
    `cleanliness`     INT          DEFAULT 100,
    `trust`           INT          DEFAULT 50,
    `age_days`        INT          DEFAULT 0,
    `born_at`         INT          NOT NULL,
    `traits`          VARCHAR(255) DEFAULT NULL,
    `bloodline`       VARCHAR(80)  DEFAULT NULL,
    `last_bred`       INT          DEFAULT 0,
    `pregnant_until`  INT          DEFAULT NULL,
    `last_product_at` INT          DEFAULT 0,
    `meta`            LONGTEXT     DEFAULT NULL,
    `updated_at`      INT          NOT NULL,
    INDEX `idx_ranch`   (`ranch_id`),
    INDEX `idx_species` (`species`),
    CONSTRAINT `fk_animal_ranch` FOREIGN KEY (`ranch_id`)
        REFERENCES `lxr_ranch_ranches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  WORKFORCE
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_workforce` (
    `id`         INT          AUTO_INCREMENT PRIMARY KEY,
    `ranch_id`   VARCHAR(40)  NOT NULL,
    `identifier` VARCHAR(80)  NOT NULL,
    `name`       VARCHAR(80)  DEFAULT NULL,
    `role`       VARCHAR(40)  NOT NULL,
    `morale`     INT          DEFAULT 70,
    `fatigue`    INT          DEFAULT 0,
    `hired_at`   INT          NOT NULL,
    `last_paid`  INT          DEFAULT 0,
    `meta`       LONGTEXT     DEFAULT NULL,
    INDEX `idx_ranch` (`ranch_id`),
    INDEX `idx_ident` (`identifier`),
    UNIQUE KEY `uq_ranch_ident` (`ranch_id`, `identifier`),
    CONSTRAINT `fk_workforce_ranch` FOREIGN KEY (`ranch_id`)
        REFERENCES `lxr_ranch_ranches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  CONTRACTS
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_contracts` (
    `id`         VARCHAR(40) NOT NULL PRIMARY KEY,
    `town`       VARCHAR(40) NOT NULL,
    `good`       VARCHAR(40) NOT NULL,
    `amount`     INT         NOT NULL,
    `reward`     INT         NOT NULL,
    `deadline`   INT         NOT NULL,
    `assigned`   VARCHAR(80) DEFAULT NULL,
    `status`     ENUM('open','active','completed','expired','failed') DEFAULT 'open',
    `created_at` INT         NOT NULL,
    INDEX `idx_status`   (`status`),
    INDEX `idx_assigned` (`assigned`),
    INDEX `idx_town`     (`town`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  AUCTIONS
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_auctions` (
    `id`          VARCHAR(40) NOT NULL PRIMARY KEY,
    `ranch_id`    VARCHAR(40) NOT NULL,
    `lot_type`    VARCHAR(32) NOT NULL,
    `lot_ref`     VARCHAR(80) NOT NULL,
    `seller`      VARCHAR(80) NOT NULL,
    `start_bid`   INT         NOT NULL,
    `current_bid` INT         NOT NULL,
    `high_bidder` VARCHAR(80) DEFAULT NULL,
    `deadline`    INT         NOT NULL,
    `status`      ENUM('live','sold','unsold','void','cancelled') DEFAULT 'live',
    `meta`        LONGTEXT    DEFAULT NULL,
    `created_at`  INT         NOT NULL,
    INDEX `idx_status` (`status`),
    INDEX `idx_ranch`  (`ranch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  ZONES
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_zones` (
    `id`         VARCHAR(40) NOT NULL PRIMARY KEY,
    `ranch_id`   VARCHAR(40) NOT NULL,
    `zone_type`  VARCHAR(32) NOT NULL,
    `vertices`   LONGTEXT    NOT NULL,
    `created_by` VARCHAR(80) DEFAULT NULL,
    `created_at` INT         NOT NULL,
    INDEX `idx_ranch` (`ranch_id`),
    CONSTRAINT `fk_zone_ranch` FOREIGN KEY (`ranch_id`)
        REFERENCES `lxr_ranch_ranches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  PROPS
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_props` (
    `id`        VARCHAR(40) NOT NULL PRIMARY KEY,
    `ranch_id`  VARCHAR(40) NOT NULL,
    `model`     VARCHAR(80) NOT NULL,
    `x`         FLOAT       NOT NULL,
    `y`         FLOAT       NOT NULL,
    `z`         FLOAT       NOT NULL,
    `heading`   FLOAT       DEFAULT 0,
    `placed_by` VARCHAR(80) DEFAULT NULL,
    `placed_at` INT         NOT NULL,
    INDEX `idx_ranch` (`ranch_id`),
    CONSTRAINT `fk_prop_ranch` FOREIGN KEY (`ranch_id`)
        REFERENCES `lxr_ranch_ranches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  ENVIRONMENT (key-value world state)
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_environment` (
    `k` VARCHAR(64) NOT NULL PRIMARY KEY,
    `v` LONGTEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  PROGRESSION
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_progression` (
    `identifier`   VARCHAR(80) NOT NULL PRIMARY KEY,
    `skills`       LONGTEXT    DEFAULT NULL,
    `achievements` LONGTEXT    DEFAULT NULL,
    `stats`        LONGTEXT    DEFAULT NULL,
    `updated_at`   INT         NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═════════════════════════════════════════════════════════════
--  LEDGER
-- ═════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `lxr_ranch_ledger` (
    `id`          INT          AUTO_INCREMENT PRIMARY KEY,
    `ranch_id`    VARCHAR(40)  NOT NULL,
    `kind`        VARCHAR(40)  NOT NULL,
    `amount`      INT          NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `actor`       VARCHAR(80)  DEFAULT NULL,
    `ts`          INT          NOT NULL,
    INDEX `idx_ranch` (`ranch_id`),
    INDEX `idx_kind`  (`kind`),
    CONSTRAINT `fk_ledger_ranch` FOREIGN KEY (`ranch_id`)
        REFERENCES `lxr_ranch_ranches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
