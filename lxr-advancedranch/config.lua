--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 LXR Core - Advanced Ranch System (Buyer Control Panel)

    This is the ONLY file a buyer needs to edit. Every tunable value — prices,
    cooldowns, livestock species, contract payouts, seasonal modifiers, keybinds,
    admin identifiers, Discord roles, UI toggles — lives here. Gameplay logic
    and anti-abuse code are protected inside the escrow-encrypted server/client
    files and read from this table at runtime.

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
    Performance Target: 150+ concurrent players, sub-0.05ms idle client usage

    Tags: RedM, Ranch, Livestock, Economy, Workforce, Auction, Contracts,
          Progression, Zoning, NUI, MariaDB, Georgian

    Framework Support:
    - LXR Core (Primary)
    - RSG Core (Primary)
    - VORP Core (Compatible)
    - RedEM:RP (Compatible)
    - QBR Core (Compatible)
    - QR Core (Compatible)
    - Standalone (Fallback)

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
    name     = 'The Land of Wolves',
    tagline  = 'Georgian RP | მგლების მიწა - რჩეულთა ადგილი!',
    type     = 'Serious Hardcore Roleplay',
    access   = 'Discord & Whitelisted',

    -- Contact & Links
    website       = 'https://www.wolves.land',
    discord       = 'https://discord.gg/CrKcWdfd3A',
    github        = 'https://github.com/iBoss21',
    store         = 'https://theluxempire.tebex.io',
    serverListing = 'https://servers.redm.net/servers/detail/8gj7eb',

    -- Developer attribution
    developer = 'iBoss21 / The Lux Empire'
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Framework = 'auto'     -- 'auto' | 'lxr-core' | 'rsg-core' | 'vorp_core' | 'redem_roleplay' | 'qbr-core' | 'qr-core' | 'standalone'

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
    ['standalone'] = {
        notifications = 'print',
        inventory     = 'none',
        target        = 'none'
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE CONFIGURATION ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Lang = 'en'   -- 'en' | 'ka'

Config.Locale = {
    en = {
        action_success        = 'Action completed.',
        action_failed         = 'Action failed. Try again.',
        no_permission         = 'You do not have permission.',
        cooldown_active       = 'Please wait before trying again.',
        not_enough_money      = 'Not enough cash.',
        ranch_created         = 'Ranch created.',
        ranch_deleted         = 'Ranch deleted.',
        ranch_transferred     = 'Ranch ownership transferred.',
        ranch_not_found       = 'Ranch not found.',
        not_owner             = 'You are not the owner of this ranch.',
        worker_hired          = 'Worker hired.',
        worker_fired          = 'Worker dismissed.',
        worker_not_employed   = 'That player does not work here.',
        animal_added          = 'Animal added to the herd.',
        animal_removed        = 'Animal removed.',
        animal_died           = 'An animal has died.',
        animal_born           = 'A new animal was born.',
        contract_accepted     = 'Contract accepted.',
        contract_completed    = 'Contract completed. Payment deposited.',
        contract_expired      = 'Contract expired.',
        auction_started       = 'Auction started.',
        auction_won           = 'Auction won.',
        auction_outbid        = 'You were outbid.',
        season_changed        = 'Season has changed.',
        weather_changed       = 'Weather has changed.',
        hazard_triggered      = 'A hazard struck the frontier.',
        ui_opened             = 'Ranch journal opened.',
        ui_closed             = 'Ranch journal closed.',
        xp_gained             = 'Experience gained.',
        level_up              = 'Skill level increased.',
        invalid_species       = 'Invalid species.',
        invalid_role          = 'Invalid role.',
        invalid_ranch         = 'Invalid ranch.',
        zone_created          = 'Zone created.',
        zone_saved            = 'Zone saved.',
        zone_cancelled        = 'Zone creation cancelled.',
        prop_placed           = 'Prop placed.',
        prop_removed          = 'Prop removed.',
        rate_limited          = 'Slow down — too many actions.',
        server_busy           = 'Server busy, try again shortly.'
    },
    ka = {
        action_success        = 'მოქმედება დასრულდა.',
        action_failed         = 'მოქმედება ვერ შესრულდა. სცადეთ თავიდან.',
        no_permission         = 'თქვენ არ გაქვთ ამის უფლება.',
        cooldown_active       = 'გთხოვთ დაელოდოთ.',
        not_enough_money      = 'თქვენ არ გაქვთ საკმარისი თანხა.',
        ranch_created         = 'რანჩო შექმნილია.',
        ranch_deleted         = 'რანჩო წაიშალა.',
        ranch_transferred     = 'მფლობელობა გადაეცა.',
        ranch_not_found       = 'რანჩო ვერ მოიძებნა.',
        not_owner             = 'თქვენ არ ხართ ამ რანჩოს მფლობელი.',
        worker_hired          = 'მუშა აყვანილია.',
        worker_fired          = 'მუშა გათავისუფლებულია.',
        worker_not_employed   = 'ეს მოთამაშე აქ არ მუშაობს.',
        animal_added          = 'ცხოველი ჯოგში დაემატა.',
        animal_removed        = 'ცხოველი წაიშალა.',
        animal_died           = 'ცხოველი დაიღუპა.',
        animal_born           = 'ახალი ცხოველი დაიბადა.',
        contract_accepted     = 'კონტრაქტი მიღებულია.',
        contract_completed    = 'კონტრაქტი დასრულდა. თანხა ჩაირიცხა.',
        contract_expired      = 'კონტრაქტი ამოიწურა.',
        auction_started       = 'აუქციონი დაიწყო.',
        auction_won           = 'აუქციონი მოიგეთ.',
        auction_outbid        = 'თქვენი ფსონი გადააჭარბეს.',
        season_changed        = 'სეზონი შეიცვალა.',
        weather_changed       = 'ამინდი შეიცვალა.',
        hazard_triggered      = 'საფრთხე ჩამოწვა საზღვარზე.',
        ui_opened             = 'რანჩოს ჟურნალი გაიხსნა.',
        ui_closed             = 'რანჩოს ჟურნალი დაიხურა.',
        xp_gained             = 'გამოცდილება მოპოვებული.',
        level_up              = 'უნარის დონე გაიზარდა.',
        invalid_species       = 'არასწორი სახეობა.',
        invalid_role          = 'არასწორი როლი.',
        invalid_ranch         = 'არასწორი რანჩო.',
        zone_created          = 'ზონა შექმნილია.',
        zone_saved            = 'ზონა შენახულია.',
        zone_cancelled        = 'ზონის შექმნა გაუქმდა.',
        prop_placed           = 'ობიექტი დადგმულია.',
        prop_removed          = 'ობიექტი მოხსნილია.',
        rate_limited          = 'ნელა — ძალიან ბევრი მოქმედება.',
        server_busy           = 'სერვერი დატვირთულია, სცადეთ თავიდან.'
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ GENERAL SETTINGS ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.General = {
    targetDistance    = 3.0,    -- Interaction distance (world units)
    enableSounds      = true,   -- Play UI and world sound effects
    enableParticles   = true,   -- Environmental particle FX (dust, rain splash)
    enableBlips       = true,   -- Show ranch blips on the map
    blipSprite        = -1420722221,  -- Ranch map blip sprite hash
    blipScale         = 0.3,
    ownerOnlyUI       = false,  -- If true, non-owners cannot open the NUI on a ranch
    allowMultiOwner   = false,  -- If true, co-owners can manage ranches
    autoSaveInterval  = 300000  -- ms between auto-saves (5 minutes)
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ KEYS CONFIGURATION ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Keys = {
    openUI          = 0x760A9C6F,   -- G — open ranch journal (primary NUI)
    closeUI         = 0xCEFD9220,   -- ESC — always closes UI
    interact        = 0x760A9C6F,   -- G — interact with ranch prompts
    cancel          = 0x8CC9CD42,   -- X — cancel action
    mapOpenUI       = 'F5',         -- RegisterKeyMapping fallback
    propPlaceAccept = 0x07CE1E61,   -- ENTER — confirm prop placement
    propRotateL     = 0xE6F612E4,   -- Q
    propRotateR     = 0x1CE6D9EB    -- E
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ TIMING & COOLDOWNS ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Cooldowns = {
    globalCooldown        = 1000,     -- ms between any two actions from same player
    uiRefreshMin          = 5000,     -- Minimum ms between NUI data pulls per player
    contractAccept        = 60000,    -- 1 min between accepting contracts
    auctionBidMin         = 2000,     -- 2s minimum between bids
    animalInteract        = 3000,     -- 3s between feed/water/groom per animal
    breedingAttempt       = 86400000, -- 24h between breeding attempts per pair (real time)
    taskAssign            = 10000,    -- 10s between task assigns (admin/foreman)
    propPlace             = 2000,     -- 2s between prop placements
    zoneCreate            = 5000      -- 5s between zone create commands
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ANIMATION CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Find more at: https://github.com/femga/rdr3_discoveries/blob/master/animations/ingameanims/ingameanims_list.lua

Config.Animation = {
    feedAnimal = {
        dict = 'amb_rest@world_human_feed_pigs@male_a@idle_a',
        anim = 'idle_a',
        flag = 1,           -- Looped
        duration = 4000
    },
    milkCow = {
        dict = 'amb_work@world_human_milk_cow@male_a@idle_a',
        anim = 'idle_a',
        flag = 1,
        duration = 8000
    },
    shearSheep = {
        dict = 'amb_work@world_human_shear_sheep@male_a@idle_a',
        anim = 'idle_a',
        flag = 1,
        duration = 7000
    },
    brushHorse = {
        dict = 'script_story@gng1@ig@ig_7_grooming_the_horse',
        anim = 'idle_player',
        flag = 1,
        duration = 6000
    },
    openJournal = {
        dict = 'script_common@other@unapproved',
        anim = 'medic_kneel_enter',
        flag = 0,
        duration = 1200
    },
    placeProp = {
        dict = 'amb_work@world_human_crouch_inspect@male_a@idle_a',
        anim = 'idle_a',
        flag = 1,
        duration = 2500
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LIVESTOCK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Per-species needs decay (per real-time hour). Values above 0 drain the stat.
    An animal at 0 health eventually dies unless intervention occurs.
    gestationHours is shortened from real gestation for gameplay pacing.
]]

Config.Livestock = {
    cattle = {
        label         = 'Cattle',
        maxPerRanch   = 80,
        baseSellPrice = 140,        -- Sold as meat/leather
        needsDecay    = { hunger = 0.12, thirst = 0.18, cleanliness = 0.05 },
        breedingCooldownHours = 48,
        gestationHours        = 36,
        litterMin     = 1,
        litterMax     = 1,
        lifespanDays  = 90,
        adultAgeDays  = 6,
        products = {
            { item = 'rawbeef',   minAge = 6, yield = { 3, 7 } },
            { item = 'leather',   minAge = 6, yield = { 1, 2 } },
            { item = 'milk_jug',  minAge = 6, yield = { 1, 3 }, femaleOnly = true, recurring = true }
        }
    },
    horse = {
        label         = 'Horse',
        maxPerRanch   = 40,
        baseSellPrice = 350,
        needsDecay    = { hunger = 0.10, thirst = 0.15, cleanliness = 0.07 },
        breedingCooldownHours = 72,
        gestationHours        = 48,
        litterMin     = 1,
        litterMax     = 1,
        lifespanDays  = 120,
        adultAgeDays  = 10,
        trustGainPerGroom = 5,
        products = {
            -- Horses are ridden, not harvested — products table intentionally empty of slaughter yields.
            { item = 'horse_hair', minAge = 10, yield = { 1, 2 }, recurring = true }
        }
    },
    sheep = {
        label         = 'Sheep',
        maxPerRanch   = 120,
        baseSellPrice = 75,
        needsDecay    = { hunger = 0.14, thirst = 0.16, cleanliness = 0.08 },
        breedingCooldownHours = 30,
        gestationHours        = 24,
        litterMin     = 1,
        litterMax     = 2,
        lifespanDays  = 70,
        adultAgeDays  = 4,
        products = {
            { item = 'raw_mutton', minAge = 4, yield = { 2, 4 } },
            { item = 'wool',       minAge = 4, yield = { 2, 5 }, recurring = true }
        }
    },
    pig = {
        label         = 'Pig',
        maxPerRanch   = 60,
        baseSellPrice = 95,
        needsDecay    = { hunger = 0.20, thirst = 0.14, cleanliness = 0.12 },
        breedingCooldownHours = 24,
        gestationHours        = 18,
        litterMin     = 3,
        litterMax     = 8,
        lifespanDays  = 60,
        adultAgeDays  = 3,
        products = {
            { item = 'raw_pork',   minAge = 3, yield = { 3, 6 } },
            { item = 'pig_hide',   minAge = 3, yield = { 1, 2 } }
        }
    },
    chicken = {
        label         = 'Chicken',
        maxPerRanch   = 200,
        baseSellPrice = 18,
        needsDecay    = { hunger = 0.08, thirst = 0.10, cleanliness = 0.04 },
        breedingCooldownHours = 8,
        gestationHours        = 6,
        litterMin     = 4,
        litterMax     = 12,
        lifespanDays  = 40,
        adultAgeDays  = 2,
        products = {
            { item = 'raw_chicken', minAge = 2, yield = { 1, 2 } },
            { item = 'chicken_egg', minAge = 2, yield = { 1, 3 }, recurring = true, recurEveryHours = 6, femaleOnly = true }
        }
    },
    goat = {
        label         = 'Goat',
        maxPerRanch   = 80,
        baseSellPrice = 65,
        needsDecay    = { hunger = 0.13, thirst = 0.14, cleanliness = 0.07 },
        breedingCooldownHours = 24,
        gestationHours        = 20,
        litterMin     = 1,
        litterMax     = 2,
        lifespanDays  = 65,
        adultAgeDays  = 3,
        products = {
            { item = 'raw_goat_meat', minAge = 3, yield = { 2, 4 } },
            { item = 'goat_milk',     minAge = 3, yield = { 1, 2 }, recurring = true, femaleOnly = true }
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BREEDING & GENETICS ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Breeding = {
    enabled                 = true,
    requireSameSpecies      = true,
    requireDifferentSex     = true,
    offspringHealthBase     = 80,
    offspringHealthVariance = 15,   -- ±15 from base
    traitInheritanceChance  = 0.60, -- 60% trait passes to offspring
    possibleTraits = {
        'hardy', 'gentle', 'fast', 'strong', 'fertile',
        'sickly', 'stubborn', 'nervous', 'clever', 'docile'
    },
    traitBonus = {
        hardy    = { needsDecayMult = 0.75 },
        gentle   = { trustGainMult  = 1.25 },
        fast     = { sellPriceMult  = 1.15 },
        strong   = { sellPriceMult  = 1.20 },
        fertile  = { breedingCdMult = 0.70 },
        sickly   = { needsDecayMult = 1.30 },
        stubborn = { trustGainMult  = 0.70 },
        nervous  = { sellPriceMult  = 0.90 },
        clever   = { xpGainMult     = 1.15 },
        docile   = { trustGainMult  = 1.15 }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WORKFORCE CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Workforce = {
    enabled             = true,
    maxWorkersPerRanch  = 20,
    defaultMorale       = 70,
    defaultFatigue      = 0,
    fatigueGainPerTask  = 8,        -- 0-100 scale
    moraleDecayPerDay   = 5,
    paydayIntervalHours = 24,       -- Real hours between auto-payouts

    roles = {
        Owner = {
            label       = 'Owner',
            rank        = 100,
            wage        = 0,
            canHire     = true,
            canFire     = true,
            canAssign   = true,
            canUpgrade  = true,
            canSellAnimal = true,
            canBuyAnimal  = true
        },
        Foreman = {
            label       = 'Foreman',
            rank        = 80,
            wage        = 225,
            canHire     = true,
            canFire     = true,
            canAssign   = true,
            canUpgrade  = false,
            canSellAnimal = true,
            canBuyAnimal  = false
        },
        Hand = {
            label   = 'Ranch Hand',
            rank    = 40,
            wage    = 110,
            canAssign = false
        },
        Wrangler = {
            label   = 'Wrangler',
            rank    = 50,
            wage    = 140,
            specialty = 'horse'
        },
        Dairyman = {
            label   = 'Dairyman',
            rank    = 50,
            wage    = 140,
            specialty = 'cattle'
        },
        Butcher = {
            label   = 'Butcher',
            rank    = 55,
            wage    = 160,
            specialty = 'slaughter'
        },
        Vet = {
            label   = 'Veterinarian',
            rank    = 70,
            wage    = 220,
            specialty = 'medical'
        },
        Teamster = {
            label   = 'Teamster',
            rank    = 55,
            wage    = 155,
            specialty = 'transport'
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DISCORD ROLE SYNC █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Discord = {
    enabled              = false,           -- Master toggle
    botToken             = '',              -- Set in server.cfg instead — NEVER hardcode here
    guildId              = '',
    webhookUrl           = '',              -- Events webhook (ownership transfer, auctions, hazards)
    syncRolesToWorkforce = true,            -- Auto-promote/demote when Discord role changes
    roleMapping = {
        -- discordRoleId = 'Workforce role name'
        -- Example: ['1234567890123456789'] = 'Foreman',
    },
    transferRoleOnSale   = true,            -- Move roles from seller to buyer after auction win
    notifyOnHazard       = true,
    notifyOnAuction      = true,
    notifyOnTransfer     = true,
    notifyOnRanchDelete  = true
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ENVIRONMENT & SEASONS █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Environment = {
    enabled            = true,
    seasonLengthMinutes = 120,                              -- How long each season lasts (real minutes)
    seasonSequence      = { 'spring', 'summer', 'autumn', 'winter' },

    seasons = {
        spring = {
            label         = 'Spring',
            tempRange     = { 8, 22 },        -- Celsius
            pastureGrowth = 1.30,             -- Multiplier on vegetation regrowth
            diseaseChance = 0.04,
            weatherBias   = { clear = 0.50, rain = 0.35, storm = 0.10, fog = 0.05 }
        },
        summer = {
            label         = 'Summer',
            tempRange     = { 22, 38 },
            pastureGrowth = 0.90,
            diseaseChance = 0.06,
            weatherBias   = { clear = 0.75, rain = 0.10, storm = 0.08, fog = 0.02, drought = 0.05 }
        },
        autumn = {
            label         = 'Autumn',
            tempRange     = { 4, 18 },
            pastureGrowth = 0.75,
            diseaseChance = 0.05,
            weatherBias   = { clear = 0.45, rain = 0.30, fog = 0.15, storm = 0.10 }
        },
        winter = {
            label         = 'Winter',
            tempRange     = { -15, 4 },
            pastureGrowth = 0.25,
            diseaseChance = 0.08,
            weatherBias   = { clear = 0.35, snow = 0.40, blizzard = 0.15, fog = 0.10 }
        }
    },

    weatherCycleMinutes = 30,                              -- How often server rolls weather
    weatherTypes = {
        'clear', 'rain', 'storm', 'snow', 'blizzard', 'fog', 'drought', 'duststorm'
    },

    hazards = {
        lightning = {
            label    = 'Lightning Strike',
            chance   = 0.02,   -- per weather roll during storm
            damage   = { livestock = 15, structures = 0.05 },
            allowedWeather = { 'storm', 'rain' }
        },
        flood = {
            label    = 'Flood',
            chance   = 0.015,
            damage   = { livestock = 8, pasture = 0.10 },
            allowedWeather = { 'storm', 'rain' }
        },
        drought = {
            label    = 'Drought',
            chance   = 0.01,
            damage   = { pasture = 0.20, waterDecay = 2.0 },
            allowedWeather = { 'clear', 'drought' }
        },
        blizzard = {
            label    = 'Blizzard',
            chance   = 0.02,
            damage   = { livestock = 10, structures = 0.03 },
            allowedWeather = { 'blizzard', 'snow' }
        },
        duststorm = {
            label    = 'Dust Storm',
            chance   = 0.01,
            damage   = { livestock = 4, cleanlinessDecay = 2.0 },
            allowedWeather = { 'clear', 'duststorm' }
        }
    },

    soil = {
        defaultFertility = 80,
        depletionPerGraze = 0.5,
        regrowthPerTick   = 1.0,
        tickIntervalMinutes = 10
    },

    wildlife = {
        enabled     = true,
        predators   = { 'wolf', 'coyote', 'cougar' },
        peaceful    = { 'deer', 'rabbit', 'pheasant' },
        predatorAttackChance = 0.03,   -- per environment tick per ranch
        predatorDamage       = { 1, 4 } -- animals killed per attack (min,max)
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ECONOMY & PRICING █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Economy = {
    enabled          = true,
    currencyLabel    = '$',
    useGold          = false,     -- wolves.land is cash-only — DO NOT enable
    minPriceClamp    = 0.40,      -- Floor: 40% of base price
    maxPriceClamp    = 1.60,      -- Ceiling: 160% of base price

    baseDemand = {
        beef = 1.0, milk = 1.0, wool = 1.0, eggs = 1.0,
        pork = 1.0, mutton = 1.0, leather = 1.0, hides = 1.0,
        horses = 1.0, chickens = 1.0
    },

    seasonalModifiers = {
        spring = { beef = 1.00, milk = 1.10, wool = 0.80, eggs = 1.15, mutton = 0.95, leather = 1.00, pork = 1.00 },
        summer = { beef = 0.95, milk = 1.15, wool = 0.65, eggs = 1.10, mutton = 0.90, leather = 1.05, pork = 1.00 },
        autumn = { beef = 1.15, milk = 1.05, wool = 1.10, eggs = 1.00, mutton = 1.15, leather = 1.10, pork = 1.10 },
        winter = { beef = 1.30, milk = 1.05, wool = 1.40, eggs = 0.95, mutton = 1.35, leather = 1.20, pork = 1.20 }
    },

    townBoards = {
        Valentine = {
            coords = vector3(-178.6, 628.1, 114.2),
            heading = 92.0,
            goods   = { 'beef', 'milk', 'eggs' }
        },
        Rhodes = {
            coords = vector3(1229.5, -1291.9, 76.9),
            heading = 178.0,
            goods   = { 'pork', 'wool', 'leather' }
        },
        Blackwater = {
            coords = vector3(-807.3, -1308.1, 43.6),
            heading = 270.0,
            goods   = { 'horses', 'beef', 'hides' }
        },
        SaintDenis = {
            coords = vector3(2735.6, -1390.9, 46.4),
            heading = 14.0,
            goods   = { 'milk', 'eggs', 'mutton' }
        },
        Strawberry = {
            coords = vector3(-1801.7, -362.0, 163.3),
            heading = 38.0,
            goods   = { 'chickens', 'wool' }
        }
    },

    contracts = {
        maxActivePerPlayer    = 5,
        defaultDeadlineHours  = 48,
        rewardBase            = 500,
        rewardPerUnit         = 12,
        penaltyOnFail         = 150,
        rerollMinutes         = 60     -- Board refresh interval
    },

    auctions = {
        enabled              = true,
        durationMinutes      = 15,
        minBidIncrementPct   = 0.05,     -- Minimum 5% bump
        startingBidMult      = 0.80,     -- 80% of base sell price
        maxConcurrentPerRanch = 3,
        houseCutPct          = 0.05      -- 5% auction-house fee
    },

    productionChains = {
        dairy = {
            input  = { milk_jug = 4 },
            output = { cheese_wheel = 1 },
            timeMinutes = 30,
            xpPerBatch  = 8
        },
        butcher = {
            input  = { rawbeef = 2 },
            output = { steak_cut = 1 },
            timeMinutes = 12,
            xpPerBatch  = 5
        },
        wool = {
            input  = { wool = 5 },
            output = { wool_bolt = 1 },
            timeMinutes = 20,
            xpPerBatch  = 4
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PROGRESSION & SKILLS ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Progression = {
    enabled         = true,
    maxLevel        = 100,
    xpCurveBase     = 100,
    xpCurveExponent = 1.35,    -- xpToLevel(n) = base * n^exp

    skills = {
        Husbandry = {
            label  = 'Husbandry',
            description = 'Animal care, feeding, grooming',
            bonuses = {
                [10] = 'Animal needs decay 5% slower',
                [25] = 'Animal needs decay 10% slower',
                [50] = 'Breeding success +10%',
                [75] = 'Offspring health +15',
                [100] = 'Animal needs decay 25% slower'
            }
        },
        Veterinary = {
            label = 'Veterinary',
            description = 'Disease treatment, injury care',
            bonuses = {
                [10] = 'Unlock basic medicine',
                [25] = 'Disease recovery +15%',
                [50] = 'Unlock tonics and salves',
                [75] = 'Surgery success +20%',
                [100] = 'Mortality chance halved'
            }
        },
        Wrangler = {
            label = 'Wrangler',
            description = 'Horse handling, trust, taming',
            bonuses = {
                [10] = 'Trust gain +10%',
                [25] = 'Cattle herding +15%',
                [50] = 'Horse bond slot +1',
                [75] = 'Taming wild horse +25%',
                [100] = 'Legendary mount access'
            }
        },
        Butcher = {
            label = 'Butcher',
            description = 'Slaughter yield and meat quality',
            bonuses = {
                [10] = 'Meat yield +10%',
                [25] = 'Quality grade +1',
                [50] = 'Sell price +10%',
                [75] = 'Bulk processing unlocked',
                [100] = 'Meat yield +30%'
            }
        },
        Teamster = {
            label = 'Teamster',
            description = 'Wagon control, delivery speed',
            bonuses = {
                [10] = 'Contract time +10%',
                [25] = 'Wagon capacity +20%',
                [50] = 'Delivery pay +15%',
                [75] = 'Unlock heavy wagons',
                [100] = 'Rapid delivery — pay +30%'
            }
        }
    },

    xpGains = {
        feedAnimal      = 2,
        waterAnimal     = 2,
        groomAnimal     = 4,
        milkCow         = 6,
        shearSheep      = 5,
        slaughter       = 10,
        breed           = 25,
        healAnimal      = 8,
        deliverContract = 15,
        winAuction      = 20,
        hireWorker      = 5
    },

    achievements = {
        first_herd        = { label = 'First Herd',        requirement = { animals = 10 },  reward = 200 },
        hundred_animals   = { label = 'Empire Herd',       requirement = { animals = 100 }, reward = 2500 },
        master_breeder    = { label = 'Master Breeder',    requirement = { births = 50 },   reward = 1500 },
        contract_champ    = { label = 'Contract Champion', requirement = { contracts = 25 }, reward = 1000 },
        auction_king      = { label = 'Auction King',      requirement = { auctionsWon = 10 }, reward = 800 },
        season_survivor   = { label = 'Four Seasons',      requirement = { seasonsSurvived = 4 }, reward = 500 }
    },

    legacySystem = {
        enabled         = true,
        heirsPerOwner   = 2,
        inheritXpPct    = 0.25,      -- New character inherits 25% XP from legacy
        inheritItemsPct = 0.10
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ RANCHES & SPAWN POINTS ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Ranches = {
    defaultPurchasePrice = 25000,
    maxRanchesPerPlayer  = 1,
    allowBanking         = true,     -- Ranch has its own cash ledger
    defaultBoundaryRadius = 120.0,

    -- Seed ranches created on first boot (can be removed/edited via admin commands).
    -- Identifier slot '' means unowned/buyable.
    seeds = {
        ['emerald_ranch'] = {
            label   = 'Emerald Ranch',
            owner   = '',
            center  = vector3(1357.47, 344.02, 93.71),
            heading = 180.0,
            radius  = 150.0,
            tier    = 1
        },
        ['pronghorn_ranch'] = {
            label   = 'Pronghorn Ranch',
            owner   = '',
            center  = vector3(-810.9, 784.21, 131.45),
            heading = 90.0,
            radius  = 200.0,
            tier    = 2
        },
        ['downes_ranch'] = {
            label   = 'Downes Ranch',
            owner   = '',
            center  = vector3(-925.3, -275.4, 74.4),
            heading = 0.0,
            radius  = 100.0,
            tier    = 1
        },
        ['hanging_dog_ranch'] = {
            label   = 'Hanging Dog Ranch',
            owner   = '',
            center  = vector3(-3594.4, -1051.3, 13.7),
            heading = 90.0,
            radius  = 180.0,
            tier    = 2
        },
        ['painted_sky_ranch'] = {
            label   = 'Painted Sky Ranch',
            owner   = '',
            center  = vector3(-2220.4, -2428.7, 67.5),
            heading = 270.0,
            radius  = 220.0,
            tier    = 3
        }
    },

    tiers = {
        [1] = { label = 'Homestead',  maxAnimals = 40,  maxWorkers = 5,  maxProps = 30,  upgradeCost = 10000 },
        [2] = { label = 'Ranch',      maxAnimals = 120, maxWorkers = 12, maxProps = 80,  upgradeCost = 25000 },
        [3] = { label = 'Estate',     maxAnimals = 300, maxWorkers = 20, maxProps = 200, upgradeCost = 60000 },
        [4] = { label = 'Empire',     maxAnimals = 800, maxWorkers = 40, maxProps = 500, upgradeCost = nil }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ZONING (POLYGON ZONES) ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Zoning = {
    enabled              = true,
    maxVerticesPerZone   = 32,
    minVerticesPerZone   = 3,
    editorHeightStep     = 0.5,      -- Z-step when extruding zones
    showAllZonesToAdmins = true,
    zoneTypes = {
        'pasture', 'barn', 'paddock', 'gate', 'trough', 'slaughter', 'market', 'restricted'
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PROPS / MAPPER ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Props = {
    enabled        = true,
    maxPerRanch    = 200,
    snapToGround   = true,
    collisionCheck = true,
    whitelistedModels = {
        'p_haybale01x', 'p_haybale02x', 'p_haybale03x',
        'p_barrel01x', 'p_crate01x', 'p_crate02x',
        'p_fencepost01x', 'p_fenceruralv_01a', 'p_fenceruralv_02a',
        'p_woodpile01x', 'p_woodpile02x',
        'p_bucket03x', 'p_pitchfork01x', 'p_shovel01x',
        'p_chickencoop01x', 'p_troughmetal01x', 'p_troughwood01x',
        'p_crate07x', 'p_kegbarrel01x'
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ UI CONFIGURATION ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.UI = {
    enableLedgerApp     = true,
    mapOverlay          = true,
    statusIcons         = true,
    photoCatalog        = true,
    auctionUI           = true,
    discordWebhooks     = true,
    voiceCommands = {
        enable          = false,  -- Experimental — leave off unless tested
        whistleDog      = true,
        callCattle      = true
    },
    theme = {
        primaryAccent   = '#c9a84c',  -- Gold
        secondaryAccent = '#8a6f2e',
        backgroundTone  = 'dark_parchment'
    },
    defaultTab          = 'dashboard', -- 'dashboard', 'livestock', 'workforce', 'economy', 'environment', 'progression', 'auction'
    showActivityFeed    = true,
    feedMaxEntries      = 25
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ADMIN CONFIGURATION ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Admin = {
    acePermission   = 'ranch.admin',
    useAce          = true,
    useIdentifiers  = true,
    identifiers = {
        -- ['license:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'] = true,
        -- ['discord:123456789012345678'] = true,
    },
    commandPrefix = 'ranch',       -- All admin commands begin with /ranch<verb>
    logToConsole  = true,
    logToWebhook  = true
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DATABASE / PERSISTENCE ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Database = {
    mode             = 'mysql',       -- 'mysql' | 'json'
    prefix           = 'lxr_ranch_',  -- Table prefix
    autoMigrate      = true,           -- Auto-create tables on first boot
    jsonFallbackPath = 'data/',        -- Used only when mode = 'json'
    saveBatchSize    = 50,
    connectTimeout   = 5000
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY & ANTI-ABUSE █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Security = {
    enabled                = true,
    resourceNameGuard      = 'lxr-advancedranch',   -- Must match resource folder exactly
    kickOnNameMismatch     = true,
    maxDistance            = 10.0,
    maxActionsPerMinute    = 60,
    requireLineOfSight     = false,
    validateTargetExists   = true,
    validateRanchMembership = true,
    logSuspiciousActivity  = true,
    kickOnExploit          = false,
    banOnExploit           = false,
    nuiDataRateLimit       = 12,    -- Max NUI pulls per minute per player
    commandCooldownMs      = 1500
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PERFORMANCE OPTIMIZATION ██████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Performance = {
    cacheEnabled              = true,
    cacheTtlSeconds           = 30,
    clientUpdateInterval      = 1500,    -- ms between client tick handlers
    livestockTickInterval     = 60000,   -- Server tick for needs decay (1 min)
    environmentTickInterval   = 30000,   -- Weather/vegetation tick (30s)
    economyTickInterval       = 60000,   -- Price refresh (1 min)
    nuiStreamInterval         = 5000,    -- NUI data stream to open clients
    maxNearbyEntities         = 100,
    cleanupInterval           = 300000,  -- Stale ephemeral data cleanup (5 min)
    useDirtyFlagSaves         = true,    -- Only save changed records
    batchedWrites             = true
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG SETTINGS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Debug = false    -- Master debug switch; enables verbose prints and diag tools

Config.DebugChannels = {
    framework   = true,
    database    = true,
    livestock   = false,
    workforce   = false,
    economy     = false,
    environment = false,
    progression = false,
    admin       = true,
    nui         = false,
    security    = true
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ END OF CONFIGURATION ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

CreateThread(function()
    Wait(1000)
    if IsDuplicityVersion() then
        local livestockCount = 0
        for _ in pairs(Config.Livestock) do livestockCount = livestockCount + 1 end

        local roleCount = 0
        for _ in pairs(Config.Workforce.roles) do roleCount = roleCount + 1 end

        local ranchCount = 0
        for _ in pairs(Config.Ranches.seeds) do ranchCount = ranchCount + 1 end

        local townCount = 0
        for _ in pairs(Config.Economy.townBoards) do townCount = townCount + 1 end

        local skillCount = 0
        for _ in pairs(Config.Progression.skills) do skillCount = skillCount + 1 end

        print([[

        ═══════════════════════════════════════════════════════════════════════════════

            ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
            ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
            ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
            ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
            ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
            ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

        ═══════════════════════════════════════════════════════════════════════════════
        🐺 LXR ADVANCED RANCH SYSTEM - SUCCESSFULLY LOADED
        ═══════════════════════════════════════════════════════════════════════════════

        Version:        1.0.0
        Server:         ]] .. Config.ServerInfo.name .. [[

        Framework:      ]] .. tostring(Config.Framework) .. [[ (auto-detect enabled)
        Persistence:    ]] .. string.upper(Config.Database.mode) .. [[

        Livestock:      ]] .. livestockCount .. [[ species configured
        Workforce:      ]] .. roleCount .. [[ roles configured
        Ranches:        ]] .. ranchCount .. [[ seed ranches
        Town Boards:    ]] .. townCount .. [[ contract boards
        Skills:         ]] .. skillCount .. [[ skill trees
        Language:       ]] .. Config.Lang .. [[

        Security:       ]] .. (Config.Security.enabled and 'ENABLED ✓' or 'DISABLED ✗') .. [[
        Environment:    ]] .. (Config.Environment.enabled and 'ENABLED ✓' or 'DISABLED ✗') .. [[
        Economy:        ]] .. (Config.Economy.enabled and 'ENABLED ✓' or 'DISABLED ✗') .. [[
        Auctions:       ]] .. (Config.Economy.auctions.enabled and 'ENABLED ✓' or 'DISABLED ✗') .. [[
        Discord Sync:   ]] .. (Config.Discord.enabled and 'ENABLED ✓' or 'DISABLED ✗') .. [[
        Debug:          ]] .. (Config.Debug and 'ENABLED' or 'DISABLED') .. [[

        ═══════════════════════════════════════════════════════════════════════════════

        Developer:   iBoss21 / The Lux Empire
        Website:     https://www.wolves.land
        Discord:     https://discord.gg/CrKcWdfd3A
        Store:       https://theluxempire.tebex.io

        ═══════════════════════════════════════════════════════════════════════════════

    ]])
    end
end)
