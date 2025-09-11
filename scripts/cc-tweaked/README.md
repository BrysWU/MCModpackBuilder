# RF Live Graph Monitor for CC:Tweaked

A modern, touchscreen-enabled RF monitoring system for Minecraft 1.20.1 with CC:Tweaked computers. This script provides real-time visualization of RF (Redstone Flux) input and output from thermal energy cells with an intuitive graphical interface.

![RF Monitor Interface](https://via.placeholder.com/800x400/1a1a1a/ffffff?text=RF+Monitor+Interface)

## Features

- **Real-time RF Monitoring**: Live graph showing RF input and output per tick
- **2x2 Monitor Support**: Optimized for 2x2 advanced monitor setups
- **Touchscreen Interface**: Interactive buttons for navigation and settings
- **Modern UI Design**: Clean, colorful interface with proper scaling
- **Error Handling**: Robust error handling to prevent crashes
- **Multi-view Interface**: Graph, Settings, and Info views
- **Configurable**: Easily adjustable update intervals and graph history

## Requirements

### Hardware Setup
1. **Computer**: Any CC:Tweaked computer
2. **Monitor**: 2x2 Advanced Monitor setup connected via modem
3. **Energy Cell**: Thermal Expansion energy cell connected via modem
4. **Modem**: Wired or wireless modem for peripheral connections

### Peripheral Names
- Monitor: `monitor_0` (automatically detected)
- Energy Cell: `thermal:energy_cell_0` (automatically detected)

## Installation

### Method 1: Direct Download (Recommended)
```lua
-- On your CC:Tweaked computer, run:
wget https://raw.githubusercontent.com/BrysWU/MCModpackBuilder/main/scripts/cc-tweaked/rf_monitor.lua rf_monitor.lua
```

### Method 2: Manual Copy
1. Copy the contents of `rf_monitor.lua`
2. Create a new file on your CC:Tweaked computer
3. Paste the code and save as `rf_monitor.lua`

## Setup Instructions

### 1. Hardware Connection
```
[Computer] ---[Modem]--- [Monitor (2x2)]
     |
     +---[Modem]--- [Energy Cell]
```

### 2. Peripheral Setup
- Place your 2x2 monitor setup
- Connect it to your computer via modem (wired or wireless)
- Connect your thermal energy cell via modem
- Ensure peripheral names match configuration:
  - Monitor: `monitor_0`
  - Energy Cell: `thermal:energy_cell_0`

### 3. Running the Script
```bash
# On your CC:Tweaked computer:
lua rf_monitor.lua
```

## Usage

### Interface Overview
- **Header Bar**: Shows script title and EXIT button
- **Status Bar**: Displays current RF storage, percentage, and rate
- **Main Area**: Graph view showing live RF data
- **Navigation Bar**: GRAPH, SETTINGS, INFO buttons

### Touch Controls
- **EXIT**: Touch the upper-right corner to exit
- **GRAPH**: View live RF input/output graph
- **SETTINGS**: Configure monitoring parameters
- **INFO**: View system information and diagnostics
- **Grid Toggle**: Touch "Show Grid" in settings to toggle graph grid

### Graph Legend
- **Green Bars (|)**: RF Input per tick
- **Red Arrows (^)**: RF Output per tick
- **Scale**: Auto-adjusting scale shown at bottom

## Configuration

Edit the `CONFIG` table at the top of the script to customize:

```lua
local CONFIG = {
    monitor_name = "monitor_0",          -- Monitor peripheral name
    energy_cell_name = "thermal:energy_cell_0", -- Energy cell name
    update_interval = 0.5,               -- Update frequency in seconds
    graph_history = 100,                 -- Number of data points to keep
    colors = {                           -- Color scheme
        background = colors.black,
        primary = colors.lightBlue,
        secondary = colors.blue,
        accent = colors.yellow,
        text = colors.white,
        success = colors.lime,
        warning = colors.orange,
        error = colors.red,
        grid = colors.gray
    }
}
```

## Troubleshooting

### Common Issues

#### "Monitor not found"
- Ensure monitor is connected via modem
- Check that monitor is named `monitor_0`
- Verify modem is properly placed and connected

#### "Energy cell not found"
- Ensure energy cell is connected via modem
- Check that energy cell is named `thermal:energy_cell_0`
- Verify the energy cell is from Thermal Expansion

#### "bad argument #1 number expected got nil"
- This error has been fixed with proper null checking
- All numeric values are validated using `safe_number()` function
- Script will default to 0 for any nil values

#### Monitor Display Issues
- For 2x2 monitors: Script automatically sets text scale to 0.5
- Ensure monitors are properly connected in a 2x2 grid
- Check that all monitor blocks are advanced monitors

### Debug Mode
The script includes comprehensive logging. Check console output for diagnostic information:
- Connection status for peripherals
- Data collection information
- Error messages and stack traces

## Technical Details

### Performance
- Update interval: 0.5 seconds (configurable)
- Graph history: 100 data points (configurable)
- Memory usage: Minimal, automatically cleans old data
- CPU usage: Optimized with proper sleep intervals

### Data Collection
- Monitors RF storage levels every update cycle
- Calculates input/output rates based on storage changes
- Maintains rolling history for graph display
- All calculations include overflow and error protection

### UI Components
- **Header**: Title and exit functionality
- **Status Bar**: Real-time RF information
- **Graph Area**: Visual representation of RF flow
- **Navigation**: Touch-responsive button interface

## Advanced Usage

### Multiple Energy Cells
To monitor multiple energy cells, modify the script to iterate through multiple peripherals:

```lua
-- Example modification for multiple cells
local energy_cells = {
    peripheral.wrap("thermal:energy_cell_0"),
    peripheral.wrap("thermal:energy_cell_1"),
    peripheral.wrap("thermal:energy_cell_2")
}
```

### Custom Themes
Modify the `colors` table in CONFIG to create custom themes:

```lua
-- Dark theme example
colors = {
    background = colors.black,
    primary = colors.purple,
    secondary = colors.magenta,
    accent = colors.pink,
    text = colors.white,
    success = colors.green,
    warning = colors.yellow,
    error = colors.red,
    grid = colors.lightGray
}
```

## Version History

- **v1.0**: Initial release with full feature set
  - Real-time RF monitoring
  - 2x2 monitor support
  - Touchscreen interface
  - Modern UI design
  - Comprehensive error handling

## License

This script is part of the MCModpackBuilder project and is provided as-is for use with CC:Tweaked in Minecraft.

## Support

For issues, suggestions, or contributions, please visit the [MCModpackBuilder repository](https://github.com/BrysWU/MCModpackBuilder).