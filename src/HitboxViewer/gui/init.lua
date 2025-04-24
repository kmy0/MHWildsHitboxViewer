local attack_log_gui = require("HitboxViewer.gui.attack_log")
local char = require("HitboxViewer.character")
local conditions = require("HitboxViewer.box.hurt.conditions")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local dummies = require("HitboxViewer.box.dummy")
local hurtbox_info = require("HitboxViewer.gui.hurtbox_info")
local table_util = require("HitboxViewer.table_util")
local util = require("HitboxViewer.gui.util")

local rt = data.runtime

local this = {}
local window = {
    flags = 0,
    condition = 1 << 1,
    font = nil,
}

local function draw_hurtboxes_header()
    if imgui.collapsing_header("Hurtboxes") then
        imgui.indent(10)
        imgui.spacing()

        imgui.begin_rect()
        util.checkbox("Disable Small Monsters##Hurtbox", "hurtboxes.disable.SmallMonster")
        util.checkbox("Disable Big Monsters##Hurtbox", "hurtboxes.disable.BigMonster")
        util.checkbox("Disable Pets##Hurtbox", "hurtboxes.disable.Pet")
        util.checkbox("Disable Self##Hurtbox", "hurtboxes.disable.MasterPlayer")
        util.checkbox("Disable Players##Hurtbox", "hurtboxes.disable.Player")
        util.checkbox("Disable Npc##Hurtbox", "hurtboxes.disable.Npc")
        imgui.end_rect(5, 10)

        imgui.same_line()
        util.set_pos(5)

        imgui.begin_rect()
        imgui.push_item_width(250)

        imgui.begin_disabled(config.current.hurtboxes.use_one_color)
        util.color_edit("Small Monsters##Hurtbox", "hurtboxes.color.SmallMonster")
        util.color_edit("Big Monsters##Hurtbox", "hurtboxes.color.BigMonster")
        util.color_edit("Pets##Hurtbox", "hurtboxes.color.Pet")
        util.color_edit("Self##Hurtbox", "hurtboxes.color.MasterPlayer")
        util.color_edit("Players##Hurtbox", "hurtboxes.color.Player")
        util.color_edit("Npc##Hurtbox", "hurtboxes.color.Npc")
        imgui.end_disabled()

        imgui.pop_item_width()
        imgui.end_rect(5, 10)

        imgui.spacing()
        imgui.spacing()

        if imgui.tree_node("Conditions") then
            if imgui.button(util.spaced_string("Create", 3)) then
                conditions:new_condition(rt.enum.condition_type.Element)
            end
            imgui.same_line()
            imgui.push_item_width(200)
            if
                util.combo(
                    "Default Hurtbox State",
                    "hurtboxes.default_state",
                    table_util.sort(table_util.keys(rt.enum.default_hurtbox_state), function(a, b)
                        return rt.enum.default_hurtbox_state[a] < rt.enum.default_hurtbox_state[b]
                    end)
                )
            then
                for _, monster in pairs(char.cache.by_type_by_gameobject[rt.enum.char.BigMonster]) do
                    ---@cast monster BigEnemy
                    for _, part in pairs(monster.parts) do
                        part.show = config.current.hurtboxes.default_state == rt.enum.default_hurtbox_state.Draw
                    end
                end
            end
            imgui.pop_item_width()
            util.tooltip("Conditions work only for Big Monsters\nConditions are evaluated from top to the bottom", true)

            imgui.separator()
            for i = 1, #conditions.sorted do
                local cond = conditions.sorted[i]
                if cond then
                    hurtbox_info.draw_condition(cond)
                end
            end

            imgui.tree_pop()
        else
            imgui.separator()
        end
        imgui.unindent(10)
        imgui.spacing()
    end
end

