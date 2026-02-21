local bind_manager = require("HitboxViewer.bind.init")
local call_queue = require("HitboxViewer.util.misc.call_queue")
local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local state = require("HitboxViewer.gui.state")
local timescale = require("HitboxViewer.util.game.timescale")
local util_bind = require("HitboxViewer.util.game.bind.init")
local util_imgui = require("HitboxViewer.util.imgui.init")
local util_misc = require("HitboxViewer.util.misc.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_map = data.mod.map
local data_gui = data.gui

local this = {}

---@return boolean
local function resize_trail_buffers()
    if not config.save_timer:active() then
        for box in char:iter_all_boxes() do
            if box.trail_buffer then
                box.trail_buffer:resize(
                    math.ceil(config.max_trail_dur / config.current.mod.trailboxes.step)
                )
            end
        end
        return false
    end
    return true
end

---@param label string
---@param draw_func fun()
---@param enabled_obj boolean?
---@param text_color integer?
---@param size number[]?
---@return boolean
local function draw_menu(label, draw_func, enabled_obj, text_color, size)
    enabled_obj = enabled_obj == nil and true or enabled_obj

    if text_color then
        imgui.push_style_color(0, text_color)
    end

    if size then
        imgui.set_next_window_size(size)
    end

    local menu = imgui.begin_menu(label, enabled_obj)

    if text_color then
        imgui.pop_style_color(1)
    end

    if menu then
        draw_func()
        imgui.end_menu()
    end

    return menu
end
local function draw_mod_menu()
    imgui.push_style_var(14, Vector2f.new(0, 2))

    set:menu_item(gui_util.tr("menu.config.draw_hitboxes"), "mod.enabled_hitboxes")
    set:menu_item(gui_util.tr("menu.config.draw_hurtboxes"), "mod.enabled_hurtboxes")
    set:menu_item(gui_util.tr("menu.config.draw_pressboxes"), "mod.enabled_pressboxes")
    set:menu_item(gui_util.tr("menu.config.draw_collisionboxes"), "mod.enabled_collisionboxes")
    util_imgui.tooltip(config.lang:tr("mod.tooltip_box_collision"))

    imgui.pop_style_var(1)
end

local function draw_lang_menu()
    local config_lang = config.current.mod.lang
    imgui.push_style_var(14, Vector2f.new(0, 2))

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if util_imgui.menu_item(menu_item, config_lang.file == menu_item) then
            config_lang.file = menu_item
            config.lang:change()
            state.translate_combo()
            config:save()
        end
    end

    imgui.separator()

    set:menu_item(gui_util.tr("menu.language.fallback"), "mod.lang.fallback")
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

    imgui.pop_style_var(1)
end

local function draw_draw_menu()
    imgui.spacing()
    imgui.indent(2)
    imgui.push_item_width(gui_util.get_item_width())

    set:slider_int(
        gui_util.tr("menu.settings.draw.slider_draw_distance"),
        "mod.draw.distance",
        0,
        10000
    )
    set:checkbox(gui_util.tr("menu.settings.draw.box_outline"), "mod.draw.outline")

    imgui.begin_disabled(not config:get("mod.draw.outline"))
    set:color_edit(gui_util.tr("menu.settings.draw.color_outline"), "mod.draw.outline_color")
    imgui.end_disabled()
    set:color_edit(
        gui_util.tr("menu.settings.draw.color_highlight"),
        "mod.hurtboxes.color.highlight"
    )

    imgui.pop_item_width()
    imgui.unindent(2)
    imgui.spacing()
end

local function draw_trail_menu()
    imgui.spacing()
    imgui.indent(2)
    imgui.push_item_width(gui_util.get_item_width())

    set:checkbox(gui_util.tr("menu.settings.trail.box_fade"), "mod.trailboxes.fade")
    util_imgui.tooltip(config.lang:tr("menu.settings.trail.tooltip_box_fade"), true)
    imgui.same_line()
    set:checkbox(gui_util.tr("menu.settings.trail.box_outline", "trail"), "mod.trailboxes.outline")

    if
        set:slider_float(
            "##menu.settings.trail.slider_step",
            "mod.trailboxes.step",
            0.001,
            config.max_trail_dur,
            string.format(
                "%s %s",
                config.lang:tr("menu.settings.trail.slider_step"),
                gui_util.seconds_to_minutes_string(config.current.mod.trailboxes.step, "%.3f")
            )
        ) and not call_queue:has(resize_trail_buffers)
    then
        call_queue:push_back(resize_trail_buffers)
    end

    set:slider_float(
        gui_util.tr("menu.settings.trail.slider_draw_dur", "trailboxes"),
        "mod.trailboxes.draw_dur",
        0.001,
        config.max_trail_dur,
        gui_util.seconds_to_minutes_string(config.current.mod.trailboxes.draw_dur, "%.3f")
    )

    imgui.pop_item_width()
    imgui.unindent(2)
    imgui.spacing()
end

local function draw_timescale_menu()
    imgui.spacing()
    imgui.indent(2)
    imgui.push_item_width(gui_util.get_item_width())
    local config_ts = config.current.mod.timescale
    local changed = false

    _, timescale.enabled =
        imgui.checkbox(gui_util.tr("menu.settings.timescale.box_enabled"), timescale.enabled)

    util_imgui.tooltip(config.lang:tr("menu.settings.timescale.tooltip_box_enabled"), true)
    set:slider_float(
        gui_util.tr("menu.settings.timescale.slider_increment"),
        "mod.timescale.step",
        0.001,
        1.0
    )
    if
        set:slider_float(
            gui_util.tr("menu.settings.timescale.slider_timescale"),
            "mod.timescale.timescale",
            0,
            1.0
        )
    then
        timescale.set(config_ts.timescale)
    end

    if
        imgui.button(
            string.format(
                "%s%s",
                config.lang:tr("menu.settings.timescale.button_minus"),
                gui_util.pad_zero(util_misc.round(config_ts.step, 3), 1, 3)
            )
        )
    then
        timescale.decrement(util_misc.round(config_ts.step, 3))
        config_ts.timescale = timescale.get_timescale()
    end

    imgui.same_line()

    if
        imgui.button(
            string.format(
                "%s%s",
                config.lang:tr("menu.settings.timescale.button_plus"),
                gui_util.pad_zero(util_misc.round(config_ts.step, 3), 1, 3)
            )
        )
    then
        timescale.increment(util_misc.round(config_ts.step, 3))
        config_ts.timescale = timescale.get_timescale()
    end

    imgui.same_line()
    changed = imgui.button(gui_util.tr("menu.settings.timescale.button_step"))
    util_imgui.tooltip(config.lang:tr("menu.settings.timescale.tooltip_button_step"))
    if changed then
        timescale.step()
    end

    imgui.pop_item_width()
    imgui.unindent(2)
    imgui.spacing()
end

local function draw_settings_menu()
    imgui.spacing()
    imgui.indent(2)

    draw_menu(gui_util.tr("menu.settings.draw.name"), draw_draw_menu)
    draw_menu(gui_util.tr("menu.settings.trail.name"), draw_trail_menu)
    draw_menu(gui_util.tr("menu.settings.timescale.name"), draw_timescale_menu)

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    if
        set:slider_int(
            gui_util.tr("menu.bind.slider_buffer"),
            "mod.bind.buffer",
            1,
            11,
            config_mod.bind.buffer - 1 == 0 and config.lang:tr("misc.text_disabled")
                or config_mod.bind.buffer - 1 == 1 and string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame")
                )
                or string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame_plural")
                )
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.buffer)
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.tooltip_buffer"))

    imgui.separator()
    imgui.begin_disabled(state.listener ~= nil)

    local manager = bind_manager.action
    local config_key = "mod.bind.action"
    set:combo("##bind_action_combo", "mod.bind.combo_action", state.combo.action.values)

    imgui.same_line()

    if imgui.button(gui_util.tr("menu.bind.button_add")) then
        state.listener = {
            opt = state.combo.action:get_key(config_mod.bind.combo_action),
            listener = util_bind.listener:new(),
            opt_name = state.combo.action:get_value(config_mod.bind.combo_action),
        }
    end

    imgui.end_disabled()

    if state.listener then
        bind_manager.monitor:pause()

        imgui.separator()

        local bind = state.listener.listener:listen() --[[@as ModBind]]
        ---@type string[]
        local bind_name

        if bind.name_display ~= "" then
            bind_name = { bind.name_display, "..." }
        else
            bind_name = { config.lang:tr("menu.bind.text_default") }
        end

        imgui.begin_table("keybind_listener", 1, 1 << 9)
        imgui.table_next_row()

        util_imgui.adjust_pos(0, 3)

        imgui.table_set_column_index(0)

        if manager:is_valid(bind) then
            bind.bound_value = state.listener.opt

            local is_col, col = manager:is_collision(bind)
            if is_col and col then
                state.listener.collision = string.format(
                    "%s %s",
                    config.lang:tr("menu.bind.tooltip_bound"),
                    config.lang:tr(mod_map.actions[col.bound_value])
                )
            else
                state.listener.collision = nil
            end
        else
            state.listener.collision = nil
        end

        imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

        local save_button = imgui.button(gui_util.tr("menu.bind.button_save"))

        if save_button then
            manager:register(bind)
            config:set(config_key, manager:get_base_binds())

            config:save()
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_disabled()
        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.button_clear")) then
            state.listener.listener:clear()
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.button_cancel")) then
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_table()
        imgui.separator()

        if state.listener and state.listener.collision then
            imgui.text_colored(state.listener.collision, data_gui.colors.bad)
            imgui.separator()
        end

        imgui.text(table.concat(bind_name, " + "))
        imgui.separator()
    end

    if
        not util_table.empty(config:get(config_key))
        and imgui.begin_table("keybind_state", 3, 1 << 9)
    then
        imgui.separator()

        ---@type ModBind[]
        local remove = {}
        local binds = config:get(config_key) --[=[@as ModBind[]]=]
        for i = 1, #binds do
            local bind = binds[i]
            imgui.table_next_row()
            imgui.table_set_column_index(0)

            if
                imgui.button(gui_util.tr("menu.bind.button_remove", bind.name, bind.bound_value))
            then
                table.insert(remove, bind)
            end

            imgui.table_set_column_index(1)
            imgui.text(config.lang:tr(mod_map.actions[bind.bound_value]))
            imgui.table_set_column_index(2)
            imgui.text(bind.name_display)
        end

        if not util_table.empty(remove) then
            for _, bind in pairs(remove) do
                manager:unregister(bind)
            end

            config:set(config_key, manager:get_base_binds())
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_tools_menu()
    local config_gui = config.gui.current.gui
    if util_imgui.menu_item(gui_util.tr("mod.button_attack_log"), nil, nil, true) then
        config_gui.attack_log.is_opened = true
    end

    if util_imgui.menu_item(gui_util.tr("mod.button_hurtbox_info"), nil, nil, true) then
        config_gui.hurtbox_info.is_opened = true
    end

    if util_imgui.menu_item(gui_util.tr("mod.button_collision_log"), nil, nil, true) then
        config_gui.collision_log.is_opened = true
    end
end

function this.draw()
    draw_menu(gui_util.tr("menu.config.name"), draw_mod_menu)
    draw_menu(gui_util.tr("menu.language.name"), draw_lang_menu)

    if not draw_menu(gui_util.tr("menu.bind.name"), draw_bind_menu) then
        if state.listener then
            state.listener = nil
            bind_manager.monitor:unpause()
        end
    end

    draw_menu(gui_util.tr("menu.settings.name"), draw_settings_menu)
    draw_menu(gui_util.tr("menu.tools.name"), draw_tools_menu)
end

return this
