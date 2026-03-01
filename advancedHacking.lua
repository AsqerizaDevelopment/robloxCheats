local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "CheatUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 500)
main.Position = UDim2.new(0.5, -200, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Parent = gui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Code
title.Text = "CHEAT MENU"
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0, 255, 140)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 20)
minimizeBtn.Position = UDim2.new(1, -60, 0.5, -10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Font = Enum.Font.Code
minimizeBtn.Text = "-"
minimizeBtn.TextSize = 16
minimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
minimizeBtn.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 20)
closeBtn.Position = UDim2.new(1, -30, 0.5, -10)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.Code
closeBtn.Text = "X"
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
closeBtn.Parent = titleBar

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -32)
scroll.Position = UDim2.new(0, 0, 0, 32)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = scroll

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local UI = {}
UI._toggles = {}
UI._minimized = false

local function createContainer(parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = container

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
    end)

    return container
end

function UI:CreateSection(text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 24)
    holder.BackgroundTransparency = 1
    holder.Parent = scroll

    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 24)
    section.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    section.BorderSizePixel = 0
    section.Font = Enum.Font.Code
    section.Text = "  " .. text
    section.TextSize = 14
    section.TextColor3 = Color3.fromRGB(0, 255, 140)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = holder

    local container = createContainer(holder)
    container.Position = UDim2.new(0, 0, 0, 26)

    return container
end

function UI:CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.Text = text
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Parent = parent or scroll

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

function UI:CreateToggle(parent, text, default, callback)
    local state = default or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.Parent = parent or scroll

    local function update()
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0,255,140) or Color3.fromRGB(220,220,220)
    end

    update()

    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then callback(state) end
    end)

    table.insert(UI._toggles, {
        set = function(v)
            state = v
            update()
            if callback then callback(state) end
        end
    })
end

minimizeBtn.MouseButton1Click:Connect(function()
    UI._minimized = not UI._minimized
    scroll.Visible = not UI._minimized
    main.Size = UI._minimized and UDim2.new(0, 400, 0, 32) or UDim2.new(0, 400, 0, 500)
end)

closeBtn.MouseButton1Click:Connect(function()
    for _,t in ipairs(UI._toggles) do
        t.set(false)
    end
    gui.Enabled = false
end)

return UI