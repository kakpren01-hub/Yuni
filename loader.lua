-- Aim Assist System Script
-- Place this in a LocalScript inside StarterPlayerScripts

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Settings
local settings = {
    enabled = false,
    fov = 100, -- Field of view for detection
    smoothness = 0.3, -- 0 = instant, 1 = very smooth
    targetLock = false, -- Lock onto target
    keybind = Enum.KeyCode.Q, -- Default keybind
    wallCheck = true, -- Check if target is behind wall
    teamCheck = false, -- Don't target teammates
}

-- UI Elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimAssistGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true

-- Rounded corners for main frame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -30, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ Aim Assist"
titleText.TextSize = 18
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
closeButton.Text = "✕"
closeButton.TextSize = 14
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

closeButton.Parent = titleBar
titleBar.Parent = mainFrame

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Scrollable content
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 5
scrollingFrame.ScrollBarImageColor3 = Color3.new(0.5, 0.5, 0.5)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
scrollingFrame.Parent = contentFrame

-- UI List Layout
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.Parent = scrollingFrame

-- Helper function to create toggle
local function createToggle(name, description, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Frame"
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.7, 0, 0, 15)
        desc.Position = UDim2.new(0, 10, 0.5, 5)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextSize = 10
        desc.TextColor3 = Color3.new(0.6, 0.6, 0.6)
        desc.Font = Enum.Font.SourceSans
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
    
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = default and Color3.new(0.3, 0.8, 0.3) or Color3.new(0.5, 0.5, 0.5)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextSize = 10
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.BorderSizePixel = 0
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 5)
    toggleCorner.Parent = toggle
    
    local state = default
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.new(0.3, 0.8, 0.3) or Color3.new(0.5, 0.5, 0.5)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    toggle.Parent = frame
    frame.Parent = scrollingFrame
    
    return toggle
end

-- Helper function to create slider
local function createSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Frame"
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(1, -20, 0, 5)
    slider.Position = UDim2.new(0, 10, 0, 35)
    slider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    slider.BorderSizePixel = 0
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(0.3, 0.6, 1)
    fill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    fill.Parent = slider
    
    local value = default
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = mouse.X - slider.AbsolutePosition.X
            local percent = math.clamp(relativeX / slider.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
    
    slider.Parent = frame
    frame.Parent = scrollingFrame
    
    return frame
end

-- Create UI elements
createToggle("Enabled", "Toggle aim assist on/off", settings.enabled, function(state)
    settings.enabled = state
end)

createSlider("FOV", 30, 200, settings.fov, function(value)
    settings.fov = value
end)

createSlider("Smoothness", 0, 1, settings.smoothness, function(value)
    settings.smoothness = value
end)

createToggle("Target Lock", "Lock onto current target", settings.targetLock, function(state)
    settings.targetLock = state
end)

createToggle("Wall Check", "Check if target is behind wall", settings.wallCheck, function(state)
    settings.wallCheck = state
end)

createToggle("Team Check", "Don't target teammates", settings.teamCheck, function(state)
    settings.teamCheck = state
end)

-- Keybind display
local keybindFrame = Instance.new("Frame")
keybindFrame.Name = "KeybindFrame"
keybindFrame.Size = UDim2.new(1, 0, 0, 50)
keybindFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
keybindFrame.BackgroundTransparency = 0.3
keybindFrame.BorderSizePixel = 0

local keybindCorner = Instance.new("UICorner")
keybindCorner.CornerRadius = UDim.new(0, 8)
keybindCorner.Parent = keybindFrame

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
keybindLabel.Position = UDim2.new(0, 10, 0, 0)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Keybind"
keybindLabel.TextSize = 14
keybindLabel.TextColor3 = Color3.new(1, 1, 1)
keybindLabel.Font = Enum.Font.SourceSans
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = keybindFrame

local keybindButton = Instance.new("TextButton")
keybindButton.Name = "KeybindButton"
keybindButton.Size = UDim2.new(0, 80, 0, 30)
keybindButton.Position = UDim2.new(1, -90, 0.5, -15)
keybindButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
keybindButton.Text = settings.keybind.Name
keybindButton.TextSize = 12
keybindButton.TextColor3 = Color3.new(1, 1, 1)
keybindButton.Font = Enum.Font.SourceSansBold
keybindButton.BorderSizePixel = 0

local keybindBtnCorner = Instance.new("UICorner")
keybindBtnCorner.CornerRadius = UDim.new(0, 5)
keybindBtnCorner.Parent = keybindButton

local listening = false

keybindButton.MouseButton1Click:Connect(function()
    listening = true
    keybindButton.Text = "..."
    keybindButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
end)

userInputService.InputBegan:Connect(function(input)
    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
        settings.keybind = input.KeyCode
        keybindButton.Text = input.KeyCode.Name
        keybindButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        listening = false
    end
end)

keybindButton.Parent = keybindFrame
keybindFrame.Parent = scrollingFrame

-- Toggle Button (to open/close UI)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0.5, -20)
toggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
toggleButton.BackgroundTransparency = 0.3
toggleButton.Text = "⚡"
toggleButton.TextSize = 20
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.BorderSizePixel = 0

