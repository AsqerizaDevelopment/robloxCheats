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
local Highlights = {}

-- Helper: safe pcall wrapper
local function safe(fn)
    local ok, res = pcall(fn)
    return ok, res
end

-- Cleanup highlight utilities
local function applyHighlight(player)
    if not player then return end
    safe(function()
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
    safe(function()
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

-- Ensure highlights persist across joins/respawns
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if ESPEnabled then applyHighlight(plr) end
    end)
    if ESPEnabled and plr.Character then applyHighlight(plr) end
end)
for _, plr in ipairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(function()
        if ESPEnabled then applyHighlight(plr) end
    end)
    if ESPEnabled and plr.Character then applyHighlight(plr) end
end

-- ===== UI: clean, readable layout =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeFlopperCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Window = Instance.new("Frame")
Window.Size = UDim2.new(0, 420, 0, 360)
Window.Position = UDim2.new(0, 60, 0, 60)
Window.BackgroundColor3 = Color3.fromRGB(24,24,24)
Window.BorderSizePixel = 0
Window.Active = true
Window.Draggable = true
Window.Parent = ScreenGui
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(32,32,32)
Header.Parent = Window
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DeFlopper — Clean UI"
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(240,240,240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 64, 0, 28)
CloseBtn.Position = UDim2.new(1, -78, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(196, 40, 28)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "Close"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- Layout: Sidebar + Content
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -64)
Sidebar.Position = UDim2.new(0, 12, 0, 56)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Window

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -156, 1, -64)
Content.Position = UDim2.new(0, 140, 0, 56)
Content.BackgroundTransparency = 1
Content.Parent = Window

local function createSidebarButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.LayoutOrder = 1
    return btn
end

local PVPBtn = createSidebarButton("PVP")
local TrollBtn = createSidebarButton("Troll")

-- Sidebar layout so buttons stack instead of overlapping
local SidebarList = Instance.new("UIListLayout")
SidebarList.Parent = Sidebar
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 6)

-- Tab selection helper
local function selectTab(selected)
    for _, v in ipairs(Sidebar:GetChildren()) do
        if v:IsA("TextButton") then
            if v == selected then
                v.BackgroundColor3 = Color3.fromRGB(60,120,60)
            else
                v.BackgroundColor3 = Color3.fromRGB(40,40,40)
            end
        end
    end
end

local function clearContent()
    for _, c in pairs(Content:GetChildren()) do
        if not (c:IsA("UIListLayout") or c:IsA("UIPadding")) then
            c:Destroy()
        end
    end
end

local UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)

local function createSection(title)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, -12, 0, 0)
    sec.AutomaticSize = Enum.AutomaticSize.Y
    sec.BackgroundColor3 = Color3.fromRGB(28,28,28)
    sec.BorderSizePixel = 0
    sec.Parent = Content
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0,6)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0,8)
    padding.PaddingLeft = UDim.new(0,8)
    padding.Parent = sec

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,6)
    layout.Parent = sec

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = 1
    lbl.Parent = sec

    return sec
end

-- Reusable toggle widget
local function createToggle(text, initial, parent, onToggle)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -12, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 72, 0, 28)
    toggle.Position = UDim2.new(1, -84, 0, 4)
    toggle.BackgroundColor3 = initial and Color3.fromRGB(0,150,0) or Color3.fromRGB(60,60,60)
    toggle.BorderSizePixel = 0
    toggle.Text = initial and "ON" or "OFF"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Parent = container
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,6)

    toggle.MouseButton1Click:Connect(function()
        local new = not initial
        initial = new
        toggle.BackgroundColor3 = new and Color3.fromRGB(0,150,0) or Color3.fromRGB(60,60,60)
        toggle.Text = new and "ON" or "OFF"
        pcall(function() onToggle(new, toggle) end)
    end)

    return container, toggle
end

