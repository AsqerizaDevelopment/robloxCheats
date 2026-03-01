local base = "https://raw.githubusercontent.com/AsqerizaDevelopment/robloxCheats/main/Bloxstrike/src/"

_G.Bloxstrike = {}

print("=== BLOXSTRIKE LOADER START ===")

-- load ESP
do
    local src = game:HttpGet(base.."utils/BloxstrikeESP.lua", true)
    local fn, err = loadstring(src)

    print("ESP loadstring:", fn, err)

    if fn then
        _G.Bloxstrike.utils = {
            ESP = fn()
        }
        print("ESP loaded OK")
    else
        warn("ESP compile error:", err)
    end
end

-- load UI
do
    local src = game:HttpGet(base.."BloxstrikeUI.lua", true)
    local fn, err = loadstring(src)

    print("UI loadstring:", fn, err)

    if fn then
        print("Calling UI...")
        _G.Bloxstrike.UI = fn(_G.Bloxstrike)
        print("UI loaded OK")
    else
        warn("UI compile error:", err)
    end
end

print("=== BLOXSTRIKE LOADER END ===")

return _G.Bloxstrike