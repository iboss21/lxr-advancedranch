# LXR Ranch System — Support Response Templates

> For use by support staff in Discord / Tebex tickets.

---

## Template 1 — General First Response

```
Hi [NAME],

Thank you for reaching out to The Lux Empire support!

We've received your ticket and will respond as soon as possible.
In the meantime, please check the troubleshooting guide included with the resource:
  → docs/TROUBLESHOOTING.md

If your issue is a startup error, please share:
  1. The full error from your server console
  2. Your framework name and version
  3. Your `Config.Framework` value in config.lua

🐺 wolves.land Support Team
```

---

## Template 2 — Resource Name Mismatch

```
Hi [NAME],

The error you're seeing is a resource name protection check.

Your resource folder must be named exactly:
  lxr-advancedranch

Please rename the folder and restart your server.

This protection is intentional and cannot be disabled in production.

🐺 wolves.land Support Team
```

---

## Template 3 — Framework Not Detected

```
Hi [NAME],

The framework bridge could not find a running framework on your server.

Please check:
  1. Your framework resource is started BEFORE lxr-advancedranch in server.cfg
  2. The framework resource name matches one of the supported ones (see docs/FRAMEWORKS.md)
  3. Try setting Config.Framework = 'your-framework-name' manually in config.lua

If you want to test without a framework, set:
  Config.Framework = 'standalone'

🐺 wolves.land Support Team
```

---

## Template 4 — Closing / Resolved

```
Hi [NAME],

Glad we could help! If you have any further questions, don't hesitate to open a new ticket.

⭐ If you enjoyed LXR Ranch System, please leave a review on our Tebex store:
   https://theluxempire.tebex.io

🐺 wolves.land — The Land of Wolves
```

---

*🐺 wolves.land — © 2026 iBoss21 / The Lux Empire | All Rights Reserved*
