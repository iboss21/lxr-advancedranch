# 🐺 Framework Integration — lxr-advancedranch

This resource bridges every mainstream RedM framework through `shared/framework.lua`. Detection runs on boot; set `Config.Framework = 'auto'` (default) or force a specific key.

---

## Auto-Detection Order

1. `lxr-core`
2. `rsg-core`
3. `vorp-core`
4. `redem-rp`
5. `qbr-core`
6. `qr-core`
7. `standalone` (fallback)

The first resource found with state `started` wins.

---

## LXR Core (Primary)

Native target. Items are registered via `LXRCore.Functions.CreateUseableItem`. Inventory operations route through `Player.Functions.AddItem/RemoveItem` with `Player.Functions.GetItemByName` for existence checks.

## RSG Core (Primary)

Mirrors the LXR path via `RSGCore.Functions.GetPlayer` et al. Used on the live wolves.land server. Inventory uses `Player.PlayerData.items` for introspection.

Gold is disabled in this resource — `Config.Economy.useGold = false` means wolves.land rules apply regardless of RSG's built-in gold currency.

## VORP Core (Compatible)

Player fetch via `VORPcore.getUser(src).getUsedCharacter`. Inventory via `exports.vorp_inventory:getItemCount` / `addItem` / `subItem`. Money via `Character.addCurrency(0, amount)` (type 0 = cash).

## RedEM:RP (Compatible)

Uses `RedEM:getPlayerFromId` callback form. Inventory via `RedEMRP:getInventory` / `giveItem` / `removeItem`. Legacy callback-based API; detection gracefully handles the async shape.

## QBR / QR Core (Compatible)

Same overall shape as RSG. QBR and QR have diverged in detail; the bridge probes both `QBRCore` and `QRCore` globals. Inventory ops are identical to RSG's API.

## Standalone

Minimal fallback. No inventory integration — calls to `Framework.HasItem`, `AddItem`, `RemoveItem` return `false` / no-op. Cash accounting still works via a simple in-memory ledger per ranch. Use only for development or servers that will integrate inventory through a custom layer.

---

## Adapting Item Keys

Item keys like `'milk_jug'`, `'rawbeef'`, `'leather'`, `'wool'`, `'eggs'` are assumed to exist in your inventory. If yours uses different keys:

1. Edit `Config.Livestock.<species>.products` to match your inventory item names.
2. Edit `Config.Economy.productionChains.<chain>.input` / `.output` likewise.
3. Ensure `Config.Economy.baseDemand` has an entry for every good your contracts can ask for.

No code changes needed — the resource reads all item keys from config.

---

## Notify Backend

`Framework.Notify(src_or_message, type, duration)` routes to your framework's native notification:

- **LXR / RSG:** `TriggerClientEvent('rsg:TextUI', src, message, type)` (fallback to RSG chat).
- **VORP:** `TriggerClientEvent('vorp:TipRight', src, message, duration)`.
- **RedEM:** `TriggerClientEvent('RedEMRP:Notify', src, type, 'Ranch', message, duration)`.
- **Standalone:** `TriggerClientEvent('chat:addMessage', src, { args = { 'Ranch', message } })`.

Override by editing `Framework.Notify` directly if your server runs a custom notification system.

---

## Admin Check

`Framework.IsAdmin(src)` runs two checks:

1. ACE — `IsPlayerAceAllowed(src, Config.Admin.acePermission)`.
2. Identifier allowlist — `Config.Admin.identifiers[<any of the player's identifiers>] == true`.

Either passing grants admin. If you only use one, leave the other empty.

---

© 2026 iBoss21 / The Lux Empire · **wolves.land** · All Rights Reserved
