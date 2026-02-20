local config = require("HitboxViewer.config.init")
local util_misc = require("HitboxViewer.util.misc.init")

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

---@param n string | number
---@param width integer?
function this.pad_zero(n, width)
    if type(n) == "number" then
        n = tostring(n)
    end

    width = width or 2

    local int_part, dec_part = n:match("([^%.]+)%.?(.*)")

    if #dec_part > 0 then
        local padded_int = string.format("%0" .. width .. "d", tonumber(int_part))
        return padded_int .. "." .. dec_part
    end
    return string.format("%0" .. width .. "d", tonumber(int_part))
end

---@param n number
---@param n_format string?
---@param pad boolean?
function this.seconds_to_minutes_string(n, n_format, pad)
    if not n_format then
        n_format = "%d"
    end

    local minutes = n / 60
    local seconds = n
    local seconds_f = string.format(n_format, seconds)
    local format = "%s %s"

    if minutes >= 1 then
        minutes = math.floor(minutes)
        seconds = n - minutes * 60
        seconds_f = string.format(n_format, seconds)
        format = string.format("%s, %s", format, format)
        local minutes_f = string.format(n_format, minutes)

        return string.format(
            format,
            pad and this.pad_zero(minutes_f) or minutes_f,
            minutes == 1 and config.lang:tr("misc.text_minute")
                or config.lang:tr("misc.text_minute_plural"),
            pad and this.pad_zero(seconds_f) or seconds_f,
            util_misc.round(seconds, 1) == 1 and config.lang:tr("misc.text_second")
                or config.lang:tr("misc.text_second_plural")
        )
    end

    return string.format(
        format,
        pad and this.pad_zero(seconds_f) or seconds_f,
        util_misc.round(seconds, 1) == 1 and config.lang:tr("misc.text_second")
            or config.lang:tr("misc.text_second_plural")
    )
end

return this
