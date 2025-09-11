--[[
RF Monitor Startup Script
Automatically starts the RF Monitor with error recovery
Place this as "startup.lua" for automatic startup
--]]

local function log(message)
    print("[Startup] " .. message)
end

local function check_files()
    if not fs.exists("rf_monitor.lua") then
        log("rf_monitor.lua not found!")
        log("Running installer...")
        
        if fs.exists("installer.lua") then
            shell.run("installer.lua")
        else
            log("Installer not found. Please download rf_monitor.lua manually.")
            return false
        end
    end
    
    return fs.exists("rf_monitor.lua")
end

local function run_monitor()
    local attempts = 0
    local max_attempts = 3
    
    while attempts < max_attempts do
        attempts = attempts + 1
        log("Starting RF Monitor (attempt " .. attempts .. "/" .. max_attempts .. ")")
        
        local success, error_msg = pcall(shell.run, "rf_monitor.lua")
        
        if success then
            log("RF Monitor exited normally")
            break
        else
            log("RF Monitor crashed: " .. tostring(error_msg))
            
            if attempts < max_attempts then
                log("Restarting in 5 seconds...")
                sleep(5)
            else
                log("Max restart attempts reached. Manual intervention required.")
                break
            end
        end
    end
end

local function main()
    log("RF Monitor Auto-Startup v1.0")
    
    -- Check if files exist
    if not check_files() then
        log("Required files missing. Startup aborted.")
        return
    end
    
    -- Welcome message
    log("RF Monitor will start in 3 seconds...")
    log("Press Ctrl+T to cancel automatic startup")
    
    -- Countdown with cancel option
    for i = 3, 1, -1 do
        sleep(1)
        print(i .. "...")
    end
    
    log("Starting RF Monitor...")
    run_monitor()
    
    log("RF Monitor startup sequence complete")
end

-- Check for skip argument
local args = {...}
if args[1] == "skip" then
    log("Skipping automatic startup (skip argument provided)")
else
    main()
end