local char = require("HitboxViewer.character.init")
local conditions = require("HitboxViewer.box.hurt.conditions.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local drag_util = require("HitboxViewer.gui.drag")
local generic = require("HitboxViewer.gui.generic")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local util_imgui = require("HitboxViewer.util.imgui.init")
local util_table = require("HitboxViewer.util.misc.table")

local ace = data.ace
local mod = data.mod

local this = {}
local drag = drag_util:new()

---@param cond ConditionBase
---@param config_key string
local function draw_condition(cond, config_key)
    imgui.push_item_width(gui_util.get_item_width())

    local item_config_key = config_key .. ".type"
    if
        set:combo(
            "##combo_cond_type_" .. cond.key,
            item_config_key,
            util_table.sort(util_table.keys(mod.enum.condition_type), function(a, b)
                return mod.enum.condition_type[a] < mod.enum.condition_type[b]
            end)
        )
    then
        cond = conditions.swap_condition(cond, config:get(item_config_key))
    end

    imgui.same_line()

    item_config_key = config_key .. ".state"
    if
        set:combo(
            "##combo_cond_state_" .. cond.key,
            item_config_key,
            util_table.sort(util_table.keys(mod.enum.condition_state), function(a, b)
                return mod.enum.condition_state[a] < mod.enum.condition_state[b]
            end)
        )
    then
        cond.state = config:get(item_config_key)
    end

    imgui.same_line()

    local disabled = cond.type ~= mod.enum.condition_type.Element
        and cond.type ~= mod.enum.condition_type.Extract
        and cond.type ~= mod.enum.condition_type.Break

    imgui.begin_disabled(disabled)

    item_config_key = config_key .. ".sub_type"
    if
        cond.type == mod.enum.condition_type.Element
            and set:combo(
                "##combo_cond_element_" .. cond.key,
                item_config_key,
                util_table.sort(util_table.keys(mod.enum.element), function(a, b)
                    return mod.enum.element[a] < mod.enum.element[b]
                end)
            )
        or cond.type == mod.enum.condition_type.Extract and set:combo(
            "##combo_cond_extract_" .. cond.key,
            item_config_key,
            util_table.sort(util_table.keys(mod.enum.extract), function(a, b)
                return mod.enum.extract[a] < mod.enum.extract[b]
            end)
        )
        or cond.type == mod.enum.condition_type.Break
            and set:combo(
                "##combo_cond_break_" .. cond.key,
                item_config_key,
                util_table.sort(util_table.keys(mod.enum.break_state), function(a, b)
                    return mod.enum.break_state[a] < mod.enum.break_state[b]
                end)
            )
    then
        ---@cast cond ElementCondition | BreakCondition | ExtractCondition
        cond.sub_type = config:get(item_config_key)
    end

    if disabled then
        imgui.combo("##combo_cond_dummy")
    end

    imgui.end_disabled()
    imgui.begin_disabled(cond.state ~= mod.enum.condition_state.Highlight)

    item_config_key = config_key .. ".color"
    if set:color_edit("##color_cond_" .. cond.key, config_key .. ".color") then
        cond.color = config:get(item_config_key)
    end

    imgui.end_disabled()

    imgui.begin_disabled(cond.type ~= mod.enum.condition_type.Element)
    imgui.same_line()

    item_config_key = config_key .. ".from"
    if
        set:slider_int(
            "##slider_cond_from_" .. cond.key,
            config_key .. ".from",
            0,
            300,
            "From " .. (cond.from or 0)
        )
    then
        cond.from = config:get(item_config_key)

        if cond.from > cond.to then
            cond.to = cond.from
            config:set(config_key .. ".to")
        end
    end

    imgui.same_line()

    item_config_key = config_key .. ".to"
    if
        set:slider_int(
            "##slider_cond_to_" .. cond.key,
            config_key .. ".to",
            0,
            300,
            "To " .. (cond.to or 0)
        )
    then
        cond.to = config:get(item_config_key)

        if cond.to < cond.from then
            cond.from = cond.to
            config:set(config_key .. ".from")
        end
    end

    if cond.type == mod.enum.condition_type.Scar then
        ---@cast cond ScarCondition
        cond.sub_type = mod.enum.scar.RAW
    end

    imgui.end_disabled()
    imgui.pop_item_width()
end

local function options()
    local config_mod = config.current.mod

    if imgui.tree_node(gui_util.tr("mod.tree_guard")) then
        util_imgui.tooltip_text(config.lang:tr("mod.tooltip_player_only"))
        set:color_edit(gui_util.tr("mod.color_guard"), "mod.hurtboxes.guard_type.color.one_color")

        imgui.separator()

        set:checkbox(
            gui_util.tr("mod.box_disable_top_guard"),
            "mod.hurtboxes.guard_type.disable_top"
        )
        util_imgui.tooltip(config.lang:tr("mod.tooltip_disable_top_guard"), true)
        set:checkbox(
            gui_util.tr("mod.box_disable_bottom_guard"),
            "mod.hurtboxes.guard_type.disable_bottom"
        )
        util_imgui.tooltip(config.lang:tr("mod.tooltip_disable_bottom_guard"), true)
        imgui.separator()
        generic.draw_box_type_options(
            util_table.keys(config_mod.hurtboxes.guard_type.disable),
            "mod.hurtboxes.guard_type",
            function(t, i, j)
                return util_table.contains(ace.map.guard_names, t[i])
            end
        )

        imgui.tree_pop()
    end

    if imgui.tree_node(gui_util.tr("mod.tree_conditions")) then
        util_imgui.tooltip_text(config.lang:tr("mod.tooltip_big_only"))
        util_imgui.tooltip_text(config.lang:tr("mod.tooltip_evaluate_order"))

        if imgui.button(gui_util.tr("mod.button_create_condition")) then
            conditions.new_condition(mod.enum.condition_type.Element)
        end
        imgui.same_line()
        imgui.push_item_width(gui_util.get_item_width())

        set:combo(
            gui_util.tr("mod.combo_hurtbox_state"),
            "mod.hurtboxes.default_state",
            util_table.sort(util_table.keys(mod.enum.default_hurtbox_state), function(a, b)
                return mod.enum.default_hurtbox_state[a] < mod.enum.default_hurtbox_state[b]
            end)
        )

        imgui.pop_item_width()
        imgui.separator()

        ---@type ConditionBase[]
        local remove = {}
        drag:clear()
        for i = 1, #conditions.sorted do
            local cond = conditions.sorted[i]

            drag:draw_drag_button(cond.key, cond, gui_util.get_row_height(2))
            imgui.same_line()

            if
                imgui.button(
                    gui_util.tr("mod.button_remove", cond.key),
                    { 0, gui_util.get_row_height(2) }
                )
            then
                table.insert(remove, cond)
            end

            imgui.same_line()

            imgui.begin_group()
            draw_condition(cond, "mod.hurtboxes.conditions.int:" .. i)
            imgui.end_group()

            drag:check_drag_pos(cond)
            imgui.separator()
        end

        if drag:is_released() then
            config:save()
        elseif drag:is_drag() then
            for i, cond in
                pairs(util_table.sort(util_table.values(conditions.sorted), function(a, b)
                    return drag.item_pos[a] > drag.item_pos[b]
                end))
            do
                cond.key = #conditions.sorted - i
            end
            conditions.sort()
        end

        if not util_table.empty(remove) then
            for _, cond in pairs(remove) do
                conditions.remove(cond)
            end

            config:save()
        end

        imgui.tree_pop()
    end
end

function this.draw()
    generic.draw_box_options(gui_util.tr("mod.header_hurtboxes"), "mod.hurtboxes", options)
end

return this