local function draw_settings_header()
    if imgui.collapsing_header("General Settings") then
        imgui.indent(10)

        imgui.push_item_width(250)
        util.combo("Shape Spawner", "gui.dummy_shape", rt.enum.shape_dummy)
        imgui.pop_item_width()
        imgui.same_line()

        if imgui.button(util.spaced_string("Go", 7)) then
            dummies.spawn(config.current.gui.dummy_shape)
        end
        imgui.same_line()
        if imgui.button(util.spaced_string("Clear", 6)) then
            dummies.clear()
        end

        imgui.push_item_width(519)
        util.slider_float("Draw Distance", "draw.distance", 0, 10000, "%.0f")
        imgui.pop_item_width()
        util.checkbox("Show Outline", "draw.outline")

        if imgui.tree_node("Colors") then
            util.color_edit("Outline", "draw.outline_color")
            util.checkbox("Use Single Color##Hitbox", "hitboxes.use_one_color")
            imgui.same_line()

            if imgui.button(util.spaced_string("Apply Hitbox Color To All Hitbox Colors", 3)) then
                imgui.open_popup("confirm_all_colors_hitbox")
            end

            if util.popup_yesno("Are you sure?", "confirm_all_colors_hitbox") then
                for key, _ in pairs(config.current.hitboxes.color) do
                    config.current.hitboxes.color[key] = config.current.hitboxes.color.one_color
                end
                for key, _ in pairs(config.current.hitboxes.damage_type.color) do
                    config.current.hitboxes.damage_type.color[key] = config.current.hitboxes.color.one_color
                end
                for key, _ in pairs(config.current.hitboxes.damage_angle.color) do
                    config.current.hitboxes.damage_angle.color[key] = config.current.hitboxes.color.one_color
                end
                for key, _ in pairs(config.current.hitboxes.guard_type.color) do
                    config.current.hitboxes.guard_type.color[key] = config.current.hitboxes.color.one_color
                end
            end

            imgui.begin_disabled(not config.current.hitboxes.use_one_color)
            util.color_edit("Hitbox", "hitboxes.color.one_color")
            imgui.end_disabled()

            imgui.spacing()
            imgui.spacing()

            util.checkbox("Use Single Color##Hurtbox", "hurtboxes.use_one_color")
            imgui.same_line()

            if imgui.button(util.spaced_string("Apply Hurtbox Color To All Hurtbox Colors", 3)) then
                imgui.open_popup("confirm_all_colors_hurtbox")
            end

            if util.popup_yesno("Are you sure?", "confirm_all_colors_hurtbox") then
                for key, _ in pairs(config.current.hurtboxes.color) do
                    config.current.hurtboxes.color[key] = config.current.hurtboxes.color.one_color
                end
            end

            imgui.begin_disabled(not config.current.hurtboxes.use_one_color)
            util.color_edit("Hurtbox", "hurtboxes.color.one_color")
            imgui.end_disabled()
            imgui.tree_pop()
        end

        if imgui.button(util.spaced_string("Restore Defaults", 3)) then
            imgui.open_popup("confirm_restore")
        end

        if util.popup_yesno("Are you sure?", "confirm_restore") then
            config.restore()
            conditions:restore_default()
        end

        imgui.unindent(10)
        imgui.separator()
        imgui.spacing()
    end
end

local function draw_hitboxes_header()
    if imgui.collapsing_header("Hitboxes") then
        imgui.indent(10)
        imgui.spacing()

        imgui.begin_rect()
        util.checkbox("Disable Small Monsters##Hitbox", "hitboxes.disable.SmallMonster")
        util.checkbox("Disable Big Monsters##Hitbox", "hitboxes.disable.BigMonster")
        util.checkbox("Disable Pets##Hitbox", "hitboxes.disable.Pet")
        util.checkbox("Disable Self##Hitbox", "hitboxes.disable.MasterPlayer")
        util.checkbox("Disable Players##Hitbox", "hitboxes.disable.Player")
        util.checkbox("Disable Npc##Hitbox", "hitboxes.disable.Npc")
        imgui.end_rect(5, 10)

        imgui.same_line()
        util.set_pos(5)

        imgui.begin_rect()
        imgui.push_item_width(250)

        imgui.begin_disabled(config.current.hitboxes.use_one_color)
        util.color_edit("Small Monsters##Hitbox", "hitboxes.color.SmallMonster")
        util.color_edit("Big Monsters##Hitbox", "hitboxes.color.BigMonster")
        util.color_edit("Pets##Hitbox", "hitboxes.color.Pet")
        util.color_edit("Self##Hitbox", "hitboxes.color.MasterPlayer")
        util.color_edit("Players##Hitbox", "hitboxes.color.Player")
        util.color_edit("Npc##Hitbox", "hitboxes.color.Npc")
        imgui.end_disabled()

        imgui.pop_item_width()
        imgui.end_rect(5, 10)

        imgui.spacing()
        imgui.spacing()

        util.tooltip("Color application order:\nMisc Type > Guard Type > Damage Angle > Damage Type > Char", true)
        if imgui.tree_node("Damage Type") then
            imgui.spacing()
            util.box_type_setup(config.current.hitboxes.damage_type, "hitboxes.damage_type", "damage_type")
            imgui.tree_pop()
        end
        if imgui.tree_node("Damage Angle") then
            imgui.spacing()
            util.box_type_setup(config.current.hitboxes.damage_angle, "hitboxes.damage_angle", "damage_angle")
            imgui.tree_pop()
        end
        if imgui.tree_node("Guard Type") then
            imgui.spacing()
            util.box_type_setup(config.current.hitboxes.guard_type, "hitboxes.guard_type", "guard_type")
            imgui.tree_pop()
        end
        local node = imgui.tree_node("Misc Type")
        util.tooltip("Evaluated from top to bottom")
        if node then
            imgui.spacing()
            util.box_type_setup(config.current.hitboxes.misc_type, "hitboxes.misc_type", "misc_type", function(t, i, j)
                return table_util.table_contains(data.custom_attack_type.sorted, t[i])
            end)
            imgui.tree_pop()
        end
        imgui.unindent(10)
        imgui.spacing()
    end
end