-- Build default PVP content
local function showPVP()
    clearContent()
    local sec1 = createSection("Player Aids")
    createToggle("ESP", ESPEnabled, sec1, function(state)
        ESPEnabled = state
        if ESPEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then applyHighlight(plr) end
            end
        else
            for plr, _ in pairs(Highlights) do removeHighlight(plr) end
        end
    end)

    createToggle("Tracers", TracerEnabled, sec1, function(state)
        TracerEnabled = state
    end)

    local sec2 = createSection("Aimbot")
    createToggle("Aimbot", AimbotEnabled, sec2, function(state)
        AimbotEnabled = state
    end)

    -- FOV and Sensitivity small controls (responsive row)
    local fovRow = Instance.new("Frame")
    fovRow.Size = UDim2.new(1, -12, 0, 28)
    fovRow.BackgroundTransparency = 1
    fovRow.LayoutOrder = 2
    fovRow.Parent = sec2

    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0.6, 0, 1, 0)
    fovLabel.Position = UDim2.new(0, 4, 0, 0)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Font = Enum.Font.Gotham
    fovLabel.Text = "FOV: " .. tostring(FOVAmount)
    fovLabel.TextSize = 12
    fovLabel.TextColor3 = Color3.fromRGB(200,200,200)
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left
    fovLabel.Parent = fovRow

    local fovInc = Instance.new("TextButton")
    fovInc.Size = UDim2.new(0, 28, 0, 20)
    fovInc.Position = UDim2.new(1, -44, 0, 4)
    fovInc.BackgroundColor3 = Color3.fromRGB(60,60,60)
    fovInc.Text = "+"
    fovInc.Font = Enum.Font.GothamBold
    fovInc.TextSize = 14
    fovInc.TextColor3 = Color3.fromRGB(255,255,255)
    fovInc.Parent = fovRow
    Instance.new("UICorner", fovInc).CornerRadius = UDim.new(0,4)

    local fovDec = fovInc:Clone()
    fovDec.Position = UDim2.new(1, -80, 0, 4)
    fovDec.Text = "-"
    fovDec.Parent = fovRow

    fovInc.MouseButton1Click:Connect(function()
        FOVAmount = math.clamp(FOVAmount + 5, 10, 1000)
        fovLabel.Text = "FOV: " .. tostring(FOVAmount)
    end)
    fovDec.MouseButton1Click:Connect(function()
        FOVAmount = math.clamp(FOVAmount - 5, 10, 1000)
        fovLabel.Text = "FOV: " .. tostring(FOVAmount)
    end)
end

local function showTroll()
    clearContent()
    local sec1 = createSection("World Control")
    createToggle("Freeze All", FreezeEnabled, sec1, function(state)
        FreezeEnabled = state
        if not FreezeEnabled then
            SavedPositions = {}
            TPPositions = {}
        end
    end)

    local bringBtn = Instance.new("TextButton")
    bringBtn.Size = UDim2.new(1, -12, 0, 32)
    bringBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    bringBtn.BorderSizePixel = 0
    bringBtn.Text = "Bring All To Me"
    bringBtn.Font = Enum.Font.GothamBold
    bringBtn.TextSize = 14
    bringBtn.TextColor3 = Color3.fromRGB(255,255,255)
    bringBtn.Parent = sec1
    bringBtn.LayoutOrder = 2
    Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0,6)

    bringBtn.MouseButton1Click:Connect(function()
        if not FreezeEnabled then
            bringBtn.Text = "Enable Freeze First"
            task.wait(1)
            bringBtn.Text = "Bring All To Me"
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
end

-- Sidebar switching
PVPBtn.MouseButton1Click:Connect(function()
    selectTab(PVPBtn)
    showPVP()
end)
TrollBtn.MouseButton1Click:Connect(function()
    selectTab(TrollBtn)
    showTroll()
end)
-- default
selectTab(PVPBtn)
showPVP()

-- Close behavior: cleanup highlights, tracers and GUI
CloseBtn.MouseButton1Click:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local hl = player.Character:FindFirstChild("DeFlopperHighlight")
            if hl then hl:Destroy() end
        end
    end
    for _, line in pairs(Tracers) do
        safe(function() line:Remove() end)
    end
    Tracers = {}
    if FOVCircle then
        pcall(function() FOVCircle.Visible = false end)
    end
    ScreenGui:Destroy()
end)

Players.PlayerRemoving:Connect(function(player)
    SavedPositions[player] = nil
    TPPositions[player] = nil
    removeHighlight(player)
end)

-- Main runtime loop preserved from original file (keeps features intact)
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

    -- Tracers
    if TracerEnabled then
        for _, line in pairs(Tracers) do safe(function() line:Remove() end) end
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
        for _, line in pairs(Tracers) do safe(function() line:Remove() end) end
        Tracers = {}
    end

    -- Aimbot logic preserved
    if AimbotEnabled then
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
