local call_queue = require("HitboxViewer.util.misc.call_queue")
local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local state = require("HitboxViewer.gui.state")
local util_imgui = require("HitboxViewer.util.imgui.init")

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

local function draw_settings_menu()
    imgui.spacing()
    imgui.indent(2)

    draw_menu(gui_util.tr("menu.settings.draw.name"), draw_draw_menu)
    draw_menu(gui_util.tr("menu.settings.trail.name"), draw_trail_menu)

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
    draw_menu(gui_util.tr("menu.settings.name"), draw_settings_menu)
    draw_menu(gui_util.tr("menu.tools.name"), draw_tools_menu)
end

return this
