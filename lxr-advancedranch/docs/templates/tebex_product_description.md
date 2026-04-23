# 🐺 lxr-advancedranch — Advanced Ranch Management for RedM

*Run a living ranching empire. Breed legendary bloodlines. Weather four real seasons. Bid at the auction house. Pass the empire to your heir.*

---

## Why This Script

Every RedM ranch script ships a corral, an NPC, and a buy-button. **lxr-advancedranch** ships a living economy: livestock with genetics, a workforce with morale, town-board contracts, a live auction house with DB-escrow, seasonal weather with hazards, skill trees with tier unlocks, and a legacy system that lets players hand an empire to their next character.

Battle-tested on **wolves.land**, the live Georgian hardcore RedM server. Written to the same engineering standard as every resource in The Lux Empire catalog: server-authoritative, oxmysql-backed, framework-bridged, and wrapped in a parchment-aesthetic NUI.

---

## Features at a Glance

### 🐄 Livestock
- **6 species** — cattle, horse, sheep, pig, chicken, goat — each with unique decay rates, lifespans, and gestation timers
- **10 heritable traits** (hardy, fast_gainer, high_yield, docile, and more) with bonus modifiers for decay, sell price, breeding, offspring health
- **Full breeding system** — sex-aware, cooldown-gated, trait-inheriting, gestation-tracked
- **Server-authoritative interactions** — feed, water, groom, milk, shear, slaughter (rate-limited)
- **Bloodline tracking** — every animal carries its lineage

### 👥 Workforce
- **8 roles** — Owner, Foreman, Hand, Wrangler, Dairyman, Butcher, Veterinarian, Teamster
- **Morale-scaled payroll** — wages pay 0.75×–1.25× based on worker morale
- **Fatigue simulation** — workers tire out, recover on rest
- **Capability-gated actions** — foremen can hire; hands can't; butchers can slaughter; vets can cure
- **Discord role sync** — optional

### 💰 Economy
- **Dynamic pricing** — seasonal modifiers, demand multipliers, clamped to [40%, 160%]
- **5 town boards** — Valentine, Rhodes, Blackwater, Saint Denis, Strawberry — contracts reroll hourly
- **Auction house** — DB-escrowed lots, 5% house cut, auto-refund of outbid bidders
- **3 production chains** — dairy, butcher, wool — convert raw goods to finished products
- **Full ledger** — every balance movement tracked and queryable

### 🌦 Environment
- **4 real seasons** — rotate on configurable real-time cycle (default 120 min/season)
- **5 hazards** — lightning, flood, drought, blizzard, dust storm — gated by weather type
- **Soil fertility** — per-ranch, regrows over time
- **Wildlife predators** — periodic attacks on livestock

### 📈 Progression
- **5 skill trees** — Husbandry, Veterinary, Wrangler, Butcher, Teamster
- **Tier-unlock bonuses** at levels 10/25/50/75/100
- **6 achievements** — stat-driven, with cash rewards
- **Legacy system** — pass 25% XP and 10% items to your next character

### 🗺 Zoning & Props
- **Polygon zone editor** — in-world, ENTER to drop vertices
- **8 zone types** — pasture, corral, barn, dairy, slaughter, crops, storage, custom
- **Whitelisted prop mapper** — Q/E rotate, scroll for distance, ENTER to confirm

### 🎨 NUI
- **7-tab parchment dashboard** — Dashboard, Livestock, Workforce, Economy, Environment, Progression, Auction
- **wolves.land aesthetic** — Playfair Display + Great Vibes + Crimson Text + Special Elite, aged-gold accents, torn-parchment cards on dark overlay
- **Vanilla JS** — no React, no build step, ESC always closes

### 🌍 Localization
- **English + Georgian** bundled out of the box — native-quality Georgian translations, not machine-generated

---

## Framework Support

Auto-detects on boot. Compatible with:

| Framework | Status |
|-----------|--------|
| LXR Core | Primary |
| RSG Core | Primary |
| VORP Core | Compatible |
| RedEM:RP | Compatible |
| QBR Core | Compatible |
| QR Core | Compatible |
| Standalone | Fallback |

---

## What You Get

- Full source (client/server/shared/locales/docs/html/sql), with `config.lua`, `locales/*`, `sql/*`, `html/*`, and `docs/*` left unencrypted for configuration.
- Auto-migrating MariaDB schema (or JSON fallback for dev).
- Complete admin command suite (25+ commands).
- Comprehensive docs: `INSTALL`, `CONFIG`, `COMMANDS`, `FRAMEWORKS`, `EVENTS`, `TROUBLESHOOTING`, `CHANGELOG`.
- Discord webhook integration for ownership, payroll, hazards, auctions.
- English + Georgian locale files.
- One server license (one `server.cfg`).

---

## Technical Requirements

- FXServer artifact **5848+**
- **oxmysql** (or JSON mode for dev)
- MariaDB 10.4+ / MySQL 8+ (for MySQL mode)
- A supported framework (or standalone)

---

## Support

- 💬 **Discord:** [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)
- 🌐 **Website:** [wolves.land](https://www.wolves.land)
- 🛒 **Store:** [theluxempire.tebex.io](https://theluxempire.tebex.io)

---

## License

Proprietary. One Tebex purchase = one server license. Redistribution, repackaging, leaking, resale, or decryption attempts terminate your license immediately and may result in permanent bans from The Lux Empire catalog.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
