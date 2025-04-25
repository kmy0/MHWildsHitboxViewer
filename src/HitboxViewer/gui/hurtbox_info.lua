local char = require("HitboxViewer.character")
local conditions = require("HitboxViewer.box.hurt.conditions")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local table_util = require("HitboxViewer.table_util")
local util = require("HitboxViewer.gui.util")

local rt = data.runtime
local gui = data.gui

local this = {}

local table_data = {
    name = "hurtbox_info",
    flags = 1 << 8 | 1 << 7 | 1 << 0 | 1 << 10 | 3 << 13,
    col_count = 18,
    headers = {
        "Scars",
        "Part Name",
        "Show",
        "Highlight",
        "Enabled",
        "Weak",
        "Break",
        "Extract",
        "Slash",
        "Blow",
        "Shot",
        "Stun",
        "Fire",
        "Water",
        "Ice",
        "Thunder",
        "Dragon",
        "LightPlant",
    },
    header_to_key = {
        ["Part Name"] = "display_name",
        ["Enabled"] = "enabled",
        ["Show"] = "show",
        ["Highlight"] = "highlight",
        ["Extract"] = "extract",
        ["Break"] = "can_break",
        ["Weak"] = "is_weak",
        ["Scars"] = "scars",
        ["Slash"] = "Slash",
        ["Blow"] = "Blow",
        ["Shot"] = "Shot",
        ["Fire"] = "Fire",
        ["Water"] = "Water",
        ["Ice"] = "Ice",
        ["Thunder"] = "Thunder",
        ["Dragon"] = "Dragon",
        ["LightPlant"] = "LightPlant",
        ["Stun"] = "Stun",
    },
}

---@param scars ScarBox[]
local function draw_scar_rows(scars)
    for _, scar in ipairs(scars) do
        imgui.table_next_row()

        for col = 1, table_data.col_count do
            imgui.table_set_column_index(col - 1)
            imgui.table_set_bg_color(1, 1011830607, col - 1)
            local header = table_data.headers[col]

            if header == "Part Name" then
                imgui.text(scar.state)
            elseif header == "Enabled" or header == "Extract" or header == "Weak" or header == "Break" then
                imgui.text(gui.data_missing)
            else
                imgui.text(scar.hitzone[table_data.header_to_key[header]] --[[@as string]])
            end
        end
    end
end

---@param monster BigEnemy
local function draw_table(monster)
    local sorted_parts = monster:get_sorted_part_groups()
    for _, header in ipairs(table_data.headers) do
        imgui.table_setup_column(header)
    end

    imgui.table_headers_row()

    for row, part in ipairs(sorted_parts) do
        imgui.table_next_row()

        for col = 1, table_data.col_count do
            imgui.table_set_column_index(col - 1)
            local header = table_data.headers[col]
            ---@diagnostic disable-next-line: no-unknown
            local value

            if header == "Part Name" then
                imgui.text(part.name)
            elseif header == "Show" or header == "Highlight" then
                value = part[table_data.header_to_key[header]] --[[@as boolean]]
                imgui.spacing()
                if
                    imgui.button(
                        string.format(
                            "%s##%s_%s_%s",
                            util.spaced_string(not value and "No" or "Yes", 3),
                            part.guid,
                            header,
                            row - 1
                        )
                    )
                then
                    ---@diagnostic disable-next-line: no-unknown
                    part[table_data.header_to_key[header]] = not value
                end
                imgui.spacing()
            elseif header == "Break" then
                imgui.text(
                    part.part_data[table_data.header_to_key[header]]
                            and (part.part_data.is_broken and (part.part_data.is_lost and "Severed" or "Broken") or "Yes")
                        or "No"
                )
            elseif header == "Weak" or header == "Enabled" then
                imgui.text(part.part_data[table_data.header_to_key[header]] and "Yes" or "No")
            elseif header == "Extract" then
                imgui.text(part.part_data[table_data.header_to_key[header]])
            elseif header == "Scars" then
                if part.part_data.scar_boxes then
                    imgui.spacing()
                    if imgui.arrow_button("##scars_click" .. row, part.part_data.is_scar_gui_open and 3 or 1) then
                        part.part_data.is_scar_gui_open = not part.part_data.is_scar_gui_open
                    end
                    imgui.spacing()
                end
            else
                imgui.text(part.part_data.hitzone[table_data.header_to_key[header]] --[[@as string]])
            end
        end

        if part.part_data.is_scar_gui_open then
            draw_scar_rows(part.part_data.scar_boxes)
        end
    end
end

