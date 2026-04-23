# 🐺 Installation Guide — lxr-advancedranch

> **Developer:** iBoss21 / The Lux Empire · [wolves.land](https://www.wolves.land) · [Discord](https://discord.gg/CrKcWdfd3A)

---

## Prerequisites

- RedM server running FXServer artifact **5848+**
- Database: **MariaDB 10.4+** or **MySQL 8+** (JSON mode works for dev/standalone)
- [**oxmysql**](https://github.com/overextended/oxmysql) (not required for JSON mode)
- A supported framework (or `standalone`):
  - LXR Core · RSG Core · VORP Core · RedEM:RP · QBR Core · QR Core

---

## Step 1 — Drop the Resource

Unzip `lxr-advancedranch.zip` into your server's `resources/` folder. Confirm the folder is named **exactly** `lxr-advancedranch` — the resource guard will refuse to start if the folder is renamed (this prevents leaks from being redeployed).

```
resources/
└── lxr-advancedranch/
    ├── fxmanifest.lua
    ├── config.lua
    ├── client/
    ├── server/
    ├── shared/
    ├── html/
    ├── locales/
    ├── docs/
    └── sql/
```

---

## Step 2 — Database

### Option A: Automatic (recommended)

Set these defaults in `config.lua`:

```lua
Config.Database = {
    mode             = 'mysql',
    prefix           = 'lxr_ranch_',
    autoMigrate      = true,
    ...
}
```

Ensure `oxmysql` is running **before** `lxr-advancedranch` in `server.cfg`. All tables are created on first boot.

### Option B: Manual

Set `autoMigrate = false` and import `sql/schema.sql`:

```bash
mysql -u <user> -p <database> < resources/lxr-advancedranch/sql/schema.sql
```

### Option C: JSON (dev only)

```lua
Config.Database = { mode = 'json', jsonFallbackPath = 'data/', ... }
```

Not recommended for production — lacks atomicity and indexing.

---

## Step 3 — server.cfg

```cfg
# order matters
ensure oxmysql
ensure lxr-advancedranch

# admin permission
add_ace group.admin ranch.admin allow
```

If you want per-identifier admin without ACE groups, add identifiers to `Config.Admin.identifiers`.

---

## Step 4 — Framework

By default the resource auto-detects. To force one:

```lua
Config.Framework = 'rsg-core'   -- or 'lxr-core', 'vorp-core', etc.
```

See `docs/FRAMEWORKS.md` for per-framework notes, especially if inventory item keys differ on your server.

---

## Step 5 — Discord (optional)

For webhook notifications (ownership transfers, auctions, payroll, hazards):

```lua
Config.Discord = {
    enabled    = true,
    webhookUrl = 'https://discord.com/api/webhooks/...',
    guildId    = 'your-guild-id',
    ...
}
```

For Discord role → workforce role sync, add your bot token via `server.cfg` rather than hard-coding in `config.lua`:

```cfg
set lxr_discord_token "your-bot-token"
```

Then your sync layer fetches roles using that token (implementation is server-operator specific — `RanchCore.SyncDiscordRolesForPlayer` is the hook).

---

## Step 6 — First Boot

Start the server. Expected console output:

```
[lxr-advancedranch] framework detected: rsg-core
[lxr-advancedranch] DB migration complete — 10 tables verified
[lxr-advancedranch] Seed ranches inserted: 5
[lxr-advancedranch] Environment loaded — season: spring, weather: clear
[lxr-advancedranch] Tickers started (livestock, environment, economy, auctions, workforce)
```

Join the server and press **F5** to open the ranch journal.

---

## Step 7 — Admin Test

In-game, run:

```
/ranchdump
```

Should print ranch/animal/worker/contract/auction counts. If admin gate fails, check your ACE config or `Config.Admin.identifiers`.

---

## Troubleshooting

See `docs/TROUBLESHOOTING.md` for common issues: framework not detecting, DB connection failures, NUI not rendering, resource refusing to start due to rename, etc.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
