local collisionbox = require("HitboxViewer.gui.collisionbox")
local config = require("HitboxViewer.config.init")
local dummybox = require("HitboxViewer.gui.dummybox")
local hitbox = require("HitboxViewer.gui.hitbox")
local hurtbox = require("HitboxViewer.gui.hurtbox")
local menu_bar = require("HitboxViewer.gui.menu_bar")
local pressbox = require("HitboxViewer.gui.pressbox")
local state = require("HitboxViewer.gui.state")
local util_imgui = require("HitboxViewer.util.imgui.init")

local this = {
    window = {
        flags = 1024,
        condition = 2,
    },
}

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
        menu_bar.draw()
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
