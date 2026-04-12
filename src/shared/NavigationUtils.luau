local NavigationUtils = {}

-- Konwertuje stopnie na kierunek świata (N, NE, E, SE, S, SW, W, NW)
function NavigationUtils.getCardinal(degrees)
    local directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
    local index = math.floor((degrees + 22.5) / 45) % 8 + 1
    return directions[index]
end

-- Konwertuje współrzędne Roblox (X, Z) na format geograficzny
-- Założenie: X+ to East (E), X- to West (W), Z+ to South (S), Z- to North (N)
function NavigationUtils.formatGeoCoords(pos)
    local x = pos.X
    local z = pos.Z
    
    local latDir = z <= 0 and "N" or "S"
    local lonDir = x >= 0 and "E" or "W"
    
    return string.format("%.1f°%s, %.1f°%s", math.abs(z), latDir, math.abs(x), lonDir)
end

-- Oblicza kierunek w stopniach na podstawie LookVector (0 = North)
function NavigationUtils.calculateDegrees(lookVector)
    -- W Roblox, LookVector (0,0,-1) to przód (North)
    -- atan2(-X, -Z) daje 0 dla (0,0,-1)
    local degrees = (math.deg(math.atan2(-lookVector.X, -lookVector.Z)) + 180) % 360
    return degrees
end

return NavigationUtils
