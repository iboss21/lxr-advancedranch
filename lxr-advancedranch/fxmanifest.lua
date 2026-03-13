fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources will become incompatible once RedM ships.'

name        'lxr-advancedranch'
author      'iBoss21 / The Lux Empire'
description 'LXR Ranch System — Production-grade ranch management for RedM. wolves.land'
version     '1.0.0'

lua54 'yes'

-- ═══════════════════════════════════════════════════════════════════════════════
-- TEBEX ESCROW — PUBLIC SURFACE
-- Files listed here remain readable to buyers. All other files are encrypted.
-- ═══════════════════════════════════════════════════════════════════════════════
escrow_ignore {
    'config.lua',
    'fxmanifest.lua',
    'README.md',
    'locales/**',
    'docs/**'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SHARED SCRIPTS (loaded in both client and server contexts)
-- config.lua MUST load first — it defines the public Config table
-- ═══════════════════════════════════════════════════════════════════════════════
shared_scripts {
    'config.lua',        -- PUBLIC: buyer control panel
    'locales/en.lua',    -- PUBLIC: English locale
    'locales/ka.lua',    -- PUBLIC: Georgian locale
    'shared/config.lua', -- PROTECTED: internal config shim
    'shared/utils.lua',
    'shared/framework.lua'
}

client_scripts {
    'client/main.lua',
    'client/zoning.lua',
    'client/vegetation.lua',
    'client/props.lua',
    'client/admin_menu.lua',
    'client/ui.lua'
}

server_scripts {
    'server/ranch_manager.lua',
    'server/environment.lua',
    'server/livestock.lua',
    'server/workforce.lua',
    'server/economy.lua',
    'server/progression.lua',
    'server/admin.lua',
    'server/storage.lua'
}

files {
    'data/*.json',
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

ui_page 'html/index.html'

provides {
    'ranch-system-omni'
}
