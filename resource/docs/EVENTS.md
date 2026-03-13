# 🐺 LXR Ranch System — Events Reference

> **wolves.land — The Land of Wolves**  
> © 2026 iBoss21 / The Lux Empire | All Rights Reserved

---

All events follow the namespace format:

```
lxr-ranch-system:client:<action>
lxr-ranch-system:server:<action>
```

---

## Server → Client Events

| Event | Arguments | Description |
|-------|-----------|-------------|
| `lxr-ranch-system:client:syncRanch` | `ranchId, data` | Sync ranch data to client |
| `lxr-ranch-system:client:syncZones` | `ranchId, parcels` | Sync zone/parcel data |
| `lxr-ranch-system:client:syncVegetation` | `zoneId, data` | Sync vegetation state |
| `lxr-ranch-system:client:syncVegetationBulk` | `allZones` | Bulk sync all zones |
| `lxr-ranch-system:client:syncProps` | `ranchId, props` | Sync prop placement |
| `lxr-ranch-system:client:notify` | `message, type` | Send a notification |

---

## Client → Server Events

| Event | Arguments | Description |
|-------|-----------|-------------|
| `lxr-ranch-system:server:requestSync` | — | Request full sync from server |
| `lxr-ranch-system:server:placeprop` | `ranchId, propData` | Place a prop on a ranch |
| `lxr-ranch-system:server:removeProps` | `ranchId, propId` | Remove a prop |
| `lxr-ranch-system:server:saveZone` | `zoneId, points` | Save a zone polygon |

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
AddEventHandler('lxr-ranch-system:client:syncRanch', function(ranchId, data)
    -- update your local state
end)

-- Trigger a server event (client-side)
TriggerServerEvent('lxr-ranch-system:server:requestSync')
```

---

## Notes

- The server **never trusts** client event data without validation.
- All server events include rate limiting and sanity checks.
- Do not register handlers on these events unless you are extending the system.

---

*🐺 wolves.land — The Land of Wolves*
