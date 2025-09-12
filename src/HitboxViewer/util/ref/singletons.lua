---@class SingletonUtil
---@field singletons table<string, ace.GAElement | NativeSingleton>

---@class (exact) NativeSingleton
---@field ptr userdata
---@field type_def RETypeDefinition
---@field type_def_name string

local m = require("HitboxViewer.util.ref.methods")
local types = require("HitboxViewer.util.ref.types")

---@class SingletonUtil
local this = {
    singletons = {},
}

---@class NativeSingleton
local NativeSingleton = {
    __index = function(self, key)
        ---@cast self NativeSingleton
        if m.t_get(self.type_def_name, key) then
            return function(...)
                return sdk.call_native_func(self.ptr, self.type_def, key, select(2, ...))
            end
        end
        return sdk.get_native_field(self.ptr, self.type_def, key)
    end,
    __newindex = function(self, key, value)
        ---@cast self NativeSingleton
        sdk.set_native_field(self.ptr, self.type_def, key, value)
    end,
}

---@param key string
---@param value any
function NativeSingleton:set_field(key, value)
    sdk.set_native_field(self.ptr, self.type_def, key, value)
end

---@param key string
function NativeSingleton:get_field(key)
    sdk.get_native_field(self.ptr, self.type_def, key)
end

---@param name string
---@param ... any
function NativeSingleton:call(name, ...)
    sdk.call_native_func(self.ptr, self.type_def, name, ...)
end

---@generic T
---@param singleton `T`
---@return T
function this.get(singleton)
    if not this.singletons[singleton] then
        this.singletons[singleton] = sdk.get_managed_singleton(singleton) --[[@as ace.GAElement]]
    end

    return this.singletons[singleton]
end

---@generic T
---@param singleton `T`
---@return T
function this.get_native(singleton)
    if not this.singletons[singleton] then
        local o = {
            ptr = sdk.get_native_singleton(singleton),
            type_def = types.get(singleton),
        }
        o.type_def_name = o.type_def:get_full_name()
        setmetatable(o, NativeSingleton)

        o.type_def_name = o.type_def:get_full_name()
        this.singletons[singleton] = o
    end

    return this.singletons[singleton]
end

return this