---@param cond ConditionBase
function this.draw_condition(cond)
    ---@type boolean
    local changed, save
    ---@type any
    local value
    ---@type boolean?
    local dir
    local remove = false

    if imgui.button(string.format("%s##remove_%s", util.spaced_string("Remove", 3), cond.key)) then
        remove = true
    end

    imgui.same_line()
    if imgui.arrow_button(string.format("##up_%s", cond.key), 2) then
        dir = true
    end

    imgui.same_line()
    if imgui.arrow_button(string.format("##down_%s", cond.key), 3) then
        dir = false
    end

    imgui.same_line()
    imgui.push_item_width(200)
    changed, value = imgui.combo(
        "##combo_type_" .. cond.key,
        cond.type,
        table_util.sort(table_util.keys(rt.enum.condition_type), function(a, b)
            return rt.enum.condition_type[a] < rt.enum.condition_type[b]
        end)
    )
    save = changed or save

    if changed then
        cond = conditions:swap_condition(cond, value)
    end

    imgui.same_line()
    changed, cond.state = imgui.combo(
        "##condition_state_" .. cond.key,
        cond.state,
        table_util.sort(table_util.keys(rt.enum.condition_state), function(a, b)
            return rt.enum.condition_state[a] < rt.enum.condition_state[b]
        end)
    )
    save = changed or save
    imgui.pop_item_width()

    if cond.type == rt.enum.condition_type.Element then
        ---@cast cond ElementCondition
        imgui.same_line()
        imgui.push_item_width(200)
        changed, cond.sub_type = imgui.combo(
            "##combo_element" .. cond.key,
            cond.sub_type,
            table_util.sort(table_util.keys(rt.enum.element), function(a, b)
                return rt.enum.element[a] < rt.enum.element[b]
            end)
        )
        save = changed or save
        imgui.pop_item_width()

        imgui.push_item_width(304)
        changed, cond.from = imgui.slider_int("##from_" .. cond.key, cond.from, 0, 300, "From " .. cond.from)
        save = changed or save

        if changed and cond.from > cond.to then
            cond.to = cond.from
        end

        imgui.same_line()
        changed, cond.to = imgui.slider_int("##to_" .. cond.key, cond.to, 0, 300, "To " .. cond.to)
        save = changed or save

        if changed and cond.to < cond.from then
            cond.from = cond.to
        end
        imgui.pop_item_width()
    elseif cond.type == rt.enum.condition_type.Extract then
        ---@cast cond ExtractCondition
        imgui.push_item_width(200)
        imgui.same_line()
        changed, cond.sub_type = imgui.combo(
            "##combo_extract" .. cond.key,
            cond.sub_type,
            table_util.sort(table_util.keys(rt.enum.extract), function(a, b)
                return rt.enum.extract[a] < rt.enum.extract[b]
            end)
        )
        save = changed or save
        imgui.pop_item_width()
    elseif cond.type == rt.enum.condition_type.Break then
        ---@cast cond BreakCondition
        imgui.push_item_width(200)
        imgui.same_line()
        changed, cond.sub_type = imgui.combo(
            "##combo_break" .. cond.key,
            cond.sub_type,
            table_util.sort(table_util.keys(rt.enum.break_state), function(a, b)
                return rt.enum.break_state[a] < rt.enum.break_state[b]
            end)
        )
        save = changed or save
        imgui.pop_item_width()
    elseif cond.type == rt.enum.condition_type.Scar then
        ---@cast cond ScarCondition
        cond.sub_type = 2
    end

    if cond.state == rt.enum.condition_state.Highlight then
        imgui.push_item_width(616)
        changed, cond.color = imgui.color_edit("##color" .. cond.key, cond.color)
        save = changed or save
        imgui.pop_item_width()
    end

    imgui.separator()
    if dir ~= nil then
        local index = table_util.index(conditions.sorted, cond) --[[@as integer]]
        if dir then
            index = index - 1
        else
            index = index + 1
        end

        if conditions:swap_order(cond, conditions.sorted[index]) then
            save = false
        end
    end

    if save then
        conditions:save()
    elseif remove then
        conditions:remove(cond)
    end
end

function this.draw()
    if
        config.current.enabled_hurtboxes
        and not config.current.hurtboxes.disable.BigMonster
        and not char.cache:is_empty(rt.enum.char.BigMonster)
    then
        local sorted_monsters = char.get_sorted_chars(rt.enum.char.BigMonster)
        if not sorted_monsters then
            return
        end

        for i, monster in ipairs(sorted_monsters) do
            ---@cast monster BigEnemy
            local in_draw_distance = monster.distance < config.current.draw.distance
            if imgui.tree_node(string.format("%s##%s", monster.name, monster.id)) then
                imgui.spacing()

                util.set_pos(5)
                imgui.begin_rect()
                imgui.text("In Draw Distance: ")
                imgui.same_line()
                imgui.text_colored(
                    in_draw_distance and "Yes" or "No",
                    in_draw_distance and gui.colors.good or gui.colors.bad
                )
                imgui.text("Distance: ")
                imgui.same_line()
                imgui.text_colored(string.format("%.3f", monster.distance), gui.colors.info)
                imgui.end_rect(5, 10)
                imgui.spacing()

                if
                    imgui.begin_table(
                        table_data.name .. i,
                        table_data.col_count,
                        table_data.flags --[[@as ImGuiTableFlags]]
                    )
                then
                    draw_table(monster)
                    imgui.end_table()
                end
                imgui.tree_pop()
            end
        end
    end
end

return this
