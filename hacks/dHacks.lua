local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace and workspace.CurrentCamera

-- Aimbot runtime state (keeps original logic)
local Locked = nil
local Animation = nil
local RequiredDistance = 2000
local FOVAmount = 90
local ThirdPerson = false
local ThirdPersonSensitivity = 3
local Sensitivity = 0
local LockPart = "HumanoidRootPart"
local FOVCircle = nil
if Drawing and Drawing.new then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(255,255,255)
end

local FreezeEnabled = false
local ESPEnabled = false
local AimbotEnabled = false
local TracerEnabled = false
local SavedPositions = {}
local TPPositions = {}
local Tracers = {}

-- ===== SCREEN GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeFlopperCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ===== MAIN FRAME =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- ===== TITLE BAR =====
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DeFlopper Cheat Settings"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, -5)
CloseBtn.Position = UDim2.new(1, -45, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ===== TAB BUTTONS =====
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local function createTabButton(name, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 1, -5)
    btn.Position = UDim2.new(0, xPos, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local PVPTabBtn = createTabButton("PVP", 5)
local TrollTabBtn = createTabButton("Troll", 155)

-- ===== TAB CONTENT FRAMES =====
local function createTabFrame()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 1, -90)
    frame.Position = UDim2.new(0, 10, 0, 85)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = frame
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 10)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.FillDirection = Enum.FillDirection.Vertical

    return frame
end

local PVPFrame = createTabFrame()
local TrollFrame = createTabFrame()
PVPFrame.Visible = true

-- ===== BUTTON CREATION =====
local function createButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- PVP Buttons
local ESPBtn = createButton("ESP: OFF", PVPFrame)
local TracerBtn = createButton("Tracers: OFF", PVPFrame)
local AimbotBtn = createButton("Aimbot: OFF", PVPFrame)
-- Troll Buttons
local FreezeBtn = createButton("Freeze All: OFF", TrollFrame)
local BringBtn = createButton("Bring All To Me", TrollFrame)

local Highlights = {}

local function applyHighlight(player)
    if not player then return end
    pcall(function()
        local char = player.Character
        if not char then return end
        local existing = char:FindFirstChild("DeFlopperHighlight")
        if existing then
            Highlights[player] = existing
            return
        end
        local hl = Instance.new("Highlight")
        hl.Name = "DeFlopperHighlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.Parent = char
        Highlights[player] = hl
    end)
end

local function removeHighlight(player)
    if not player then return end
    pcall(function()
        if Highlights[player] and Highlights[player].Parent then
            Highlights[player]:Destroy()
        else
            local ch = player.Character
            if ch then
                local h = ch:FindFirstChild("DeFlopperHighlight")
                if h then h:Destroy() end
            end
        end
        Highlights[player] = nil
    end)
end

-- Ensure highlights persist across respawns and new players
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if ESPEnabled then applyHighlight(plr) end
    end)
    if ESPEnabled and plr.Character then applyHighlight(plr) end
end)

-- Attach CharacterAdded handlers for players already in-game
for _, plr in ipairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(function()
        if ESPEnabled then applyHighlight(plr) end
    end)
    if ESPEnabled and plr.Character then applyHighlight(plr) end
end

-- ===== TAB BUTTON LOGIC =====
PVPTabBtn.MouseButton1Click:Connect(function()
    PVPFrame.Visible = true
    TrollFrame.Visible = false
end)

TrollTabBtn.MouseButton1Click:Connect(function()
    PVPFrame.Visible = false
    TrollFrame.Visible = true
end)



-- ===== BUTTON LOGIC =====
FreezeBtn.MouseButton1Click:Connect(function()
    FreezeEnabled = not FreezeEnabled
    if not FreezeEnabled then
        SavedPositions = {}
        TPPositions = {}
    end
    FreezeBtn.Text = FreezeEnabled and "Freeze All: ON" or "Freeze All: OFF"
    FreezeBtn.BackgroundColor3 = FreezeEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPBtn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    ESPBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    if ESPEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then applyHighlight(plr) end
        end
    else
        for plr, _ in pairs(Highlights) do
            removeHighlight(plr)
        end
    end
end)

BringBtn.MouseButton1Click:Connect(function()
    if not FreezeEnabled then
        BringBtn.Text = "Enable Freeze First"
        task.wait(1)
        BringBtn.Text = "Bring All To Me"
        return
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local tpPos = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
        for player, _ in pairs(SavedPositions) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                TPPositions[player] = tpPos
            end
        end
    end
end)

TracerBtn.MouseButton1Click:Connect(function()
    TracerEnabled = not TracerEnabled
    TracerBtn.Text = TracerEnabled and "Tracers: ON" or "Tracers: OFF"
    TracerBtn.BackgroundColor3 = TracerEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

AimbotBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotBtn.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    AimbotBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)


