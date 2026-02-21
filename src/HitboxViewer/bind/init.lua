---@class ModBinds
---@field action ModBindManager
---@field monitor BindMonitor

---@class (exact) ModBindBase : BindBase
---@class (exact) ModBind : Bind, ModBindBase

local actions = require("HitboxViewer.bind.actions")
local bind_monitor = require("HitboxViewer.util.game.bind.monitor")
local config = require("HitboxViewer.config.init")
local mod_bind_manager = require("HitboxViewer.bind.manager")
local util_game = require("HitboxViewer.util.game.init")

---@class ModBinds
local this = {}

---@enum ModBindManagerType
this.manager_names = {
    ACTION = "action",
}

---@param bind ModBind
local function action(bind)
    local fn = actions[bind.bound_value] --[[@as fun(bind: Bind, monitor: BindMonitor)]]
    if fn then
        fn(bind, this.monitor)
    end
end

---@return boolean
function this.init()
    if not util_game.bind.init() then
        return false
    end

    local bind_key = config.current.mod.bind

    this.action = mod_bind_manager:new(this.manager_names.ACTION, action)

    if not this.action:load(bind_key.action) then
        bind_key.action = this.action:get_base_binds()
    end

    this.monitor = bind_monitor:new(this.action)
    this.monitor:set_max_buffer_frame(bind_key.buffer)
    return true
end

return this
