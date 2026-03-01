local ESP = {}
ESP._enabled = false
ESP._tracerEnabled = false
ESP._tracers = {}
ESP._lastChar = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ENEMY_FILL = Color3.fromRGB(255,0,0)
local ENEMY_OUTLINE = Color3.fromRGB(255,255,255)
local TEAM_FILL = Color3.fromRGB(0,170,255)
local TEAM_OUTLINE = Color3.fromRGB(255,255,255)

print("Wallhacks module loaded")

local function isAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getTeamId(p)
    if p.Team ~= nil then return p.Team end
    if p.TeamColor ~= nil then return p.TeamColor end

    local attr = p:GetAttribute("Team")
    if attr ~= nil then return attr end

    local attr2 = p:GetAttribute("TeamId")
    if attr2 ~= nil then return attr2 end

    local val = p:FindFirstChild("Team")
    if val and val.Value ~= nil then return val.Value end

    return nil
end

local function isTeammate(p)
    local my = getTeamId(LocalPlayer)
    local other = getTeamId(p)
    if my == nil or other == nil then return false end
    return my == other
end

local function addESP(p, character)
    if not ESP._enabled then return end
    if not character then return end
    if p == LocalPlayer then return end

    local h = character:FindFirstChild("ESP")
    if not h then
        h = Instance.new("Highlight")
        h.Name = "ESP"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = character
    end

    local alive = isAlive(character)
    local teammate = isTeammate(p)

    if alive then
        if teammate then
            h.FillColor = TEAM_FILL
            h.OutlineColor = TEAM_OUTLINE
        else
            h.FillColor = ENEMY_FILL
            h.OutlineColor = ENEMY_OUTLINE
        end
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
    else
        h.FillTransparency = 1
        h.OutlineTransparency = 0
        h.OutlineColor = ENEMY_OUTLINE
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
            if state then addESP(p, p.Character) else removeESP(p.Character) end
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

            if char ~= ESP._lastChar[p] then
                ESP._lastChar[p] = char
                if ESP._enabled then
                    addESP(p, char)
                end
                if ESP._tracerEnabled then
                    removeTracer(p)
                    createTracer(p)
                end
            end

            if ESP._enabled and char then
                addESP(p, char)
            end

            if ESP._tracerEnabled and char and isAlive(char) and char:FindFirstChild("HumanoidRootPart") then
                local line = ESP._tracers[p]
                if not line then
                    createTracer(p)
                    line = ESP._tracers[p]
                end

                if isTeammate(p) then
                    line.Color = TEAM_FILL
                else
                    line.Color = ENEMY_FILL
                end

                local pos, visible = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

                if visible then
                    line.From = origin
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                local line = ESP._tracers[p]
                if line then line.Visible = false end
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