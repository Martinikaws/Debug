"""Builds Debug/gui.lua from the main drawn GUI (RivalsSkinChangerFULLMATCHA/gui.lua).

The debug build is the same GUI plus an Output tab: everything the GUI and the
changer print is kept, can be copied or saved, and a Diagnostics button adds a
snapshot of the game UI's state. Run it again after the main GUI changes.
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SRC = os.path.join(ROOT, "..", "RivalsSkinChangerFULLMATCHA", "gui.lua")


def main():
    s = open(SRC, encoding="utf-8", newline="").read().replace("\r\n", "\n")
    tab = open(os.path.join(HERE, "output_tab.lua"), encoding="utf-8").read()

    def rep(old, new, count=1):
        nonlocal s
        assert s.count(old) == count, (s.count(old), old[:70])
        s = s.replace(old, new)

    rep("-- Rivals changer GUI, drawn on screen\n",
        "-- Rivals changer GUI, drawn on screen - DEBUG BUILD (Debug repo; made by\n"
        "-- tools/make_debug.py from the main GUI, plus an Output tab)\n")
    rep('local SITE = "https://martinikaws.github.io/rivals-skins/"\n',
        'local SITE = "https://martinikaws.github.io/rivals-skins/"\n'
        "\n"
        "-- Debug log: everything this GUI and the changer print, kept for the\n"
        "-- Output tab (last 3000 lines, across reruns of this GUI).\n"
        "local DBG = {log = _G.__RSC_DEBUG_LOG or {}}\n"
        "_G.__RSC_DEBUG_LOG = DBG.log\n"
        "DBG.realPrint = _G.__RSC_DBG_REALPRINT or print\n"
        "_G.__RSC_DBG_REALPRINT = DBG.realPrint\n"
        "function DBG.add(line)\n"
        "    DBG.log[#DBG.log + 1] = os.date(\"%H:%M:%S \") .. line\n"
        "    while #DBG.log > 3000 do table.remove(DBG.log, 1) end\n"
        "end\n"
        "function DBG.print(...)\n"
        "    local parts = {}\n"
        "    for i = 1, select(\"#\", ...) do parts[i] = tostring((select(i, ...))) end\n"
        "    DBG.add(table.concat(parts, \" \"))\n"
        "    DBG.realPrint(...)\n"
        "end\n"
        "_G.__RSC_DBG_PRINT = DBG.print\n"
        "local print = DBG.print\n")
    # The changer's print wrapper (top of main.lua) gets the logging print.
    rep("""    local source, from = changerSource()
""", """    local source, from = changerSource()
    if type(source) == "string" then
        DBG.add("[Debug] Running the changer from " .. tostring(from) .. " (" .. #source .. " bytes)")
        source = source:gsub("end%)%(print%)", "end)(_G.__RSC_DBG_PRINT or print)", 1)
    end
""")
    rep('    text("Skin Changer", x + 16 + textWidth("Rivals ", 16, true), y + 12, C.accent, 16, 5, true)\n',
        '    text("Skin Changer (Debug)", x + 16 + textWidth("Rivals ", 16, true), y + 12, C.accent, 16, 5, true)\n')
    rep("-- The window\n", tab + "-- The window\n")
    rep('local TABS = {"Skins", "Cosmetics", "Visuals", "Misc", "Sounds", "Settings"}',
        'local TABS = {"Skins", "Cosmetics", "Visuals", "Misc", "Sounds", "Settings", "Output"}')
    rep("""    Settings = drawSettings}""", """    Settings = drawSettings, Output = drawOutput}""")
    out = os.path.join(ROOT, "gui.lua")
    open(out, "w", encoding="utf-8", newline="").write(s.replace("\n", "\r\n"))
    print("wrote", out)


if __name__ == "__main__":
    main()
