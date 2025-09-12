local config = require("HitboxViewer.config.init")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local util_table = require("HitboxViewer.util.misc.table")

local this = {}

---@param types string[]
---@param config_key string
---@param predicate (fun(t: table, i: integer, j:integer) : boolean)?
---@param sort (fun(a: string, b: string): boolean)?
function this.draw_box_type_options(types, config_key, predicate, sort)
    if predicate then
        types = util_table.remove(types, predicate)
    end

    table.sort(types, sort)

    imgui.begin_group()
    imgui.push_item_width(gui_util.get_item_width())
    for _, key in ipairs(types) do
        set:checkbox(
            string.format("%s %s##%s_%s", config.lang:tr("misc.text_disable"), key, config_key, key),
            string.format("%s.disable.%s", config_key, key)
        )
    end
    imgui.pop_item_width()
    imgui.end_group()

    imgui.same_line()

    imgui.begin_group()
    imgui.push_item_width(gui_util.get_item_width())
    for _, key in ipairs(types) do
        local item_config_key = string.format("%s.color_enable.%s", config_key, key)
        set:checkbox(string.format("##%s", item_config_key), item_config_key)
        imgui.begin_disabled(not config:get(item_config_key))
        imgui.same_line()
        item_config_key = string.format("%s.color.%s", config_key, key)
        set:color_edit(string.format("##%s", item_config_key), item_config_key)
        imgui.end_disabled()
    end
    imgui.pop_item_width()
    imgui.end_group()
end

---@param name string
---@param config_key string
---@param additional_options_fn fun()?
function this.draw_box_options(name, config_key, additional_options_fn)
    if imgui.collapsing_header(name) then
        imgui.push_item_width(gui_util.get_item_width())
        set:color_edit(gui_util.tr("mod.color_box", config_key), config_key .. ".color.one_color")
        imgui.pop_item_width()
        imgui.separator()

        imgui.begin_group()

        set:checkbox(
            gui_util.tr("mod.box_disable_small_monsters", config_key),
            config_key .. ".disable.SmallMonster"
        )
        set:checkbox(
            gui_util.tr("mod.box_disable_big_monsters", config_key),
            config_key .. ".disable.BigMonster"
        )
        set:checkbox(gui_util.tr("mod.box_disable_pet", config_key), config_key .. ".disable.Pet")
        set:checkbox(
            gui_util.tr("mod.box_disable_self", config_key),
            config_key .. ".disable.MasterPlayer"
        )
        set:checkbox(
            gui_util.tr("mod.box_disable_players", config_key),
            config_key .. ".disable.Player"
        )
        set:checkbox(gui_util.tr("mod.box_disable_npc", config_key), config_key .. ".disable.Npc")

        imgui.end_group()
        imgui.same_line()

        imgui.begin_group()
        imgui.push_item_width(gui_util.get_item_width())

        for _, key in ipairs({
            "SmallMonster",
            "BigMonster",
            "Pet",
            "MasterPlayer",
            "Player",
            "Npc",
        }) do
            local item_config_key = string.format("%s.color_enable.%s", config_key, key)
            imgui.begin_disabled(config:get(string.format("%s.disable.%s", config_key, key)))
            set:checkbox("##" .. item_config_key, item_config_key)

            imgui.begin_disabled(not config:get(item_config_key))
            imgui.same_line()

            item_config_key = string.format("%s.color.%s", config_key, key)
            set:color_edit("##" .. item_config_key, item_config_key)

            imgui.end_disabled()
            imgui.end_disabled()
        end

        imgui.pop_item_width()
        imgui.end_group()

        if additional_options_fn then
            additional_options_fn()
        end
    end
end

return this
