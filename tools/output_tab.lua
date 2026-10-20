-- Output (debug build): everything the changer and this GUI printed since
-- Matcha started, plus a diagnostics snapshot, to copy and send for support.
-- Nothing is sent anywhere: Copy puts it on your clipboard, Save writes
-- rivals_debug_output.txt in the workspace. It holds your Roblox version,
-- server (JobId), the changer's log, your config and the game UI's state.
local function diagnostics()
    local out = {}
    local function add(s) out[#out + 1] = s end
    local function try(label, fn)
        local ok, v = pcall(fn)
        add(label .. ": " .. (ok and tostring(v) or ("error " .. tostring(v))))
    end
    add("===== Diagnostics " .. os.date("%Y-%m-%d %H:%M:%S") .. " =====")
    try("Roblox", function() return getrbxversion() end)
    try("Place / server", function() return game.PlaceId .. " / " .. game.JobId end)
    try("Executor", function() return identifyexecutor and table.concat({identifyexecutor()}, " ") or "?" end)
    add("Support ID: " .. tostring(state.supportId or supportId() or "unavailable"))
    try("Changer busy", function() local b = _G.__RIVALS_SKIN_CHANGER_BUSY return b and string.format("%.0fs ago", tick() - b) or "no" end)
    try("Changer state", function() return _G.__RIVALS_SKIN_CHANGER_STATE and "applied this session" or "none" end)
    try("Problems", function()
        local p = _G.__RSC_PROBLEMS
        return (type(p) == "table" and #p > 0) and table.concat(p, " | ") or "none"
    end)
    try("Memory layout", function()
        local L = _G.__RSC_LAYOUT
        if type(L) ~= "table" then return "none" end
        local t = {}
        for k, v in pairs(L) do t[#t + 1] = k .. "=" .. tostring(v) end
        table.sort(t)
        return table.concat(t, " ")
    end)
    try("Offsets", function()
        local o = _G.__RSC_OFFSETS
        return type(o) == "table" and (tostring(o.from) .. " " .. tostring(o.version) .. " fits=" .. tostring(o.fits)) or "none"
    end)
    -- Roblox's own UI (top bar, menu, chat, player list). When it breaks, the
    -- game's UI also shifts down, which moves the crosshair.
    try("GuiInset", function()
        local a, b = game:GetService("GuiService"):GetGuiInset()
        return tostring(a) .. " " .. tostring(b)
    end)
    try("CoreGui.RobloxGui", function()
        local rg = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
        if not rg then return "missing" end
        local names = {}
        for _, c in ipairs(rg:GetChildren()) do names[#names + 1] = c.Name end
        table.sort(names)
        return #names .. " children: " .. table.concat(names, ", ")
    end)
    try("CoreGui top-level", function()
        local names = {}
        for _, c in ipairs(game:GetService("CoreGui"):GetChildren()) do names[#names + 1] = c.Name end
        table.sort(names)
        return table.concat(names, ", ")
    end)
    -- Name holders: an Instance's name is a pointer to a shared string with
    -- a reference count at +48. Every "Modules" should point to one holder
    -- whose count is at least the number of objects with that name.
    try("Name holders", function()
        local lp = game:GetService("Players").LocalPlayer
        local spots = {
            {"CoreGui.RobloxGui.Modules", function() return game:GetService("CoreGui").RobloxGui:FindFirstChild("Modules") end},
            {"PlayerScripts.Modules", function() return lp.PlayerScripts:FindFirstChild("Modules") end},
            {"StarterPlayerScripts.Modules", function() return game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("Modules") end},
            {"ReplicatedStorage.Modules", function() return game:GetService("ReplicatedStorage"):FindFirstChild("Modules") end},
        }
        local t = {}
        for _, s in ipairs(spots) do
            local ok, inst = pcall(s[2])
            if ok and inst then
                local holder = rdq(inst.Address + 112)
                t[#t + 1] = string.format("%s=%s holder %x count %s", s[1], tostring(inst.Name), holder or 0, tostring(rdi((holder or 0) + 48)))
            else
                t[#t + 1] = s[1] .. "=missing"
            end
        end
        -- Fewer counts than objects named "Modules" means a teleport can free
        -- the name while Roblox's own UI still uses it.
        local n = 0
        for _, root in ipairs({game, game:GetService("CoreGui")}) do
            for _, d in ipairs(root:GetDescendants()) do if d.Name == "Modules" then n = n + 1 end end
        end
        t[#t + 1] = "objects named Modules: " .. n
        return table.concat(t, " ; ")
    end)
    try("PlayerGui", function()
        local names = {}
        for _, c in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do names[#names + 1] = c.Name end
        table.sort(names)
        return table.concat(names, ", ")
    end)
    add("----- Config (" .. FILE .. ") -----")
    local okC, cfg = pcall(function() return isfile(FILE) and readfile(FILE) or "(none)" end)
    for line in tostring(okC and cfg or "(unreadable)"):gmatch("[^\r\n]+") do add(line) end
    add("===== End diagnostics =====")
    for _, l in ipairs(out) do DBG.add(l) end
end

local function drawOutput(x, y, w, h)
    rect(x, y, w, h, C.panel, 2, 8)
    text("Output", x + 16, y + 12, C.text, 15, 5, true)
    text("Everything the changer printed. Nothing is sent anywhere - copy it and send it with your report.", x + 16, y + 34, C.dim, 12, 5)
    local bx = x + 16
    local function btn(label, bw, fn)
        if button(bx, y + 56, bw, 28, label) then fn() end
        bx = bx + bw + 8
    end
    local log = DBG.log
    btn("Copy output", 120, function()
        local ok = pcall(setclipboard, table.concat(log, "\n"))
        state.status = ok and ("Copied " .. #log .. " lines to the clipboard.") or "Couldn't copy - use Save to file."
    end)
    btn("Save to file", 120, function()
        local ok = pcall(writefile, "rivals_debug_output.txt", table.concat(log, "\n"))
        state.status = ok and "Saved to rivals_debug_output.txt in the Matcha workspace." or "Couldn't save the file."
    end)
    btn("Diagnostics", 120, function()
        diagnostics()
        state.outScroll = nil
        state.status = "Diagnostics added to the output."
    end)
    btn("Clear", 80, function() for i = #log, 1, -1 do log[i] = nil end state.outScroll = nil end)
    btn("Up", 60, function() state.outScroll = math.max(0, (state.outScroll or math.max(0, #log - 1)) - 20) end)
    btn("Down", 70, function() state.outScroll = (state.outScroll or 0) + 20 end)

    local top, lineH = y + 96, 15
    local rows = math.floor((h - (top - y) - 8) / lineH)
    -- Follows the end of the log until scrolled.
    local first = state.outScroll or math.max(0, #log - rows)
    first = math.max(0, math.min(first, math.max(0, #log - rows)))
    if state.outScroll then state.outScroll = first < math.max(0, #log - rows) and first or nil end
    for i = 1, rows do
        local l = log[first + i]
        if not l then break end
        local bad = l:find("rror") or l:find("ouldn't") or l:find("problem")
        text(fitText(l, w - 32, 12), x + 16, top + (i - 1) * lineH, bad and C.text or C.dim, 12, 5)
    end
    text(#log .. " lines" .. (state.outScroll and "  (scrolled - press Down to the end to follow)" or ""), x + w - 16 - textWidth(#log .. " lines", 11), y + 14, C.faint, 11, 5)
end

