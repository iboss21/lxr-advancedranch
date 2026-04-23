# 🐺 Events & Exports Reference — lxr-advancedranch

All event names are auto-namespaced via `RanchCore.EventName(scope, name)` which resolves to `lxr-advancedranch:<scope>:<name>`. If you rename the resource (you shouldn't — the guard will refuse to boot), update `Config.Security.resourceNameGuard` and `EXPECTED_NAME` accordingly.

---

## Client → Server (`NetEvent`)

Registered in `sv_main.lua`, `sv_livestock.lua`, `sv_economy.lua`, `sv_progression.lua`, `sv_admin.lua`. Every handler validates `source` via the `authPlayerOnRanch` helper where ranch membership is required.

| Event | Payload | Purpose |
|-------|---------|---------|
| `client:requestBootstrap` | `{}` | Initial data pull on player spawn — ranches, environment, personal progression. |
| `client:requestUIData` | `{ tab = 'dashboard' | ... }` | Tab-scoped dashboard pull. Rate-limited per player. |
| `client:interactAnimal` | `{ animalId, action = 'feed'|'water'|'groom'|'milk'|'shear'|'slaughter' }` | Server-authoritative animal interaction. Updates needs, awards XP, yields items. |
| `client:breedAnimals` | `{ ranchId, aId, bId }` | Lock a breeding pair if cooldown, sex, and species checks pass. |
| `client:acceptContract` | `{ contractId }` | Player accepts an open town-board contract. |
| `client:deliverContract` | `{ contractId }` | Player turns in goods at the contract's town. Validates inventory, pays out. |
| `client:createAuction` | `{ ranchId, lotType, lotRef, startBid }` | Opens a new auction lot (escrowed in DB row). |
| `client:placeBid` | `{ auctionId, amount }` | Raises the current bid; refunds the prior high bidder. |
| `client:startProduction` | `{ chainKey }` | Starts a production batch; deducts inputs, schedules completion. |
| `client:zoneSaved` | `{ ranchId, zoneType, vertices }` | Commits a polygon zone after `/pzsave`. |
| `client:propPlaced` | `{ ranchId, model, x, y, z, heading }` | Registers a placed prop. |

---

## Server → Client (broadcast or per-source)

Emitted via `RanchCore.Broadcast(...)` for global updates and `TriggerClientEvent` for per-source payloads.

### Bootstrap & Ranch Lifecycle

| Event | Payload | Recipients |
|-------|---------|------------|
| `server:bootstrap` | `{ ranches, env, tierLabels, gameplayFlags }` | The requesting source. |
| `server:ranchAdded` | `{ ranch }` | All. |
| `server:ranchDeleted` | `{ ranchId }` | All. |

### Livestock

| Event | Payload |
|-------|---------|
| `server:animalAdded` | `{ animal }` |
| `server:animalRemoved` | `{ id, ranchId, reason }` |
| `server:animalUpdated` | `{ animal }` |
| `server:animalBred` | `{ motherId, fatherId, dueAt }` |

### Workforce

| Event | Payload |
|-------|---------|
| `server:workerHired` | `{ ranchId, worker }` |
| `server:workerFired` | `{ ranchId, identifier }` |
| `server:workerRoleChanged` | `{ ranchId, identifier, role }` |

### Economy

| Event | Payload |
|-------|---------|
| `server:contractUpdated` | `{ contract }` |
| `server:contractsRefreshed` | `{ town }` |
| `server:auctionCreated` | `{ auction }` |
| `server:auctionUpdated` | `{ auction }` |
| `server:auctionSettled` | `{ auctionId, status, winner, amount }` |

### Environment

| Event | Payload |
|-------|---------|
| `server:seasonChanged` | `{ season, temp }` |
| `server:weatherChanged` | `{ weather, temp }` |
| `server:hazardTriggered` | `{ ranchId, hazardKey, label, damage }` |

### Progression

| Event | Payload |
|-------|---------|
| `server:xpGained` | `{ skill, amount, total, level }` |
| `server:achievement` | `{ key, def }` |

### NUI / Tab Router

| Event | Payload |
|-------|---------|
| `server:uiData` | `{ tab, data, error? }` — reply to `requestUIData`. |

### Zoning & Props

| Event | Payload |
|-------|---------|
| `server:zoneEditorStart` | `{ zoneType }` — triggered by `/pzcreate`. |
| `server:zoneEditorSave` | `{}` — triggered by `/pzsave`. |
| `server:zoneEditorCancel` | `{}` — triggered by `/pzcancel`. |
| `server:zoneAdded` | `{ zone }` |
| `server:propEditorStart` | `{ model, ranchId }` — triggered by `/ranchprop`. |
| `server:propEditorDelete` | `{ propId? }` — triggered by `/ranchpropdel`. |
| `server:propAdded` | `{ prop }` |

---

## Exports

Registered in `cl_main.lua`, `cl_ui.lua`, `sv_progression.lua`.

### Client

| Export | Signature | Returns |
|--------|-----------|---------|
| `GetRanchId()` | — | string or `nil` — the ranch the player is currently inside. |
| `GetRanches()` | — | table — all known ranches (cached). |
| `GetEnvironment()` | — | table — `{ season, weather, temp, season_started }`. |
| `IsInsideAnyRanch()` | — | boolean. |
| `GetCurrentRanch()` | — | table or `nil` — full ranch entity. |
| `OpenRanchUI(tab?)` | optional tab string | — opens the NUI on the given tab (default `Config.UI.defaultTab`). |
| `CloseRanchUI()` | — | closes the NUI. |
| `IsUIOpen()` | — | boolean. |

### Server

| Export | Signature | Returns |
|--------|-----------|---------|
| `InheritLegacy(fromIdent, toIdent)` | two identifiers | boolean — migrates XP and stats at `Config.Progression.legacySystem.xpPct` and `.itemPct`. |
| `GetRanch(ranchId)` | string | table or `nil`. |
| `GetRanchesOwnedBy(identifier)` | string | array. |
| `AddXp(identifier, skill, amount)` | — | new level. |
| `GetSkillLevel(identifier, skill)` | — | integer. |

---

## Extending

To hook into the resource from another script:

```lua
-- example: trigger a cutscene when a player wins their first legendary auction
AddEventHandler('lxr-advancedranch:server:auctionSettled', function(payload)
    if payload.status == 'sold' then
        -- payload = { auctionId, status, winner, amount, lot_type, lot_ref }
        TriggerClientEvent('my-cutscenes:legendaryWin', payload.winner)
    end
end)
```

The resource is open at the event boundary by design — everything a third-party script needs is broadcast. Don't touch the DB directly; if you need a query, write your own with its own table prefix.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
