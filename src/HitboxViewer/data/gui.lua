---@class GuiData
---@field name_missing string
---@field data_missing string

---@class GuiData
local this = {
    name_missing = "???",
    data_missing = " - ",
}
---@enum GuiColors
this.colors = {
    bad = 0xff1947ff,
    good = 0xff47ff59,
    info = 0xff27f3f5,
}

return this
