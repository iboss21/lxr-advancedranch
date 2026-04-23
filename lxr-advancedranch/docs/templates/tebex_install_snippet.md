# 🐺 Quick Install — lxr-advancedranch

*5-minute setup. Full walkthrough in `docs/INSTALL.md`.*

---

## 1. Drop It In

Unzip into `resources/lxr-advancedranch`. **Folder name must match exactly** — the resource refuses to start otherwise.

## 2. server.cfg

```cfg
ensure oxmysql
ensure lxr-advancedranch

add_ace group.admin ranch.admin allow
```

Make sure `oxmysql` loads **before** `lxr-advancedranch`.

## 3. Database

Tables auto-create on first boot (`Config.Database.autoMigrate = true`). No manual steps needed.

If you prefer manual migration, set `autoMigrate = false` and run:

```bash
mysql -u <user> -p <database> < resources/lxr-advancedranch/sql/schema.sql
```

## 4. Configure

Open `config.lua`:

- **Framework** — leave as `'auto'` or force it: `Config.Framework = 'rsg-core'`
- **Discord webhook** — paste your URL into `Config.Discord.webhookUrl`
- **Seed ranches** — edit `Config.Ranches.seeds` to match your map

## 5. Play

Start the server. Join. Press **F5** to open the ranch journal.

First admin commands to try:
```
/ranchdump
/ranchcreate "My First Ranch"
/ranchanimaladd <ranchId> cattle 5
```

---

## Something Broken?

Check `docs/TROUBLESHOOTING.md` first. If you're still stuck, open a ticket in [our Discord](https://discord.gg/CrKcWdfd3A) with:

- FXServer artifact version
- Framework and version
- Full console output from `ensure lxr-advancedranch`
- Steps to reproduce

---

© 2026 iBoss21 / The Lux Empire · **wolves.land**
