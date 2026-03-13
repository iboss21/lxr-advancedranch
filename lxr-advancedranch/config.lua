--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 LXR Ranch System — Production Configuration

    This is the BUYER CONTROL PANEL. All user-tunable settings live here.
    Gameplay logic, security checks, and internal implementation are protected
    in the server/client/shared folders via Tebex escrow encryption.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:      The Land of Wolves 🐺
    Tagline:     Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
    Description: ისტორია ცოცხლდება აქ! (History Lives Here!)
    Type:        Serious Hardcore Roleplay
    Access:      Discord & Whitelisted

    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io
    Server:      https://servers.redm.net/servers/detail/8gj7eb

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 1.0.0
    Resource: lxr-advancedranch

    Framework Support:
    - LXR Core (Primary)
    - RSG Core (Compatible)
    - VORP Core (Compatible)
    - RedEM:RP (Compatible)
    - QBR Core (Compatible)
    - QR Core (Compatible)
    - Standalone (Fallback)

    ═══════════════════════════════════════════════════════════════════════════════
    IMPORTANT — ESCROW NOTICE
    ═══════════════════════════════════════════════════════════════════════════════

    This file (config.lua) is intentionally NOT escrow-protected.
    It is the buyer's configuration surface. Edit freely.

    The resource name security check, all gameplay logic, framework bridges,
    and anti-abuse systems are located in the protected server/client/shared
    folders. Those files are encrypted and cannot be modified.

    ═══════════════════════════════════════════════════════════════════════════════
    CREDITS
    ═══════════════════════════════════════════════════════════════════════════════

    Script Author: iBoss21 / The Lux Empire for The Land of Wolves
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

Config = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER BRANDING & INFO ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ServerInfo = {
    name        = 'The Land of Wolves 🐺',
    tagline     = 'Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!',
    description = 'ისტორია ცოცხლდება აქ!', -- History Lives Here!
    type        = 'Serious Hardcore Roleplay',
    access      = 'Discord & Whitelisted',

    -- Contact & Links
    website       = 'https://www.wolves.land',
    discord       = 'https://discord.gg/CrKcWdfd3A',
    github        = 'https://github.com/iBoss21',
    store         = 'https://theluxempire.tebex.io',
    serverListing = 'https://servers.redm.net/servers/detail/8gj7eb',

    -- Developer Info
    developer = 'iBoss21 / The Lux Empire',

    -- Tags
    tags = { 'RedM', 'Georgian', 'SeriousRP', 'Whitelist', 'RanchSystem', 'Economy', 'Livestock' }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Priority (in order):
    1. LXR-Core  (Primary)
    2. RSG-Core  (Primary)
    3. VORP Core (Supported)
    4. RedEM:RP  (Optional — if detected)
    5. QBR-Core  (Optional — if detected)
    6. QR-Core   (Optional — if detected)
    7. Standalone (Fallback — minimal functionality)
]]

Config.Framework = 'auto' -- 'auto' | 'lxr-core' | 'rsg-core' | 'vorp_core' | 'redem_roleplay' | 'qbr-core' | 'qr-core' | 'standalone'

