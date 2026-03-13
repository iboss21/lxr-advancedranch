# 🐺 LXR Ranch System — Framework Compatibility

> **wolves.land — The Land of Wolves**  
> © 2026 iBoss21 / The Lux Empire | All Rights Reserved

---

## Supported Frameworks

| Framework | Status | Auto-detected |
|-----------|--------|---------------|
| LXR Core | ✅ Primary | Yes |
| RSG Core | ✅ Primary | Yes |
| VORP Core | ✅ Supported | Yes |
| RedEM:RP | ✅ Supported | Yes |
| QBR Core | ✅ Supported | Yes |
| QR Core | ✅ Supported | Yes |
| Standalone | ✅ Fallback | Yes (last resort) |

---

## Detection Order

The framework bridge detects frameworks in this order:

```
1. LXR Core      (lxr-core)
2. RSG Core      (rsg-core)
3. VORP Core     (vorp_core)
4. RedEM:RP      (redem_roleplay)
5. QBR Core      (qbr-core)
6. QR Core       (qr-core)
7. Standalone    (fallback)
```

The first **started** resource wins.

---

## Manual Override

To force a specific framework, set in `config.lua`:

```lua
Config.Framework = 'rsg-core'
```

---

## Bridge Interface

The framework bridge exposes a unified interface regardless of the underlying framework:

```lua
Framework.Notify(source, message, type)
Framework.GetPlayer(source)
Framework.GetIdentifier(source)
Framework.GetJob(source)
Framework.AddItem(source, item, count)
Framework.RemoveItem(source, item, count)
Framework.HasItem(source, item, count)
Framework.GetMoney(source)
Framework.AddMoney(source, amount)
Framework.RemoveMoney(source, amount)
```

---

## Startup Log

When the resource starts, you will see:

```
[LXR Ranch] Framework bridge initialised: lxr-core
```

If no framework is found, the resource will use `standalone` mode with minimal functionality.

---

## Framework-Specific Notes

### LXR Core
- Primary framework. Full feature support.
- Notifications via `ox_lib`.
- Inventory via `lxr-inventory`.

### RSG Core
- Full feature support.
- Notifications via `ox_lib`.
- Inventory via `rsg-inventory`.

### VORP Core
- Full feature support.
- Notifications via `vorp:TipRight`.
- Inventory via `vorp_inventory`.

### Standalone
- Notifications via `chat:addMessage`.
- No inventory integration.
- Economy events are logged to console only.

---

*🐺 wolves.land — The Land of Wolves*
