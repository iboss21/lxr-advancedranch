# 🐺 LXR Ranch System — Troubleshooting

> **wolves.land — The Land of Wolves**  
> © 2026 iBoss21 / The Lux Empire | All Rights Reserved

---

## ❌ CRITICAL: RESOURCE NAME MISMATCH

**Error:**
```
❌  CRITICAL: RESOURCE NAME MISMATCH  ❌
Expected resource name : lxr-ranch-system
Current resource name  : <your-folder-name>
```

**Fix:** Rename the resource folder to exactly `lxr-ranch-system`.

---

## ❌ Framework Bridge Failure

**Error:**
```
LXR Ranch System — Framework Bridge Failure
No valid framework adapter found for: "..."
```

**Fix:**
1. Make sure your framework resource is started **before** `lxr-ranch-system`.
2. Set `Config.Framework = 'standalone'` if you want to run without a framework.
3. Check `Config.FrameworkSettings` for the correct resource name.

---

## ❌ Data files not loading

**Symptom:** Ranch data is empty or resets on restart.

**Fix:**
- Check that the `data/` folder exists and contains the JSON files.
- Verify file permissions allow the server to read/write in the resource directory.
- Check `Config.Storage.Files` paths match actual file locations.

---

## ❌ No permission / Admin commands not working

**Fix:**
1. Add your ace permission: `add_ace identifier.license:XXXX ranch.admin allow`
2. Or add your identifier to `Config.Admin.Identifiers` in `config.lua`.
3. Ensure `Config.Admin.AcePermission` is set correctly.

---

## ❌ UI not opening

**Fix:**
- Check that `html/index.html` exists in the resource.
- Verify `ui_page 'html/index.html'` is in `fxmanifest.lua`.
- Check browser console (F8 in RedM) for JavaScript errors.

---

## ❌ Framework events not firing

**Fix:**
- Enable verbose logging: `Config.Dev.VerboseEvents = true`
- Check the server console for framework detection messages.
- Verify the framework resource is actually running (`started` state).

---

## ℹ️ Enable Debug Mode

```lua
Config.Debug = true
Config.Dev.LogFrameworkInit = true
Config.Dev.VerboseEvents    = true
```

Restart the resource after changing debug settings.

---

## Support

If the issue persists:

- Discord: https://discord.gg/CrKcWdfd3A  
- Website: https://www.wolves.land  
- Store: https://theluxempire.tebex.io  

Please include:
1. Server console error output
2. Your framework name and version
3. Your `Config.Framework` setting

---

*🐺 wolves.land — The Land of Wolves*
