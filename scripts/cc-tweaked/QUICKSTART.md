# RF Monitor Quick Reference

## Installation (One Command)
```lua
wget https://raw.githubusercontent.com/BrysWU/MCModpackBuilder/main/scripts/cc-tweaked/installer.lua installer.lua && lua installer.lua
```

## Manual Installation
```lua
wget https://raw.githubusercontent.com/BrysWU/MCModpackBuilder/main/scripts/cc-tweaked/rf_monitor.lua rf_monitor.lua
lua rf_monitor.lua
```

## Hardware Setup
```
[Computer] --[Modem]-- [2x2 Monitor]
     |
     +--[Modem]-- [Thermal Energy Cell]
```

## Touch Controls
- **Top-Right Corner**: EXIT
- **Bottom Left**: GRAPH view
- **Bottom Center**: SETTINGS view  
- **Bottom Right**: INFO view
- **Settings Page**: Touch "Show Grid" to toggle

## Troubleshooting

### "Monitor not found"
- Check modem connection to monitor
- Ensure monitor is 2x2 advanced monitor setup

### "Energy cell not found"  
- Check modem connection to energy cell
- Verify energy cell is from Thermal Expansion

### Display Issues
- Script automatically sets 0.5 text scale for 2x2 monitors
- Ensure all 4 monitor blocks are advanced monitors

## Files Included
- `rf_monitor.lua` - Main script
- `config.lua` - Settings (optional)
- `installer.lua` - Auto installer
- `startup.lua` - Auto-start on boot
- `test.lua` - Diagnostic tests

## Key Features
- ✅ Real-time RF graph (green=input, red=output)
- ✅ Touch interface with 3 views
- ✅ Auto-scaling display
- ✅ Robust error handling
- ✅ Modern colorful UI
- ✅ 2x2 monitor optimized