local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local gui_util = require("HitboxViewer.gui.util")
local util_imgui = require("HitboxViewer.util.imgui.init")

local mod = data.mod
local gui = data.gui

local this = {
    window = {
        flags = 0,
        condition = 2,
    },
    table = {
        name = "hurtbox_info",
        flags = 1 << 8 | 1 << 7 | 1 << 0 | 1 << 10 | 3 << 13,
        col_count = 18,
        headers = {
            "scars",
            "display_name",
            "is_enabled",
            "is_show",
            "is_highlight",
            "extract",
            "can_break",
            "is_weak",
            "Slash",
            "Blow",
            "Shot",
            "Fire",
            "Water",
            "Ice",
            "Thunder",
            "Dragon",
            "LightPlant",
            "Stun",
        },
    },
}

---@param part_group PartGroup
local function draw_scar_rows(part_group)
    local scars = part_group.part_data.scar_boxes --[=[@as ScarBox[]]=]
    for i = 1, #scars do
        local scar = scars[i]
        imgui.table_next_row()

        for col = 1, this.table.col_count do
            imgui.table_set_column_index(col - 1)
            imgui.table_set_bg_color(1, 1011830607, col - 1)
            local header = this.table.headers[col]

            if header == "display_name" then
                imgui.text(
                    part_group:is_updated() and scar.state
                        or config.lang:tr("misc.text_name_missing")
                )
            elseif
                header == "is_enabled"
                or header == "extract"
                or header == "is_weak"
                or header == "can_break"
            then
                imgui.text(config.lang:tr("misc.text_data_missing"))
            else
                imgui.text(scar.hitzone[header])
            end
        end
    end
end

---@param monster BigEnemy
local function draw_table(monster)
    if
        imgui.begin_table(
            this.table.name .. tostring(monster),
            this.table.col_count,
            this.table.flags --[[@as ImGuiTableFlags]]
        )
    then
        local sorted_parts = monster:get_sorted_part_groups()
        for _, header in ipairs(this.table.headers) do
            imgui.table_setup_column(gui_util.tr("mod.table_hurtbox_info.header_" .. header))
        end
        imgui.table_headers_row()

        for row = 1, #sorted_parts do
            imgui.table_next_row()
            local part = sorted_parts[row]

            for col = 1, this.table.col_count do
                imgui.table_set_column_index(col - 1)
                local header = this.table.headers[col]

                if header == "display_name" then
                    imgui.text(part.name)
                elseif header == "is_show" or header == "is_highlight" then
                    imgui.spacing()

                    if
                        imgui.button(
                            part[header]
                                    and gui_util.tr("misc.text_yes", "hurtbox_info", header, row)
                                or gui_util.tr("misc.text_no", "hurtbox_info", header, row)
                        )
                    then
                        ---@diagnostic disable-next-line: no-unknown
                        part[header] = not part[header]
                    end

                    imgui.spacing()
                elseif header == "can_break" then
                    local text = config.lang:tr("misc.text_no")
                    if part.part_data.can_break then
                        text = part.part_data.can_lost and config.lang:tr("misc.text_sever")
                            or config.lang:tr("misc.text_break")
                    end

                    if part.part_data.is_broken then
                        text = part.part_data.can_lost and config.lang:tr("misc.text_severed")
                            or config.lang:tr("misc.text_broken")
                    end

                    imgui.text(text)
                elseif header == "is_weak" then
                    imgui.text(
                        part.part_data[header] and config.lang:tr("misc.text_yes")
                            or config.lang:tr("misc.text_no")
                    )
                elseif header == "is_enabled" then
                    imgui.text(
                        part:is_updated()
                                and (part.part_data[header] and config.lang:tr("misc.text_yes") or config.lang:tr(
                                    "misc.text_no"
                                ))
                            or config.lang:tr("misc.text_name_missing")
                    )
                elseif header == "extract" then
                    imgui.text(part.part_data[header])
                elseif header == "scars" and part.part_data.scar_boxes then
                    imgui.spacing()

                    if
                        imgui.arrow_button(
                            "##scars_click" .. row,
                            part.part_data.is_scar_gui_open and 3 or 1
                        )
                    then
                        part.part_data.is_scar_gui_open = not part.part_data.is_scar_gui_open
                    end

                    imgui.spacing()
                else
                    imgui.text(part.part_data.hitzone[header])
                end
            end

            if part.part_data.is_scar_gui_open then
                draw_scar_rows(part)
            end
        end

        imgui.end_table()
    end
