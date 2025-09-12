local config = require("HitboxViewer.config.init")

local this = {}

---@param key string
---@param ... string | integer
---@return string
function this.tr(key, ...)
    local suffix = { ... }
    table.insert(suffix, key)
    return string.format("%s##%s", config.lang:tr(key), table.concat(suffix, "_"))
end

---@return number
function this.get_item_width()
    return config.lang:get_font_size() * 16
end

---@param n integer
---@return number
function this.get_row_height(n)
    local frame_padding = 3
    local item_spacing = 2
    return (config.lang:get_font_size() + frame_padding * 2 + item_spacing * (n - 1)) * n
end

return this
