local attack_log = require("HitboxViewer.attack_log")
local config = require("HitboxViewer.config.init")
local gui_util = require("HitboxViewer.gui.util")
local util_imgui = require("HitboxViewer.util.imgui.init")
local util_table = require("HitboxViewer.util.misc.table")

local this = {
    window = {
        flags = 0,
        condition = 2,
    },
    table = {
        name = "attack_log",
        -- BordersH, BordersInnerH, Sortable, BordersOuterV, SizingStretchProp, ContextMenuInBody, Hideable
        flags = 26021,
        col_count = 15,
        headers = {
            "row",
            "char_type",
            "char_name",
            "resource_path",
            "damage_type",
            "guard_type",
            "motion_value",
            "element",
            "status",
            "mount",
            "part_break",
            "stun",
            "sharpness",
            "os_clock",
            "more_data",
        },
    },
}

---@param more_data table<string, any>
---@param title string
---@param i integer
local function draw_more_data(more_data, title, i)
    attack_log.open_entries[i] = imgui.begin_window(
        string.format("%s %s", config.lang:tr("mod.table_attack_log.header_row"), i),
        attack_log.open_entries[i]
    )

    imgui.text(title)
    ---@diagnostic disable-next-line: param-type-mismatch
    if imgui.begin_table(title, 2, 1921) then
        imgui.table_setup_column(gui_util.tr("mod.table_attack_log.header_key"))
        imgui.table_setup_column(gui_util.tr("mod.table_attack_log.header_value"))

        local keys = util_table.keys(more_data)
        ---@cast keys string[]
        table.sort(keys)
        for _, k in ipairs(keys) do
            imgui.table_next_row()
            imgui.table_set_column_index(0)
            imgui.text(k)
            imgui.table_set_column_index(1)
            imgui.text(more_data[k])
        end
        imgui.end_table()
    end
    imgui.end_window()
end

local function draw_table()
    if
        imgui.begin_table(
            this.table.name,
            this.table.col_count,
            this.table.flags --[[@as ImGuiTableFlags]]
        )
    then
        for _, header in ipairs(this.table.headers) do
            imgui.table_setup_column(gui_util.tr("mod.table_attack_log.header_" .. header))
        end

        imgui.table_headers_row()
        for i = #attack_log.entries, 1, -1 do
            imgui.table_next_row()
            local entry = attack_log.entries[i]

            for col = 1, this.table.col_count do
                imgui.table_set_column_index(col - 1)
                local header = this.table.headers[col]

                if header == "row" then
                    imgui.text(i)
                elseif header == "more_data" then
                    if
                        (
                            imgui.button(gui_util.tr("mod.button_click", i))
                            and not attack_log.open_entries[i]
                        ) or attack_log.open_entries[i]
                    then
                        attack_log.open_entries[i] = true
                        draw_more_data(
                            entry.more_data,
                            string.format(
                                "%s, %s - %s, %s, %s, %s",
                                entry.char_name,
                                entry.char_id,
                                entry.resource_path,
                                entry.resource_idx,
                                entry.set_idx,
                                entry.collidable_idx
                            ),
                            i
                        )
                    end
                else
                    imgui.text(entry[header])
                end
            end
        end

        imgui.end_table()
    end
end

function this.draw()
    local gui_attack_log = config.gui.current.gui.attack_log
    local config_mod = config.current.mod

    imgui.set_next_window_pos(
        Vector2f.new(gui_attack_log.pos_x, gui_attack_log.pos_y),
        this.window.condition
    )
    imgui.set_next_window_size(
        Vector2f.new(gui_attack_log.size_x, gui_attack_log.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_attack_log.is_opened = imgui.begin_window(
        gui_util.tr("mod.window_attack_log"),
        gui_attack_log.is_opened,
        this.window.flags
    )

    util_imgui.set_win_state(gui_attack_log)

    if not gui_attack_log.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        config.save_global()
        imgui.end_window()
        return
    end

    imgui.indent(3)
    imgui.spacing()

    if imgui.button(gui_util.tr("mod.button_clear")) then
        attack_log:clear()
    end

    imgui.same_line()

    if
        imgui.button(
            config_mod.hitboxes.pause_attack_log and gui_util.tr("mod.button_resume")
                or gui_util.tr("mod.button_pause")
        )
    then
        config_mod.hitboxes.pause_attack_log = not config_mod.hitboxes.pause_attack_log
        config:save()
    end

    draw_table()

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.unindent(3)
    imgui.spacing()
    imgui.end_window()
end

return this
