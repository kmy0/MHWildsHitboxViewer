---@class (exact) ConfigBase
---@field current SettingsBase
---@field default SettingsBase
---@field path string
---@field save_timer Timer
---@field run_save fun() updates all save timers
---@field save_global fun() save all configs
---@field save_no_timer_global fun() save all configs

---@class (exact) SettingsBase

local timer = require("HitboxViewer.util.misc.timer")
local util_table = require("HitboxViewer.util.misc.table")

---@class ConfigBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
---@type ConfigBase[]
---@diagnostic disable-next-line: inject-field
this.instances = setmetatable({}, { __mode = "v" })

---@param default_settings SettingsBase
---@param path string
---@param save_delay number?
---@return ConfigBase
function this:new(default_settings, path, save_delay)
    local o = {
        current = util_table.deep_copy(default_settings),
        default = util_table.deep_copy(default_settings),
        path = path,
    }

    o.save_timer = timer:new(save_delay or 0.5, function()
        o:save_no_timer()
    end)
    setmetatable(o, self)
    ---@cast o ConfigBase

    table.insert(this.instances, o)
    return o
end

---@param key string
---@return any
function this:get(key)
    return util_table.get_by_key(self.current, key)
end

---@param key string
---@param value any
function this:set(key, value)
    util_table.set_by_key(self.current, key, value)
    self:save()
end

function this:load()
    local loaded_config = json.load_file(self.path) --[[@as SettingsBase?]]
    if loaded_config then
        self.current = util_table.merge_t(self.default, loaded_config)
    else
        self:save_no_timer()
    end
end

function this:save()
    self.save_timer:restart()
end

---@param path string?
function this:save_no_timer(path)
    self.save_timer:abort()
    json.dump_file(path or self.path, self.current)
end

function this:restore()
    self.current = util_table.deep_copy(self.default)
    self:save_no_timer()
end

function this.run_save()
    for _, o in pairs(this.instances) do
        o.save_timer:update()
    end
end

function this.save_global()
    for _, o in pairs(this.instances) do
        o:save()
    end
end

function this.save_no_timer_global()
    for _, o in pairs(this.instances) do
        o:save_no_timer()
    end
end

return this