local function draw_hurtbox_info_header()
    if config.current.gui.hurtbox_info.detach then
        imgui.set_next_window_pos(
            Vector2f.new(config.current.gui.hurtbox_info.pos_x, config.current.gui.hurtbox_info.pos_y),
            window.condition
        )
        imgui.set_next_window_size(
            Vector2f.new(config.current.gui.hurtbox_info.size_x, config.current.gui.hurtbox_info.size_y),
            window.condition
        )

        config.current.gui.hurtbox_info.is_opened =
            imgui.begin_window("Hurtbox Info", config.current.gui.hurtbox_info.is_opened, window.flags)
        imgui.indent(10)
        imgui.spacing()
        hurtbox_info.draw()
        imgui.unindent(10)
        local pos = imgui.get_window_pos()
        local size = imgui.get_window_size()
        config.current.gui.hurtbox_info.pos_x, config.current.gui.hurtbox_info.pos_y = pos.x, pos.y
        config.current.gui.hurtbox_info.size_x, config.current.gui.hurtbox_info.size_y = size.x, size.y
        imgui.end_window()
    end

    if not config.current.gui.hurtbox_info.is_opened then
        config.current.gui.hurtbox_info.detach = false
    end

    if imgui.collapsing_header("Hurtbox Info") then
        imgui.indent(10)
        imgui.spacing()
        if not config.current.gui.hurtbox_info.detach then
            if imgui.button(util.spaced_string("Detach", 3) .. "##detatch_hurtbox_info") then
                config.current.gui.hurtbox_info.detach = true
                config.current.gui.hurtbox_info.is_opened = true
            end

            hurtbox_info.draw()
        else
            imgui.text("Detached")
        end

        imgui.spacing()
        imgui.unindent(10)
        imgui.separator()
        imgui.spacing()
    end
end

local function draw_attack_log_header()
    if config.current.gui.attack_log.detach then
        imgui.set_next_window_pos(
            Vector2f.new(config.current.gui.attack_log.pos_x, config.current.gui.attack_log.pos_y),
            window.condition
        )
        imgui.set_next_window_size(
            Vector2f.new(config.current.gui.attack_log.size_x, config.current.gui.attack_log.size_y),
            window.condition
        )

        config.current.gui.attack_log.is_opened =
            imgui.begin_window("Attack Log", config.current.gui.attack_log.is_opened, window.flags)
        imgui.indent(10)
        imgui.spacing()
        attack_log_gui.draw()
        imgui.unindent(10)
        local pos = imgui.get_window_pos()
        local size = imgui.get_window_size()
        config.current.gui.attack_log.pos_x, config.current.gui.attack_log.pos_y = pos.x, pos.y
        config.current.gui.attack_log.size_x, config.current.gui.attack_log.size_y = size.x, size.y
        imgui.end_window()
    end

    if not config.current.gui.attack_log.is_opened then
        config.current.gui.attack_log.detach = false
    end

    if imgui.collapsing_header("Attack Log") then
        imgui.indent(10)
        imgui.spacing()
        if not config.current.gui.attack_log.detach then
            if imgui.button(util.spaced_string("Detach", 3) .. "##detatch_attack_log") then
                config.current.gui.attack_log.detach = true
                config.current.gui.attack_log.is_opened = true
            end
            attack_log_gui.draw()
        else
            imgui.text("Detached")
        end

        imgui.spacing()
        imgui.unindent(10)
        imgui.separator()
        imgui.spacing()
    end
end

function this.draw()
    imgui.set_next_window_pos(
        Vector2f.new(config.current.gui.main.pos_x, config.current.gui.main.pos_y),
        window.condition
    )
    imgui.set_next_window_size(
        Vector2f.new(config.current.gui.main.size_x, config.current.gui.main.size_y),
        window.condition
    )

    if not this.font then
        ---@diagnostic disable-next-line: param-type-mismatch
        this.font = imgui.load_font(nil, 16, { 0x1, 0xFFFF, 0 })
    end

    if this.font then
        imgui.push_font(this.font)
    end

    config.current.gui.main.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.version),
        config.current.gui.main.is_opened,
        window.flags
    )

    if not config.current.gui.main.is_opened then
        imgui.end_window()
        local pos = imgui.get_window_pos()
        local size = imgui.get_window_size()
        config.current.gui.main.pos_x, config.current.gui.main.pos_y = pos.x, pos.y
        config.current.gui.main.size_x, config.current.gui.main.size_y = size.x, size.y
        config.save()
        if this.font then
            imgui.pop_font()
        end
        return
    end

    imgui.spacing()
    imgui.indent(10)

    util.checkbox("Draw Hitboxes", "enabled_hitboxes")
    local changed = util.checkbox("Draw Hurtboxes", "enabled_hurtboxes")
    if changed and config.current.enabled_hurtboxes and rt.in_game() then
        char.create_all_chars()
    end

    imgui.separator()
    imgui.spacing()
    imgui.unindent(10)

    draw_hurtboxes_header()
    draw_hitboxes_header()
    draw_settings_header()
    draw_hurtbox_info_header()
    draw_attack_log_header()

    if this.font then
        imgui.pop_font()
    end

    imgui.end_window()
end

return this
