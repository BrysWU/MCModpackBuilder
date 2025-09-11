--[[
RF Monitor Installer for CC:Tweaked
Simple installation script for the RF Live Graph Monitor
--]]

local function log(message)
    print("[Installer] " .. message)
end

local function downloadFile(url, filename)
    log("Downloading " .. filename .. "...")
    
    local request = http.get(url)
    if not request then
        error("Failed to download " .. filename)
    end
    
    local content = request.readAll()
    request.close()
    
    local file = fs.open(filename, "w")
    file.write(content)
    file.close()
    
    log("Downloaded " .. filename .. " successfully")
end

local function checkPeripherals()
    log("Checking for required peripherals...")
    
    local monitor = peripheral.find("monitor")
    local energy_cell = peripheral.find("thermal:energy_cell")
    
    if not monitor then
        log("WARNING: No monitor found. Please connect a monitor via modem.")
    else
        log("Monitor found: " .. peripheral.getName(monitor))
    end
    
    if not energy_cell then
        log("WARNING: No thermal energy cell found. Please connect an energy cell via modem.")
    else
        log("Energy cell found: " .. peripheral.getName(energy_cell))
    end
    
    return monitor ~= nil and energy_cell ~= nil
end

local function main()
    log("RF Monitor Installer v1.0")
    log("Installing RF Live Graph Monitor...")
    
    -- Check if we already have the file
    if fs.exists("rf_monitor.lua") then
        log("rf_monitor.lua already exists.")
        print("Do you want to overwrite it? (y/n): ")
        local input = read()
        if input ~= "y" and input ~= "Y" then
            log("Installation cancelled.")
            return
        end
    end
    
    -- Download the main script
    local url = "https://raw.githubusercontent.com/BrysWU/MCModpackBuilder/main/scripts/cc-tweaked/rf_monitor.lua"
    
    local success, error = pcall(downloadFile, url, "rf_monitor.lua")
    if not success then
        log("Error downloading file: " .. error)
        log("Manual installation required. Please copy the script manually.")
        return
    end
    
    -- Check peripherals
    local peripherals_ok = checkPeripherals()
    
    log("Installation complete!")
    log("")
    log("To run the RF Monitor:")
    log("  lua rf_monitor.lua")
    log("")
    
    if not peripherals_ok then
        log("Please ensure your peripherals are properly connected:")
        log("  - 2x2 Advanced Monitor connected via modem")
        log("  - Thermal Energy Cell connected via modem")
        log("")
    end
    
    print("Run RF Monitor now? (y/n): ")
    local input = read()
    if input == "y" or input == "Y" then
        log("Starting RF Monitor...")
        shell.run("rf_monitor.lua")
    end
end

-- Run installer
main()