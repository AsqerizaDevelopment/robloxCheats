local ESP = {}
ESP._enabled = false
ESP._tracerEnabled = false
ESP._tracers = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function addESP(character)
    if not ESP._enabled then return end
    if character:FindFirstChild("ESP") then return end
    if Players:GetPlayerFromCharacter(character) == LocalPlayer then return end

    local h = Instance.new("Highlight")
    h.Name = "ESP"
    h.FillColor = Color3.fromRGB(255,0,0)
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = character
end

local function removeESP(character)
    local h = character:FindFirstChild("ESP")
    if h then h:Destroy() end
end

function ESP:Set(state)
    self._enabled = state
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            if state then addESP(p.Character) else removeESP(p.Character) end
        end
    end
end

local function removeTracer(p)
    local t = ESP._tracers[p]
    if t then
        t:Remove()
        ESP._tracers[p] = nil
    end
end

local function createTracer(p)
    if p == LocalPlayer then return end
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255,0,0)
    line.Visible = false
    ESP._tracers[p] = line
end

function ESP:SetTracers(state)
    self._tracerEnabled = state
    for _,p in ipairs(Players:GetPlayers()) do
        removeTracer(p)
        if state then createTracer(p) end
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP._tracerEnabled then return end

    local origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            local line = ESP._tracers[p]

            if visible and line then
                line.From = origin
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = true
            elseif line then
                line.Visible = false
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        addESP(char)
        if ESP._tracerEnabled then createTracer(p) end
    end)
end)

for _,p in ipairs(Players:GetPlayers()) do
    if p.Character then addESP(p.Character) end
    p.CharacterAdded:Connect(function(char)
        addESP(char)
    end)
end

return ESP