local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Navigation Logic
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NavigationUtils = require(Shared:WaitForChild("NavigationUtils"))

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- Constants
local RADAR_RANGE = 100 -- Units
local BASE_SIZE = 260 -- Previous size after 30% increase
local RADAR_SIZE_PX = math.floor(BASE_SIZE * 1.15) -- Increased by exactly 15% (~300px)
local SCALE = (RADAR_SIZE_PX / 2) / RADAR_RANGE -- Pixels per unit
local UPDATE_INTERVAL_MS = 0.1 -- 100ms
local LERP_SPEED = 10
local MAX_OBJECTS = 50

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedRadarSystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Main Container (Bottom Left)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "RadarContainer"
mainFrame.Size = UDim2.new(0, RADAR_SIZE_PX + 40, 0, RADAR_SIZE_PX + 80)
mainFrame.Position = UDim2.new(0, 20, 1, -20)
mainFrame.AnchorPoint = Vector2.new(0, 1)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- Coords Label (X, Z only)
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Name = "CoordsLabel"
coordsLabel.Size = UDim2.new(1, 0, 0, 30)
coordsLabel.Position = UDim2.new(0, 10, 0, 0)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.TextSize = 20
coordsLabel.Font = Enum.Font.RobotoMono
coordsLabel.TextXAlignment = Enum.TextXAlignment.Left
coordsLabel.Text = "X: 0.0, Z: 0.0"
coordsLabel.ZIndex = 10
coordsLabel.Parent = mainFrame

-- CanvasGroup is the KEY to perfect circular clipping in Roblox
local radarCanvas = Instance.new("CanvasGroup")
radarCanvas.Name = "RadarCanvas"
radarCanvas.Size = UDim2.new(0, RADAR_SIZE_PX, 0, RADAR_SIZE_PX)
radarCanvas.Position = UDim2.new(0, 10, 0, 40)
radarCanvas.BackgroundColor3 = Color3.new(0, 0, 0) -- Pure black for darker background
radarCanvas.BackgroundTransparency = 0.6 -- Slightly more opaque for darkening
radarCanvas.BorderSizePixel = 0
radarCanvas.GroupTransparency = 0
radarCanvas.ClipsDescendants = true
radarCanvas.Parent = mainFrame

local canvasCorner = Instance.new("UICorner")
canvasCorner.CornerRadius = UDim.new(1, 0) -- Force perfect circle
canvasCorner.Parent = radarCanvas

-- Grid Container (Inside CanvasGroup directly for better clipping)
local gridContainer = Instance.new("Frame")
gridContainer.Name = "GridContainer"
gridContainer.Size = UDim2.new(1, 0, 1, 0)
gridContainer.BackgroundTransparency = 1
gridContainer.AnchorPoint = Vector2.new(0.5, 0.5)
gridContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
gridContainer.Parent = radarCanvas

-- Draw Grid Lines (Every 10 units)
-- Optimized: Only draw lines within the range
for i = -RADAR_RANGE, RADAR_RANGE, 10 do
    -- Vertical
    local vLine = Instance.new("Frame")
    vLine.Size = UDim2.new(0, 1, 1, 0) -- Limited to 1 (100% height)
    vLine.Position = UDim2.new(0.5, i * SCALE, 0.5, 0)
    vLine.AnchorPoint = Vector2.new(0.5, 0.5)
    vLine.BackgroundColor3 = Color3.new(1, 1, 1)
    vLine.BackgroundTransparency = 0.94 -- Slightly more transparent grid
    vLine.BorderSizePixel = 0
    vLine.Parent = gridContainer

    -- Horizontal
    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(1, 0, 0, 1) -- Limited to 1 (100% width)
    hLine.Position = UDim2.new(0.5, 0, 0.5, i * SCALE)
    hLine.AnchorPoint = Vector2.new(0.5, 0.5)
    hLine.BackgroundColor3 = Color3.new(1, 1, 1)
    hLine.BackgroundTransparency = 0.94 -- Slightly more transparent grid
    hLine.BorderSizePixel = 0
    hLine.Parent = gridContainer
end

-- Cardinal Markers Container (Rotates)
local cardinalContainer = Instance.new("Frame")
cardinalContainer.Name = "CardinalContainer"
cardinalContainer.Size = UDim2.new(1, 0, 1, 0)
cardinalContainer.BackgroundTransparency = 1
cardinalContainer.AnchorPoint = Vector2.new(0.5, 0.5)
cardinalContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
cardinalContainer.Parent = radarCanvas

local function createCardinal(text, angle)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0, 24, 0, 24)
    -- Position slightly inside the edge to ensure no clipping overflow
    label.Position = UDim2.new(0.5 + math.sin(math.rad(angle)) * 0.45, 0, 0.5 - math.cos(math.rad(angle)) * 0.45, 0)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.BackgroundTransparency = 1
    label.TextColor3 = (text == "N") and Color3.new(1, 0.2, 0.2) or Color3.new(1, 1, 1)
    label.TextSize = 20
    label.Font = Enum.Font.SourceSansBold
    label.ZIndex = 5
    label.Parent = cardinalContainer
    return label