-- ===== MAIN LOOPS =====
RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                if FreezeEnabled and SavedPositions[player] == nil then
                    SavedPositions[player] = root.CFrame
                end
                if FreezeEnabled then
                    if TPPositions[player] then
                        root.CFrame = TPPositions[player]
                    else
                        root.CFrame = SavedPositions[player]
                    end
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                end
            else
                SavedPositions[player] = nil
                TPPositions[player] = nil
            end

            if ESPEnabled then
                applyHighlight(player)
            else
                removeHighlight(player)
            end
        end
    end

    if TracerEnabled then
        for _, line in pairs(Tracers) do line:Remove() end
        Tracers = {}
        local LocalChar = LocalPlayer.Character
        if not LocalChar or not LocalChar:FindFirstChild("HumanoidRootPart") then return end
        local localPos = LocalChar.HumanoidRootPart.Position
        local cam = workspace.CurrentCamera
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = player.Character.HumanoidRootPart.Position
                local screenPos = cam:WorldToViewportPoint(localPos)
                local targetScreenPos = cam:WorldToViewportPoint(targetPos)
                local line = Drawing.new("Line")
                line.From = Vector2.new(screenPos.X, screenPos.Y)
                line.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                line.Color = Color3.fromRGB(255, 0, 0)
                line.Thickness = 2
                line.Transparency = 1
                table.insert(Tracers, line)
            end
        end
    else
        for _, line in pairs(Tracers) do line:Remove() end
        Tracers = {}
    end

    if AimbotEnabled then
        -- Use original locking logic: find closest player inside FOV and lock onto them.
        local mousePos = UserInputService:GetMouseLocation()

        if not Locked then
            if FOVAmount then RequiredDistance = FOVAmount else RequiredDistance = 2000 end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(LockPart) and plr.Character:FindFirstChildOfClass("Humanoid") then
                    if plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local partPos = plr.Character[LockPart].Position
                        local vector, onScreen = Camera:WorldToViewportPoint(partPos)
                        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(vector.X, vector.Y)).Magnitude
                        if dist < RequiredDistance and onScreen then
                            RequiredDistance = dist
                            Locked = plr
                        end
                    end
                end
            end
        else
            -- If locked, check if still inside the allowed distance; otherwise unlock
            if Locked and Locked.Character and Locked.Character:FindFirstChild(LockPart) then
                local vec = Camera:WorldToViewportPoint(Locked.Character[LockPart].Position)
                local d = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(vec.X, vec.Y)).Magnitude
                if d > RequiredDistance then
                    Locked = nil
                    if Animation and Animation.Cancel then pcall(function() Animation:Cancel() end) end
                    if FOVCircle then FOVCircle.Color = Color3.fromRGB(255,255,255) end
                end
            else
                Locked = nil
            end
        end

        -- If we have a lock, aim at the target using either mousemoverel (3rd person) or camera CFrame
        if Locked and Locked.Character and Locked.Character:FindFirstChild(LockPart) then
            local targetPos = Locked.Character[LockPart].Position
            if ThirdPerson then
                ThirdPersonSensitivity = math.clamp(ThirdPersonSensitivity, 0.1, 5)
                local vec = Camera:WorldToViewportPoint(targetPos)
                pcall(function()
                    mousemoverel((vec.X - mousePos.X) * ThirdPersonSensitivity, (vec.Y - mousePos.Y) * ThirdPersonSensitivity)
                end)
            else
                if Sensitivity and Sensitivity > 0 then
                    if Animation and Animation.Cancel then pcall(function() Animation:Cancel() end) end
                    Animation = TweenService:Create(Camera, TweenInfo.new(Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, targetPos)})
                    pcall(function() Animation:Play() end)
                else
                    pcall(function() Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos) end)
                end
            end
            if FOVCircle then 
                FOVCircle.Color = Color3.fromRGB(255,70,70)
                FOVCircle.Visible = true
                FOVCircle.Radius = FOVAmount
                FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
            end
        else
            if FOVCircle then FOVCircle.Visible = false end
        end
    end
end)

-- ===== CLOSE BUTTON =====
CloseBtn.MouseButton1Click:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local hl = player.Character:FindFirstChild("DeFlopperHighlight")
            if hl then hl:Destroy() end
        end
    end
    for _, line in pairs(Tracers) do line:Remove() end
    ScreenGui:Destroy()
end)

Players.PlayerRemoving:Connect(function(player)
    SavedPositions[player] = nil
    TPPositions[player] = nil
    removeHighlight(player)
end)
