local config = require("HitboxViewer.config")
local table_util = require("HitboxViewer.table_util")

local this = {}

---@param x number
---@param y number?
function this.set_pos(x, y)
    if not y then
        y = 0
    end
    local pos = imgui.get_cursor_pos()
    pos.x = pos.x + x
    pos.y = pos.y + y
    imgui.set_cursor_pos(pos)
end

---@param str string
---@param x integer
function this.spaced_string(str, x)
    local t = {}
    for i in string.gmatch(str, "([^##]+)") do
        table.insert(t, i)
    end
    if #t > 1 then
        ---@diagnostic disable-next-line: no-unknown
        t[1] = string.rep(" ", x) .. t[1] .. string.rep(" ", x)
        return table.concat(t, "##")
    end
    return string.rep(" ", x) .. str .. string.rep(" ", x)
end

---@param str string
---@param key string
---@return boolean
function this.popup_yesno(str, key)
    local ret = false
    if imgui.begin_popup(key, 1 << 27) then
        imgui.spacing()
        imgui.text(this.spaced_string(str, 3))
        imgui.spacing()

        if imgui.button(this.spaced_string("Yes", 3)) then
            imgui.close_current_popup()
            ret = true
        end

        imgui.same_line()

        if imgui.button(this.spaced_string("No", 3)) then
            imgui.close_current_popup()
        end

        imgui.spacing()
        imgui.end_popup()
    end

    return ret
end

---@param name string
---@param config_key string
---@param func fun(...): boolean, any
---@return boolean
function this.generic_config(name, config_key, func, ...)
    local changed, value
    changed, value = func(name, config.get(config_key), ...)
    if changed then
        config.set(config_key, value)
    end
    return changed
end

---@param name string
---@param config_key string
---@return boolean
function this.checkbox(name, config_key)
    return this.generic_config(name, config_key, imgui.checkbox)
end

---@param name string
---@param config_key string
---@return boolean
function this.combo(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.combo, ...)
end

---@param name string
---@param config_key string
---@return boolean
function this.color_edit(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.color_edit, ...)
end

---@param name string
---@param config_key string
---@return boolean
function this.slider_float(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.slider_float, ...)
end

---@param name string
---@param config_key string
---@return boolean
function this.slider_int(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.slider_int, ...)
end

---@param text string
---@param seperate boolean?
function this.tooltip(text, seperate)
    if seperate then
        imgui.same_line()
        imgui.text("(?)")
    end
    if imgui.is_item_hovered() then
        imgui.set_tooltip(text)
    end
end

---@param box_type HitboxType
---@param box_config_key string
---@param type_name string
---@param predicate (fun(t: table, i: integer, j:integer) : boolean)?
---@param sort (fun(a: string, b: string): boolean)?
function this.box_type_setup(box_type, box_config_key, type_name, predicate, sort)
    local keys = table_util.keys(box_type.disable)
    ---@cast keys string[]

    if predicate then
        keys = table_util.table_remove(keys, predicate)
    end

    table.sort(keys, sort)
    imgui.begin_rect()
    imgui.push_item_width(250)
    for _, key in ipairs(keys) do
        this.checkbox(
            string.format("Disable %s##%s_disable_%s", key, type_name, key),
            string.format("%s.disable.%s", box_config_key, key)
        )
    end
    imgui.pop_item_width()
    imgui.end_rect(5, 10)

    imgui.same_line()
    this.set_pos(5)

    imgui.begin_rect()
    imgui.push_item_width(250)
    for _, key in ipairs(keys) do
        this.checkbox(
            string.format("##%s_enable_color_%s", type_name, key),
            string.format("%s.color_enable.%s", box_config_key, key)
        )
        imgui.begin_disabled(not box_type.color_enable[key])
        imgui.same_line()
        this.color_edit(
            string.format("%s##%s_color_%s", key, type_name, key),
            string.format("%s.color.%s", box_config_key, key)
        )
        imgui.end_disabled()
    end
    imgui.pop_item_width()
    imgui.end_rect(5, 10)
end

return this
