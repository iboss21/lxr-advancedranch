# LXR Ranch System — Installation Snippet

Paste this into your Tebex product page "Installation" tab.

---

## Installation

1. **Download** the resource from your Tebex library after purchase.

2. **Rename** the extracted folder to exactly:
   ```
   lxr-advancedranch
   ```

3. **Place** the folder in your `resources` directory:
   ```
   resources/[lxr]/lxr-advancedranch/
   ```

4. **Add** to your `server.cfg`:
   ```
   ensure lxr-advancedranch
   ```
   > ⚠️ Your framework resource must start **before** `lxr-advancedranch`.

5. **Configure** by editing `config.lua`:
   - Set `Config.Framework` (or leave `'auto'`)
   - Add your Discord bot token and webhook URL
   - Set your admin ace permission or identifier

6. **Restart** your server. You should see:
   ```
   [LXR Ranch] Framework bridge initialised: <framework>
   ```

---

For full documentation, see the included `docs/` folder.

Support: https://discord.gg/CrKcWdfd3A

*🐺 wolves.land — © 2026 iBoss21 / The Lux Empire*
