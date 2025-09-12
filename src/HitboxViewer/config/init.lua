---@class MainConfig : ConfigBase
---@field current MainSettings
---@field default MainSettings
---
---@field lang Language
---@field gui GuiConfig
---
---@field version string
---@field commit string
---@field name string
---
---@field default_config_path string
---
---@field default_color integer
---@field default_highlight_color integer
---@field max_table_size integer
---@field max_char_loads integer
---@field max_char_updates integer
---@field max_hurtbox_loads integer
---@field max_pressbox_loads integer
---@field min_char_interval integer
---@field max_char_interval integer
---@field max_char_creates integer
---@field max_part_group_updates integer

local config_base = require("HitboxViewer.util.misc.config_base")
local lang = require("HitboxViewer.config.lang")
local util_misc = require("HitboxViewer.util.misc.init")
local version = require("HitboxViewer.config.version")

local mod_name = "HitboxViewer"
local default_color = 1020343074
local default_highlight_color = 1021633775
local config_path = util_misc.join_paths(mod_name, "config.json")

---@class MainConfig
local this = config_base:new(
    require("HitboxViewer.config.defaults.mod")(default_color, default_highlight_color),
    config_path
)

this.version = version.version
this.commit = version.commit
this.name = mod_name

this.default_config_path = config_path

this.default_color = default_color
this.default_highlight_color = default_highlight_color
this.max_table_size = 100
this.max_char_loads = 1
this.max_hurtbox_loads = 3
this.max_pressbox_loads = 3
this.max_part_group_updates = 1
this.max_char_updates = 3
this.max_char_creates = 3
this.min_char_interval = 10
this.max_char_interval = 60

this.gui = config_base:new(
    require("HitboxViewer.config.defaults.gui"),
    util_misc.join_paths(this.name, "other_configs", "gui.json")
) --[[@as GuiConfig]]
this.lang = lang:new(
    require("HitboxViewer.config.defaults.lang"),
    util_misc.join_paths(this.name, "lang"),
    "en-us.json",
    this
)

---@return boolean
function this.init()
    this:load()
    this.gui:load()
    this.lang:load()

    return true
end

return this
