# 🐺 Changelog — lxr-advancedranch

Versioning follows [Semantic Versioning](https://semver.org). Breaking changes bump the major; new features bump the minor; fixes bump the patch.

---

## [1.0.1] — 2026-04-23

### Fixed — NUI layout

- **Auction row:** the bid input and Bid button in the last grid cell were stacking vertically because the wrapper `<div>` had no flex context. Added `.auction-row > div:last-child { display: flex; gap: 8px; align-items: center; }` so they render side-by-side as intended.
- **Auction lot / body columns:** `.au-lot` was wrapping its two-word lot type across multiple lines in narrower viewports; `.au-body` was cramming seller + bidder metadata into a 1-char-wide column. Both now have `min-width` floors (160px and 180px) and `.au-lot` gets `white-space: nowrap`.
- **Create Lot form:** rigid 4-column grid (`150px 1fr 140px auto`) overflowed on viewports under ~700px. Replaced with a flex layout using `flex-wrap: wrap` and per-field `flex` basis — the row now degrades gracefully.
- **Header brand text:** "Ranch Journal" / "The Land of Wolves" subtitle was wrapping the Great Vibes script mid-word on narrow widths. Added `white-space: nowrap` to `.brand-title` and `.brand-sub`, plus `min-width: 0` on the flex container so other header sections can still shrink properly.
- **Panel subtitle (ranch name):** "Redwood Creek Ranch" was breaking across two lines in the dashboard panel header. Added `white-space: nowrap` to `.panel-sub`.

None of these touched `server/`, `client/`, `shared/`, or `config.lua` — pure NUI polish. No DB migration required. Drop-in replacement.

---

## [1.0.0] — 2026-04-23

Initial public release.

### Livestock
- Six species (cattle, horse, sheep, pig, chicken, goat) with per-species needs decay, lifespans, breeding cooldowns, gestation timers.
- Ten possible traits with per-trait bonus modifiers (`needsDecayMult`, `sellPriceMult`, `breedChanceMult`, `offspringHealthBonus`).
- Trait inheritance from parents with mutation chance; bloodline tracking.
- Server-authoritative feed / water / groom / milk / shear / slaughter with rate limiting.
- Pregnancy resolution; auto-birth at due time with litter size roll.
- Recurring product yields (milk, eggs, wool) based on last-product timestamp.

### Workforce
- Eight roles (Owner, Foreman, Hand, Wrangler, Dairyman, Butcher, Veterinarian, Teamster).
- Per-role capability flags for fine-grained permission checks.
- Morale decay, fatigue tick, passive morale recovery on rest periods.
- Payday ticker with wage scaling (0.75×–1.25× based on morale).
- Insufficient funds drop morale across the roster.
- Discord role sync hook (external bot token fetch; sync map authoritative once loaded).

### Economy
- Dynamic pricing with seasonal modifiers and demand multiplier; clamped to `[40%, 160%]` of base.
- Five town boards (Valentine, Rhodes, Blackwater, Saint Denis, Strawberry) with hourly reroll.
- Contract lifecycle (`open → active → completed | expired | failed`); penalty on expiration.
- Auction house with DB-row escrow — no item duplication possible.
- 5% house cut on sold auctions; automatic refund of outbid bidders.
- Three production chains (dairy, butcher, wool) with async completion timers and XP rewards.

### Environment
- Four-season cycle (default 120 min per season).
- Weighted weather bias per season; weather rerolls on a 15-min ticker.
- Five hazard types (lightning, flood, drought, blizzard, dust storm) with per-hazard `allowedWeather` gates.
- Per-ranch soil fertility with regrowth rate.
- Predator-attack ticker against livestock.
- Environment state persisted as KV rows.

### Progression
- Five skill trees (Husbandry, Veterinary, Wrangler, Butcher, Teamster).
- Cumulative XP curve `base × n^exp` (tunable).
- Tier-unlock bonuses at levels 10/25/50/75/100.
- Six stat-driven achievements with cash rewards.
- Legacy/heir system migrates 25% XP and 10% items to a new character.

### Ranches
- Five seed ranches (Redwood, Tumbleweed, Valentine, Annesburg, Strawberry) inserted on first boot.
- Four tiers with ascending caps on animals, workers, props.
- Ledger writes on every balance-touching event (deposits, withdrawals, payroll, auction payouts, upgrades, transfers).
- Ownership transfer with full audit trail.

### Zoning & Props
- Polygon zone editor (ENTER to drop vertex, BACKSPACE to undo, `/pzsave` to commit).
- Eight zone types (`pasture`, `corral`, `barn`, `dairy`, `slaughter`, `crops`, `storage`, `custom`).
- Whitelisted prop mapper with per-tier caps.
- Ground snap, Q/E rotation, scroll for distance, ENTER to confirm.

### NUI
- Seven-tab parchment dashboard (Dashboard, Livestock, Workforce, Economy, Environment, Progression, Auction).
- Playfair Display + Great Vibes + Crimson Text + Special Elite typography.
- Torn-edge title card, aged-gold accents, `--wl-*` CSS variable system.
- Vanilla JS (no frameworks, no build step).
- ESC always closes.
- Activity feed derived from ledger + deltas.
- Animal detail view with action buttons.
- Live auction bidding with countdown timers.

### Infrastructure
- MariaDB via oxmysql; auto-migration on boot.
- JSON fallback for dev / standalone.
- Ten tables with InnoDB, utf8mb4, foreign keys with `ON DELETE CASCADE`.
- Dirty-flag batched saves; 5-min autosave ticker.
- Resource-name tamper guard refuses to boot if folder is renamed.
- ACE admin gating (`ranch.admin`) with identifier allowlist fallback.
- Full Discord webhook trail for ownership, payroll, hazards, auctions.
- Multi-framework bridge (LXR, RSG, VORP, RedEM:RP, QBR, QR, standalone).

### Localization
- English and Georgian bundled. Native-quality Georgian translations — not machine-generated.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
