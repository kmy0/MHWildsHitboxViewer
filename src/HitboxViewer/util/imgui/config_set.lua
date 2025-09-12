---@class (exact) ImguiConfigSet
---@field ref ConfigBase

---@class ImguiConfigSet
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param config_ref ConfigBase
---@return ImguiConfigSet
function this:new(config_ref)
    return setmetatable({ ref = config_ref }, self)
end

---@param name string
---@param config_key string
---@param func fun(...): boolean, any
---@return boolean
function this:generic_config(name, config_key, func, ...)
    local changed, value
    changed, value = func(name, self.ref:get(config_key), ...)
    if changed then
        self.ref:set(config_key, value)
    end
    return changed
end

---@param name string
---@param config_key string
---@return boolean
function this:checkbox(name, config_key)
    return self:generic_config(name, config_key, imgui.checkbox)
end

---@param name string
---@param config_key string
---@param values  string[]
---@return boolean
function this:combo(name, config_key, values)
    return self:generic_config(name, config_key, imgui.combo, values)
end

---@param name string
---@param config_key string
---@param flags_obj integer? `ImGuiColorEditFlags`
---@return boolean
function this:color_edit(name, config_key, flags_obj)
    return self:generic_config(name, config_key, imgui.color_edit, flags_obj)
end

---@param name string
---@param config_key string
---@param v_min number
---@param v_max number
---@param display_format? string
---@return boolean
function this:slider_float(name, config_key, v_min, v_max, display_format)
    return self:generic_config(name, config_key, imgui.slider_float, v_min, v_max, display_format)
end

---@param name string
---@param config_key string
---@param v_min number
---@param v_max number
---@param display_format? string
---@return boolean
function this:slider_int(name, config_key, v_min, v_max, display_format)
    return self:generic_config(name, config_key, imgui.slider_int, v_min, v_max, display_format)
end

return this
