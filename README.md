# Rivals Skin Changer - Debug

**Switched off for now:** `gui.lua` only prints a note pointing to the normal loadstring. Run `tools/make_debug.py` to build the debug GUI again.

The normal drawn GUI plus an **Output** tab, for bug reports.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/Debug/refs/heads/main/gui.lua"))()
```

1. Run the line above in Matcha (it replaces the normal GUI until you rejoin).
2. Reproduce the problem (apply, rejoin, play a match...).
3. Open the **Output** tab, press **Diagnostics**, then **Copy output** (or **Save to file**, which writes `rivals_debug_output.txt` in the Matcha workspace).
4. Send the text with your report.

Nothing is sent anywhere by the script. The output holds your Roblox version, the server ID, the changer's log, your config file and the state of the game's UI.

The debug GUI runs `main.lua` from this repo: the changer with fixes still being tested, before they reach the main release.

`tools/make_debug.py` builds `gui.lua` and copies `main.lua` from the main GUI and changer (`RivalsSkinChangerFULLMATCHA/gui.lua`) and `tools/output_tab.lua`.
