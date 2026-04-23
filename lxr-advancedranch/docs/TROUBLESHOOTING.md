# 🐺 Troubleshooting — lxr-advancedranch

---

## The resource refuses to start

**Symptom.** Console prints `[lxr-advancedranch] FATAL: resource renamed from 'lxr-advancedranch' — halting.` and the resource stops.

**Cause.** The folder is not named exactly `lxr-advancedranch`. This guard blocks redistribution and also trips on accidental renames.

**Fix.** Rename the folder back to `lxr-advancedranch`. If you need a legitimate rename for a fork, update `Config.Security.resourceNameGuard` and the `EXPECTED_NAME` constant at the top of `server/sv_main.lua`.

---

## Framework not detected

**Symptom.** Console prints `framework detected: standalone` on a server that clearly runs RSG (or similar).

**Cause.** `lxr-advancedranch` started before your framework's resource reached state `started`. Detection is a one-shot probe on boot.

**Fix.** In `server.cfg`, ensure the framework `ensure` line comes before `ensure lxr-advancedranch`. If the framework is lazy-loaded, set `Config.Framework = 'rsg-core'` (or whatever key) to skip detection.

---

## `oxmysql was unable to establish a connection`

**Symptom.** Ranch tables never create; `DB.Ready` stays false; NUI shows empty data.

**Cause.** `oxmysql` can't reach your DB. Not an `lxr-advancedranch` bug.

**Fix.** Check `set mysql_connection_string "..."` in `server.cfg`. For MariaDB on Debian 12 (wolves.land stack), confirm the `mariadb` service is running and listening on the configured port:

```bash
systemctl status mariadb
ss -tlnp | grep 3306
```

Temporary workaround: set `Config.Database.mode = 'json'` to run against the file fallback. Not suitable for production.

---

## NUI opens but all tabs show empty data

**Symptom.** F5 opens the journal, tabs switch, but lists and cards are blank.

**Cause.** Either:
- The player isn't associated with any ranch and `Config.General.ownerOnlyUI = true`.
- NUI rate limiter is throttling `requestUIData`.
- Framework bridge returned `nil` for the player — inventory and money calls fail.

**Fix.** Run `/ranchdump` in rcon to confirm ranches exist. Check console for `[lxr-advancedranch] NUI throttled for src=N` — raise `Config.Security.nuiDataRateLimit` if you see it frequently. Confirm the framework matches your server.

---

## Resource refuses escrow upload / Tebex rejects

**Symptom.** Tebex escrow CLI rejects the upload.

**Cause.** Almost always: you edited a protected file. The following paths are `escrow_ignore` in `fxmanifest.lua` and remain editable:

```
config.lua
locales/*
sql/*
docs/*
html/*
```

**Fix.** Revert any edits to `server/`, `client/`, or `shared/database.lua`, `shared/framework.lua`, `shared/utils.lua`. If you genuinely need a code-level change, open a support ticket — custom forks are not permitted under the standard license.

---

## Workers aren't being paid

**Symptom.** Payday webhook never fires; worker `last_paid` stays at 0.

**Cause.** Either ranch balance is empty (payday fails silently and drops morale instead), or the payday interval hasn't elapsed yet.

**Fix.** Payday only fires when `now - last_paid >= Config.Workforce.paydayIntervalHours * 3600`. For testing, set `paydayIntervalHours = 0.05` (3 min) and watch the ticker. Confirm `ranch.balance > 0` via `/ranchdump`.

---

## Discord webhook not firing

**Symptom.** Ownership transfers, auctions, etc., don't appear in Discord.

**Cause.** Usually:
- `Config.Discord.enabled = false`.
- Webhook URL is wrong or the Discord channel was deleted.
- The server can't reach `discord.com` — firewall or egress restriction.

**Fix.** Verify with:

```bash
curl -X POST -H "Content-Type: application/json" \
     -d '{"content":"test"}' \
     https://discord.com/api/webhooks/.../...
```

If `200` returns and you see the test message, the config or URL is wrong. If you get a connection error, your host is blocking outbound HTTPS.

---

## MariaDB vs MySQL ENUM edge cases

**Symptom.** On MySQL 8+ only: `CREATE TABLE ... ENUM(...) DEFAULT 'xxx'` fails if `xxx` isn't one of the listed values.

**Cause.** MySQL 8's stricter `sql_mode` (`STRICT_TRANS_TABLES`). MariaDB is more permissive.

**Fix.** Every ENUM in `sql/schema.sql` has a valid default. If you're hitting this, your DB has diverged from the shipped schema. Drop the `lxr_ranch_*` tables and let auto-migrate rebuild, or rerun `sql/schema.sql` cleanly.

---

## Prop placement fails silently

**Symptom.** `/ranchprop prop_barrel_01a` starts the editor, you press ENTER, nothing happens.

**Cause.** Model isn't in `Config.Props.whitelistedModels`. The server rejects the placement request without a toast (the NUI isn't in scope during placement).

**Fix.** Add the model to the whitelist, restart the resource. Whitelist is deliberately strict to prevent trolls from placing `prop_giant_cactus_01` on main roads.

---

## Georgian characters render as boxes

**Symptom.** Activity feed or locale strings show `□□□` instead of Georgian text.

**Cause.** Browser or Chromium Embedded Framework is missing the font. Google Fonts `Playfair Display` / `Crimson Text` have Georgian glyph coverage; loading should be automatic.

**Fix.** Confirm outbound HTTPS to `fonts.googleapis.com` and `fonts.gstatic.com` from the client. If your players' clients are behind a restrictive firewall, self-host the fonts under `html/fonts/` and rewrite the `<link>` in `html/index.html`.

---

## Other issues

Open a ticket in [Discord](https://discord.gg/CrKcWdfd3A). Include:

- FXServer artifact version (`version` in console).
- Framework and version.
- Full console output from `ensure lxr-advancedranch` to first error.
- Your `config.lua` (redact webhook URL and tokens).
- Steps to reproduce.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
