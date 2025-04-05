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
---@param config_entry table<string, any>
---@param config_entry_name string
---@param func function
---@return boolean
function this.generic_config(name, config_entry, config_entry_name, func, ...)
    local changed
    changed, config_entry[config_entry_name] = func(name, config_entry[config_entry_name], ...)
    return changed
end

---@param name string
---@param config_entry table<string, any>
---@param config_entry_name string
---@return boolean
function this.checkbox(name, config_entry, config_entry_name)
    return this.generic_config(name, config_entry, config_entry_name, imgui.checkbox)
end

---@param name string
---@param config_entry table<string, any>
---@param config_entry_name string
---@return boolean
function this.combo(name, config_entry, config_entry_name, ...)
    return this.generic_config(name, config_entry, config_entry_name, imgui.combo, ...)
end

---@param name string
---@param config_entry table<string, any>
---@param config_entry_name string
---@return boolean
function this.color_edit(name, config_entry, config_entry_name, ...)
    return this.generic_config(name, config_entry, config_entry_name, imgui.color_edit, ...)
end

---@param name string
---@param config_entry table<string, any>
---@param config_entry_name string
---@return boolean
function this.slider_float(name, config_entry, config_entry_name, ...)
    return this.generic_config(name, config_entry, config_entry_name, imgui.slider_float, ...)
end

---@param name string
---@param config_entry table<string, any>
---@param config_entry_name string
---@return boolean
function this.slider_int(name, config_entry, config_entry_name, ...)
    return this.generic_config(name, config_entry, config_entry_name, imgui.slider_int, ...)
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

---@param config_entry table<string, any>
---@param config_entry_name string
function this.box_type_setup(config_entry, config_entry_name)
    local keys = table_util.keys(config_entry[config_entry_name].disable, true)
    imgui.begin_rect()
    imgui.push_item_width(250)
    for _, key in ipairs(keys) do
        this.checkbox(
            string.format("Disable %s##%s_disable_%s", key, config_entry_name, key),
            config_entry[config_entry_name].disable,
            key
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
            string.format("##%s_enable_color_%s", config_entry_name, key),
            config_entry[config_entry_name].color_enable,
            key
        )
        if not config_entry[config_entry_name].color_enable[key] then
            imgui.push_style_var(0, 0.4)
        end
        imgui.same_line()
        this.color_edit(
            string.format("%s##%s_color_%s", key, config_entry_name, key),
            config_entry[config_entry_name].color,
            key
        )
        if not config_entry[config_entry_name].color_enable[key] then
            imgui.pop_style_var(1)
        end
    end
    imgui.pop_item_width()
    imgui.end_rect(5, 10)
end

return this
