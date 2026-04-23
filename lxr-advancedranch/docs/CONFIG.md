# 🐺 Configuration Reference — lxr-advancedranch

> Every tunable value lives in `config.lua`. This document walks each section end-to-end.

---

## `Config.General`

- `autoSaveInterval` — milliseconds between dirty-flag flushes. Default 300000 (5 min). Lower values hit the DB harder; higher values risk more data loss on crash.
- `ownerOnlyUI` — if `true`, non-owners and non-staff cannot open the NUI on a ranch. Admins always can.

## `Config.Framework`

Either `'auto'` (detects on boot) or a specific framework key: `'lxr-core'`, `'rsg-core'`, `'vorp-core'`, `'redem-rp'`, `'qbr-core'`, `'qr-core'`, `'standalone'`.

## `Config.Locale`

Inline English and Georgian key tables. For overrides, edit `locales/en.lua` or `locales/ka.lua` — `Locales[lang][key]` wins over `Config.Locale[lang][key]`.

## `Config.Keys`

- `openUI` / `closeUI` — control hashes for raw `IsControlJustReleased` checks.
- `mapOpenUI` — the `RegisterKeyMapping` fallback (default `F5`). Players can rebind in FiveM/RedM settings.

## `Config.Livestock`

Per-species dictionary. Key fields:

| Field | Meaning |
|-------|---------|
| `needsDecay` | table with `hunger`, `thirst`, `cleanliness` decay per livestock tick |
| `breedingCooldownHours` | real hours between breedings |
| `gestationHours` | real hours from breed to birth |
| `litterMin` / `litterMax` | offspring count range |
| `lifespanDays` | age at which an animal dies of old age |
| `adultAgeDays` | age at which breeding becomes possible |
| `products` | array of item keys this species yields (e.g. `{'milk_jug','rawbeef','leather'}`) |

## `Config.Breeding`

- `possibleTraits` — all traits the system can roll (e.g. `'hardy'`, `'fast_gainer'`, `'high_yield'`, `'docile'`).
- `traitBonus` — per-trait modifier table. Recognized keys: `needsDecayMult` (scales decay rate, 0.85 = 15% slower), `sellPriceMult`, `breedChanceMult`, `offspringHealthBonus`.

## `Config.Workforce`

- `paydayIntervalHours` — real hours between automatic payouts. The payday ticker runs every 10 min; each worker is paid only when `(now - last_paid) >= intervalSec`.
- `roles` — per-role definition. `wage` is the base pay; the actual payment is scaled from 0.75× at zero morale to 1.25× at 100 morale.
- Permission flags on roles: `canHire`, `canFire`, `canAssign`, `canUpgrade`, `canSellAnimal`, `canBuyAnimal`. Used by `RanchCore.WorkerCan(ranchId, ident, capability)`.

## `Config.Discord`

Master switch `enabled`. `webhookUrl` drives audit notifications. `syncRolesToWorkforce` enables role-mirroring (requires an external bot fetch — the mapping table is authoritative once role IDs are loaded into `RanchCore._DiscordRoleCache`).

## `Config.Environment`

- `seasonLengthMinutes` — real minutes per season. Default 120. Lower for rapid test cycles.
- `weatherCycleMinutes` — how often weather rolls against the season's `weatherBias` distribution.
- `hazards.<key>` — each has `chance` (per weather roll), `damage` (livestock/pasture/structure), `allowedWeather` (only fires during these weather types).
- `soil` — global fertility defaults and per-tick regrowth rate.
- `wildlife.predatorAttackChance` — per-ranch attack probability per wildlife tick (every 15 min).

## `Config.Economy`

- `baseDemand` — multiplier applied before seasonal modifiers.
- `seasonalModifiers` — per-season, per-good price multiplier. The final price = `base × seasonal × demand`, clamped to `[minPriceClamp, maxPriceClamp]`.
- `townBoards` — each board defines location (`coords`, `heading`) and available goods. Contracts reroll on `contracts.rerollMinutes` (default 60).
- `auctions.houseCutPct` — auction house fee skimmed from the winning bid before payout.
- `productionChains` — input → output with `timeMinutes` duration and `xpPerBatch` reward.

## `Config.Progression`

- `xpCurveBase` / `xpCurveExponent` — `xpToLevel(n) = base × n^exp`. With defaults (100, 1.35), level 10 ≈ 2,400 XP, level 50 ≈ 67,000 XP, level 100 ≈ 510,000 XP (cumulative).
- `skills.<name>.bonuses` — table of `[levelThreshold] = 'description'`. Gameplay effects are wired in-code for `needsDecayMult` etc.; the description drives UI and Discord announcements.
- `xpGains` — lookup table; action keys map to the `AddXp` amount.
- `achievements` — stat-driven. `requirement` is a table of stat thresholds; once all are met, the achievement unlocks and `reward` cash is granted.
- `legacySystem` — on character creation, call `exports['lxr-advancedranch']:InheritLegacy(fromIdent, toIdent)` to carry over XP and stats at the configured percentage.

## `Config.Ranches`

- `seeds` — inserted on first boot. Each entry gets a stable ID matching the table key.
- `tiers` — caps per tier (`maxAnimals`, `maxWorkers`, `maxProps`) and the cash cost to upgrade. The top tier has `upgradeCost = nil` (terminal).

## `Config.Zoning`

Polygon zone parameters. `maxVerticesPerZone` is enforced client-side during editing. `zoneTypes` is used for the editor dropdown — extend freely.

## `Config.Props`

`whitelistedModels` is the hard allowlist. Any model not in this list is rejected server-side even if a client forges the NUI call.

## `Config.UI`

- `defaultTab` — which tab opens first. One of `'dashboard'`, `'livestock'`, `'workforce'`, `'economy'`, `'environment'`, `'progression'`, `'auction'`.
- `theme.primaryAccent` — gold hex. Match to your server branding if you rebrand (remember: this is a Lux Empire / wolves.land product; aesthetic rebranding beyond accent color requires a license extension).
- `feedMaxEntries` — activity feed buffer size in the dashboard.

## `Config.Admin`

- `acePermission` — ACE key admins must have. Default `'ranch.admin'`.
- `identifiers` — explicit allowlist by license/discord ID, useful for servers that don't use ACE groups.

## `Config.Database`

- `mode` — `'mysql'` or `'json'`.
- `prefix` — table prefix. Change ONLY before first boot or follow a manual migration.
- `autoMigrate` — creates tables on boot if missing.

## `Config.Security`

- `resourceNameGuard` — must match the resource folder name exactly.
- `kickOnNameMismatch` — refuse to start if the folder is renamed. Keep `true` in production.
- `nuiDataRateLimit` — max NUI pulls per minute per player. Reduce on high-concurrency servers.

## `Config.Performance`

Caching and tick intervals. The defaults are tuned for 150+ concurrent players on a single FXServer instance. See comments in `config.lua` for per-field guidance.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
