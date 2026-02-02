local util_game = require("HitboxViewer.util.game.init")
local util_misc = require("HitboxViewer.util.misc.init")
local uuid = require("HitboxViewer.util.misc.uuid")

local this = {}
---@type table<string, number>
local child_window_sizes = {}

---@param x number
---@param y number?
function this.adjust_pos(x, y)
    if not y then
        y = 0
    end
    local pos = imgui.get_cursor_pos()
    pos.x = pos.x + x
    pos.y = pos.y + y
    imgui.set_cursor_pos(pos)
end

---@param text string
---@param seperate boolean?
---@param seperate_text string? by_default (?)
function this.tooltip(text, seperate, seperate_text)
    if seperate then
        seperate_text = seperate_text or "(?)"
        imgui.same_line()
        imgui.text(seperate_text)
    end
    if imgui.is_item_hovered() then
        imgui.set_tooltip(text)
    end
end

function this.tooltip_exclamation(text)
    this.tooltip(text, true, "(!)")
end

function this.tooltip_text(text)
    imgui.begin_disabled(true)
    imgui.text(string.format("( %s )", text))
    imgui.end_disabled()
end

---@param label string
---@param padding number?
---@param thickness number?
---@param color integer?
function this.separator_text(label, padding, thickness, color)
    padding = padding or 50
    thickness = thickness or 3
    color = color or 2106363020

    local label_size = imgui.calc_text_size(label)
    local pos = imgui.get_cursor_screen_pos()
    local pos_y = pos.y + label_size.y / 2
    local pos_x_start = pos.x
    local pos_x_end = pos.x + padding

    imgui.draw_list_path_line_to({ pos_x_start, pos_y })
    imgui.draw_list_path_line_to({ pos_x_end, pos_y })
    imgui.draw_list_path_stroke(color, false, thickness)

    imgui.invisible_button(uuid.generate(), { pos_x_end - pos.x, 1 })
    imgui.same_line()
    imgui.text(label)

    pos_x_start = pos_x_end + label_size.x + 15
    pos_x_end = imgui.get_window_pos().x + imgui.get_window_size().x
    imgui.draw_list_path_line_to({ pos_x_start, pos_y })
    imgui.draw_list_path_line_to({ pos_x_end, pos_y })
    imgui.draw_list_path_stroke(color, false, thickness)
end

---@param color integer
---@param offset_x integer?
---@param offset_y integer?
function this.highlight(color, offset_x, offset_y)
    if not offset_x then
        offset_x = 0
    end
    if not offset_y then
        offset_y = 0
    end
    this.adjust_pos(offset_x, offset_y)
    imgui.push_style_color(5, color)
    imgui.begin_rect()
    imgui.end_rect(0, 0)
    imgui.pop_style_color(1)
end

---@param x integer?
---@param y integer?
function this.spacer(x, y)
    x = x or 0
    y = y or 0
    imgui.push_style_var(14, Vector2f.new(x, y))
    imgui.invisible_button(uuid.generate())
    imgui.pop_style_var(1)
end

---@param label string
---@param size_object Vector2f|Vector3f|Vector4f|number[]?
function this.dummy_button(label, size_object)
    imgui.push_style_color(21, 4282400832)
    imgui.push_style_color(22, 4282400832)
    imgui.push_style_color(23, 4282400832)
    local ret = imgui.button(label, size_object)
    imgui.pop_style_color(3)
    return ret
end

---@param label string
---@param size_object Vector2f|Vector3f|Vector4f|number[]?
---@return boolean
function this.dummy_button2(label, size_object)
    imgui.push_style_color(21, 0x00000000)
    imgui.push_style_color(23, 0xff4f4e4d)
    imgui.push_style_var(11, Vector2f.new(0, 0))
    local ret = imgui.button(label, size_object)
    imgui.pop_style_color(2)
    imgui.pop_style_var(1)
    return ret
end

---@param str_id string
---@param draw_func fun()
function this.center_h(str_id, draw_func)
    if imgui.begin_table(str_id .. "_center_h_table", 3, 3 << 13) then
        imgui.table_setup_column(
            string.format("##%s_%s_%s", str_id, "center_h_table_header", 1),
            nil,
            0.01
        )
        imgui.table_setup_column(
            string.format("##%s_%s_%s", str_id, "center_h_table_header", 2),
            1 << 4
        )
        imgui.table_setup_column(
            string.format("##%s_%s_%s", str_id, "center_h_table_header", 3),
            nil,
            0.01
        )

        imgui.table_next_row()
        imgui.table_set_column_index(0)
        imgui.table_set_column_index(1)
        draw_func()
        imgui.table_set_column_index(2)
        imgui.end_table()
    end
