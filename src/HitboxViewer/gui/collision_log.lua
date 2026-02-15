local collision_log = require("HitboxViewer.collision_log")
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
        name = "collision_log",
        -- BordersH, BordersInnerH, Sortable, BordersOuterV, SizingStretchProp, ContextMenuInBody, Hideable
        flags = 26021,
        col_count = 11,
        headers = {
            "row",
            "caller",
            "char_a",
            "col_a_res",
            "col_a_set",
            "col_a_idx",
            "char_b",
            "col_b_res",
            "col_b_set",
            "col_b_idx",
            "os_clock",
        },
        header_to_key = {
            caller = "caller_name",
            char_a = "char_a.char_name",
            col_a_res = "char_a.col.resource_idx",
            col_a_set = "char_a.col.set_idx",
            col_a_idx = "char_a.col.collidable_idx",
            char_b = "char_b.char_name",
            col_b_res = "char_b.col.resource_idx",
            col_b_set = "char_b.col.set_idx",
            col_b_idx = "char_b.col.collidable_idx",
            os_clock = "os_clock",
        },
    },
}

local function draw_table()
    if
        imgui.begin_table(
            this.table.name,
            this.table.col_count,
            this.table.flags --[[@as ImGuiTableFlags]]
        )
    then
        for _, header in ipairs(this.table.headers) do
            imgui.table_setup_column(gui_util.tr("mod.table_collision_log.header_" .. header))
        end

        imgui.table_headers_row()
        for i = #collision_log.entries, 1, -1 do
            imgui.table_next_row()
            local entry = collision_log.entries[i]

            for col = 1, this.table.col_count do
                imgui.table_set_column_index(col - 1)
                local header = this.table.headers[col]

                if header == "row" then
                    imgui.text(i)
                else
                    imgui.text(util_table.get_by_key(entry, this.table.header_to_key[header]))
                end
            end
        end

        imgui.end_table()
    end
end

function this.draw()
    local gui_collision_log = config.gui.current.gui.collision_log
    local config_mod = config.current.mod

    imgui.set_next_window_pos(
        Vector2f.new(gui_collision_log.pos_x, gui_collision_log.pos_y),
        this.window.condition
    )
    imgui.set_next_window_size(
        Vector2f.new(gui_collision_log.size_x, gui_collision_log.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_collision_log.is_opened = imgui.begin_window(
        gui_util.tr("mod.window_collision_log"),
        gui_collision_log.is_opened,
        this.window.flags
    )

    util_imgui.set_win_state(gui_collision_log)

    if not gui_collision_log.is_opened then
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
        collision_log:clear()
    end

    imgui.same_line()

    if
        imgui.button(
            config_mod.collisionboxes.pause_collision_log and gui_util.tr("mod.button_resume")
                or gui_util.tr("mod.button_pause")
        )
    then
        config_mod.collisionboxes.pause_collision_log =
            not config_mod.collisionboxes.pause_collision_log
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
