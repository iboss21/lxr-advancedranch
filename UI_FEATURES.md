# Ranch System UI/UX - Supreme Features Documentation

## Overview
The Land of the Wolves Ranch System features a supreme-level UI/UX built with modern web technologies (HTML5, CSS3, JavaScript) and optimized specifically for RedM gameplay. This document details all the advanced features implemented.

## 🎨 Design Philosophy

### Western Aesthetic
- **Color Palette**: Warm earth tones with authentic frontier colors
  - Primary Background: Dark brown (`rgba(20, 15, 10, 0.95)`)
  - Accent Color: Leather tan (`#d4a574`)
  - Success: Natural green (`#6b9b37`)
  - Warning: Gold (`#d4a020`)
  - Danger: Deep red (`#b83a3a`)

### Typography
- **Headers**: Merriweather (Serif) - Period-appropriate feel
- **Body**: Roboto (Sans-serif) - Modern readability

### Visual Effects
- Smooth animations and transitions
- Subtle shadows and glows
- Responsive hover states
- Progress bars with gradients

## 🖥️ Main UI Components

### 1. Dashboard
**Purpose**: Central hub for ranch overview and quick access

**Features**:
- **Quick Stats Cards**
  - Total Animals count with animated icon
  - Active Workers count
  - Current Balance (formatted with commas)
  - Ranch Level progression

- **Recent Activity Feed**
  - Real-time updates of ranch events
  - Timestamped entries
  - Auto-scrolling with max 10 visible items

- **Ranch Health Indicators**
  - Cleanliness meter (affects disease risk)
  - Worker Morale (affects productivity)
  - Structural Integrity (maintenance needs)
  - Animated progress bars with color coding

- **Quick Access Buttons**
  - Progression & Skills modal
  - Auction House modal

### 2. Livestock Management
**Purpose**: Comprehensive animal tracking and management

**Features**:
- **Search & Filter System**
  - Real-time text search
  - Species filter dropdown
  - Instant results update

- **Grid View**
  - Responsive card layout
  - Visual species icons
  - Health and trust percentages
  - Click to view full details

- **Animal Detail Modal** (NEW)
  - **Basic Information**
    - Species, Breed, Age, Gender
    - Custom naming system
  
  - **Health Status**
    - Health percentage with visual bar
    - Trust meter (bonding level)
    - Hunger indicator
    - Color-coded status
  
  - **Genetics System**
    - Bloodline tracking
    - Quality ratings (Poor, Common, Good, Excellent, Superior)
    - Trait badges (e.g., "Fast Runner", "Calm Temperament")
    - Color-coded quality badges
  
  - **Quick Actions**
    - Feed: Restore hunger instantly
    - Treat: Apply medical treatment
    - Breed: Initiate breeding sequence
    - Sell: Market the animal

### 3. Workforce Management
**Purpose**: Employee roster and task coordination

**Features**:
- Worker cards with role display
- Morale and fatigue tracking
- Task board for active assignments
- Hire worker functionality
- Role-based permissions visualization

### 4. Economy & Trading
**Purpose**: Financial management and market interactions

**Features**:
- **Ledger System**
  - Total income tracking
  - Expense monitoring
  - Net balance calculation
  - Transaction history

- **Market Prices**
  - Dynamic pricing display
  - Product price fluctuations
  - Season-based adjustments

- **Contracts Board**
  - Active delivery contracts
  - Town-based missions
  - Reward tracking
  - Deadline monitoring

### 5. Environment System
**Purpose**: Weather, seasons, and ecological simulation

**Features**:
- **Season Display**
  - Current season with icon
  - Season effects listing
  - Growth/weather modifiers

- **Weather Information**
  - Real-time weather status
  - Temperature display
  - Visual weather icons

- **Hazard Warnings**
  - Active environmental threats
  - Lightning, floods, droughts, etc.
  - Alert notifications

- **Vegetation Status**
  - Pasture quality meter
  - Soil fertility tracking
  - Regrowth indicators

