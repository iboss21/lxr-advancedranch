# 🐺 lxr-advancedranch

**Advanced Ranch Management System for RedM** — a production-grade livestock, workforce, economy, and progression framework for The Land of Wolves and any RSG-Core / LXR-Core / VORP / RedEM server.

> **Developer:** iBoss21 / The Lux Empire
> **Website:** [wolves.land](https://www.wolves.land) · **Discord:** [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A) · **Store:** [theluxempire.tebex.io](https://theluxempire.tebex.io)
> **Version:** 1.0.0 · **License:** Proprietary — The Lux Empire

---

## What's Inside

A self-contained ranching universe: six livestock species with real genetics and breeding, an eight-role workforce with morale-scaled payroll, four-season world weather with five hazard types, town-board delivery contracts, a live auction house with DB-row escrow, three production chains, five skill trees with tier-unlock bonuses, six achievements, a legacy/heir XP inheritance system, polygon zoning, a whitelisted prop mapper, and a parchment-aesthetic NUI dashboard with seven tabs.

Backed by MariaDB via oxmysql (JSON fallback for dev), server-authoritative networking, resource-name tamper guards, ACE admin gating, and a full Discord webhook trail for ownership, payroll, hazards, and auctions.

---

## Core Systems

**Livestock.** Six species (cattle, horse, sheep, pig, chicken, goat) with per-species decay curves, lifespans, breeding cooldowns, and gestation. Traits inherit from parents with mutation chance; trait modifiers scale needs decay and sell prices. Server-authoritative feed/water/groom/milk/shear/slaughter grants XP to the appropriate skill.

**Workforce.** Eight roles (Owner, Foreman, Hand, Wrangler, Dairyman, Butcher, Veterinarian, Teamster) with capability flags (`canHire`, `canFire`, `canSellAnimal`, etc.). Morale decays over time, fatigue recovers passively, wages scale from 0.75× to 1.25× based on morale. Payday pulls from the ranch balance; insufficient funds drop worker morale.

**Economy.** Dynamic seasonal pricing with clamps (40% floor, 160% ceiling). Five town boards (Valentine, Rhodes, Blackwater, Saint Denis, Strawberry) generate delivery contracts that reroll hourly. Auction house uses DB-row escrow — no item duplication possible, 5% house cut on sale. Three production chains (dairy, butcher, wool) convert raw goods to finished products.

**Environment.** Four seasons rotate on a configurable real-time interval (default 120 min/season). Weather rolls use per-season weighted bias. Five hazards (lightning, flood, drought, blizzard, dust storm) trigger on matching weather. Soil fertility regrows per-ranch. Wildlife predators periodically attack livestock.

**Progression.** Five skill trees (Husbandry, Veterinary, Wrangler, Butcher, Teamster), each with tier-unlock bonuses at levels 10/25/50/75/100. Cumulative XP curve: `base × n^exp`. Six achievements with stat-driven requirements. Legacy/heir system carries 25% XP and 10% items to a new character.

**Zoning & Props.** Polygon zone editor (ENTER to place vertex, BACKSPACE to undo, `/pzsave` to commit). Eight zone types. Whitelisted prop mapper with ground snap, Q/E rotation, scroll for distance, per-tier caps.

**NUI.** Seven tabs (Dashboard, Livestock, Workforce, Economy, Environment, Progression, Auction). Parchment aesthetic on dark overlay. Torn-edge title card, aged-gold accents, Playfair Display + Great Vibes + Crimson Text + Special Elite typography. Vanilla JS. ESC always closes.

---

## Installation

1. Drop the folder into your `resources/` directory as `lxr-advancedranch`.
2. Install [oxmysql](https://github.com/overextended/oxmysql) if you're not already running it.
3. Add to `server.cfg`:
   ```
   ensure oxmysql
   ensure lxr-advancedranch
   ```
4. Start the server once. If `Config.Database.autoMigrate = true` (default), all tables are created on boot. Otherwise run `sql/schema.sql` manually.
5. Grant admin ACE permission:
   ```
   add_ace group.admin ranch.admin allow
   ```
6. Edit `config.lua` — seed ranches, Discord webhooks, framework mode if not auto.
7. Open the ranch journal in-game with **F5** (default).

See `docs/INSTALL.md` for detailed walkthrough.

---

## Framework Support

Auto-detects at startup; manual override via `Config.Framework`.

| Framework  | Status   |
| ---------- | -------- |
| LXR Core   | Primary  |
| RSG Core   | Primary  |
| VORP Core  | Compatible |
| RedEM:RP   | Compatible |
| QBR Core   | Compatible |
| QR Core    | Compatible |
| Standalone | Fallback |

See `docs/FRAMEWORKS.md` for framework-specific notes.

---

## Configuration

All tunable values live in `config.lua`. Protected files (server/, client/, shared/framework.lua, shared/utils.lua, shared/database.lua) read from `Config.*` at runtime and are packaged behind Tebex escrow. See `docs/CONFIG.md` for a per-section walkthrough.

Never edit files under `server/`, `client/`, or `shared/database.lua` — escrow will reject it and your server will refuse to start the resource.

---

## Documentation

| File                       | Contents                                      |
| -------------------------- | --------------------------------------------- |
| `docs/INSTALL.md`          | Step-by-step installation                     |
| `docs/CONFIG.md`           | Configuration reference                       |
| `docs/COMMANDS.md`         | Full admin command reference                  |
| `docs/FRAMEWORKS.md`       | Framework integration notes                   |
| `docs/EVENTS.md`           | Net event + export reference                  |
| `docs/TROUBLESHOOTING.md`  | Common issues and fixes                       |
| `docs/CHANGELOG.md`        | Version history                               |

---

## Support

- **Discord:** [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)
- **Tebex:** [theluxempire.tebex.io](https://theluxempire.tebex.io)
- Open a ticket with: server type, framework, `server.cfg` resource block, full console on first start, and steps to reproduce.

---

## License

Proprietary. One server per Tebex license. Redistribution, repackaging, leaking, or decryption attempts violate the EULA and terminate your license immediately.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