local toggleBtnCorner = Instance.new("UICorner")
toggleBtnCorner.CornerRadius = UDim.new(0, 10)
toggleBtnCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleButton.Visible = not mainFrame.Visible
end)

toggleButton.Parent = screenGui
mainFrame.Parent = screenGui

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    toggleButton.Visible = true
end)

-- AIM ASSIST LOGIC

local currentTarget = nil
local aimActive = false

-- Get closest target
local function getClosestTarget()
    local closest = nil
    local closestDistance = settings.fov
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer == player then continue end
        if settings.teamCheck and otherPlayer.Team == player.Team then continue end
        
        local character = otherPlayer.Character
        if not character then continue end
        
        local head = character:FindFirstChild("Head")
        if not head then continue end
        
        -- Check if on screen
        local screenPoint, onScreen = camera:WorldToScreenPoint(head.Position)
        if not onScreen then continue end
        
        -- Check distance from center
        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
        
        if distance < closestDistance then
            -- Wall check
            if settings.wallCheck then
                local ray = Ray.new(camera.CFrame.Position, (head.Position - camera.CFrame.Position).Unit * 500)
                local hit, position = workspace:FindPartOnRay(ray, player.Character)
                if hit and hit:IsDescendantOf(character) then
                    closest = otherPlayer
                    closestDistance = distance
                end
            else
                closest = otherPlayer
                closestDistance = distance
            end
        end
    end
    
    return closest
end

-- Main aim loop
runService.RenderStepped:Connect(function()
    if not settings.enabled then
        currentTarget = nil
        return
    end
    
    if aimActive then
        if settings.targetLock and currentTarget then
            -- Keep targeting the same player
            local character = currentTarget.Character
            if character then
                local head = character:FindFirstChild("Head")
                if head then
                    local targetPosition = head.Position
                    local currentPosition = camera.CFrame.Position
                    local lookAt = CFrame.lookAt(currentPosition, targetPosition)
                    
                    -- Apply smoothness
                    local lerpAlpha = 1 - settings.smoothness
                    camera.CFrame = camera.CFrame:Lerp(lookAt, lerpAlpha)
                end
            else
                currentTarget = nil
            end
        else
            -- Find new target
            currentTarget = getClosestTarget()
        end
    else
        currentTarget = nil
    end
end)

-- Keybind to activate aim
userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == settings.keybind and settings.enabled then
        aimActive = true
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.KeyCode == settings.keybind then
        aimActive = false
        currentTarget = nil
    end
end)

-- Switch targets with mouse wheel
mouse.WheelForward:Connect(function()
    if aimActive and settings.enabled then
        -- Find next target
        local players = game.Players:GetPlayers()
        local currentIndex = 0
        
        for i, p in pairs(players) do
            if p == currentTarget then
                currentIndex = i
                break
            end
        end
        
        -- Get next valid target
        for i = currentIndex + 1, #players do
            if players[i] ~= player then
                local character = players[i].Character
                if character and character:FindFirstChild("Head") then
                    currentTarget = players[i]
                    break
                end
            end
        end
    end
end)

mouse.WheelBackward:Connect(function()
    if aimActive and settings.enabled then
        local players = game.Players:GetPlayers()
        local currentIndex = #players + 1
        
        for i, p in pairs(players) do
            if p == currentTarget then
                currentIndex = i
                break
            end
        end
        
        for i = currentIndex - 1, 1, -1 do
            if players[i] ~= player then
                local character = players[i].Character
                if character and character:FindFirstChild("Head") then
                    currentTarget = players[i]
                    break
                end
            end
        end
    end
end)

-- FOV Circle (visual indicator)
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.Size = UDim2.new(0, settings.fov * 2, 0, settings.fov * 2)
fovCircle.Position = UDim2.new(0.5, -settings.fov, 0.5, -settings.fov)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Parent = screenGui

local fovCircleUI = Instance.new("UICorner")
fovCircleUI.CornerRadius = UDim.new(0, settings.fov)
fovCircleUI.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 1
fovStroke.Color = Color3.new(0.3, 0.6, 1)
fovStroke.Transparency = 0.5
fovStroke.Parent = fovCircle

-- Update FOV circle
runService.RenderStepped:Connect(function()
    fovCircle.Size = UDim2.new(0, settings.fov * 2, 0, settings.fov * 2)
    fovCircle.Position = UDim2.new(0.5, -settings.fov, 0.5, -settings.fov)
    fovCircleUI.CornerRadius = UDim.new(0, settings.fov)
end)

print("Aim Assist loaded! Press the toggle button to open the UI.")
