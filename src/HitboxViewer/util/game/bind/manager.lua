---@class BindManager
---@field name string
---@field binds Bind[]
---@field sorted Bind[]
---@field owner BindMonitor
---@field protected _on_data_changed fun(o: BindManager)[]

---@class (exact) BindBase
---@field name string
---@field name_display string
---@field device string
---@field bound_value any
---@field keys integer[]

---@class (exact) Bind : BindBase
---@field action fun()

local util_table = require("HitboxViewer.util.misc.table")

---@class BindManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param name string?
---@return BindManager
function this:new(name)
    local o = {
        binds = {},
        _on_data_changed = {},
        name = name or tostring(self),
        sorted = {},
    }
    setmetatable(o, self)
    ---@cast o BindManager
    return o
end

---@param binds Bind[]
---@return boolean -- wether all binds passed validation
function this:load(binds)
    self.binds = {}
    local ret = true
    for i = 1, #binds do
        local b = binds[i]
        if not self:is_valid(b) or self:is_collision(b) then
            ret = false
        else
            table.insert(self.binds, b)
        end
    end

    self.sorted = self:_sort_binds()
    self:_execute_on_data_changed_callback()

    return ret
end

---@param monitor BindMonitor
function this:set_owner(monitor)
    self.owner = monitor
end

---@param bind Bind
---@return boolean, Bind?
function this:register(bind)
    if self:is_valid(bind) then
        local is_collision, col = self:is_collision(bind)
        if is_collision then
            return false, col
        end

        table.insert(self.binds, bind)
        self.sorted = self:_sort_binds()
        self:_execute_on_data_changed_callback()
        return true
    end

    return false
end

---@param callback fun(o: BindManager)
function this:register_on_data_changed_callback(callback)
    table.insert(self._on_data_changed, callback)
end

function this:_execute_on_data_changed_callback()
    for _, cb in pairs(self._on_data_changed) do
        cb(self)
    end
end

---@param bind BindBase
---@return boolean, Bind?
function this:is_collision(bind)
    for _, b in pairs(self.binds) do
        if b.name == bind.name then
            return true, b
        end
    end

    return false
end

---@param bind Bind
function this:unregister(bind)
    self.binds = util_table.remove(self.binds, function(_, i, _)
        return self.binds[i].name ~= bind.name
    end)
    self.sorted = self:_sort_binds()
    self:_execute_on_data_changed_callback()
end

---@return Bind[]
function this:get_base_binds()
    local ret = util_table.deep_copy(self.binds)
    util_table.do_something(ret, function(_, _, value)
        value.action = nil
    end)
    return ret
end

---@param bind Bind
---@return boolean
function this:is_valid(bind)
    return not util_table.empty(bind.keys)
end

---@protected
---@return Bind[]
function this:_sort_binds()
    local ret = util_table.deep_copy(self.binds)
    return util_table.sort(ret, function(a, b)
        return #a.keys > #b.keys
    end)
end

return this
