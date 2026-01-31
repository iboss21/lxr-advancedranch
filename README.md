# 🏇 Ranch System: Omni Frontier

> **A Supreme-Level Ranch Management System for RedM**  
> Transform your RedM server into a living, breathing frontier ranch simulation with deep livestock management, dynamic seasons, workforce systems, and immersive UI.

![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)
![RedM](https://img.shields.io/badge/RedM-Compatible-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

---

## 📸 Screenshots

<div align="center">
  <img src="https://github.com/user-attachments/assets/7f4cfa18-4bce-48cb-919d-8752478bb3f6" alt="Ranch Dashboard" width="800"/>
  <p><em>Supreme-level dashboard with real-time ranch statistics and health monitoring</em></p>
  
  <p><em>Additional screenshots coming soon: Livestock Management, Environment System, Economy & Ledger, Progression & Skills, Auction House</em></p>
</div>

> **Note:** Screenshots show the supreme-level NUI interface designed specifically for RedM. All UI elements are fully responsive and optimized for gameplay.

---

## ✨ Features Overview

### 🎮 Supreme-Level UI System
- **Modern NUI Interface** - Beautiful, responsive UI built with HTML5/CSS3/JavaScript
- **RedM Optimized** - Designed specifically for RedM with proper keybindings and controls
- **Real-Time Updates** - Live data synchronization across all ranch systems
- **Multiple Views** - Dashboard, Livestock, Workforce, Economy, Environment, and Admin tabs
- **Theme** - Authentic western aesthetic with warm earth tones and period-appropriate styling

### 🐄 Livestock Management
- **Multi-Species Support** - Horses, cattle, sheep, pigs, chickens, goats, and more
- **Advanced Genetics** - Breeding system with bloodlines and trait inheritance
- **Health & Trust** - Individual animal health, trust meters, and personality traits
- **Lifecycle Simulation** - Birth, growth, aging, and natural lifecycle progression
- **Medical System** - Disease tracking, injury treatment, and veterinary gameplay

### 🌍 Environment & Ecology
- **Dynamic Seasons** - Spring, Summer, Autumn, Winter with unique characteristics
- **Weather System** - Clear, rain, storms, snow, fog with gameplay impacts
- **Environmental Hazards** - Lightning, floods, droughts, blizzards, dust storms
- **Soil & Vegetation** - Pasture quality, fertility tracking, and regrowth mechanics
- **Wildlife Ecosystem** - Deer, wolves, coyotes, rodents with AI behaviors

### 👥 Workforce System
- **Flexible Roles** - Owner, Foreman, Hand, Wrangler, Dairyman, Butcher, Vet, Teamster
- **Task Management** - Assign tasks, track completion, manage schedules
- **Morale & Fatigue** - Worker satisfaction affects productivity
- **Discord Integration** - Auto-sync roles with Discord for external management
- **AI Workforce** - Optional AI workers for single-player ranch management

### 💰 Economy & Trading
- **Dynamic Pricing** - Market prices fluctuate based on season and demand
- **Contract System** - Town boards with delivery contracts and deadlines
- **Auction House** - Live bidding system for livestock and goods
- **Ledger Tracking** - Complete accounting with income, expenses, and balance sheets
- **Production Chains** - Dairy, meat processing, wool, eggs, and byproducts

### 🎯 Progression & Achievements
- **XP System** - Gain experience through ranch activities
- **Skill Trees** - Husbandry, Veterinary, Teamster, Wrangler, Butcher specializations
- **Achievements** - Unlock rewards for milestones and accomplishments
- **Legacy System** - Heir mechanics for multi-generation gameplay

### 🛠️ Administrative Tools
- **Comprehensive Commands** - Full suite of admin commands for ranch management
- **Zoning System** - PZCreate integration for defining ranch boundaries
- **Prop Placement** - Mapper tools for decorating ranches with props
- **Ownership Control** - Transfer, create, delete ranches with full audit logging
- **Discord Webhooks** - Real-time notifications for ownership changes and events

---

## 🚀 Installation

### Prerequisites
- RedM server (latest version recommended)
- Basic knowledge of RedM resource installation
- (Optional) [oxmysql](https://github.com/overextended/oxmysql) for database storage

### Step-by-Step Installation

1. **Download the Resource**
   ```bash
   cd resources
   git clone https://github.com/iboss21/Ranch-System-Mega-Features.git
   ```

2. **Rename the Resource Folder**
   ```bash
   mv Ranch-System-Mega-Features/resource omni_ranch
   ```

3. **Add to Server Configuration**
   
   Edit your `server.cfg` or `resources.cfg`:
   ```cfg
   ensure omni_ranch
   ```

4. **Configure Permissions**
   
   Edit `omni_ranch/shared/config.lua` to add admin identifiers:
   ```lua
   Config.Admin = {
       AcePermission = "ranch.admin",
       Identifiers = {
           ["license:your_license_here"] = true,
       },
       -- ... other settings
   }
   ```

5. **Grant ACE Permissions (Alternative)**
   
   In your `server.cfg`:
   ```cfg
   add_ace group.admin ranch.admin allow
   ```

6. **Start Your Server**
   ```bash
   # Start or restart your RedM server
   ```

7. **Verify Installation**
   - Join your server
   - Press `F5` to open the Ranch UI (default keybind)
   - Check console for `[RanchUI] Ranch UI Client loaded successfully`

---

## 🎮 Usage Guide

### Opening the Ranch UI

**Method 1: Keybind**
- Press `F5` (default) to open the Ranch UI
- Press `ESC` to close

**Method 2: Command**
```
/ranchui [ranchId]
```

### Admin Commands

All commands require the `ranch.admin` ACE permission or whitelisted identifier.

#### Ranch Management
| Command | Description | Example |
|---------|-------------|---------|
| `/ranchcreate <name> [identifier]` | Create a new ranch | `/ranchcreate "Circle T Ranch" license:abc123` |
| `/ranchdelete <ranchId>` | Delete a ranch | `/ranchdelete ranch_001` |
| `/ranchtransfer <ranchId> <identifier>` | Transfer ownership | `/ranchtransfer ranch_001 citizenid:JD001` |
| `/ranchsetrole <ranchId> <discordRoleId>` | Link Discord role | `/ranchsetrole ranch_001 1234567890` |

#### Environment Control
| Command | Description | Example |
|---------|-------------|---------|
| `/ranchseason <season>` | Set global season | `/ranchseason spring` |
| `/ranchweather` | Roll new weather | `/ranchweather` |
| `/ranchhazard <hazardKey> [ranchId]` | Trigger hazard | `/ranchhazard lightning ranch_001` |

#### Livestock Management
| Command | Description | Example |
|---------|-------------|---------|
| `/ranchanimaladd <ranchId> <species> [count]` | Add animals | `/ranchanimaladd ranch_001 cattle 10` |
| `/ranchanimaldel <ranchId> <animalId>` | Remove animal | `/ranchanimaldel ranch_001 animal_123` |

#### Workforce & Economy
| Command | Description | Example |
|---------|-------------|---------|
| `/ranchassign <ranchId> <identifier> <role>` | Assign worker | `/ranchassign ranch_001 license:abc Hand` |
| `/ranchtask <ranchId> <taskType>` | Post task | `/ranchtask ranch_001 feeding` |
| `/ranchcontract [town] [contractId] [ranchId]` | Manage contracts | `/ranchcontract Valentine` |
| `/ranchxp <ranchId> <amount>` | Grant XP | `/ranchxp ranch_001 100` |

#### Mapping & Zoning
| Command | Description | Example |
|---------|-------------|---------|
| `/pzcreate [zoneId]` | Create polygon zone | `/pzcreate pasture_01` |
| `/pzsave` | Save zone | `/pzsave` |
| `/pzcancel` | Cancel zone creation | `/pzcancel` |
| `/ranchprop <model> [ranchId]` | Spawn prop | `/ranchprop p_haybale02x ranch_001` |
| `/ranchpropdel [ranchId]` | Remove props | `/ranchpropdel ranch_001` |

### Available Seasons
- `spring` - Increased crop growth, higher precipitation
- `summer` - Hot and dry, drought risk
- `autumn` - Harvest bonuses, rutting season
- `winter` - Cold weather, increased feed demand

### Available Hazards
- `lightning` - Fire risk, barn damage
- `flood` - Livestock danger, crop damage
- `drought` - Reduced pasture quality, water stress
- `blizzard` - Extreme cold, structural damage
- `duststorm` - Suffocation risk, building wear

### Worker Roles
- `Owner` - Full permissions
- `Foreman` - Task assignment, hiring, upgrades
- `Hand` - Basic tasks
- `Wrangler` - Horse handling, cattle moving
- `Dairyman` - Dairy processing
- `Butcher` - Meat processing
- `Vet` - Animal treatment and diagnosis
- `Teamster` - Wagon operations, deliveries


---

## ⚙️ Configuration

The system is highly configurable through `shared/config.lua`. Key sections:

### UI Configuration
```lua
Config.UI = {
    EnableLedgerApp = true,
    MapOverlay = true,
    StatusIcons = true,
    PhotoCatalog = true,
    AuctionUI = true,
    DiscordWebhooks = true,
    VoiceCommands = {
        enable = true,
        whistleDog = true,
        callCattle = true
    }
}
```

### Environment Settings
```lua
Config.Environment = {
    SeasonLengthMinutes = 120,  -- How long each season lasts
    SeasonSequence = { "spring", "summer", "autumn", "winter" },
    -- Weather patterns, hazards, wildlife, soil, water...
}
```

### Economy Settings
```lua
Config.Economy = {
    DynamicPricing = {
        baseDemand = { beef = 1.0, milk = 1.0, wool = 1.0 },
        seasonalModifiers = {
            winter = { beef = 1.3, milk = 1.1 }
        }
    },
    Contracts = {
        maxActive = 5,
        townBoards = { "Valentine", "Rhodes", "Blackwater" }
    }
}
```

### Livestock Configuration
```lua
Config.Livestock = {
    cattle = {
        needsDecayPerHour = { hunger = 0.15, thirst = 0.2 },
        breedingCooldownDays = 60,
        gestationDays = 9
    }
    -- ... more species settings
}
```

For complete configuration options, see `shared/config.lua`.

---

## 🔧 Customization

### Changing UI Keybind

Edit `client/ui.lua`:
```lua
RegisterKeyMapping('ranchui', 'Open Ranch UI', 'keyboard', 'F5')  -- Change F5 to your preferred key
```

### Customizing UI Colors

Edit `html/css/style.css`:
```css
:root {
    --primary-bg: rgba(20, 15, 10, 0.95);
    --accent-color: #d4a574;  -- Change to your preferred color
    /* ... */
}
```

### Adding Custom Livestock Species

Edit `shared/config.lua`:
```lua
Config.Livestock.yourspecies = {
    needsDecayPerHour = { hunger = 0.1, thirst = 0.15 },
    breedingCooldownDays = 30,
    -- ... your settings
}
```

### Discord Webhook Integration

Configure in `shared/config.lua`:
```lua
Config.Discord = {
    WebhookUrl = "your_webhook_url_here",
    AlertChannelId = "channel_id",
    TransferRoleOnSale = true
}
```

---

## 📊 Data Storage

By default, the system uses JSON file storage:

- `data/ranches.json` - Ranch ownership and metadata
- `data/animals.json` - Livestock registry
- `data/workforce.json` - Worker rosters
- `data/economy.json` - Market prices and contracts
- `data/environment.json` - Season and weather state
- `data/progression.json` - XP and achievements
- `data/production.json` - Processing chains
- `data/vegetation.json` - Pasture and vegetation data

### Migrating to MySQL

To use MySQL instead of JSON:

1. Install [oxmysql](https://github.com/overextended/oxmysql)
2. Edit `server/storage.lua`
3. Replace JSON read/write functions with SQL queries
4. Create database tables based on JSON structure

---

## 🎯 Events & Exports

### Client Events

**Listening Events:**
- `ranch:zones:sync` - Zone data synchronized
- `ranch:livestock:updated` - Livestock data updated
- `ranch:workforce:rosterUpdated` - Workforce roster changed
- `ranch:economy:updated` - Economy data refreshed
- `ranch:environment:updated` - Environment state changed
- `ranch:progression:updated` - Progression data updated

**Triggerable Events:**
- `ranch:ui:addActivity` - Add activity to feed
- `ranch:ui:notify` - Show notification

### Client Exports

```lua
-- Open Ranch UI
exports['omni_ranch']:OpenRanchUI(ranchId)

-- Close Ranch UI
exports['omni_ranch']:CloseRanchUI()

-- Check if UI is open
local isOpen = exports['omni_ranch']:IsUIOpen()

-- Get ranch data
local zones = exports['omni_ranch']:GetRanchZones()
local livestock = exports['omni_ranch']:GetLivestock()
local workforce = exports['omni_ranch']:GetWorkforce()
local economy = exports['omni_ranch']:GetEconomy()
local environment = exports['omni_ranch']:GetEnvironment()
local progression = exports['omni_ranch']:GetProgression()
```

### Server Events

**Triggerable Events:**
- `ranch:ownershipChanged` - Emitted after deed transfers
- Server-side events match data sync patterns

---

## 🐛 Troubleshooting

### UI Not Opening

**Problem:** Pressing F5 does nothing

**Solutions:**
1. Check console for errors: `[RanchUI] Ranch UI Client loaded successfully`
2. Verify resource is running: `/ensure omni_ranch`
3. Check fxmanifest.lua includes all files
4. Clear cache and restart

### NUI Focus Issues

**Problem:** Can't click UI elements or can't close UI

**Solutions:**
1. Press `ESC` multiple times
2. Use `/ranchui` command to toggle
3. Check browser console (F12) for JavaScript errors
4. Restart resource: `/restart omni_ranch`

### Missing Data in UI

**Problem:** Livestock/workforce shows "Loading..."

**Solutions:**
1. Ensure you have ranch data (create ranch first)
2. Check server console for data sync errors
3. Verify JSON files exist in `data/` folder
4. Check file permissions on JSON files

### Permission Denied

**Problem:** Admin commands don't work

**Solutions:**
1. Add your license to `Config.Admin.Identifiers`
2. Or grant ACE: `add_ace group.admin ranch.admin allow`
3. Restart server after config changes
4. Check identifier format (license:, citizenid:, discord:, etc.)

### UI Display Issues

**Problem:** UI looks broken or misaligned

**Solutions:**
1. Clear browser cache: `/resmon` and check NUI memory
2. Check console for CSS loading errors
3. Verify all HTML/CSS/JS files are in correct locations
4. Test with different screen resolution

---

## 🤝 Integration with Other Resources

### Framework Compatibility

This resource is framework-agnostic by default but can integrate with:

- **RedM Reborn** - Use `GetPlayerData()` for character info
- **RedEM:RP** - Integrate with job system
- **VORP** - Connect to VORP character and inventory
- **QBCore RedM** - Use QBCore player functions

### Example Integration (VORP)

```lua
-- In client/ui.lua, modify openRanchUI():
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local User = VORPcore.getUser()
local Character = User.getUsedCharacter
ranchData.ranchName = Character.firstname .. "'s Ranch"
```

---

## 📝 Roadmap & Future Features

### Planned Features
- ✅ Supreme-level NUI interface (COMPLETED)
- ✅ Full livestock management (COMPLETED)
- ✅ Dynamic environment system (COMPLETED)
- ✅ Economy and contracts (COMPLETED)
- ✅ Comprehensive documentation (COMPLETED)
- 🔲 MySQL migration tools
- 🔲 Advanced genetics visualization
- 🔲 Mobile companion app
- 🔲 VR mode support (experimental)
- 🔲 Multiplayer ranch co-op
- 🔲 Ranch PvP competitions
- 🔲 Seasonal events and festivals

### Community Suggestions
We welcome feature requests! Open an issue on GitHub to suggest improvements.

---

## 📜 License

This project is licensed under the MIT License. See LICENSE file for details.

---

## 🙏 Credits

**Development Team:**
- Omni Frontier Dev Team - Core development
- iboss21 - Project maintainer
- Community Contributors - Bug reports and suggestions

**Special Thanks:**
- RedM community for framework support
- CFX.re for the platform
- All beta testers and early adopters

---

## 📞 Support

**Documentation:** You're reading it!  
**Issues:** [GitHub Issues](https://github.com/iboss21/Ranch-System-Mega-Features/issues)  
**Discord:** Join our community (link in repository)  

---

## 🌟 Show Your Support

If you find this resource useful:
- ⭐ Star the repository on GitHub
- 🐛 Report bugs and suggest features
- 💬 Share with other RedM server owners
- 📝 Write a review or showcase your ranch

---

<div align="center">
  
### Built with ❤️ for the RedM Community

**Transform your server. Embrace the frontier. Build your ranch empire.**

</div>
