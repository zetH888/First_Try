local NavigationUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("NavigationUtils"))

local Test = {
    Success = 0,
    Total = 0
}

local function assertTest(name, condition)
    Test.Total = Test.Total + 1
    if condition then
        Test.Success = Test.Success + 1
        print("✅ TEST PASSED: " .. name)
    else
        warn("❌ TEST FAILED: " .. name)
    end
end

-- 1. Test formatowania współrzędnych
assertTest("North-East Coord", NavigationUtils.formatGeoCoords({X = 10, Z = -5}) == "5.0°N, 10.0°E")
assertTest("South-West Coord", NavigationUtils.formatGeoCoords({X = -15, Z = 20}) == "20.0°S, 15.0°W")
assertTest("Origin Coord", NavigationUtils.formatGeoCoords({X = 0, Z = 0}) == "0.0°N, 0.0°E")

-- 2. Test kierunków świata
assertTest("Cardinal North", NavigationUtils.getCardinal(0) == "N")
assertTest("Cardinal East", NavigationUtils.getCardinal(90) == "E")
assertTest("Cardinal South", NavigationUtils.getCardinal(180) == "S")
assertTest("Cardinal West", NavigationUtils.getCardinal(270) == "W")

-- 3. Test obliczania stopni na podstawie LookVector
assertTest("North LookVector", math.abs(NavigationUtils.calculateDegrees(Vector3.new(0, 0, -1)) - 0) < 0.1)
assertTest("East LookVector", math.abs(NavigationUtils.calculateDegrees(Vector3.new(1, 0, 0)) - 90) < 0.1)
assertTest("South LookVector", math.abs(NavigationUtils.calculateDegrees(Vector3.new(0, 0, 1)) - 180) < 0.1)
assertTest("West LookVector", math.abs(NavigationUtils.calculateDegrees(Vector3.new(-1, 0, 0)) - 270) < 0.1)

print(string.format("\nNavigation Tests Finished: %d/%d passed", Test.Success, Test.Total))

return Test