end

local function reset_states()
    local sorted_monsters = char.get_sorted_chars(mod.enum.char.BigMonster)
    if not sorted_monsters then
        return
    end
    ---@cast sorted_monsters BigEnemy[]

    for i = 1, #sorted_monsters do
        local monster = sorted_monsters[i]
        local sorted_parts = monster:get_sorted_part_groups()

        for j = 1, #sorted_parts do
            local part = sorted_parts[j]
            part.is_show = true
            part.is_highlight = false
        end
    end
end

local function draw_monsters()
    local sorted_monsters = char.get_sorted_chars(mod.enum.char.BigMonster)
    if not sorted_monsters then
        return
    end
    ---@cast sorted_monsters BigEnemy[]

    for i = 1, #sorted_monsters do
        local monster = sorted_monsters[i]
        local win_x = imgui.get_window_size().x
        local pos = imgui.get_cursor_pos()
        local header_x = imgui.calc_text_size(monster.name).x + config.lang:get_font_size() * 2
        local pad_x = config.lang:get_font_size()
        local pad_y = 3

        if imgui.collapsing_header(string.format("%s##%s", monster.name, monster.id)) then
            draw_table(monster)
        end

        local ori_pos = imgui.get_cursor_pos()
        local text_x = imgui.calc_text_size(
            string.format(
                "%s: %s",
                config.lang:tr("misc.text_distance"),
                string.format("%.3f", monster.distance)
            )
        ).x + pad_x

        if win_x - text_x > header_x then
            imgui.set_cursor_pos({ win_x - text_x, pos.y + pad_y })
            imgui.text(string.format("%s:", config.lang:tr("misc.text_distance")))
            imgui.same_line()
            imgui.text_colored(
                string.format("%.3f", monster.distance),
                monster.distance <= config.current.mod.draw.distance and gui.colors.good
                    or gui.colors.bad
            )
            imgui.set_cursor_pos(ori_pos)
        end
    end
end

function this.draw()
    local gui_hurtbox_info = config.gui.current.gui.hurtbox_info
    local config_mod = config.current.mod

    imgui.set_next_window_pos(
        Vector2f.new(gui_hurtbox_info.pos_x, gui_hurtbox_info.pos_y),
        this.window.condition
    )
    imgui.set_next_window_size(
        Vector2f.new(gui_hurtbox_info.size_x, gui_hurtbox_info.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_hurtbox_info.is_opened = imgui.begin_window(
        gui_util.tr("mod.window_hurtbox_info"),
        gui_hurtbox_info.is_opened,
        this.window.flags
    )

    local pos = imgui.get_window_pos()
    local size = imgui.get_window_size()

    gui_hurtbox_info.pos_x, gui_hurtbox_info.pos_y = pos.x, pos.y
    gui_hurtbox_info.size_x, gui_hurtbox_info.size_y = size.x, size.y

    if not gui_hurtbox_info.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        config.save_global()
        imgui.end_window()
        reset_states()
        return
    end

    imgui.spacing()
    imgui.indent(3)

    if
        not config_mod.enabled_hurtboxes
        or config_mod.hurtboxes.disable.BigMonster
        or char.cache.is_empty(mod.enum.char.BigMonster)
    then
        imgui.text_colored(config.lang:tr("misc.text_no_monsters"), gui.colors.bad)
    else
        draw_monsters()
    end

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.unindent(3)
    imgui.spacing()
    imgui.end_window()
end

return this
