--[[
    ═══════════════════════════════════════════════════════════════════════════════
    🐺 LXR Ranch System — Locale: Georgian (ka)
    ═══════════════════════════════════════════════════════════════════════════════
    wolves.land — The Land of Wolves
    © 2026 iBoss21 / The Lux Empire | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

Locales = Locales or {}

Locales['ka'] = {
    -- ზოგადი / General
    ranch_system        = 'ფერმის სისტემა',
    success             = 'წარმატება',
    error               = 'შეცდომა',
    warning             = 'გაფრთხილება',
    info                = 'ინფო',
    no_permission       = 'თქვენ არ გაქვთ ამის ნება.',
    invalid_args        = 'არასწორი არგუმენტები.',

    -- ფერმის მართვა / Ranch management
    ranch_created       = 'ფერმა "%s" წარმატებით შეიქმნა (ID: %s).',
    ranch_deleted       = 'ფერმა "%s" წაიშალა.',
    ranch_not_found     = 'ფერმა ვერ მოიძებნა.',
    ranch_name_required = 'ფერმის სახელი საჭიროა.',
    ranch_limit_reached = 'მიაღწიეთ ფერმების მაქსიმალურ რაოდენობას (%d).',
    ranch_ownership_transferred = '"%s" ფერმის საკუთრება გადაეცა %s-ს.',

    -- პირუტყვი / Livestock
    animal_fed          = '%s გამოკვება.',
    animal_watered      = '%s დაჰლია წყალი.',
    animal_treated      = '%s მკურნალობა %s-ისთვის.',
    animal_born         = 'თქვენს ფერმაში ახალი %s დაიბადა!',
    animal_died         = 'თქვენი %s გარდაიცვალა.',
    animal_trust_up     = '%s მეტად გენდობათ.',
    animal_trust_down   = '%s გეშინია.',

    -- სამუშაო ძალა / Workforce
    worker_hired        = '%s დაიქირავა, როლი: %s.',
    worker_fired        = '%s დათხოვნილ იქნა.',
    task_assigned       = 'დავალება "%s" მიეკუთვნა %s-ს.',
    task_completed      = '%s-მ დაასრულა დავალება "%s".',
    low_morale          = 'სამუშაო ძალის მორალი კრიტიკულად დაბალია!',

    -- ეკონომიკა / Economy
    contract_accepted   = 'კონტრაქტი მიღებულია: %s.',
    contract_completed  = 'კონტრაქტი შესრულდა! მიიღეთ $%d.',
    contract_expired    = 'კონტრაქტი "%s" ვადაგასული.',
    auction_bid_placed  = '$%d ბიდი დაყენდა %s-ზე.',
    auction_won         = 'თქვენ მოიგეთ %s ($%d).',
    insufficient_funds  = 'საკმარისი ფული არ გაქვთ.',

    -- გარემო და სახიფათო მოვლენები / Environment & hazards
    season_change       = 'სეზონი შეიცვალა: %s.',
    weather_change      = 'ამინდის განახლება: %s.',
    hazard_lightning    = 'ელჭექი! დაიცავით ბეღლები.',
    hazard_flood        = 'წყალდიდობა — პირუტყვი მაღლობზე გადაიყვანეთ!',
    hazard_drought      = 'გვალვა. წყლის მარაგი ეკონომიურად გამოიყენეთ.',
    hazard_blizzard     = 'ბურანი! ცხოველები დაუყოვნებლივ შეაფარეთ.',
    hazard_duststorm    = 'მტვრის ქარიშხალი — საფარველი დაადეთ ტაფებს!',

    -- პროგრესია / Progression
    level_up            = 'ფერმის დონე %d-მდე ასწიეთ!',
    skill_unlocked      = 'უნარი განბლოკილია: %s.',
    achievement_earned  = 'მიღწევა: %s.',
    xp_gained           = 'მიღებული %d XP.',

    -- ადმინი / Admin
    admin_only          = 'ეს ბრძანება მხოლოდ ადმინისტრატორებისთვისაა.',
    player_not_found    = 'მოთამაშე ვერ მოიძებნა.',
    identifier_required = 'მოთამაშის ID ვერ დადგინდა.',
}
