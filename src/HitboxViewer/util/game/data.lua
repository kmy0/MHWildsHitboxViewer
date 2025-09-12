---@diagnostic disable: no-unknown

local util_table = require("HitboxViewer.util.misc.table")

local this = {}
local rl = {}
---@type {fixed: table<string, table<System.Enum, string>>, enum: table<string, table<System.Enum, string>>}}
local enums = {
    fixed = {},
    enum = {},
}

---@generic T, T2
---@param fixed_type `T`
---@param enum_type `T2`
---@return table<`T`, string>, table<`T2`, string>
local function get_enums(fixed_type, enum_type)
    local fixed_t = enums.fixed[fixed_type]
    local enum_t = enums.enum[enum_type]

    if not fixed_t then
        enums.fixed[fixed_type] = {}
        this.get_enum(fixed_type, enums.fixed[fixed_type])
        fixed_t = enums.fixed[fixed_type]
    end

    if not enum_t then
        enums.enum[enum_type] = {}
        this.get_enum(enum_type, enums.enum[enum_type])
        enum_t = enums.enum[enum_type]
    end

    return fixed_t, enum_t
end

---@generic K, V
---@param table table<K, V>
---@param value V
---@param clear boolean?
---@return K
function this.reverse_lookup(table, value, clear)
    if not rl[table] or clear then
        rl[table] = {}

        for k, v in pairs(table) do
            rl[table][v] = k
        end
    end

    return rl[table][value]
end

---@param type_def_name string
---@param as_string boolean?
---@param ignore_values string[]?
function this.iter_fields(type_def_name, as_string, ignore_values)
    local type_def = sdk.find_type_definition(type_def_name)
    if not type_def then
        return
    end

    local fields = type_def:get_fields()
    for _, field in pairs(fields) do
        local name = field:get_name()

        if
            string.lower(name) == "max"
            or string.lower(name) == "value__"
            or string.lower(name) == "invalid"
            or (ignore_values and util_table.contains(ignore_values, name))
        then
            goto continue
        end

        local data = field:get_data()
        if as_string then
            data = tostring(data)
        end

        coroutine.yield(name, data)
        ::continue::
    end
end

---@param type_def_name string
---@return table<string, any>
function this.get_data(type_def_name)
    local ret = {}
    local co = coroutine.create(this.iter_fields)
    local status = true
    ---@type integer
    local data
    ---@type integer | string
    local name
    while status do
        status, name, data = coroutine.resume(co, type_def_name)
        if name and data then
            ret[name] = data
        end
    end

    return ret
end

---@generic T
---@param type_def_name `T`
---@param t {[T]: string}
---@param as_string boolean?
---@param ignore_values string[]?
---@return {[T]: string}
function this.get_enum(type_def_name, t, as_string, ignore_values)
    local co = coroutine.create(this.iter_fields)
    local status = true
    ---@type integer
    local data
    ---@type integer | string
    local name
    while status do
        status, name, data = coroutine.resume(co, type_def_name, as_string, ignore_values)
        if name and data then
            t[data] = name
        end
    end

    return t
end

---@generic T
---@param fixed_type `T`
---@param enum_value integer
---@return `T`
function this.enum_to_fixed(fixed_type, enum_value)
    ---@cast fixed_type string
    local enum_type = fixed_type:match("(.+)_Fixed$")
    local fixed_t, enum_t = get_enums(fixed_type, enum_type)
    local enum_name = enum_t[enum_value]
    return this.reverse_lookup(fixed_t, enum_name)
end

---@generic T
---@param enum_type `T`
---@param fixed_value integer
---@return `T`
function this.fixed_to_enum(enum_type, fixed_value)
    local fixed_type = enum_type .. "_Fixed"
    local fixed_t, enum_t = get_enums(fixed_type, enum_type)
    local fixed_name = fixed_t[fixed_value]
    return this.reverse_lookup(enum_t, fixed_name)
end

return this
