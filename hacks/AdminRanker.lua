-- HD Admin Ranks GUI System
-- Complete script that creates and manages the admin ranks interface

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Main Module Functions
local HDAdminRanks = {}

-- GUI Creation Functions
local function createScreenGui(name)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
    screenGui.IgnoreGuiInset = false
    screenGui.ClipToDeviceSafeArea = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    return screenGui
end

local function createFrame(parent, name, size, position, bgColor)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Parent = parent
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = bgColor or Color3.fromRGB(56, 56, 56)
    frame.BorderSizePixel = 0
    frame.BorderColor3 = Color3.fromRGB(27, 42, 53)
    frame.BackgroundTransparency = 0
    return frame
end

local function createTextLabel(parent, name, text, size, position, textColor)
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = name
    textLabel.Parent = parent
    textLabel.Size = size
    textLabel.Position = position
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    return textLabel
end

local function createTextButton(parent, name, text, size, position, bgColor, textColor)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = bgColor or Color3.fromRGB(163, 162, 165)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold
    return button
end

local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createUIStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = parent
    return stroke
end

-- Dragify Function
local function dragify(frame)
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = frame.Position
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(frame, TweenInfo.new(0.25), {Position = position}):Play()
    end
    
    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:GetFocusedTextBox() == nil then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

-- Admin Rank Functions
local function createRankButton(parent, rankName, rankColor, position)
    local button = createTextButton(parent, rankName, rankName, UDim2.new(0, 140, 0, 40), position, rankColor)
    createUICorner(button, 8)
    createUIStroke(button, Color3.fromRGB(0, 0, 0), 1)
    
    -- Add hover effects safely
    button.MouseEnter:Connect(function()
        local newColor = Color3.new(
            math.clamp(rankColor.R * 1.2, 0, 1),
            math.clamp(rankColor.G * 1.2, 0, 1),
            math.clamp(rankColor.B * 1.2, 0, 1)
        )
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = rankColor}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[HD Admin] You have been given " .. rankName .. " rank!";
            Color = rankColor;
            Font = Enum.Font.SourceSansBold;
        })
    end)
    
    return button
end

-- Main GUI Creation
function HDAdminRanks.createGUI()
    local existingGUI = playerGui:FindFirstChild("HDAdminRanks")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    local screenGui = createScreenGui("HDAdminRanks")
    
    local mainFrame = createFrame(screenGui, "Frame", UDim2.new(0, 540, 0, 300), UDim2.new(0.28, 0, 0.19, 0), Color3.fromRGB(56, 56, 56))
    createUICorner(mainFrame, 12)
    createUIStroke(mainFrame, Color3.fromRGB(27, 42, 53), 2)
    
    local innerFrame = createFrame(mainFrame, "Frame2", UDim2.new(0, 523, 0, 220), UDim2.new(0.015, 0, 0.022, 0), Color3.fromRGB(163, 214, 116))
    createUICorner(innerFrame, 10)
    
    local titleLabel = createTextLabel(innerFrame, "TextLabel", "HD Admin Ranks", UDim2.new(0, 200, 0, 30), UDim2.new(0.5, -100, 0, 10), Color3.fromRGB(255, 255, 255))
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    
    local ranks = {
        {name = "HD Vip", color = Color3.fromRGB(255, 215, 0), pos = UDim2.new(0, 20, 0, 60)},
        {name = "HD Mod", color = Color3.fromRGB(0, 255, 127), pos = UDim2.new(0, 180, 0, 60)},
        {name = "HD Admin", color = Color3.fromRGB(0, 127, 255), pos = UDim2.new(0, 340, 0, 60)},
        {name = "HD HeadAdmin", color = Color3.fromRGB(255, 0, 255), pos = UDim2.new(0, 20, 0, 130)},
        {name = "HD Owner", color = Color3.fromRGB(255, 69, 0), pos = UDim2.new(0, 180, 0, 130)},
        {name = "HD Above Owner", color = Color3.fromRGB(255, 0, 0), pos = UDim2.new(0, 340, 0, 130)},
    }
    
    for _, rank in ipairs(ranks) do
        createRankButton(innerFrame, rank.name, rank.color, rank.pos)
    end
    
    local closeButton = createTextButton(innerFrame, "Close", "X", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 10), Color3.fromRGB(255, 0, 0))
    createUICorner(closeButton, 15)
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local loaderButton = createTextButton(innerFrame, "HD Admin Loader", "Load Admin", UDim2.new(0, 140, 0, 40), UDim2.new(0.5, -70, 0, 200), Color3.fromRGB(128, 128, 128))
    createUICorner(loaderButton, 8)
    loaderButton.MouseButton1Click:Connect(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[HD Admin] Admin commands loaded successfully!";
            Color = Color3.fromRGB(0, 255, 0);
            Font = Enum.Font.SourceSansBold;
        })
    end)
    
    dragify(mainFrame)
    
    return screenGui
end

-- Load function
function HDAdminRanks.load(targetPlayer)
    if targetPlayer then
        HDAdminRanks.target = targetPlayer.Name
    else
        HDAdminRanks.target = player.Name
    end
    
    HDAdminRanks.createGUI()
end

-- Auto-load
HDAdminRanks.load()

return HDAdminRanks
