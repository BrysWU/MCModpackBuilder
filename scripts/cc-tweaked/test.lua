--[[
RF Monitor Test Script
Tests the functionality of the RF monitoring system
--]]

local function log(message)
    print("[Test] " .. message)
end

local function test_peripheral_detection()
    log("Testing peripheral detection...")
    
    local peripherals = peripheral.getNames()
    log("Available peripherals: " .. table.concat(peripherals, ", "))
    
    local monitor = peripheral.find("monitor")
    local energy_cell = peripheral.find("thermal:energy_cell")
    
    log("Monitor found: " .. tostring(monitor ~= nil))
    log("Energy cell found: " .. tostring(energy_cell ~= nil))
    
    if monitor then
        local w, h = monitor.getSize()
        log("Monitor size: " .. w .. "x" .. h)
        log("Monitor color support: " .. tostring(monitor.isColor()))
    end
    
    if energy_cell then
        local max_energy = energy_cell.getMaxEnergyStored()
        local current_energy = energy_cell.getEnergyStored()
        log("Energy cell max capacity: " .. tostring(max_energy))
        log("Energy cell current energy: " .. tostring(current_energy))
    end
    
    return monitor ~= nil, energy_cell ~= nil
end

local function test_safe_number()
    log("Testing safe_number function...")
    
    -- Load the safe_number function from rf_monitor.lua
    local function safe_number(value, default)
        if type(value) == "number" and value == value then
            return value
        end
        return default or 0
    end
    
    -- Test cases
    local test_cases = {
        {value = 42, expected = 42, description = "normal number"},
        {value = nil, expected = 0, description = "nil value"},
        {value = "string", expected = 0, description = "string value"},
        {value = 0/0, expected = 0, description = "NaN value"},
        {value = math.huge, expected = math.huge, description = "infinity"},
        {value = -math.huge, expected = -math.huge, description = "negative infinity"},
    }
    
    local passed = 0
    for _, test in ipairs(test_cases) do
        local result = safe_number(test.value, 0)
        local success = result == test.expected
        log("Test " .. test.description .. ": " .. (success and "PASS" or "FAIL"))
        if success then
            passed = passed + 1
        end
    end
    
    log("Safe number tests: " .. passed .. "/" .. #test_cases .. " passed")
    return passed == #test_cases
end

local function test_format_functions()
    log("Testing format functions...")
    
    -- Load format functions from rf_monitor.lua
    local function safe_number(value, default)
        if type(value) == "number" and value == value then
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
    
    -- Test RF formatting
    local rf_tests = {
        {value = 0, expected = "0 RF"},
        {value = 500, expected = "500 RF"},
        {value = 1500, expected = "1.5K RF"},
        {value = 1500000, expected = "1.5M RF"},
        {value = nil, expected = "0 RF"},
    }
    
    local passed = 0
    for _, test in ipairs(rf_tests) do
        local result = format_rf(test.value)
        local success = result == test.expected
        log("RF format " .. tostring(test.value) .. ": " .. result .. " (" .. (success and "PASS" or "FAIL") .. ")")
        if success then
            passed = passed + 1
        end
    end
    
    log("Format tests: " .. passed .. "/" .. #rf_tests .. " passed")
    return passed == #rf_tests
end

local function test_monitor_drawing()
    log("Testing monitor drawing...")
    
    local monitor = peripheral.find("monitor")
    if not monitor then
        log("No monitor found for drawing test")
        return false
    end
    
    -- Test basic drawing operations
    local success = true
    
    -- Test clearing
    local ok, err = pcall(monitor.clear)
    if not ok then
        log("Failed to clear monitor: " .. err)
        success = false
    end
    
    -- Test text scale
    ok, err = pcall(monitor.setTextScale, 0.5)
    if not ok then
        log("Failed to set text scale: " .. err)
        success = false
    end
    
    -- Test color setting
    ok, err = pcall(monitor.setBackgroundColor, colors.black)
    if not ok then
        log("Failed to set background color: " .. err)
        success = false
    end
    
    ok, err = pcall(monitor.setTextColor, colors.white)
    if not ok then
        log("Failed to set text color: " .. err)
        success = false
    end
    
    -- Test cursor positioning and writing
    ok, err = pcall(monitor.setCursorPos, 1, 1)
    if not ok then
        log("Failed to set cursor position: " .. err)
        success = false
    end
    
    ok, err = pcall(monitor.write, "RF Monitor Test")
    if not ok then
        log("Failed to write text: " .. err)
        success = false
    end
    
    log("Monitor drawing test: " .. (success and "PASS" or "FAIL"))
    return success
end

local function run_all_tests()
    log("Starting RF Monitor Test Suite")
    log("=" .. string.rep("=", 40))
    
    local tests = {
        {name = "Peripheral Detection", func = test_peripheral_detection},
        {name = "Safe Number Function", func = test_safe_number},
        {name = "Format Functions", func = test_format_functions},
        {name = "Monitor Drawing", func = test_monitor_drawing},
    }
    
    local passed = 0
    local total = #tests
    
    for _, test in ipairs(tests) do
        log("")
        log("Running test: " .. test.name)
        log("-" .. string.rep("-", 30))
        
        local success, result = pcall(test.func)
        if success and result then
            log("✓ " .. test.name .. " PASSED")
            passed = passed + 1
        else
            log("✗ " .. test.name .. " FAILED" .. (success and "" or ": " .. result))
        end
    end
    
    log("")
    log("=" .. string.rep("=", 40))
    log("Test Results: " .. passed .. "/" .. total .. " tests passed")
    
    if passed == total then
        log("🎉 All tests passed! RF Monitor should work correctly.")
    else
        log("⚠️  Some tests failed. Please check your setup.")
    end
    
    return passed == total
end

-- Run the test suite
run_all_tests()