### 6. Admin Controls
**Purpose**: Server administration and debugging

**Features**:
- Quick action buttons for:
  - Ranch creation
  - Ownership transfers
  - Season manipulation
  - Hazard triggering
  - Animal spawning
  - XP granting
- Admin audit logs
- Command shortcuts

## 🆕 Advanced Features (NEW)

### Progression & Skills Modal
**Access**: Click "Progression" button on Dashboard

**Components**:

1. **XP Bar System**
   - Visual level display
   - Animated progress bar
   - Current/Required XP counter
   - Gradient fill effect

2. **Skill Trees** (4 Categories)
   
   **Husbandry Skills**
   - Basic Training → Advanced Care → Master Handler
   - Animal breeding efficiency
   - Health management bonuses
   
   **Veterinary Skills**
   - First Aid → Disease Treatment → Surgery
   - Medical success rates
   - Diagnosis accuracy
   
   **Wrangler Skills**
   - Roping → Breaking → Cattle Drive
   - Horse handling efficiency
   - Livestock movement speed
   
   **Teamster Skills**
   - Wagon Handling → Long Haul → Master Trader
   - Delivery capacity
   - Trade negotiation bonuses

3. **Achievement System**
   - Grid layout with cards
   - Locked/Unlocked states
   - Icon visualization
   - Description tooltips
   - Examples:
     - First Steps: Purchase first animal
     - Growing Herd: Own 10 animals
     - New Life: Birth first animal
     - Master Breeder: Breed 50 animals
     - Entrepreneur: First sale
     - Wealthy Rancher: Earn $10,000

### Auction House Modal
**Access**: Click "Auction" button on Dashboard

**Features**:

1. **Auction Listings**
   - Grid view of active auctions
   - Item title and type
   - Current bid amount
   - Time remaining countdown
   - Seller information
   - Quality badge display

2. **Bidding System**
   - Input field for bid amount
   - Minimum bid validation
   - Real-time bid submission
   - Success notifications

3. **Filter Controls**
   - All Auctions
   - Livestock only
   - Equipment only
   - Goods only

4. **Item Categories**
   - Livestock (horses, cattle, sheep, etc.)
   - Equipment (wagons, tools)
   - Goods (feed, materials)

### Notification System
**Purpose**: Real-time feedback and alerts

**Features**:
- Toast notifications (top-right corner)
- 4 types: Success, Error, Warning, Info
- Auto-dismiss after 3 seconds
- Icon-based visual indicators
- Smooth slide-in animation
- Color-coded by type

### Tooltip System
**Purpose**: Contextual help and information

**Features**:
- Hover-activated tooltips
- Fixed positioning
- Dark theme consistency
- Max-width constraint
- Smooth fade transitions

## 🎮 User Interactions

### Keyboard Controls
- **F5**: Open Ranch UI (default, configurable)
- **ESC**: Close UI and all modals
- **Tab**: Navigate between form fields
- **Enter**: Submit forms/actions

### Mouse Interactions
- **Click**: Primary selection
- **Hover**: Tooltips and visual feedback
- **Scroll**: Navigate content within tabs
- All buttons have hover effects
- Cards have lift effect on hover

### Touch Support
- Responsive grid layouts
- Touch-friendly button sizes
- Swipe-capable content areas
- Mobile breakpoints implemented

## 📱 Responsive Design

### Breakpoints
- **Desktop**: 1400px+ (default)
- **Tablet**: 768px - 1199px
- **Mobile**: <768px

### Adaptations
- Grid columns adjust (4 → 2 → 1)
- Navigation tabs wrap on small screens
- Modal sizes scale appropriately
- Font sizes remain readable
- Touch targets enlarged

## 🔧 Technical Implementation

### File Structure
```
resource/html/
├── index.html        # Main UI structure
├── demo.html         # Standalone demo for screenshots
├── css/
│   └── style.css     # Complete styling
└── js/
    └── app.js        # UI logic and interactions
```

