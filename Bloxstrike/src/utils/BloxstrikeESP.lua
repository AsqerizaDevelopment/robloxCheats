local ESP = {}
ESP._enabled = false
ESP._tracerEnabled = false
ESP._tracers = {}
ESP._lastChar = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function addESP(character)
    if not ESP._enabled then return end
    if not character then return end
    if Players:GetPlayerFromCharacter(character) == LocalPlayer then return end

    local h = character:FindFirstChild("ESP")
    if not h then
        h = Instance.new("Highlight")
        h.Name = "ESP"
        h.FillColor = Color3.fromRGB(255,0,0)
        h.OutlineColor = Color3.fromRGB(255,255,255)
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = character
    elseif h.Parent ~= character then
        h.Parent = character
    end
end

local function removeESP(character)
    if not character then return end
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

    local origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character

            -- ✅ CHARACTER REPLACE DETECTIE (RONDE FIX)
            if char ~= ESP._lastChar[p] then
                ESP._lastChar[p] = char

                if ESP._enabled then
                    addESP(char)
                end

                -- 🔧 TRACER RESET BIJ NIEUWE RONDE
                if ESP._tracerEnabled then
                    removeTracer(p)
                    createTracer(p)
                end
            end

            -- ✅ ESP WATCHDOG
            if ESP._enabled and char and not char:FindFirstChild("ESP") then
                addESP(char)
            end

            -- ✅ TRACER WATCHDOG + UPDATE
            if ESP._tracerEnabled and char and char:FindFirstChild("HumanoidRootPart") then
                local line = ESP._tracers[p]

                -- tracer kwijt → opnieuw maken
                if not line then
                    createTracer(p)
                    line = ESP._tracers[p]
                end

                local pos, visible = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

                if visible then
                    line.From = origin
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if ESP._tracerEnabled then
        createTracer(p)
    end
end)

for _,p in ipairs(Players:GetPlayers()) do
    if ESP._tracerEnabled then
        createTracer(p)
    end
end

return ESP