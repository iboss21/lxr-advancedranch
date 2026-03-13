# 🐺 LXR Ranch System — Configuration Reference

> **wolves.land — The Land of Wolves**  
> © 2026 iBoss21 / The Lux Empire | All Rights Reserved

---

All buyer-tunable settings are in `config.lua` at the root of the resource.  
**Do not edit** files in `client/`, `server/`, or `shared/` — they are escrow-protected.

---

## Config.ServerInfo

Branding fields shown in logs and notifications.

| Key | Type | Description |
|-----|------|-------------|
| `name` | string | Server display name |
| `tagline` | string | Server tagline |
| `website` | string | Server website URL |
| `discord` | string | Discord invite link |

---

## Config.Framework

```lua
Config.Framework = 'auto'
```

| Value | Description |
|-------|-------------|
| `'auto'` | Auto-detects framework at startup (recommended) |
| `'lxr-core'` | Force LXR Core |
| `'rsg-core'` | Force RSG Core |
| `'vorp_core'` | Force VORP Core |
| `'redem_roleplay'` | Force RedEM:RP |
| `'qbr-core'` | Force QBR Core |
| `'qr-core'` | Force QR Core |
| `'standalone'` | No framework (minimal functionality) |

---

## Config.Debug / Config.Dev

```lua
Config.Debug = false        -- enable debug prints
Config.Dev.SkipNameGuard = false  -- ⚠ NEVER true in production
```

---

## Config.Admin

```lua
Config.Admin = {
    AcePermission = 'ranch.admin',
    Identifiers   = {},
    AllowConsole  = true
}
```

Add your identifier to `Identifiers` for direct admin access without ace permissions.

---

## Config.Discord

```lua
Config.Discord = {
    BotToken    = '',   -- Discord bot token
    GuildId     = '',   -- Guild (server) ID
    WebhookUrl  = ''    -- Webhook URL for alerts
}
```

---

## Config.Ranches

| Key | Default | Description |
|-----|---------|-------------|
| `MaxPerPlayer` | `4` | Max ranches per player |
| `ExpansionCostPerAcre` | `125` | Cost per acre expansion |
| `MergeCooldownHours` | `12` | Hours between ranch merges |

---

## Config.Livestock

Controls animal species, needs decay, breeding thresholds, and trust values.

```lua
Config.Livestock.NeedsTickMinutes = 15   -- how often needs decay
Config.Livestock.TrustThresholds  = { hostile=0.2, wary=0.45, calm=0.7, bonded=0.9 }
```

---

## Config.Economy

```lua
Config.Economy.DynamicPricing    -- base demand & seasonal modifiers
Config.Economy.Contracts.maxActive = 5
Config.Economy.Auctions.enable    = true
```

---

## Config.Environment

```lua
Config.Environment.SeasonLengthMinutes = 120   -- real-time minutes per season
```

---

## Config.Workforce

```lua
Config.Workforce.DailyWageBase   = 8
Config.Workforce.EnableAIHands   = true
```

---

## Config.Progression

```lua
Config.Progression.LevelThresholds = { 0, 200, 500, 900, 1400, 2000 }
Config.Progression.XPPerContract   = 50
```

---

*🐺 wolves.land — The Land of Wolves*
