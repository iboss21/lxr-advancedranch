--[[
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██╔██╗ ██║██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝

    🐺 LXR Core - Advanced Ranch System

    Production-grade ranch management for RedM. Deeds, multi-species livestock
    with breeding and lifecycle, workforce with Discord role sync, dynamic
    seasonal environment, dynamic pricing with contracts and a live auction
    house, progression trees, polygon zoning, and a parchment-styled NUI
    dashboard. MariaDB persistence with JSON fallback.

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
    Performance Target: Optimized for 150+ player hardcore RP servers

    Tags: RedM, Georgian, SeriousRP, Whitelist, Ranch, Livestock, Economy,
          Workforce, Auction, Contracts, Progression, Zoning, NUI

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

    Script Author:    iBoss21 / The Lux Empire for The Land of Wolves
    Original Concept: Frontier ranch simulation — iBoss21
    Inspired by:      Red Dead Online ranch mechanics, historical 1899 husbandry

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name        'lxr-advancedranch'
author      'iBoss21 / The Lux Empire'
description 'Advanced ranch system — livestock, workforce, economy, environment, progression, auction, zoning, NUI — multi-framework, MariaDB persistence'
version     '1.0.1'

lua54 'yes'

-- ═══════════════════════════════════════════════════════════════════════════════
-- TEBEX ESCROW — PUBLIC SURFACE
-- Files listed here remain readable to buyers. All other files are encrypted.
-- ═══════════════════════════════════════════════════════════════════════════════
escrow_ignore {
    'config.lua',
    'fxmanifest.lua',
    'README.md',
    'LICENSE',
    'locales/**',
    'docs/**',
    'sql/**',
    'html/**'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SHARED SCRIPTS — load in both client and server contexts
-- ═══════════════════════════════════════════════════════════════════════════════
shared_scripts {
    'config.lua',              -- PUBLIC: buyer control panel (must load first)
    'locales/en.lua',          -- PUBLIC: English
    'locales/ka.lua',          -- PUBLIC: Georgian
    'shared/framework.lua',    -- PROTECTED: framework bridge
    'shared/utils.lua'         -- PROTECTED: shared helpers
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVER SCRIPTS — authoritative logic
-- Order matters: database first, then ranch manager, then subsystems.
-- ═══════════════════════════════════════════════════════════════════════════════
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'shared/database.lua',
    'server/sv_main.lua',
    'server/sv_ranches.lua',
    'server/sv_livestock.lua',
    'server/sv_workforce.lua',
    'server/sv_economy.lua',
    'server/sv_environment.lua',
    'server/sv_progression.lua',
    'server/sv_admin.lua',
    'server/sv_nui.lua'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLIENT SCRIPTS — presentation, UI, world effects
-- ═══════════════════════════════════════════════════════════════════════════════
client_scripts {
    'client/cl_main.lua',
    'client/cl_ui.lua',
    'client/cl_zoning.lua',
    'client/cl_props.lua',
    'client/cl_admin.lua'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- NUI — parchment dashboard
-- ═══════════════════════════════════════════════════════════════════════════════
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/img/*.png',
    'html/img/*.svg',
    'html/img/*.jpg'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- DEPENDENCIES — optional, checked at runtime
-- ═══════════════════════════════════════════════════════════════════════════════
dependencies {
    '/server:5848',
    '/onesync',
    'oxmysql'
}

provide 'lxr-ranch'