### JavaScript Architecture
- jQuery for DOM manipulation
- Event-driven design
- NUI message handling
- State management via `ranchData` object
- Modular function structure

### CSS Architecture
- CSS Variables for theming
- BEM-like naming conventions
- Responsive utilities
- Animation keyframes
- Custom scrollbars

### RedM Integration
- NUI message system
- Lua callback handlers
- SetNuiFocus management
- Resource export functions

## 🎯 Quality Features

### Genetics Visualization
- Color-coded quality badges
- Trait badge system
- Bloodline tracking
- Visual hierarchy

### Data Formatting
- Currency with $ and commas
- Percentages with % symbol
- Time remaining countdowns
- Capitalized names

### Loading States
- Spinner animations
- Placeholder content
- Skeleton screens
- Progress indicators

### Error Handling
- Validation messages
- Confirmation dialogs
- Fallback content
- Graceful degradation

## 🚀 Performance Optimizations

### Best Practices
- Lazy loading of content
- Debounced search inputs
- Throttled scroll events
- Minimal reflows
- CSS hardware acceleration

### Asset Management
- CDN for external libraries
- Minifiable structure
- Cached resources
- Optimized images

## 📋 Testing Checklist

### Functionality
- ✅ UI opens and closes properly
- ✅ All tabs switch correctly
- ✅ Modals open/close smoothly
- ✅ Forms validate input
- ✅ Data updates in real-time
- ✅ Notifications appear/dismiss
- ✅ Tooltips show on hover

### Visual
- ✅ Consistent color scheme
- ✅ Proper font rendering
- ✅ Smooth animations
- ✅ No layout shifts
- ✅ Icon alignment
- ✅ Button states

### Responsive
- ✅ Works on 1920x1080
- ✅ Works on 1440x900
- ✅ Works on 1280x720
- ✅ Tablets (landscape/portrait)
- ✅ Mobile devices

### Integration
- ✅ NUI messages handled
- ✅ Lua callbacks work
- ✅ Server events triggered
- ✅ Data synchronization
- ✅ ESC key closes UI

## 🎨 Customization Guide

### Changing Colors
Edit CSS variables in `style.css`:
```css
:root {
    --primary-bg: rgba(20, 15, 10, 0.95);
    --accent-color: #d4a574;
    /* ...modify as needed */
}
```

### Adding New Tabs
1. Add button in `.nav-tabs`
2. Create `.tab-content` div
3. Add `showTab()` handler
4. Update `loadTabData()`

### Custom Modals
1. Create modal structure
2. Add modal styles
3. Implement open/close functions
4. Register callback handlers

### New Notifications
Call `showNotification()` with:
- `message`: Text to display
- `type`: 'success' | 'error' | 'warning' | 'info'

## 📸 Screenshots

Screenshots demonstrating all features should be placed in `/screenshots/`:
- `dashboard.png` - Main dashboard view
- `livestock.png` - Livestock grid and filters
- `animal-detail.png` - Animal modal with genetics
- `progression.png` - Skills and achievements
- `auction.png` - Auction house interface
- `environment.png` - Environment and seasons
- `workforce.png` - Worker management
- `economy.png` - Ledger and contracts

## 🐛 Known Limitations

1. **Browser Compatibility**: Designed for RedM's CEF (Chromium)
2. **Max Animals**: Grid performance may degrade with 500+ animals
3. **Modal Stacking**: Only one modal open at a time
4. **Real-time Updates**: Requires server-side event system

## 🔮 Future Enhancements

- Drag-and-drop task assignment
- Interactive ranch map
- Production chain flowcharts
- Advanced charting (line/bar graphs)
- Voice command integration
- VR mode support
- Mobile companion app
- Legacy/heir selection interface

## 📞 Support

For issues or questions:
- Check console for JavaScript errors (F12)
- Verify fxmanifest.lua includes all files
- Test with demo.html first
- Check NUI focus state
- Review server logs

---

**Last Updated**: 2025-01-31  
**Version**: 0.1.0  
**Maintainer**: Omni Frontier Dev Team
