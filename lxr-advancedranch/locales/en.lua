--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 Advanced Ranch System - English Locale

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

Locales = Locales or {}

Locales['en'] = {
    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 GENERAL
    -- ════════════════════════════════════════════════════════════════════════════
    no_permission          = 'You do not have permission to do that.',
    no_ranch               = 'You are not associated with any ranch.',
    admin_only             = 'This command is restricted to administrators.',
    debug_on               = 'Debug view enabled.',
    debug_off              = 'Debug view disabled.',

    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 LIVESTOCK
    -- ════════════════════════════════════════════════════════════════════════════
    animal_fed             = 'Animal fed.',
    animal_watered         = 'Animal watered.',
    animal_groomed         = 'Animal groomed.',
    animal_died            = 'An animal has died.',
    animal_capacity_full   = 'Ranch capacity reached for livestock.',
    breed_cooldown         = 'This animal is still in breeding cooldown.',
    breed_same_species     = 'Both animals must be the same species.',
    breed_opposite_sex     = 'Breeding requires one male and one female.',
    breed_started          = 'Breeding pair locked. Gestation underway.',

    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 WORKFORCE / PAYDAY
    -- ════════════════════════════════════════════════════════════════════════════
    worker_hired           = 'Worker hired.',
    worker_fired           = 'Worker dismissed.',
    worker_role_changed    = 'Worker role updated.',
    payday_received        = 'Payday: $%s received.',
    payday_failed          = 'Ranch could not cover payroll.',
    roster_full            = 'The roster is full.',

    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 ECONOMY / CONTRACTS / AUCTIONS
    -- ════════════════════════════════════════════════════════════════════════════
    contract_accepted      = 'Contract accepted.',
    contract_delivered     = 'Delivery complete. +$%s',
    contract_expired       = 'Contract expired — penalty applied.',
    missing_goods          = 'You do not have the required goods.',
    missing_input          = 'Missing required inputs.',
    production_started     = 'Production started.',
    production_done        = 'Production complete.',
    bid_rejected           = 'Bid rejected.',
    bid_rejected_not_live  = 'This lot is no longer live.',
    bid_rejected_expired   = 'This lot has expired.',
    bid_rejected_own_lot   = 'You cannot bid on your own lot.',
    bid_rejected_too_low   = 'Bid too low — raise above the minimum increment.',
    bid_rejected_insufficient = 'You do not have enough money to cover this bid.',
    auction_won            = 'Auction won.',
    auction_sold           = 'Your lot sold.',

    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 ENVIRONMENT / HAZARDS
    -- ════════════════════════════════════════════════════════════════════════════
    season_changed         = 'Season changed to %s.',
    weather_changed        = 'Weather: %s',
    hazard_near            = 'Hazard near your ranch: %s',

    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 PROGRESSION
    -- ════════════════════════════════════════════════════════════════════════════
    skill_level_up         = '%s reached level %s.',
    skill_unlock           = 'Unlocked: %s',
    achievement_unlocked   = 'Achievement unlocked — %s',

    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 ZONING
    -- ════════════════════════════════════════════════════════════════════════════
    zone_editor_started    = 'Zone editor active. ENTER = vertex, BACKSPACE = undo, /pzsave to save, /pzcancel to abort.',
    zone_editor_cancelled  = 'Zone editor cancelled.',
    zone_vertex_added      = 'Vertex placed (%s).',
    zone_vertex_removed    = 'Last vertex removed.',
    zone_vertex_cap        = 'Maximum vertices reached.',
    zone_too_few_verts     = 'Zone needs at least 3 vertices.',
    zone_not_on_ranch      = 'You must be inside a ranch boundary to save a zone.',
    zone_saved             = 'Zone saved.',

    -- ════════════════════════════════════════════════════════════════════════════
    -- 🔧 PROPS
    -- ════════════════════════════════════════════════════════════════════════════
    prop_place_help        = 'Q/E rotate, scroll = distance, ENTER confirm, BACKSPACE cancel.',
    prop_placed            = 'Prop placed.',
    prop_cancelled         = 'Placement cancelled.',
    prop_deleted           = 'Prop removed.',
    prop_model_failed      = 'Failed to load prop model.',
    prop_cap_reached       = 'This ranch has reached its prop cap.'
}

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 wolves.land — The Land of Wolves
-- © 2026 iBoss21 / The Lux Empire — All Rights Reserved
-- ════════════════════════════════════════════════════════════════════════════════
