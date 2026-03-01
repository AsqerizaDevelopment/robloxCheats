local ESP = {}
ESP._enabled = false

local Players = game.GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function addESP(player)
    if not esp._enabled then return end
    if player:FindFirstChild("ESP") then return end

    local h = Instance.new("Highlight")
    h.Name = "ESP"
    h.FillColor = Color3.fromRGB(255,0,0)
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = player
end

local function removeESP(player)
    local h = player:FindFirstChild("ESP")
    if h then
        h:Destroy()
    end
end

function ESP:Set(state)
    self._enabled = state
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            if state then
                addESP(p.Character)
            else
                removeESP(p.Character)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        addESP(char)
    end)
end)

return ESP