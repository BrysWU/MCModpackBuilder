--[[
RF Live Graph Monitor for CC:Tweaked
Author: Minecraft Modpack Builder
Description: Real-time RF monitoring system with touchscreen interface
Requires: 2x2 monitor setup connected via modem, thermal energy cell
Version: 1.0
--]]

-- Load configuration
local function load_config()
    local default_config = {
        monitor_name = "monitor_0",
        energy_cell_name = "thermal:energy_cell_0",
        update_interval = 0.5,
        graph_history = 100,
        text_scale = 0.5,
        colors = {
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
    
    -- Try to load external config
    if fs.exists("config.lua") then
        local success, config_data = pcall(dofile, "config.lua")
        if success and type(config_data) == "table" then
            -- Merge configurations
            if config_data.peripherals then
                default_config.monitor_name = config_data.peripherals.monitor_name or default_config.monitor_name
                default_config.energy_cell_name = config_data.peripherals.energy_cell_name or default_config.energy_cell_name
            end
            if config_data.display then
                default_config.update_interval = config_data.display.update_interval or default_config.update_interval
                default_config.graph_history = config_data.display.graph_history or default_config.graph_history
                default_config.text_scale = config_data.display.text_scale or default_config.text_scale
            end
            if config_data.colors then
                for k, v in pairs(config_data.colors) do
                    default_config.colors[k] = v
                end
            end
        end
    end
    
    return default_config
end

local CONFIG = load_config()

-- Global variables
local monitor = nil
local energy_cell = nil
local graph_data = {
    input = {},
    output = {},
    storage = {},
    timestamps = {}
}
local last_rf = 0
local last_time = 0
local ui_state = {
    current_view = "graph", -- "graph", "settings", "info"
    scale_mode = "auto", -- "auto", "manual"
    max_scale = 10000,
    show_grid = true
}

-- Utility functions
local function log(message)
    print("[RF Monitor] " .. tostring(message))
end

local function safe_number(value, default)
    if type(value) == "number" and value == value then -- Check for NaN
        return value
    end
    return default or 0
end

local function format_rf(rf)
    rf = safe_number(rf, 0)
    if rf >= 1000000 then
        return string.format("%.1fM RF", rf / 1000000)
    elseif rf >= 1000 then
        return string.format("%.1fK RF", rf / 1000)
    else
        return string.format("%d RF", rf)
    end
end

local function format_rate(rate)
    rate = safe_number(rate, 0)
    if rate >= 0 then
        return "+" .. format_rf(rate) .. "/t"
    else
        return format_rf(rate) .. "/t"
    end
end

-- Monitor setup functions
local function setup_monitor()
    -- Try multiple methods to find monitor
    monitor = peripheral.find("monitor")
    
    if not monitor then
        monitor = peripheral.wrap(CONFIG.monitor_name)
    end
    
    if not monitor then
        -- Try common monitor names
        local common_names = {"monitor_0", "monitor_1", "monitor", "advanced_monitor_0"}
        for _, name in ipairs(common_names) do
            monitor = peripheral.wrap(name)
            if monitor then
                log("Found monitor with name: " .. name)
                break
            end
        end
    end
    
    if not monitor then
        error("Monitor not found! Please ensure a monitor is connected via modem.\nTried names: " .. CONFIG.monitor_name .. ", monitor_0, monitor_1, monitor")
    end
    
    -- Set up 2x2 monitor configuration
    monitor.setTextScale(CONFIG.text_scale or 0.5)
    monitor.setBackgroundColor(CONFIG.colors.background)
    monitor.setTextColor(CONFIG.colors.text)
    monitor.clear()
    
    local w, h = monitor.getSize()
    log("Monitor connected - Size: " .. w .. "x" .. h .. " (" .. (monitor.isColor() and "Color" or "Monochrome") .. ")")
    
    return true
end

local function setup_energy_cell()
    -- Try multiple methods to find energy cell
    energy_cell = peripheral.find("thermal:energy_cell")
    
    if not energy_cell then
        energy_cell = peripheral.wrap(CONFIG.energy_cell_name)
    end
    
    if not energy_cell then
        -- Try common energy cell names
        local common_names = {
            "thermal:energy_cell_0", 
            "thermal:energy_cell_1", 
            "thermal:energy_cell",
            "energycell_0",
            "energycell_1"
        }
        for _, name in ipairs(common_names) do
            energy_cell = peripheral.wrap(name)
            if energy_cell then
                log("Found energy cell with name: " .. name)
                break
            end
        end
    end
    
    if not energy_cell then
        -- List available peripherals for debugging
        local peripherals = peripheral.getNames()
        local peripheral_list = table.concat(peripherals, ", ")
        error("Energy cell not found! Please ensure a thermal energy cell is connected via modem.\nAvailable peripherals: " .. peripheral_list)
    end
    
    -- Test energy cell functionality
    local max_energy = energy_cell.getMaxEnergyStored()
    local current_energy = energy_cell.getEnergyStored()
    
    if not max_energy or max_energy == 0 then
        log("Warning: Energy cell reports 0 max capacity")
    end
    
    log("Energy cell connected - Capacity: " .. format_rf(safe_number(max_energy, 0)))
    return true
end

-- Data collection functions
local function collect_rf_data()
    if not energy_cell then return nil end
    
    local current_time = os.clock()
    local success, current_rf, max_rf
    
    -- Safely get energy data with error handling
    success, current_rf = pcall(energy_cell.getEnergyStored)
    if not success then
        log("Warning: Failed to read energy stored: " .. tostring(current_rf))
        return nil
    end
    
    success, max_rf = pcall(energy_cell.getMaxEnergyStored)
    if not success then
        log("Warning: Failed to read max energy: " .. tostring(max_rf))
        max_rf = 1000000 -- Default fallback
    end
    
    current_rf = safe_number(current_rf, 0)
    max_rf = safe_number(max_rf, 1)
    
    local rf_change = 0
    local time_diff = current_time - last_time
    
    if last_time > 0 and time_diff > 0 then
        rf_change = (current_rf - last_rf) / time_diff
    end
    
    -- Store data
    local data_point = {
        storage = current_rf,
        max_storage = max_rf,
        rate = rf_change,
        input = math.max(0, rf_change),
        output = math.abs(math.min(0, rf_change)),
        timestamp = current_time
    }
    
    -- Add to history
    table.insert(graph_data.input, data_point.input)
    table.insert(graph_data.output, data_point.output)
    table.insert(graph_data.storage, current_rf)
    table.insert(graph_data.timestamps, current_time)
    
    -- Limit history size
    while #graph_data.input > CONFIG.graph_history do
        table.remove(graph_data.input, 1)
        table.remove(graph_data.output, 1)
        table.remove(graph_data.storage, 1)
        table.remove(graph_data.timestamps, 1)
    end
    
    last_rf = current_rf
    last_time = current_time
    
    return data_point
end

-- Drawing functions
local function draw_header()
    if not monitor then return end
    
    local w, h = monitor.getSize()
    monitor.setCursorPos(1, 1)
    monitor.setBackgroundColor(CONFIG.colors.primary)
    monitor.setTextColor(CONFIG.colors.background)
    
    -- Clear header line
    local header = " RF Monitor v1.0" .. string.rep(" ", w - 16) .. "EXIT"
    monitor.write(header:sub(1, w))
    
    monitor.setBackgroundColor(CONFIG.colors.background)
    monitor.setTextColor(CONFIG.colors.text)
end

local function draw_status_bar(data)
    if not monitor or not data then return end
    
    local w, h = monitor.getSize()
    monitor.setCursorPos(1, 2)
    monitor.setBackgroundColor(CONFIG.colors.secondary)
    monitor.setTextColor(CONFIG.colors.text)
    
    local storage_percent = (data.storage / math.max(data.max_storage, 1)) * 100
    local status_text = string.format(" %s (%.1f%%) | %s ", 
        format_rf(data.storage), 
        storage_percent, 
        format_rate(data.rate))
    
    monitor.write(status_text .. string.rep(" ", w - #status_text))
    
    monitor.setBackgroundColor(CONFIG.colors.background)
end

local function draw_graph()
    if not monitor or #graph_data.input == 0 then return end
    
    local w, h = monitor.getSize()
    local graph_area = {
        x = 2,
        y = 4,
        width = w - 2,
        height = h - 6
    }
    
    -- Calculate scales
    local max_input = 0
    local max_output = 0
    
    for i = 1, #graph_data.input do
        max_input = math.max(max_input, safe_number(graph_data.input[i], 0))
        max_output = math.max(max_output, safe_number(graph_data.output[i], 0))
    end
    
    local max_rate = math.max(max_input, max_output)
    if max_rate == 0 then max_rate = 1000 end -- Default scale
    
    -- Draw grid if enabled
    if ui_state.show_grid then
        monitor.setTextColor(CONFIG.colors.grid)
        for y = graph_area.y, graph_area.y + graph_area.height - 1 do
            monitor.setCursorPos(graph_area.x, y)
            monitor.write(string.rep(".", graph_area.width))
        end
    end
    
    -- Draw input (positive) values
    monitor.setTextColor(CONFIG.colors.success)
    for i = 1, math.min(#graph_data.input, graph_area.width) do
        local data_index = #graph_data.input - graph_area.width + i
        if data_index > 0 then
            local value = safe_number(graph_data.input[data_index], 0)
            local bar_height = math.floor((value / max_rate) * graph_area.height)
            
            for j = 0, bar_height - 1 do
                local y_pos = graph_area.y + graph_area.height - 1 - j
                if y_pos >= graph_area.y then
                    monitor.setCursorPos(graph_area.x + i - 1, y_pos)
                    monitor.write("|")
                end
            end
        end
    end
    
    -- Draw output (negative) values  
    monitor.setTextColor(CONFIG.colors.error)
    for i = 1, math.min(#graph_data.output, graph_area.width) do
        local data_index = #graph_data.output - graph_area.width + i
        if data_index > 0 then
            local value = safe_number(graph_data.output[data_index], 0)
            local bar_height = math.floor((value / max_rate) * graph_area.height / 2)
            
            for j = 0, bar_height - 1 do
                local y_pos = graph_area.y + graph_area.height - 1 - j
                if y_pos >= graph_area.y then
                    monitor.setCursorPos(graph_area.x + i - 1, y_pos)
                    monitor.write("^")
                end
            end
        end
    end
    
    -- Draw legend
    monitor.setTextColor(CONFIG.colors.text)
    monitor.setCursorPos(1, h - 1)
    monitor.setTextColor(CONFIG.colors.success)
    monitor.write("| Input ")
    monitor.setTextColor(CONFIG.colors.error)
    monitor.write("^ Output ")
    monitor.setTextColor(CONFIG.colors.text)
    monitor.write("Scale: " .. format_rf(max_rate))
end

local function draw_buttons()
    if not monitor then return end
    
    local w, h = monitor.getSize()
    monitor.setCursorPos(1, h)
    monitor.setBackgroundColor(CONFIG.colors.accent)
    monitor.setTextColor(CONFIG.colors.background)
    
    local buttons = {"GRAPH", "SETTINGS", "INFO"}
    local button_width = math.floor(w / #buttons)
    
    for i, button in ipairs(buttons) do
        local x_pos = (i - 1) * button_width + 1
        monitor.setCursorPos(x_pos, h)
        
        if ui_state.current_view == button:lower() then
            monitor.setBackgroundColor(CONFIG.colors.primary)
        else
            monitor.setBackgroundColor(CONFIG.colors.accent)
        end
        
        local padding = math.floor((button_width - #button) / 2)
        local button_text = string.rep(" ", padding) .. button .. string.rep(" ", button_width - #button - padding)
        monitor.write(button_text:sub(1, button_width))
    end
    
    monitor.setBackgroundColor(CONFIG.colors.background)
    monitor.setTextColor(CONFIG.colors.text)
end

local function draw_settings_view()
    if not monitor then return end
    
    local w, h = monitor.getSize()
    
    -- Clear content area
    for y = 3, h - 2 do
        monitor.setCursorPos(1, y)
        monitor.write(string.rep(" ", w))
    end
    
    monitor.setCursorPos(2, 4)
    monitor.setTextColor(CONFIG.colors.accent)
    monitor.write("SETTINGS")
    
    monitor.setTextColor(CONFIG.colors.text)
    monitor.setCursorPos(2, 6)
    monitor.write("Update Interval: " .. CONFIG.update_interval .. "s")
    
    monitor.setCursorPos(2, 7)
    monitor.write("Graph History: " .. CONFIG.graph_history .. " points")
    
    monitor.setCursorPos(2, 8)
    monitor.write("Show Grid: " .. (ui_state.show_grid and "ON" or "OFF"))
    
    monitor.setCursorPos(2, 9)
    monitor.write("Scale Mode: " .. ui_state.scale_mode:upper())
end

local function draw_info_view()
    if not monitor then return end
    
    local w, h = monitor.getSize()
    
    -- Clear content area
    for y = 3, h - 2 do
        monitor.setCursorPos(1, y)
        monitor.write(string.rep(" ", w))
    end
    
    monitor.setCursorPos(2, 4)
    monitor.setTextColor(CONFIG.colors.accent)
    monitor.write("SYSTEM INFO")
    
    monitor.setTextColor(CONFIG.colors.text)
    monitor.setCursorPos(2, 6)
    monitor.write("Monitor: " .. (monitor and "Connected" or "Disconnected"))
    
    monitor.setCursorPos(2, 7)
    monitor.write("Energy Cell: " .. (energy_cell and "Connected" or "Disconnected"))
    
    monitor.setCursorPos(2, 8)
    monitor.write("Data Points: " .. #graph_data.input)
    
    monitor.setCursorPos(2, 9)
    monitor.write("Uptime: " .. string.format("%.1fs", os.clock()))
    
    if energy_cell then
        monitor.setCursorPos(2, 11)
        monitor.write("Max Capacity: " .. format_rf(safe_number(energy_cell.getMaxEnergyStored(), 0)))
    end
end

-- Touch event handling
local function handle_touch(x, y)
    if not monitor then return end
    
    local w, h = monitor.getSize()
    
    -- Check header (exit button)
    if y == 1 and x >= w - 3 then
        return "exit"
    end
    
    -- Check bottom buttons
    if y == h then
        local button_width = math.floor(w / 3)
        local button_index = math.floor((x - 1) / button_width) + 1
        
        if button_index == 1 then
            ui_state.current_view = "graph"
        elseif button_index == 2 then
            ui_state.current_view = "settings"
        elseif button_index == 3 then
            ui_state.current_view = "info"
        end
        return "button_press"
    end
    
    -- Settings view interactions
    if ui_state.current_view == "settings" then
        if y == 8 then -- Grid toggle
            ui_state.show_grid = not ui_state.show_grid
            return "setting_change"
        end
    end
    
    return "none"
end

-- Main drawing function
local function draw_ui()
    if not monitor then return end
    
    monitor.clear()
    
    draw_header()
    
    local current_data = collect_rf_data()
    if current_data then
        draw_status_bar(current_data)
    end
    
    if ui_state.current_view == "graph" then
        draw_graph()
    elseif ui_state.current_view == "settings" then
        draw_settings_view()
    elseif ui_state.current_view == "info" then
        draw_info_view()
    end
    
    draw_buttons()
end

-- Main loop
local function main()
    log("Starting RF Monitor v1.0...")
    
    -- Initialize peripherals with better error messages
    local success, error_msg
    
    success, error_msg = pcall(setup_monitor)
    if not success then
        error("Monitor setup failed: " .. tostring(error_msg))
    end
    
    success, error_msg = pcall(setup_energy_cell)
    if not success then
        error("Energy cell setup failed: " .. tostring(error_msg))
    end
    
    log("All peripherals connected successfully")
    log("Monitor size: " .. monitor.getSize())
    log("Press EXIT on monitor or Ctrl+T to quit")
    
    -- Initial draw
    draw_ui()
    
    -- Main loop
    local running = true
    local last_update = 0
    
    while running do
        local start_time = os.clock()
        
        -- Handle events with timeout
        local event_data = {os.pullEventRaw(0.1)} -- 100ms timeout
        local event = event_data[1]
        
        if event == "terminate" then
            running = false
        elseif event == "monitor_touch" then
            local side = event_data[2]
            local x = safe_number(event_data[3], 1)
            local y = safe_number(event_data[4], 1)
            
            log("Touch detected at " .. x .. "," .. y)
            local action = handle_touch(x, y)
            if action == "exit" then
                running = false
            elseif action == "button_press" or action == "setting_change" then
                draw_ui() -- Immediate redraw for responsiveness
            end
        elseif event == "peripheral_detach" then
            local side = event_data[2]
            log("Peripheral detached: " .. tostring(side))
            -- Try to reconnect
            if not monitor or not monitor.getSize then
                pcall(setup_monitor)
            end
            if not energy_cell then
                pcall(setup_energy_cell)
            end
        elseif event == "peripheral" then
            local side = event_data[2]
            log("Peripheral attached: " .. tostring(side))
            -- Try to connect if we're missing peripherals
            if not monitor then
                pcall(setup_monitor)
            end
            if not energy_cell then
                pcall(setup_energy_cell)
            end
        end
        
        -- Update display at configured interval
        if start_time - last_update >= CONFIG.update_interval then
            local success, error_msg = pcall(draw_ui)
            if not success then
                log("Error updating display: " .. tostring(error_msg))
            end
            last_update = start_time
        end
        
        -- Small delay to prevent excessive CPU usage
        local elapsed = os.clock() - start_time
        if elapsed < 0.05 then
            sleep(0.05 - elapsed)
        end
    end
    
    log("RF Monitor stopped")
    if monitor then
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.setTextColor(CONFIG.colors.text)
        monitor.setBackgroundColor(CONFIG.colors.background)
        monitor.write("RF Monitor - Stopped")
        monitor.setCursorPos(1, 2)
        monitor.write("Thank you for using RF Monitor!")
    end
end

-- Error handling wrapper
local function safe_main()
    local success, error_msg = pcall(main)
    if not success then
        log("Error: " .. tostring(error_msg))
        if monitor then
            monitor.clear()
            monitor.setCursorPos(1, 1)
            monitor.setTextColor(CONFIG.colors.error)
            monitor.write("ERROR: " .. tostring(error_msg))
        end
        print("Error: " .. tostring(error_msg))
    end
end

-- Start the program
safe_main()