# 🪪 jsfour-idcard

> A modern, refactored identification card system for ESX Legacy FiveM servers

## 📋 Overview

An updated and refactored version of the classic jsfour-idcard resource. This script provides a complete identity documentation system for FiveM servers, allowing players to view and share their **ID cards**, **driver licenses**, and **firearms licenses** with an intuitive interface.

This fork includes significant improvements to code quality, performance, and modern ESX integration patterns.

---

## ✨ Features

- 🪪 **ID Cards**: View and display official identification documents
- 🚗 **Driver Licenses**: Check and share driving credentials  
- 🔫 **Firearms Licenses**: Manage and present weapon permits
- 👥 **Share Documents**: Present identification to nearby players with immersive roleplay support
- 🌐 **Easy Localization**: Centralized translation system for gender, labels, and license types
- ⚡ **Optimized Client/Server**: Modern event handling with efficient cleanup
- 🔐 **Secure**: Parameterized queries and proper null checks for data safety

---

## 🔄 What's New in This Fork

### ✨ Client-Side Improvements

- ✅ Added `CloseIDCard` helper function for clean state management
- ✅ Refactored event registration with inline handler
- ✅ Replaced perpetual key loop with smart thread that cleans up after ESC/BACKSPACE is pressed
- ✅ Better memory management and performance optimization

### 🛠️ Server-Side Improvements

- ✅ Modern ESX integration via `exports['es_extended']:getSharedObject()`
- ✅ Proper player validation with `ESX.GetPlayerFromId()` and null checks
- ✅ **Parameterized SQL queries** (`?` placeholders) for security and injection prevention
- ✅ Optimized license checking with early breaks
- ✅ Cleaner notification system using `ESX.ShowNotification()`
- ✅ Streamlined user/licenses data assembly and transmission
- ✅ Code cleanup and inline comments for maintainability

---

## 📥 Installation

### Prerequisites

- **es_extended (ESX Legacy)** - Core framework
- **oxmysql** - Database connectivity (or your configured MySQL resource)
- **esx_license** - License system for driver and firearms permits

### Setup Steps

1. **Download** and extract the resource to your `resources` folder
2. **Ensure** ESX Legacy and esx_license are properly installed
3. **Add** to your `server.cfg`:
   ```
   ensure jsfour-idcard
   ```
4. **Restart** your server or use the in-game restart command

---

## 🎮 Usage

### Viewing Your Own Documents

```lua
-- View your ID card
TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))

-- View your driver license
TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')

-- View your firearms license
TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
```

### Showing Documents to Others

```lua
local player, distance = ESX.Game.GetClosestPlayer()

if distance ~= -1 and distance <= 3.0 then
  -- Show ID card
  TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
  
  -- Or show driver license
  TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'driver')
  
  -- Or show firearms license
  TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'weapon')
else
  ESX.ShowNotification('No players nearby')
end
```

### Complete Menu Example

```lua
function openIDMenu()
  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'id_card_menu',
    {
      title    = 'Documentation',
      elements = {
        {label = 'Check your ID', value = 'checkID'},
        {label = 'Show your ID', value = 'showID'},
        {label = 'Check driver license', value = 'checkDriver'},
        {label = 'Show driver license', value = 'showDriver'},
        {label = 'Check firearms license', value = 'checkFirearms'},
        {label = 'Show firearms license', value = 'showFirearms'},
      }
    },
    function(data, menu)
      local val = data.current.value
      local player, distance = ESX.Game.GetClosestPlayer()
      
      if val == 'checkID' then
        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
      elseif val == 'checkDriver' then
        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
      elseif val == 'checkFirearms' then
        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
      elseif distance ~= -1 and distance <= 3.0 then
        if val == 'showID' then
          TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
        elseif val == 'showDriver' then
          TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'driver')
        elseif val == 'showFirearms' then
          TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'weapon')
        end
      else
        ESX.ShowNotification('No players nearby')
      end
    end,
    function(data, menu)
      menu.close()
    end
  )
end
```

---

### 🌐 Localization & Labels

The system now features a centralized translation object in `init.js`. This allows you to easily change the UI text without digging through the logic.

```javascript
const lang = {
  male: "VARÓN",
  female: "MUJER",
  bike: "MOTO",
  truck: "CAMIÓN",
  car: "COCHE"
};

---

## 🎨 Customization

### Card Design

A PSD template is available for customizing the visual design of ID cards:

📥 [Download PSD Template](https://www.dropbox.com/sh/ho6xq5cmk6sxz6x/AAB3aPJOylL7EWrU6BFb45-0a?dl=0)

You can modify colors, fonts, and layouts to match your server's branding.

---

## 🔗 Dependencies

| Dependency | Repository | Purpose |
|---|---|---|
| **es_extended (ESX Legacy)** | [ESX Core](https://github.com/esx-framework/esx_core) | Core player framework |
| **esx_license** | [ESX License](https://github.com/esx-framework/ESX-Legacy-Addons/tree/main/%5Besx_addons%5D/esx_license) | License management system |
| **oxmysql** | [oxmysql](https://github.com/overextended/oxmysql) | Database queries |

---

## 📝 About This Fork

This refactored version is **designed specifically for TempestaRP's infrastructure**. It is shared as-is for those who might find it useful.

### ⚠️ Important Notice

- ⚠️ **No Technical Support**: We do not provide setup assistance, debugging, or implementation help
- 🔧 **TempestaRP-Specific**: This code is optimized for our server's exact setup and may require heavy adaptation for other environments
- 📚 **Minimal Documentation**: Code comments and notes are minimal because this is our internal implementation, not a public library
- 🚀 **Reference Implementation**: Use this as a reference or example—it's not designed to be plug-and-play
- 👤 **Respect Original License**: Always respect JSFOUR's original copyright and no-resale terms

---

## 📝 License

**Original Work by JSFOUR:**

```
Copyright (C) JSFOUR - All Rights Reserved 
You are not allowed to sell this script or re-upload it 
Visit my page at https://github.com/jonassvensson4 
Written by Jonas Svensson, July 2018 
```

This fork respects the original author's licensing terms. Please do **not** sell or reupload this resource.

---

## 🙏 Credits

- **Original Author**: [Jonas Svensson (JSFOUR)](https://github.com/jonassvensson4)
- **Original Repository**: [jsfour-idcard](https://github.com/jnsvns/jsfour-idcard)
- **This Fork**: Modern refactoring with improved code quality and ESX integration

---

## 👨‍💻 Fork Changes Summary

This fork includes a complete refactor focusing on:

- **Performance**: Eliminated perpetual key loops in favor of smart thread management.
- **UI & UX**: Added smooth `fadeIn/fadeOut` animations and automatic data clearing when closing.
- **Localization Support**: Refactored JavaScript to include a dictionary for easy translation of genders and vehicle types.
- **Security**: Parameterized SQL queries prevent injection attacks.
- **Modern ESX**: Updated to current ESX Legacy integration patterns.
- **Code Quality**: Cleaned up the license rendering logic using dynamic arrays instead of hardcoded checks.

---

<div align="center">

⭐ If you find this useful, consider giving it a star!

Made with ❤️ for the FiveM community

</div>
