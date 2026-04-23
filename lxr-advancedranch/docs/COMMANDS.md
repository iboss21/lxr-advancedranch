# 🐺 Admin Command Reference — lxr-advancedranch

All commands require **`ranch.admin`** ACE permission or an entry in `Config.Admin.identifiers`. Every invocation is logged to console and, if `Config.Admin.logToWebhook = true`, to the Discord webhook.

---

## Ranch Management

### `/ranchcreate <label> [ownerIdentifier]`
Creates a new ranch at your current coordinates. If `ownerIdentifier` is omitted, the ranch is left unowned. Seeds tier 1.

### `/ranchdelete <ranchId>`
Permanently deletes a ranch. Cascades to animals, workforce, zones, props, ledger, and auctions.

### `/ranchtransfer <ranchId> <newOwnerIdentifier>`
Moves ownership. Writes to the ledger; notifies Discord.

### `/ranchupgrade <ranchId>`
Bumps the tier by one, deducting `Config.Ranches.tiers[nextTier].upgradeCost` from the ranch balance. Fails if the ranch is at the top tier or has insufficient funds.

### `/ranchsetrole <ranchId> <discordRoleId>`
Binds a Discord role ID to a ranch's meta (`ranch.meta.discordRoleId`). Used by the Discord sync layer.

---

## Environment

### `/ranchseason <spring|summer|autumn|winter>`
Force-sets the current season. Broadcasts the new snapshot.

### `/ranchweather [weatherType]`
With an argument: sets weather directly. Without: rerolls weather using the current season's weighted bias.

### `/ranchhazard <hazardKey> [ranchId]`
Triggers a hazard (e.g. `lightning`, `flood`, `drought`, `blizzard`, `duststorm`). Omitting `ranchId` applies globally.

---

## Livestock

### `/ranchanimaladd <ranchId> <species> [count]`
Adds livestock of the given species. `count` defaults to 1. Sex alternates male/female.

### `/ranchanimaldel <ranchId> <animalId>`
Removes an animal by ID.

---

## Workforce

### `/ranchassign <ranchId> <identifier> <role>`
If the identifier isn't already on the roster, they're hired. If they are, their role is updated.

### `/ranchfire <ranchId> <identifier>`
Dismisses a worker. Ledger-logged.

---

## Contracts & Progression

### `/ranchcontract`
Manually rerolls all town boards, discarding expired contracts and topping each board back up to three open slots.

### `/ranchxp <identifier> <skill> <amount>`
Grants XP directly. Useful for testing or rewarding events. `skill` must be one of `Husbandry`, `Veterinary`, `Wrangler`, `Butcher`, `Teamster`.

---

## Zoning

### `/pzcreate [zoneName]`
Starts the in-world polygon zone editor. While active:
- **ENTER** — drop a vertex at your current position.
- **BACKSPACE** — remove the last vertex.
- `/pzsave` — commit the zone (requires ≥3 vertices and you must be inside a ranch boundary).
- `/pzcancel` — abort without saving.

### `/pzsave` / `/pzcancel`
See above.

---

## Props

### `/ranchprop <model> [ranchId]`
Starts the prop placement editor for a whitelisted model. Controls:
- **Q / E** — rotate.
- **Scroll wheel** — distance from player.
- **ENTER** — confirm placement.
- **BACKSPACE** — cancel.

Non-whitelisted models are rejected client-side and again server-side.

### `/ranchpropdel [propId]`
With ID: deletes that specific prop. Without: deletes the nearest owned prop within 9m of the admin.

---

## Diagnostic

### `/ranchdump`
Console-only (available from rcon). Prints counts of ranches, animals, workers, contracts, auctions, plus the current season/weather.

### `/ranchcoord`
Prints your current coordinates and heading. Useful for placing seed ranches or debug zones.

### `/ranchdebug`
Toggles a vertical gold beam at the center of every ranch for quick visual debugging.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
