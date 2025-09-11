-- RF Monitor Configuration
-- Edit this file to customize your RF monitoring setup

return {
    -- Peripheral Configuration
    peripherals = {
        monitor_name = "monitor_0",              -- Name of monitor peripheral
        energy_cell_name = "thermal:energy_cell_0", -- Name of energy cell peripheral
        auto_detect = true,                      -- Auto-detect peripherals if names not found
    },
    
    -- Display Settings
    display = {
        text_scale = 0.5,                       -- Text scale for 2x2 monitor setup
        update_interval = 0.5,                  -- Update frequency in seconds
        graph_history = 100,                    -- Number of data points to keep in graph
        show_grid = true,                       -- Show grid lines on graph
        animation_speed = 0.1,                  -- UI animation delay
    },
    
    -- Graph Settings
    graph = {
        auto_scale = true,                      -- Automatically scale graph
        manual_scale_max = 10000,               -- Maximum scale when auto_scale is false
        bar_characters = {
            input = "|",                        -- Character for RF input bars
            output = "^",                       -- Character for RF output bars
        },
        show_legend = true,                     -- Show graph legend
        smooth_data = false,                    -- Apply smoothing to graph data
    },
    
    -- Color Theme
    colors = {
        background = colors.black,
        primary = colors.lightBlue,
        secondary = colors.blue,
        accent = colors.yellow,
        text = colors.white,
        success = colors.lime,
        warning = colors.orange,
        error = colors.red,
        grid = colors.gray,
        header_bg = colors.lightBlue,
        header_text = colors.black,
        status_bg = colors.blue,
        button_bg = colors.yellow,
        button_text = colors.black,
        button_active_bg = colors.lightBlue,
    },
    
    -- UI Layout
    ui = {
        header_height = 1,                      -- Height of header bar
        status_height = 1,                      -- Height of status bar
        button_height = 1,                      -- Height of button bar
        graph_margin = 2,                       -- Margin around graph area
        button_spacing = 0,                     -- Spacing between buttons
    },
    
    -- Data Collection
    data = {
        collection_interval = 0.1,              -- How often to collect data (seconds)
        rate_calculation_window = 5,            -- Window for rate calculation (data points)
        storage_precision = 0,                  -- Decimal places for storage display
        rate_precision = 1,                     -- Decimal places for rate display
    },
    
    -- Alert System
    alerts = {
        enabled = true,                         -- Enable alert system
        low_storage_threshold = 10,             -- Low storage alert (percentage)
        high_rate_threshold = 50000,            -- High rate alert (RF/t)
        storage_critical_threshold = 5,         -- Critical storage alert (percentage)
        alert_sound = true,                     -- Play sound for alerts
        alert_blink = true,                     -- Blink display for alerts
    },
    
    -- Performance Settings
    performance = {
        max_fps = 20,                          -- Maximum display updates per second
        gc_interval = 100,                     -- Garbage collection interval (updates)
        memory_limit = 1000,                   -- Memory usage limit (KB)
        cpu_yield_interval = 0.05,             -- CPU yield interval for long operations
    },
    
    -- Debug Settings
    debug = {
        enabled = false,                        -- Enable debug mode
        log_level = "INFO",                    -- Log level: DEBUG, INFO, WARN, ERROR
        show_performance = false,               -- Show performance metrics
        log_to_file = false,                   -- Log to file instead of console
        log_file = "rf_monitor.log",           -- Log file name
    },
    
    -- Advanced Features
    advanced = {
        multi_cell_support = false,            -- Support multiple energy cells
        network_monitoring = false,            -- Monitor network-connected cells
        data_export = false,                   -- Export data to files
        remote_access = false,                 -- Allow remote computer access
        backup_config = true,                  -- Backup configuration on changes
    }
}