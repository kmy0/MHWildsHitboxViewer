local config = require("HitboxViewer.config.init")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local util_imgui = require("HitboxViewer.util.imgui.init")
local util_table = require("HitboxViewer.util.misc.table")

local this = {}
---@type {[string]: {[integer]: number}}
local col_sizes = {}
local col_keys = {
    "header_type",
    "header_disable",
    "header_trail",
    "header_color_enable",
    "header_color",
}

---@param config_key string
---@param keys string[]
---@param type_names string[]
---@param disable_trail boolean?
local function draw_box_table(config_key, keys, type_names, disable_trail)
    if not col_sizes[config_key] then
        col_sizes[config_key] = {}
    end

    disable_trail = disable_trail ~= nil and disable_trail or false

    if
        imgui.begin_table(
            config_key,
            #col_keys,
            imgui.TableFlags.SizingFixedFit | imgui.TableFlags.BordersInnerV --[[@as ImGuiTableFlags]]
        )
    then
        for i = 1, #col_keys do
            local key = config.lang:tr("mod.table_generic_settings." .. col_keys[i])
            local size = math.max(
                imgui.calc_text_size(key).x + config.lang:get_font_size(),
                col_sizes[config_key][i] or 0
            )
            imgui.table_setup_column(key, nil, size)
        end

        imgui.table_next_row()
        for i = 1, #col_keys do
            imgui.table_set_column_index(i - 1)
            local key = config.lang:tr("mod.table_generic_settings." .. col_keys[i])

            imgui.begin_disabled(col_keys[i] == "header_trail" and disable_trail)
            util_imgui.center_h(key .. config_key, function()
                util_imgui.dummy_button3(string.format("%s##%s", key, config_key))
            end)
            imgui.end_disabled()
        end

        for i = 1, #keys do
            local key = keys[i]
            imgui.table_next_row()

            imgui.table_set_column_index(0)
            util_imgui.dummy_button3(string.format("%s##%s", type_names[i], config_key))
            col_sizes[config_key][1] =
                math.max(imgui.calc_text_size(type_names[i]).x, col_sizes[config_key][1] or 0)

            imgui.table_set_column_index(1)
            local item_config_key = string.format("%s.disable.%s", config_key, key)
            util_imgui.center_h(item_config_key, function()
                set:checkbox("##" .. item_config_key, item_config_key)
                col_sizes[config_key][2] =
                    math.max(imgui.calc_item_width(), col_sizes[config_key][2] or 0)
            end)

            local disabled = config:get(item_config_key)
            imgui.begin_disabled(disabled)
            imgui.begin_disabled(disable_trail)
            imgui.table_set_column_index(2)
            item_config_key = string.format("%s.trail_enable.%s", config_key, key)
            util_imgui.center_h(item_config_key, function()
                set:checkbox_tri(
                    "##" .. item_config_key,
                    item_config_key,
                    nil,
                    disable_trail or disabled
                )
                col_sizes[config_key][3] =
                    math.max(imgui.calc_item_width(), col_sizes[config_key][3] or 0)
            end)
            imgui.end_disabled()

            imgui.table_set_column_index(3)
            item_config_key = string.format("%s.color_enable.%s", config_key, key)
            util_imgui.center_h(item_config_key, function()
                set:checkbox("##" .. item_config_key, item_config_key)
                col_sizes[config_key][4] =
                    math.max(imgui.calc_item_width(), col_sizes[config_key][4] or 0)
            end)

            imgui.table_set_column_index(4)

            imgui.begin_disabled(not config:get(item_config_key))
            item_config_key = string.format("%s.color.%s", config_key, key)
            util_imgui.center_h(item_config_key, function()
                imgui.push_item_width(gui_util.get_item_width())
                set:color_edit("##" .. item_config_key, item_config_key)
                col_sizes[config_key][5] = math.max(
                    imgui.calc_item_width() + config.lang:get_font_size(),
                    col_sizes[config_key][5] or 0
                )
                imgui.pop_item_width()
            end)

            imgui.end_disabled()
            imgui.end_disabled()
        end

        imgui.end_table()
    end
end

---@param types string[]
---@param config_key string
---@param predicate (fun(t: table, i: integer, j:integer) : boolean)?
---@param sort (fun(a: string, b: string): boolean)?
---@param disable_trail boolean?
function this.draw_box_type_options(types, config_key, predicate, sort, disable_trail)
    if predicate then
        types = util_table.remove(types, predicate)
    end

    local keys = util_table.sort(types, sort)
    draw_box_table(config_key, keys, keys, disable_trail)
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

        local keys = {
            "SmallMonster",
            "BigMonster",
            "Pet",
            "MasterPlayer",
            "Player",
            "Npc",
        }
        ---@type string[]
        local names = {}

        for i = 1, #keys do
            local key = keys[i]
            table.insert(names, config.lang:tr("mod.char_type." .. key))
        end

        draw_box_table(config_key, keys, names)

        if additional_options_fn then
            imgui.separator()
            additional_options_fn()
        end
    end
end

return this
