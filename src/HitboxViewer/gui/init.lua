local collisionbox = require("HitboxViewer.gui.collisionbox")
local config = require("HitboxViewer.config.init")
local draw_settings = require("HitboxViewer.gui.draw_settings")
local dummybox = require("HitboxViewer.gui.dummybox")
local gui_util = require("HitboxViewer.gui.util")
local hitbox = require("HitboxViewer.gui.hitbox")
local hurtbox = require("HitboxViewer.gui.hurtbox")
local pressbox = require("HitboxViewer.gui.pressbox")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local state = require("HitboxViewer.gui.state")
local util_imgui = require("HitboxViewer.util.imgui.init")

local this = {
    window = {
        flags = 1024,
        condition = 2,
    },
}

local function draw_menu_bar()
    if imgui.begin_menu(gui_util.tr("menu.config.name")) then
        set:menu_item(gui_util.tr("menu.config.draw_hitboxes"), "mod.enabled_hitboxes")
        set:menu_item(gui_util.tr("menu.config.draw_hurtboxes"), "mod.enabled_hurtboxes")
        set:menu_item(gui_util.tr("menu.config.draw_pressboxes"), "mod.enabled_pressboxes")
        set:menu_item(gui_util.tr("menu.config.draw_collisionboxes"), "mod.enabled_collisionboxes")
        util_imgui.tooltip(config.lang:tr("mod.tooltip_box_collision"))

        imgui.end_menu()
    end

    if imgui.begin_menu(gui_util.tr("menu.language.name")) then
        local config_lang = config.current.mod.lang
        imgui.push_style_var(14, Vector2f.new(0, 2))

        for i = 1, #config.lang.sorted do
            local menu_item = config.lang.sorted[i]
            if util_imgui.menu_item(menu_item, config_lang.file == menu_item) then
                config_lang.file = menu_item
                config.lang:change()
                config:save()
            end
        end

        imgui.separator()

        set:menu_item(gui_util.tr("menu.language.fallback"), "mod.lang.fallback")
        util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

        imgui.pop_style_var(1)
        imgui.end_menu()
    end

    if imgui.begin_menu(gui_util.tr("menu.draw_settings.name")) then
        draw_settings.draw()

        imgui.end_menu()
    end

    local config_gui = config.gui.current.gui
    if imgui.begin_menu(gui_util.tr("menu.tools.name")) then
        if util_imgui.menu_item(gui_util.tr("mod.button_attack_log"), nil, nil, true) then
            config_gui.attack_log.is_opened = true
        end

        if util_imgui.menu_item(gui_util.tr("mod.button_hurtbox_info"), nil, nil, true) then
            config_gui.hurtbox_info.is_opened = true
        end

        if util_imgui.menu_item(gui_util.tr("mod.button_collision_log"), nil, nil, true) then
            config_gui.collision_log.is_opened = true
        end

        imgui.end_menu()
    end
end

function this.draw()
    local gui_main = config.gui.current.gui.main

    imgui.set_next_window_pos(Vector2f.new(gui_main.pos_x, gui_main.pos_y), this.window.condition)
    imgui.set_next_window_size(
        Vector2f.new(gui_main.size_x, gui_main.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_main.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.commit),
        gui_main.is_opened,
        this.window.flags
    )

    util_imgui.set_win_state(gui_main)

    if not gui_main.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        config.save_global()
        imgui.end_window()
        return
    end

    if imgui.begin_menu_bar() then
        draw_menu_bar()
        imgui.end_menu_bar()
    end

    imgui.spacing()
    imgui.indent(3)

    hitbox.draw()
    hurtbox.draw()
    pressbox.draw()
    collisionbox.draw()
    dummybox.draw()

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.unindent(3)
    imgui.spacing()
    imgui.end_window()
end

---@return boolean
function this.init()
    state.init()
    return true
end

return this
