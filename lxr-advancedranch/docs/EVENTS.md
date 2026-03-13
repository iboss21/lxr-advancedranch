# 🐺 LXR Ranch System — Events Reference

> **wolves.land — The Land of Wolves**  
> © 2026 iBoss21 / The Lux Empire | All Rights Reserved

---

All events follow the namespace format:

```
lxr-advancedranch:client:<action>
lxr-advancedranch:server:<action>
```

---

## Server → Client Events

| Event | Arguments | Description |
|-------|-----------|-------------|
| `lxr-advancedranch:client:syncRanch` | `ranchId, data` | Sync ranch data to client |
| `lxr-advancedranch:client:syncZones` | `ranchId, parcels` | Sync zone/parcel data |
| `lxr-advancedranch:client:syncVegetation` | `zoneId, data` | Sync vegetation state |
| `lxr-advancedranch:client:syncVegetationBulk` | `allZones` | Bulk sync all zones |
| `lxr-advancedranch:client:syncProps` | `ranchId, props` | Sync prop placement |
| `lxr-advancedranch:client:notify` | `message, type` | Send a notification |

---

## Client → Server Events

| Event | Arguments | Description |
|-------|-----------|-------------|
| `lxr-advancedranch:server:requestSync` | — | Request full sync from server |
| `lxr-advancedranch:server:placeprop` | `ranchId, propData` | Place a prop on a ranch |
| `lxr-advancedranch:server:removeProps` | `ranchId, propId` | Remove a prop |
| `lxr-advancedranch:server:saveZone` | `zoneId, points` | Save a zone polygon |

---

## Server-Side Events

| Event | Arguments | Description |
|-------|-----------|-------------|
| `ranch:ownershipChanged` | `ranchId, newOwner` | Fires when ownership is transferred |
| `ranch:ranchCreated` | `ranchId, data` | Fires when a new ranch is created |
| `ranch:ranchDeleted` | `ranchId` | Fires when a ranch is deleted |

---

## Usage Example

```lua
-- Listen for ranch sync (client-side)
AddEventHandler('lxr-advancedranch:client:syncRanch', function(ranchId, data)
    -- update your local state
end)

-- Trigger a server event (client-side)
TriggerServerEvent('lxr-advancedranch:server:requestSync')
```

---

## Notes

- The server **never trusts** client event data without validation.
- All server events include rate limiting and sanity checks.
- Do not register handlers on these events unless you are extending the system.

---

*🐺 wolves.land — The Land of Wolves*