end

---@param str_id string
---@param text string
---@param button_yes string
---@param button_no string
---@return boolean
function this.popup_yesno(str_id, text, button_yes, button_no)
    local ret = false
    if imgui.begin_popup(str_id, 1 << 27) then
        this.spacer(0, 2)
        this.center_h(str_id .. "_popupyesno1", function()
            imgui.text(text)
        end)
        this.spacer(0, 1)
        this.center_h(str_id .. "_popupyesno2", function()
            if imgui.button(string.format("%s##%s_yes", button_yes, str_id)) then
                ret = true
                imgui.close_current_popup()
            end

            imgui.same_line()

            if imgui.button(string.format("%s##%s_no", button_no, str_id)) then
                imgui.close_current_popup()
            end
        end)
        this.spacer(0, 2)
        imgui.end_popup()
    end

    return ret
end

---@param x number
---@param y number
---@param size integer
---@param color integer? by default, 0xFFFFFFFF
function this.draw_checkmark(x, y, size, color)
    local thickness = math.max(size / 5.0, 1.0)
    local third = size / 3.0
    color = color or 0xFFFFFFFF
    local bx = x - size
    local by = y + size - third * 0.5

    imgui.draw_list_path_line_to({ bx - third, by - third })
    imgui.draw_list_path_line_to({ bx, by })
    imgui.draw_list_path_line_to({ bx + third * 2, by - third * 2 })
    imgui.draw_list_path_stroke(color, false, thickness)
end

---@param label string
---@param selected_obj boolean?
---@param enabled_obj boolean?
---@param close_on_click boolean?
---@return boolean, boolean?
function this.menu_item(label, selected_obj, enabled_obj, close_on_click)
    local pos_screen = imgui.get_cursor_screen_pos()
    local pos = imgui.get_cursor_pos()
    local win_size = imgui.get_window_size()
    local win_pos = imgui.get_window_pos()
    local checkmark_padding = string.rep(" ", 10)
    local padding = pos_screen.x - win_pos.x
    local disabled = enabled_obj ~= nil and enabled_obj or false
    local id = label
    local ret = selected_obj

    imgui.begin_disabled(disabled)

    label, id = table.unpack(util_misc.split_string(label, "##"))
    label = label .. checkmark_padding
    if not id then
        id = label
    end

    local text_size = imgui.calc_text_size(label)
    local changed =
        this.dummy_button2("##" .. id, { win_size.x - padding * 2, text_size.y + padding * 2 })

    pos.y = pos.y + padding
    pos.x = pos.x + padding

    imgui.set_cursor_pos(pos)
    imgui.text(label)

    if selected_obj then
        this.draw_checkmark(
            pos_screen.x + win_size.x - padding,
            pos_screen.y + padding,
            text_size.y - padding,
            disabled and 0xff9d9d9d or nil
        )
    end

    if changed and type(ret) == "boolean" then
        ret = not ret
    end

    if changed and close_on_click then
        imgui.close_current_popup()
    end

    imgui.end_disabled()
    return changed, ret
end

---@param key string
function this.open_popup(key, offset_x, offset_y)
    offset_x = offset_x or 0
    offset_y = offset_y or 0

    local screen_center = util_game.get_screen_center()
    imgui.set_next_window_pos(Vector2f.new(screen_center.x - offset_x, screen_center.y - offset_y))
    imgui.open_popup(key)
end

---@param name string
---@param draw_fn fun()
---@param size_y number?
---@param spacing number?
function this.draw_child_window(name, draw_fn, size_y, spacing)
    size_y = size_y or 0
    spacing = spacing or 0

    if not child_window_sizes[name] then
        child_window_sizes[name] = size_y
    end

    imgui.begin_child_window(name, { 0, child_window_sizes[name] }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()
    draw_fn()
    local size = imgui.get_cursor_pos().y - pos.y - spacing
    child_window_sizes[name] = size > 0 and size or child_window_sizes[name]
    imgui.end_child_window()
end

---@param win_state {pos_x: number, pos_y: number, size_x: number, size_y: number}
---@param min_y_size number?
function this.set_win_state(win_state, min_y_size)
    min_y_size = min_y_size or 22 --collapsed win size
    local size = imgui.get_window_size()

    if size.y <= min_y_size then
        return
    end

    local pos = imgui.get_window_pos()

    win_state.pos_x, win_state.pos_y = pos.x, pos.y
    win_state.size_x, win_state.size_y = size.x, size.y
end

return this