end

local cardinals = {
    N = createCardinal("N", 0),
    E = createCardinal("E", 90),
    S = createCardinal("S", 180),
    W = createCardinal("W", 270)
}

-- Object Container (Rotates)
local objectContainer = Instance.new("Frame")
objectContainer.Name = "ObjectContainer"
objectContainer.Size = UDim2.new(1, 0, 1, 0)
objectContainer.BackgroundTransparency = 1
objectContainer.AnchorPoint = Vector2.new(0.5, 0.5)
objectContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
objectContainer.Parent = radarCanvas

-- Center Marker (Player)
local centerMarker = Instance.new("Frame")
centerMarker.Size = UDim2.new(0, 6, 0, 6)
centerMarker.Position = UDim2.new(0.5, 0, 0.5, 0)
centerMarker.AnchorPoint = Vector2.new(0.5, 0.5)
centerMarker.BackgroundColor3 = Color3.new(1, 1, 1)
centerMarker.ZIndex = 10
centerMarker.Parent = radarCanvas
local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = centerMarker

-- Pooling System
local pools = {
    Player = {},
    Structure = {},
    Other = {}
}

local function getFromPool(type)
    for _, item in ipairs(pools[type]) do
        if not item.Visible then
            item.Visible = true
            return item
        end
    end
    
    local item
    if type == "Player" then
        item = Instance.new("Frame")
        item.Size = UDim2.new(0, 4, 0, 4)
        item.BackgroundColor3 = Color3.new(0.2, 1, 0.2)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = item
    elseif type == "Structure" then
        item = Instance.new("Frame")
        item.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        item.BackgroundTransparency = 0.4
    else
        item = Instance.new("Frame")
        item.Size = UDim2.new(0, 6, 0, 6)
        item.BackgroundColor3 = Color3.new(0.2, 0.2, 1)
    end
    
    item.AnchorPoint = Vector2.new(0.5, 0.5)
    item.BorderSizePixel = 0
    item.Visible = true
    item.Parent = objectContainer
    table.insert(pools[type], item)
    return item
end

local function resetPools()
    for _, pool in pairs(pools) do
        for _, item in ipairs(pool) do
            item.Visible = false
        end
    end
end

-- Update Logic
local lastUpdate = 0
local currentRotation = 0

RunService.RenderStepped:Connect(function(dt)
    local character = localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- 1. Update Coords (X, Z only)
    coordsLabel.Text = string.format("X: %.1f, Z: %.1f", hrp.Position.X, hrp.Position.Z)

    -- 2. Radar Rotation (Based on Camera)
    local camLook = camera.CFrame.LookVector
    local targetRotation = math.deg(math.atan2(camLook.X, camLook.Z)) + 180
    
    local diff = (targetRotation - currentRotation)
    if diff > 180 then diff -= 360 elseif diff < -180 then diff += 360 end
    currentRotation = currentRotation + diff * math.min(dt * LERP_SPEED, 1)
    
    gridContainer.Rotation = currentRotation
    objectContainer.Rotation = currentRotation
    cardinalContainer.Rotation = currentRotation
    
    -- Keep cardinal letters upright
    for _, label in pairs(cardinals) do
        label.Rotation = -currentRotation
    end

    -- 3. Optimized Object Update (100ms)
    if tick() - lastUpdate >= UPDATE_INTERVAL_MS then
        lastUpdate = tick()
        resetPools()
        
        local count = 0
        
        -- Players
        for _, player in ipairs(Players:GetPlayers()) do
            if count >= MAX_OBJECTS then break end
            if player == localPlayer then continue end
            
            local otherChar = player.Character
            local otherHrp = otherChar and otherChar:FindFirstChild("HumanoidRootPart")
            if otherHrp then
                local offset = otherHrp.Position - hrp.Position
                if offset.Magnitude <= RADAR_RANGE then
                    local dot = getFromPool("Player")
                    dot.Position = UDim2.new(0.5 + (offset.X * SCALE) / RADAR_SIZE_PX, 0, 0.5 + (offset.Z * SCALE) / RADAR_SIZE_PX, 0)
                    count += 1
                end
            end
        end
        
        -- Structures
        for _, part in ipairs(Workspace:GetPartBoundsInRadius(hrp.Position, RADAR_RANGE)) do
            if count >= MAX_OBJECTS then break end
            if part:IsDescendantOf(character) or part.Name == "Baseplate" then continue end
            
            if part.Size.Magnitude > 10 then
                local offset = part.Position - hrp.Position
                local struct = getFromPool("Structure")
                struct.Size = UDim2.new(0, part.Size.X * SCALE, 0, part.Size.Z * SCALE)
                struct.Position = UDim2.new(0.5 + (offset.X * SCALE) / RADAR_SIZE_PX, 0, 0.5 + (offset.Z * SCALE) / RADAR_SIZE_PX, 0)
                struct.Rotation = -part.Orientation.Y
                count += 1
            end
        end
    end
end)

print("Radar Circular Clipping & Position Fixed!")
