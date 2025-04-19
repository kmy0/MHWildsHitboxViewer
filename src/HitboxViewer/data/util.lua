local table_util = require("HitboxViewer.table_util")

local this = {}
local rl = {}

---@generic K
---@generic V
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
            or (ignore_values and table_util.table_contains(ignore_values, name))
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
---@param table table
---@param as_string boolean?
---@param ignore_values string[]?
function this.get_enum(type_def_name, table, as_string, ignore_values)
    local co = coroutine.create(this.iter_fields)
    local status = true
    ---@type integer
    local data
    ---@type integer | string
    local name
    while status do
        status, name, data = coroutine.resume(co, type_def_name, as_string, ignore_values)
        if name and data then
            table[data] = name
        end
    end
end

return this
