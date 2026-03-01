local base = "https://raw.githubusercontent.com/AsqerizaDevelopment/robloxCheats/main/Bloxstrike/src/"

_G.Bloxstrike = _G.Bloxstrike or {}
_G.Bloxstrike.utils = _G.Bloxstrike.utils or {}

print("=== BLOXSTRIKE LOADER START ===")

do
    print("Loading ESP...")
    local src = game:HttpGet(base.."utils/BloxstrikeESP.lua")
    local fn, err = loadstring(src)

    if not fn then
        warn("ESP compile error:", err)
    else
        local ok, result = pcall(fn)
        if ok and result then
            _G.Bloxstrike.utils.ESP = result
            print("ESP loaded OK")
        else
            warn("ESP runtime error:", result)
        end
    end
end

do
    print("Loading UI...")
    local src = game:HttpGet(base.."BloxstrikeUI.lua")
    local fn, err = loadstring(src)

    if not fn then
        warn("UI compile error:", err)
    else
        local ok, result = pcall(fn, _G.Bloxstrike)
        if ok then
            _G.Bloxstrike.UI = result
            print("UI loaded OK")
        else
            warn("UI runtime error:", result)
        end
    end
end

print("=== BLOXSTRIKE LOADER END ===")

return _G.Bloxstrike