Config.FrameworkSettings = {
    ['lxr-core'] = {
        resource      = 'lxr-core',
        notifications = 'ox_lib',
        inventory     = 'lxr-inventory',
        target        = 'ox_target',
        events = {
            server   = 'lxr-core:server:%s',
            client   = 'lxr-core:client:%s',
            callback = 'lxr-core:callback:%s'
        }
    },
    ['rsg-core'] = {
        resource      = 'rsg-core',
        notifications = 'ox_lib',
        inventory     = 'rsg-inventory',
        target        = 'ox_target',
        events = {
            server   = 'RSGCore:Server:%s',
            client   = 'RSGCore:Client:%s',
            callback = 'RSGCore:Callback:%s'
        }
    },
    ['vorp_core'] = {
        resource      = 'vorp_core',
        notifications = 'vorp',
        inventory     = 'vorp_inventory',
        target        = 'vorp_core',
        events = {
            server = 'vorp:server:%s',
            client = 'vorp:client:%s'
        }
    },
    ['redem_roleplay'] = {
        resource      = 'redem_roleplay',
        notifications = 'redem',
        inventory     = 'redem_inventory',
        target        = 'redem_target',
        events = {
            server = 'redem:%s:server',
            client = 'redem:%s:client'
        }
    },
    ['qbr-core'] = {
        resource      = 'qbr-core',
        notifications = 'ox_lib',
        inventory     = 'qbr-inventory',
        target        = 'ox_target',
        events = {
            server = 'QBR:Server:%s',
            client = 'QBR:Client:%s'
        }
    },
    ['qr-core'] = {
        resource      = 'qr-core',
        notifications = 'ox_lib',
        inventory     = 'qr-inventory',
        target        = 'ox_target',
        events = {
            server = 'QR:Server:%s',
            client = 'QR:Client:%s'
        }
    },
    ['standalone'] = {
        notifications = 'print',
        inventory     = 'none',
        target        = 'none'
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE CONFIGURATION ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Lang = 'en' -- Active language: 'en' | 'ka'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG & DEVELOPER FLAGS ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Debug = false -- Enable debug logging (disable on production)

Config.Dev = {
    SkipNameGuard     = false, -- ⚠ NEVER set true in production — bypasses resource name protection
    LogFrameworkInit  = false, -- Log framework detection steps
    VerboseEvents     = false, -- Log all fired events
    DisableRateLimits = false  -- Disable rate-limiting on events (testing only)
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ADMINISTRATION & ACCESS ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Admin = {
    AcePermission            = 'ranch.admin',
    Identifiers              = {
        -- ['license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = true,
    },
    AllowConsole             = true,
    AllowOfflineAssignment   = true,
    CommandRateLimitSeconds  = 2,
    AuditLog = {
        Enabled     = true,
        RollingDays = 30
    }
}

Config.IdentifierPriority = { 'license', 'citizenid', 'cid', 'discord', 'steam' }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DISCORD INTEGRATION ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Discord = {
    UseRoles              = true,
    BotToken              = '',
    GuildId               = '',
    OwnershipRolePrefix   = 'Ranch Owner - ',
    StaffRoleIds          = {},
    AlertChannelId        = '',
    WebhookUrl            = '',
    SyncOnJoin            = true,
    SyncIntervalMinutes   = 15,
    TransferRoleOnSale    = true,
    ArchiveRoleOnDelete   = true
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ STORAGE CONFIGURATION █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Storage = {
    Files = {
        Ranches     = 'data/ranches.json',
        Vegetation  = 'data/vegetation.json',
        Animals     = 'data/animals.json',
        Workforce   = 'data/workforce.json',
        Production  = 'data/production.json',
        Environment = 'data/environment.json',
        Economy     = 'data/economy.json',
        Progression = 'data/progression.json'
    },
    AutoPersistInterval = 120
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ RANCH SETTINGS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Ranches = {
    MaxPerPlayer                 = 4,
    AutoCreateDiscordRoles       = true,
    AllowCitizenIdFallback       = true,
    AllowIdTransferFromSource    = true,
    RequireLandSurveyForExpansion = true,
    ExpansionCostPerAcre         = 125,
    MergeCooldownHours           = 12,
    DefaultMetadata = {
        cleanliness = 0.75,
        feedStores = {
            hay     = 500,
            grain   = 300,
            silage  = 200,
            mineral = 100
        },
        utilities = {
            water        = true,
            windmill     = true,
            smokehouse   = false,
            dairy        = false,
            shearingShed = false,
            coop         = false,
            pigPen       = false
        },
        maintenance = {
            structuralIntegrity = 0.9,
            fireRisk            = 0.2,
            floodRisk           = 0.15,
            predatorRisk        = 0.25
        },
        workforce = {
            morale  = 0.8,
            fatigue = 0.2,
            roster  = {}
        },
        ledger = {
            balance       = 0,
            insuranceTier = 'standard',
            debts         = {},
            contracts     = {}
        }
    },
    Upgrades = {
        barns = {
            { id = 'basic_barn',      capacity = 10, cleanliness = 0.5 },
            { id = 'reinforced_barn', capacity = 20, cleanliness = 0.7 },
            { id = 'sanitized_barn',  capacity = 30, cleanliness = 0.9 }
        },
        coops = {
            { id = 'starter_coop',   capacity = 12, warmth = 0.6 },
            { id = 'insulated_coop', capacity = 24, warmth = 0.8 }
        },
        pens = {
            pigPen  = { id = 'hog_pen',  cleanliness = 0.6, drainage = 0.5 },
            goatPen = { id = 'goat_pen', cleanliness = 0.7, drainage = 0.7 }
        },
        utilities = {
            windmill   = { power = 10, upkeep = 5 },
            waterTower = { capacity = 1000, upkeep = 4 },
            bellTower  = { range = 120, moraleBonus = 0.05 }
        }
    },
    Decorations = {
        signStyles      = { 'Classic', 'Modern', 'Rustic', 'Iron' },
        bannerMaterials = { 'Canvas', 'Leather', 'Silk' },
        lighting        = { 'Lantern', 'OilLamp', 'Electric' },
        fencing         = { 'SplitRail', 'BarbedWire', 'StoneWall', 'Picket' }
    },
    Maintenance = {
        DecayPerDay            = 0.01,
        RepairTools            = { 'hammer', 'saw', 'brush' },
        FireMitigationItems    = { 'bucket', 'pump', 'sandbag' },
        FloodMitigationItems   = { 'sandbag', 'drainageDitch' },
        PredatorMitigationItems = { 'reinforcedFence', 'guardDog', 'trap' }
    },
    Roles = {
        Owner    = { permissions = { 'all' },                                       wageMultiplier = 0    },
        Foreman  = { permissions = { 'assign_tasks', 'hire_fire', 'upgrade' },      wageMultiplier = 1.5  },
        Hand     = { permissions = { 'basic_tasks' },                               wageMultiplier = 1.0  },
        Wrangler = { permissions = { 'handle_horses', 'move_cattle' },              wageMultiplier = 1.2  },
        Dairyman = { permissions = { 'process_dairy' },                             wageMultiplier = 1.1  },
        Butcher  = { permissions = { 'process_meat' },                              wageMultiplier = 1.15 },
        Vet      = { permissions = { 'treat_animals', 'diagnose' },                 wageMultiplier = 1.4  },
        Teamster = { permissions = { 'operate_wagon', 'deliver_goods' },            wageMultiplier = 1.25 }
    },
    Morale = {
        Bonuses = {
            payOnTime      = 0.05,
            goodMeals      = 0.03,
            housingQuality = 0.02,
            eventWins      = 0.08
        },
        Penalties = {
            injuries        = -0.07,
            unpaidWages     = -0.1,
            predatorAttack  = -0.05,
            accidents       = -0.06
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ZONING, VEGETATION & MAPPING ██████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ZoneDefaults = {
    VegetationState     = 1.0,
    WildlifeDensity     = 1.0,
    SoilFertility       = 1.0,
    IrrigationLevel     = 0.5,
    PestPressure        = 0.1,
    GrazingRotationDays = 5
}

Config.Zoning = {
    EnablePZCreate           = true,
    CreatorCommand           = 'pzcreate',
    SaveCommand              = 'pzsave',
    CancelCommand            = 'pzcancel',
    PreviewBlipSprite        = 1873519383,
    PreviewBlipColor         = 0,
    MaxPoints                = 40,
    RequireElevationSamples  = true,
    AutoSnapToTerrain        = true,
    PromptOverrides = {
        start   = 'Press ~INPUT_MULTIPLAYER_INFO~ to add zone points',
        confirm = 'Press ~INPUT_FRONTEND_ACCEPT~ to confirm zone'
    }
}

Config.Props = {
    PlacerCommand  = 'ranchprop',
    RemoverCommand = 'ranchpropdel',
    RotateLeftKey  = 174,
    RotateRightKey = 175,
    ElevateUpKey   = 172,
    ElevateDownKey = 173,
    GridSnapSize   = 0.25,
    UsableProps = {
        ['p_barrel03x']     = { label = 'Water Barrel',    type = 'utility', interactions = { 'Fill', 'Clean' }        },
        ['p_haybale02x']    = { label = 'Hay Bale',        type = 'fodder',  interactions = { 'Pitchfork', 'Stack' }   },
        ['p_trough01x']     = { label = 'Feeding Trough',  type = 'utility', interactions = { 'Fill', 'Scrub' }        },
        ['p_barnlantern01x'] = { label = 'Lantern',        type = 'lighting', interactions = { 'Light', 'Extinguish' } }
    }
}

Config.MappingPrompts = {
    ZoneCreation   = 'Document fence lines, pasture rotations, and hazard zones.',
    PropUsage      = 'Place usable props for immersive chores and task mini-games.',
    VegetationPaint = 'Use vegetation modifiers to express seasonal regrowth and damage.'
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ENVIRONMENT & WORLD STATE █████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Environment = {
    SeasonLengthMinutes = 120,
    SeasonSequence      = { 'spring', 'summer', 'autumn', 'winter' },
    Seasons = {
        spring = { temperature = { min = 40, max = 70 },  precipitationChance = 0.35, floodRisk = 0.2,   cropBonus = 0.15,    pastureRegrowth = 0.25 },
        summer = { temperature = { min = 75, max = 105 }, precipitationChance = 0.1,  droughtRisk = 0.4, cropPenalty = -0.2,  wildfireRisk = 0.3    },
        autumn = { temperature = { min = 50, max = 80 },  precipitationChance = 0.25, harvestBonus = 0.2, ruttingSeason = true, pestMigration = 0.1  },
        winter = { temperature = { min = 5,  max = 35 },  precipitationChance = 0.4,  blizzardRisk = 0.35, feedDemandMultiplier = 1.4, diseaseRisk = 0.25 }
    },
    WeatherPatterns = {
        clear = { weight = 40, duration = { min = 15, max = 45 } },
        rain  = { weight = 25, duration = { min = 10, max = 30 } },
        storm = { weight = 10, duration = { min = 5,  max = 15 }, hazard = 'lightning' },
        snow  = { weight = 15, duration = { min = 10, max = 40 } },
        fog   = { weight = 10, duration = { min = 8,  max = 20 } }
    },
    Hazards = {
        lightning = { ignitionChance = 0.1,  barnFireDamage = 0.25, notification = 'Lightning storm! Secure the barns.',                             randomChance = 0.08 },
        flood     = { livestockRisk = 0.2,   cropDamage = 0.35,     notification = 'Floodwaters rising—move stock to high ground!', debrisSpawn = true, randomChance = 0.05 },
        drought   = { pasturePenalty = 0.5,  milkYieldPenalty = 0.3, waterConsumptionBonus = 0.4, notification = 'Drought settling in. Ration water supplies.', randomChance = 0.06 },
        blizzard  = { feedDemand = 0.5,      frostbiteRisk = 0.2,   structureDamage = 0.15,  notification = 'Blizzard inbound! Shelter animals immediately.', randomChance = 0.04 },
        duststorm = { suffocationRisk = 0.35, buildingDamage = 0.1,  notification = 'Dust storm approaching—cover troughs and bring stock inside!',  randomChance = 0.05 }
    },
    Wildlife = {
        deer    = { curiosityRange = 80,  grazingPenalty = 0.05 },
        wolves  = { raidChanceNight = 0.2, packSize = { 3, 6 } },
        coyotes = { raidChickensChance = 0.3 },
        rodents = { grainSpoilRate = 0.1, deterrent = 'barn_cat' }
    },
    Soil = {
        FertilityDecayPerHarvest = 0.12,
        OvergrazePenalty         = 0.3,
        RecoveryPerManure        = 0.05,
        CropRotationBonus        = 0.2
    },
    Water = {
        BaseConsumptionPerAnimal   = 10,
        DroughtMultiplier          = 1.4,
        FloodContaminationChance   = 0.25
    },
    Astronomy = {
        MeteorShowers  = { enabled = true, frequencyHours = 72, bonus = 'morale' },
        EclipseEvents  = { enabled = true, effect = 'haunted', durationMinutes = 10 }
    },
    AmbientAudio = {
        EnableDynamicTracks = true,
        TrackSets = {
            spring = 'audio/spring_mix.ogg',
            summer = 'audio/summer_mix.ogg',
            autumn = 'audio/autumn_mix.ogg',
            winter = 'audio/winter_mix.ogg'
        }
    },
    UpdateIntervals = {
        WeatherMinutes  = 10,
        HazardMinutes   = 15,
        WildlifeMinutes = 20
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LIVESTOCK, GENETICS & CARE ████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Livestock = {
    NeedsTickMinutes  = 15,
    MemoryDecayMinutes = 120,
    TrustThresholds   = { hostile = 0.2, wary = 0.45, calm = 0.7, bonded = 0.9 },
    Species = {
        cattle   = { label = 'Cattle',      gestationDays = 9,  yields = { milk = 6, beef = 4, manure = 5 },      preferredPasture = 'grass',    genetics = { milkYield = { 0.8, 1.2 }, coatColor = { 'black', 'brown', 'speckled' } }, diseases = { 'hoof_rot', 'pox', 'parasites' }, temperament = { base = 0.6, aggression = 0.3 }, housing = 'barn'          },
        horses   = { label = 'Horse',       gestationDays = 11, yields = { stamina = 1, haul = 1 },               preferredPasture = 'mixed',    genetics = { speed = { 0.85, 1.15 }, temperament = { 'calm', 'fiery', 'bold', 'stubborn' } }, diseases = { 'colic', 'ticks' }, temperament = { base = 0.5, aggression = 0.4 }, housing = 'stable', training = { groundwork = true, riding = true, pulling = true } },
        sheep    = { label = 'Sheep',       gestationDays = 5,  yields = { wool = 8, manure = 2 },                preferredPasture = 'clover',   genetics = { woolQuality = { 0.9, 1.3 }, color = { 'white', 'black', 'brown' } }, diseases = { 'parasites', 'pox' }, temperament = { base = 0.7, aggression = 0.1 }, housing = 'shearing_shed' },
        goats    = { label = 'Goat',        gestationDays = 5,  yields = { milk = 4, meat = 2 },                  preferredPasture = 'brush',    genetics = { milkFat = { 0.9, 1.3 } }, diseases = { 'ticks', 'parasites' }, temperament = { base = 0.65, aggression = 0.2 }, housing = 'goat_pen'     },
        pigs     = { label = 'Pig',         gestationDays = 4,  yields = { meat = 8, fat = 6 },                   preferredPasture = 'mud',      genetics = { marbling = { 0.8, 1.4 } }, diseases = { 'pox', 'parasites' }, temperament = { base = 0.4, aggression = 0.35 }, housing = 'pig_pen'      },
        chickens = { label = 'Chicken',     gestationDays = 1,  yields = { eggs = 12, feathers = 6 },             preferredPasture = 'yard',     genetics = { eggYield = { 0.7, 1.5 }, color = { 'white', 'brown', 'speckled' } }, diseases = { 'pox' }, temperament = { base = 0.8, aggression = 0.05 }, housing = 'coop'          },
        ducks    = { label = 'Duck',        gestationDays = 1,  yields = { eggs = 8, down = 5 },                  preferredPasture = 'pond',     genetics = { eggWeight = { 0.8, 1.4 } }, diseases = { 'parasites' }, temperament = { base = 0.75, aggression = 0.08 }, housing = 'pond'          },
        turkeys  = { label = 'Turkey',      gestationDays = 1,  yields = { meat = 6, feathers = 7 },              preferredPasture = 'orchard',  genetics = { size = { 0.9, 1.4 } }, diseases = { 'pox' }, temperament = { base = 0.55, aggression = 0.25 }, housing = 'yard'          },
        dogs     = { label = 'Dog',         gestationDays = 2,  yields = { loyalty = 1 },                         preferredPasture = 'yard',     genetics = { loyalty = { 0.8, 1.4 } }, diseases = { 'ticks' }, temperament = { base = 0.9, aggression = 0.2 }, housing = 'kennel'        },
        cats     = { label = 'Cat',         gestationDays = 2,  yields = { pestControl = 1 },                     preferredPasture = 'barn',     genetics = { hunting = { 0.9, 1.5 } }, diseases = { 'parasites' }, temperament = { base = 0.85, aggression = 0.15 }, housing = 'barn'         },
        alpaca   = { label = 'Alpaca',      gestationDays = 7,  yields = { fiber = 5 },                           preferredPasture = 'highland', genetics = { fiberLength = { 1.0, 1.4 } }, diseases = { 'parasites' }, temperament = { base = 0.7, aggression = 0.12 }, housing = 'shearing_shed' },
        bees     = { label = 'Bee Colony',  gestationDays = 0,  yields = { honey = 10, wax = 4 },                 preferredPasture = 'orchard',  genetics = { productivity = { 0.8, 1.6 } }, diseases = { 'mites' }, temperament = { base = 0.4, aggression = 0.6 }, housing = 'apiary'        },
        rabbits  = { label = 'Rabbit',      gestationDays = 1,  yields = { fur = 6, meat = 3 },                   preferredPasture = 'burrow',   genetics = { litterSize = { 0.9, 1.5 } }, diseases = { 'parasites' }, temperament = { base = 0.7, aggression = 0.1 }, housing = 'hutch'         }
    },
    Needs = {
        hunger      = { decayPerTick = 0.1,  feedTypes = { hay = true, grain = true } },
        thirst      = { decayPerTick = 0.12, prefersCleanWater = true },
        cleanliness = { decayPerTick = 0.05, bathingRequired = false },
        stress      = { decayPerTick = 0.03, crowdingPenalty = 0.1 },
        social      = { decayPerTick = 0.04, herdAnimals = true },
        temperature = { tolerance = { min = 15, max = 85 }, shelterBonus = 0.25 }
    },
    Breeding = {
        minTrustForBreeding  = 0.6,
        inbreedingPenalty    = 0.35,
        bloodlineBonus       = 0.2,
        complicationChance   = 0.15,
        VetRequiredThreshold = 0.5
    },
    Memory = {
        kindnessBonus      = 0.1,
        mistreatmentPenalty = 0.2,
        treatDecay         = 0.01
    }
}

Config.Healthcare = {
    Diseases = {
        hoof_rot  = { severity = 0.4,  treatment = 'hoof_scrub',        quarantineDays = 2              },
        colic     = { severity = 0.6,  treatment = 'colic_tonic',        vetRequired = true              },
        ticks     = { severity = 0.3,  treatment = 'tick_salve'                                          },
        pox       = { severity = 0.5,  treatment = 'pox_vaccine',        contagious = true               },
        parasites = { severity = 0.45, treatment = 'dewormer'                                             },
        mites     = { severity = 0.25, treatment = 'smoke_fumigation'                                    }
    },
    Injuries = {
        wagon_accident = { severity = 0.5, treatment = 'splint',   recoveryDays = 3                      },
        predator_bite  = { severity = 0.7, treatment = 'stitch',   infectionRisk = 0.4                   },
        broken_leg     = { severity = 0.8, treatment = 'cast',     recoveryDays = 7                      },
        horn_gouge     = { severity = 0.6, treatment = 'bandage',  infectionRisk = 0.3                   }
    },
    Tools = {
        salves     = { 'arnica', 'sage' },
        tonics     = { 'colic_tonic', 'nerve_tonic' },
        poultices  = { 'mud', 'herbal' },
        bandages   = { 'linen', 'leather' },
        splints    = { 'wood', 'iron' },
        vaccines   = { 'pox', 'distemper' },
        hoofPicks  = true,
        horseshoes = { 'iron', 'steel', 'bronze' }
    },
    Farrier = {
        enableMinigame      = true,
        nailTolerance       = 0.2,
        shoeTypes           = { 'standard', 'racing', 'draft', 'ice' },
        visitFrequencyDays  = 14
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WORKFORCE & TASKS █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Workforce = {
    EnableAIHands          = true,
    DailyWageBase          = 8,
    AccidentChance         = 0.08,
    FatiguePerTask         = 0.12,
    RestRecoveryPerHour    = 0.1,
    MoraleDecayPerHour     = 0.02,
    TaskBoard = {
        MaxActiveTasks = 20,
        TaskTypes = {
            feeding     = { durationMinutes = 15, xp = 10 },
            watering    = { durationMinutes = 10, xp = 8  },
            mucking     = { durationMinutes = 20, xp = 12 },
            milking     = { durationMinutes = 30, xp = 15 },
            fenceRepair = { durationMinutes = 25, xp = 14 },
            herding     = { durationMinutes = 35, xp = 18 }
        },
        CooldownMinutes = 30
    },
    Roles = Config.Ranches.Roles
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PRODUCTION & PROCESSING ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ProductionChains = {
    Dairy   = { milkYieldMultiplier = 1.0, butterAgingMinutes = 30, cheeseAgingHours = 24, humidityControl = true },
    Meat    = { primeCutBonus = 0.2, spoilageChance = 0.15, wasteToByproduct = 0.4 },
    Poultry = { incubatorDurationHours = 24, eggGradingQuality = { A = 0.9, B = 0.7, C = 0.5 } },
    Fiber   = { washingLoss = 0.1, dyeingOptions = { 'indigo', 'madder', 'walnut' }, yarnQualityMultiplier = 1.2 },
    Byproducts = {
        manure   = { fertilizerValue = 0.3,  compostTimeHours = 12 },
        bones    = { toolConversionRate = 0.5 },
        hides    = { tanningDurationHours = 16 },
        feathers = { fletchingValue = 0.4 }
    },
    Smoking = {
        jerkyHours = 12,
        baconHours = 10,
        hamHours   = 14,
        woodTypes  = { 'hickory', 'mesquite', 'apple' }
    },
    Brining = {
        sausageHours           = 8,
        saltConsumptionPerBatch = 5
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CROPS & FEED ██████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Crops = {
    Forage = {
        corn    = { growthDays = 5, yield = 40 },
        oats    = { growthDays = 4, yield = 35 },
        clover  = { growthDays = 3, yield = 25 },
        sorghum = { growthDays = 6, yield = 45 },
        alfalfa = { growthDays = 5, yield = 50 }
    },
    Storage = {
        siloCapacity    = 1000,
        spoilagePerDay  = 0.02,
        hayBaleRatsChance = 0.2,
        tarpBonus       = 0.3
    },
    WaterSystems = {
        troughs   = { capacity = 120,  cleanlinessDecay = 0.05 },
        wells     = { replenishPerHour = 40 },
        windmills = { pumpRate = 25 },
        handPumps = { pumpRate = 10 }
    },
    Fertilizer = {
        manure   = { fertilityBonus = 0.15 },
        compost  = { fertilityBonus = 0.2  },
        boneMeal = { fertilityBonus = 0.25 }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LAW, CRIME & REPUTATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Law = {
    Rustling = {
        fenceCutTimeSeconds = 30,
        rebrandTimeSeconds  = 45,
        evidenceChance      = 0.4,
        notifySheriff       = true
    },
    Sheriff = {
        bountyReward             = { min = 25, max = 120 },
        investigationTimeMinutes = 30,
        courtSummonsDays         = 3
    },
    Insurance = {
        tiers = {
            basic    = { premium = 10, payout = 0.4 },
            standard = { premium = 20, payout = 0.6 },
            premium  = { premium = 35, payout = 0.8 }
        },
        predatorCoverage = true,
        disasterCoverage = true
    },
    Reputation = {
        tracks = {
            honest     = { label = 'Honest Rancher' },
            suspect    = { label = 'Rustler Suspect' },
            cattleKing = { label = 'Cattle King' }
        },
        decayPerDay      = 0.02,
        bonusPerContract = 0.05
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PREDATORS, BANDITS & EVENTS ███████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Hazards = {
    Predators = {
        wolves  = { spawnChanceNight = 0.25, deterrents = { 'guardDog', 'torches' } },
        cougars = { spawnChanceHills = 0.15, damage = 0.6 },
        coyotes = { spawnChance = 0.3, target = 'chickens' },
        bears   = { spawnChance = 0.05, penBreakChance = 0.4 }
    },
    Bandits = {
        raidChance         = 0.08,
        gangSizes          = { min = 3, max = 7 },
        stealAmount        = { min = 1, max = 4 },
        evidenceDropChance = 0.2
    },
    NaturalEvents = {
        blizzard = { frequencyHours = 12 },
        tornado  = { frequencyHours = 48, damage = 0.9 },
        locust   = { frequencyHours = 36, cropDamage = 0.8 },
        barnFire = { frequencyHours = 24, spreadChance = 0.4 },
        drought  = { frequencyHours = 30, durationHours = 12 }
    },
    CommunityEvents = {
        rodeo          = { frequencyHours = 72,  moraleBonus = 0.1,  reward = nil  },
        countyFair     = { frequencyHours = 96,  reward = 150 },
        harvestFestival = { frequencyHours = 120, cropBonus = 0.2 },
        ranchDance     = { frequencyHours = 60,  moraleBonus = 0.08 }
    },
    Competitions = {
        biggestBull  = { reward = 80  },
        bestWool     = { reward = 60  },
        fastestHorse = { reward = 100 }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ HORSE TRAINING & LOGISTICS ████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Horses = {
    Training = {
        groundwork = { sessions = 5, staminaBonus = 0.1  },
        riding     = { sessions = 7, staminaBonus = 0.15 },
        pulling    = { sessions = 6, haulBonus = 0.2     },
        obstacle   = { sessions = 8, controlBonus = 0.25 }
    },
    Bonding = {
        levels = {
            { label = 'Stranger',    requirement = 0   },
            { label = 'Acquainted',  requirement = 200 },
            { label = 'Partner',     requirement = 500 },
            { label = 'Soulmate',    requirement = 900 }
        },
        bonuses = { stamina = 0.3, calmness = 0.4, commandResponse = 0.35 }
    },
    Tack = {
        saddleDurability  = 0.02,
        horseshoeBreakChance = 0.1,
        bridleSnapChance  = 0.05
    },
    DraftTeams = {
        teamSizes       = { 2, 4 },
        staminaDrainPerLoad = 0.1,
        synergyBonus    = 0.15
    }
}

Config.Logistics = {
    Wagons = {
        hay  = { capacity = 40, breakdownChance = 0.1  },
        milk = { capacity = 30, breakdownChance = 0.12 },
        meat = { capacity = 35, breakdownChance = 0.14 },
        tool = { capacity = 25, breakdownChance = 0.08 }
    },
    LoadInteraction = {
        timePerItemSeconds   = 2,
        weightAffectsHandling = true
    },
    Repairs = {
        axleBreakChance  = 0.08,
        wheelPopChance   = 0.1,
        repairKits       = { 'axle_kit', 'wheel_kit' }
    },
    Railroad = {
        enable                 = true,
        carCapacity            = 20,
        scheduleIntervalMinutes = 45,
        bulkSaleBonus          = 0.2
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ECONOMY & MARKET ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Economy = {
    DynamicPricing = {
        baseDemand = {
            beef  = 1.0,
            milk  = 1.0,
            wool  = 1.0,
            eggs  = 1.0,
            hides = 1.0
        },
        seasonalModifiers = {
            winter = { beef = 1.3, milk = 1.1  },
            spring = { wool = 1.2, eggs = 1.3  },
            summer = { hides = 1.1             },
            autumn = { grain = 1.25            }
        }
    },
    Contracts = {
        maxActive        = 5,
        townBoards       = { 'Valentine', 'Rhodes', 'Blackwater' },
        expiryHours      = 24,
        reputationBonus  = 0.05
    },
    Auctions = {
        enable                  = true,
        liveBidding             = true,
        reservePriceModifier    = 0.8,
        fraudDetection          = true,
        minParticipants         = 3
    },
    Ledger = {
        enableAccounting    = true,
        trackExpenses       = true,
        expenseCategories   = { 'wages', 'upkeep', 'feed', 'repairs', 'insurance' },
        analyticsWindowDays = 30
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PROGRESSION & META ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Progression = {
    XPPerContract   = 50,
    XPPerBirth      = 30,
    XPPerCompetition = 80,
    LevelThresholds = { 0, 200, 500, 900, 1400, 2000 },
    SkillTrees = {
        Husbandry  = { tiers = 3, perks = { 'Better Breeding',  'Efficient Feeding', 'Calm Whisper'     } },
        Veterinary = { tiers = 3, perks = { 'Faster Diagnosis', 'Gentle Hands',      'Field Surgery'    } },
        Teamster   = { tiers = 3, perks = { 'Sure Footing',     'Load Master',       'Express Delivery' } },
        Wrangler   = { tiers = 3, perks = { 'Quick Lasso',      'Herd Sense',        'Stampede Control' } },
        Butcher    = { tiers = 3, perks = { 'Prime Cut',        'Clean Carcass',     'Smoke Master'     } }
    },
    Achievements = {
        calves   = { goal = 100, reward = 'Golden Branding Iron' },
        rustler  = { goal = 10,  reward = "Sheriff's Favor"      },
        cheese   = { goal = 200, reward = 'Master Cheesemaker'   }
    },
    Legacy = {
        enableHeirs       = true,
        heirCount         = 3,
        inheritanceTax    = 0.1,
        heirPerkOptions   = { 'Legacy Brand', 'Old Money', 'Tall Tales' }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ UI & TOOLS ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.UI = {
    EnableLedgerApp  = true,
    MapOverlay       = true,
    StatusIcons      = true,
    PhotoCatalog     = true,
    AuctionUI        = true,
    DiscordWebhooks  = true,
    VoiceCommands = {
        enable      = true,
        whistleDog  = true,
        callCattle  = true
    },
    Tutorials = {
        introMissions      = true,
        contextualPrompts  = true,
        knowledgeBaseLinks = {
            'https://redm.munafio.com/blog',
            'https://forum.cfx.re/c/redm-releases/60'
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PREMIUM & EXTRAS ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.GodExtras = {
    HauntedEvents = {
        enabled          = true,
        ghostCowChance   = 0.02,
        cursedFenceChance = 0.01
    },
    Tebex = {
        enabled    = false,
        productIds = {
            ranchBrandPack  = '',
            exclusiveWagon  = '',
            exoticLivestock = ''
        }
    },
    VRHooks = {
        enabled       = false,
        spectatorMode = true,
        photoMode     = true
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire | All Rights Reserved
-- ████████████████████████████████████████████████████████████████████████████████
