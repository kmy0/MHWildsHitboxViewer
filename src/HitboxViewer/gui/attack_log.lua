local attack_log = require("HitboxViewer.attack_log")
local config = require("HitboxViewer.config")
local table_util = require("HitboxViewer.table_util")
local util = require("HitboxViewer.gui.util")

local this = {}

local table_data = {
    name = "attack_log",
    flags = 1 << 8 | 1 << 7 | 1 << 0 | 1 << 10 | 3 << 13,
    col_count = 15,
    headers = {
        "Row",
        "Char Type",
        "Char Name",
        "Attack ID",
        "Damage Type",
        "Damage Angle",
        "Guard Type",
        "Motion",
        "Element",
        "Status",
        "Mount",
        "Part Break",
        "Stun",
        "Sharpness",
        "More Data",
    },
    header_to_key = {
        ["Char Type"] = "char_type",
        ["Char Name"] = "char_name",
        ["Attack ID"] = "attack_id",
        ["Damage Type"] = "damage_type",
        ["Motion"] = "motion_value",
        ["Element"] = "element",
        ["Mount"] = "mount",
        ["Part Break"] = "part_break",
        ["Status"] = "status",
        ["Sharpness"] = "sharpness",
        ["Stun"] = "stun",
        ["Damage Angle"] = "damage_angle",
        ["Guard Type"] = "guard_type",
    },
}

---@param more_data table<string, any>
---@param title string
---@param i integer
local function draw_more_data(more_data, title, i)
    attack_log.open_entries[i] = imgui.begin_window("Row " .. i, attack_log.open_entries[i])

    imgui.text(title)
    ---@diagnostic disable-next-line: param-type-mismatch
    if imgui.begin_table(title, 2, table_data.flags) then
        imgui.table_setup_column("Key")
        imgui.table_setup_column("Value")

        local keys = table_util.keys(more_data)
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

function this.draw()
    if not config.current.gui.attack_log.detach then
        imgui.same_line()
    end

    if imgui.button(util.spaced_string("Clear", 3) .. "##clear_attack_log") then
        attack_log:clear()
    end
    imgui.same_line()
    if
        imgui.button(
            config.current.gui.attack_log.pause and util.spaced_string("Resume", 3)
                or util.spaced_string("Pause", 3) .. "##attack_log_state"
        )
    then
        config.current.gui.attack_log.pause = not config.current.gui.attack_log.pause
    end

    if config.current.enabled_hitboxes then
        if
            imgui.begin_table(table_data.name, table_data.col_count, table_data.flags --[[@as ImGuiTableFlags]])
        then
            for _, header in ipairs(table_data.headers) do
                imgui.table_setup_column(header)
            end

            imgui.table_headers_row()
            for i = #attack_log.entries, 1, -1 do
                imgui.table_next_row()
                local entry = attack_log.entries[i]

                for col = 1, table_data.col_count do
                    imgui.table_set_column_index(col - 1)
                    local header = table_data.headers[col]

                    if header == "Row" then
                        imgui.text(i --[[@as string]])
                    elseif header == "Char Name" then
                        imgui.text(entry[table_data.header_to_key[header]])
                    elseif header == "More Data" then
                        if
                            (
                                imgui.button(util.spaced_string("Click##attack_log_click" .. i, 3))
                                and not attack_log.open_entries[i]
                            ) or attack_log.open_entries[i]
                        then
                            attack_log.open_entries[i] = true
                            draw_more_data(
                                entry.more_data,
                                string.format("%s, %s - %s", entry.char_name, entry.char_id, entry.attack_id),
                                i
                            )
                        end
                    else
                        imgui.text(entry[table_data.header_to_key[header]])
                    end
                end
            end
            imgui.end_table()
        end
    end
end

return this
