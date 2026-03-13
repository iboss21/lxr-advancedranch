# 🐺 LXR Ranch System — Installation Guide

> **wolves.land — The Land of Wolves**  
> © 2026 iBoss21 / The Lux Empire | All Rights Reserved

---

## Requirements

| Dependency | Version | Notes |
|------------|---------|-------|
| RedM / FiveM | Latest | RedM (rdr3) only |
| Framework | Any supported | See FRAMEWORKS.md |
| Lua 5.4 | Included | `lua54 'yes'` required |

---

## Step 1 — Download & Extract

Purchase the resource from the Tebex store:  
**https://theluxempire.tebex.io**

After purchase, download the `.zip` from Tebex and extract it.

---

## Step 2 — Rename the Resource Folder

The resource folder **must** be named exactly:

```
lxr-ranch-system
```

> ⚠️ The server-side guard will **refuse to start** if the name is wrong.  
> This is intentional and cannot be bypassed.

---

## Step 3 — Install

Place the `lxr-ranch-system` folder in your server's `resources` directory:

```
server-data/
  resources/
    [lxr]/
      lxr-ranch-system/   ← here
```

---

## Step 4 — Add to server.cfg

```cfg
ensure lxr-ranch-system
```

> Make sure your framework resource starts **before** `lxr-ranch-system`.

---

## Step 5 — Configure

Open `config.lua` and set:

1. `Config.Framework` — set to `'auto'` or specify your framework
2. `Config.Discord` — add your bot token, guild ID, and webhook URL
3. `Config.Admin.AcePermission` — set your ace permission or add identifiers

Full configuration reference: see **CONFIG.md**

---

## Step 6 — Start & Verify

Start your server. In the console you should see:

```
[LXR Ranch] Framework bridge initialised: <your-framework>
```

If you see a **CRITICAL: RESOURCE NAME MISMATCH** error, rename the folder as instructed in Step 2.

---

## Permissions

Add admin permission:

```cfg
add_ace identifier.license:XXXXXXXX ranch.admin allow
```

Or use the `Config.Admin.Identifiers` table in `config.lua`.

---

## Support

- Discord: https://discord.gg/CrKcWdfd3A
- Website: https://www.wolves.land
- Store: https://theluxempire.tebex.io

---

*🐺 wolves.land — The Land of Wolves*
