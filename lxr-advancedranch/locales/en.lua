--[[
    ═══════════════════════════════════════════════════════════════════════════════
    🐺 LXR Ranch System — Locale: English (en)
    ═══════════════════════════════════════════════════════════════════════════════
    wolves.land — The Land of Wolves
    © 2026 iBoss21 / The Lux Empire | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

Locales = Locales or {}

Locales['en'] = {
    -- General
    ranch_system        = 'Ranch System',
    success             = 'Success',
    error               = 'Error',
    warning             = 'Warning',
    info                = 'Info',
    no_permission       = 'You do not have permission to do that.',
    invalid_args        = 'Invalid arguments.',

    -- Ranch management
    ranch_created       = 'Ranch "%s" created successfully (ID: %s).',
    ranch_deleted       = 'Ranch "%s" has been deleted.',
    ranch_not_found     = 'Ranch not found.',
    ranch_name_required = 'A ranch name is required.',
    ranch_limit_reached = 'You have reached the maximum number of ranches (%d).',
    ranch_ownership_transferred = 'Ownership of "%s" transferred to %s.',

    -- Livestock
    animal_fed          = '%s has been fed.',
    animal_watered      = '%s has been given water.',
    animal_treated      = '%s has been treated for %s.',
    animal_born         = 'A new %s has been born on your ranch!',
    animal_died         = 'Your %s has passed away.',
    animal_trust_up     = '%s trusts you more now.',
    animal_trust_down   = '%s is frightened of you.',

    -- Workforce
    worker_hired        = '%s has been hired as %s.',
    worker_fired        = '%s has been dismissed.',
    task_assigned       = 'Task "%s" assigned to %s.',
    task_completed      = '%s completed the task "%s".',
    low_morale          = 'Workforce morale is critically low!',

    -- Economy
    contract_accepted   = 'Contract accepted: %s.',
    contract_completed  = 'Contract fulfilled! You earned $%d.',
    contract_expired    = 'Contract "%s" has expired.',
    auction_bid_placed  = 'Bid of $%d placed on %s.',
    auction_won         = 'You won the auction for %s ($%d).',
    insufficient_funds  = 'You do not have enough money.',

    -- Environment & hazards
    season_change       = 'The season has changed to %s.',
    weather_change      = 'Weather update: %s.',
    hazard_lightning    = 'Lightning storm! Secure the barns.',
    hazard_flood        = 'Floodwaters rising — move stock to high ground!',
    hazard_drought      = 'Drought settling in. Ration water supplies.',
    hazard_blizzard     = 'Blizzard inbound! Shelter animals immediately.',
    hazard_duststorm    = 'Dust storm approaching — cover troughs and bring stock inside!',

    -- Progression
    level_up            = 'You have reached Ranch Level %d!',
    skill_unlocked      = 'Skill unlocked: %s.',
    achievement_earned  = 'Achievement earned: %s.',
    xp_gained           = 'You gained %d XP.',

    -- Admin
    admin_only          = 'This command is for administrators only.',
    player_not_found    = 'Player not found.',
    identifier_required = 'Unable to determine player identifier.',
}
