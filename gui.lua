-- Rivals Skin Changer - debug build: switched off for now.
-- (tools/make_debug.py builds the full debug GUI again when it's needed.)
local msg = "[Rivals Debug] The debug build is off for now - use the normal loadstring:\n"
    .. 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/RivalsSkinChangerFULLMATCHA/refs/heads/main/gui.lua"))()'
print(msg)
pcall(function()
    if type(notify) == "function" then notify("Rivals Skin Changer", "The debug build is off - use the normal loadstring.", 8) end
end)
