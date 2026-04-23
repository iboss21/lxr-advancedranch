# 🐺 Support Response Templates — lxr-advancedranch

*Canned responses for the most common support tickets. Paste, edit, send.*

---

## T1. Resource won't start — rename guard

```
Hey [name],

The issue is that your folder is named "[their-name]" instead of "lxr-advancedranch".
This guard exists to prevent leaked copies from being trivially redeployed.

Rename the folder to exactly `lxr-advancedranch` (case-sensitive) and restart the
resource. You should see:

    [lxr-advancedranch] framework detected: <your framework>
    [lxr-advancedranch] DB migration complete — 10 tables verified

If you need to keep a custom name, edit `Config.Security.resourceNameGuard` in
config.lua AND the `EXPECTED_NAME` constant at the top of `server/sv_main.lua`
to match. Both must agree.

Let me know if that clears it up.

— iBoss / The Lux Empire
```

---

## T2. Framework detected as standalone (wrong)

```
Hey [name],

Detection is a one-shot probe on boot — if lxr-advancedranch starts before
your framework finishes loading, it falls back to standalone.

Two fixes:

1. In server.cfg, make sure your framework's `ensure` line comes BEFORE
   `ensure lxr-advancedranch`.

2. Or skip detection entirely by forcing it in config.lua:

       Config.Framework = 'rsg-core'   -- or lxr-core, vorp-core, etc.

Restart. You should see the correct detection line in console.

— iBoss
```

---

## T3. NUI shows empty data / tabs are blank

```
Hey [name],

A few things to check:

1. Run `/ranchdump` in rcon — do any ranches exist?
2. Is the player associated with a ranch (owner or worker)?
   If `Config.General.ownerOnlyUI = true`, non-associated players see empty data.
3. Check console for "[lxr-advancedranch] NUI throttled for src=N" spam — if so,
   raise `Config.Security.nuiDataRateLimit`.
4. Confirm Framework.GetPlayer(src) returns non-nil on your framework — post
   the output of `/ranchdump` and a screenshot of the dashboard.

— iBoss
```

---

## T4. Tebex rejected the upload / escrow error

```
Hey [name],

This is almost always because a protected file was edited. The files you CAN edit are:

    config.lua
    locales/*.lua
    sql/*.sql
    docs/*.md
    html/*

Everything under `server/`, `client/`, and `shared/` (except the locales + config)
is escrow-protected and cannot be modified.

Revert your changes to those files from the original zip, re-upload, and you
should be good. If you need a legitimate code-level change, open a ticket
describing what you're trying to accomplish — I may be able to add it to a
future release or provide a config hook.

— iBoss
```

---

## T5. Workers not being paid

```
Hey [name],

Payday only fires when:

    now - last_paid >= Config.Workforce.paydayIntervalHours * 3600

And only when the ranch balance can cover the wage. If the balance is empty,
payday fails silently and drops worker morale by 5 points.

For testing, set `paydayIntervalHours = 0.05` (3 min) temporarily and watch.
Verify ranch balance with `/ranchdump`.

— iBoss
```

---

## T6. Discord webhook not firing

```
Hey [name],

Confirm with curl:

    curl -X POST -H "Content-Type: application/json" \
         -d '{"content":"test"}' \
         <your webhook URL>

If that posts to your channel: `Config.Discord.webhookUrl` in config.lua is
wrong or has whitespace. Double-check the URL.

If curl errors: your host is blocking outbound HTTPS or the webhook was
deleted. Create a new webhook in Discord server settings and paste the new URL.

— iBoss
```

---

## T7. Request for source / unlock / decryption

```
Hey [name],

I don't provide unlocked sources or decryption keys — it would compromise
every other customer. The protected files are what keeps resale at bay.

All of the following are editable without unlock:

    - config.lua (every tunable value)
    - locales/*.lua (all player-facing text)
    - sql/schema.sql (manual migration path)
    - docs/*.md (documentation)
    - html/* (NUI styling and layout)

If there's a specific feature you need that you can't achieve through config
alone, tell me what you're trying to do. I may add a hook, or your idea might
make it into the next release.

— iBoss
```

---

## T8. Refund request (first 48h)

```
Hey [name],

Tebex refunds are handled directly through the store's refund policy — I can't
process them manually on my end. The "Request Refund" button on your order
page in Tebex handles it.

That said: if there's a specific blocker, tell me what's wrong. In my experience
most refund requests come from something solvable in 10 minutes.

— iBoss
```

---

## T9. Bug report — confirmed reproduction

```
Hey [name],

Thanks for the clean repro — that made it fast to track down. Confirmed the
[bug description] on my test server. Fix is going into the next patch.

Patch window: [date]. You'll get the updated build as a new download through
your Tebex order page.

Appreciate the detailed report. That's exactly the format I need.

— iBoss
```

---

## T10. Feature request

```
Hey [name],

Good idea. Queued for consideration — I keep a roadmap for the Advanced Ranch
line and will evaluate this against the other open requests.

I can't promise a timeline, but if it lands it'll be in the changelog. If the
use case is urgent enough that you can't wait, custom work is available at
commercial rates — DM me.

— iBoss
```

---

© 2026 iBoss21 / The Lux Empire · **wolves.land**
