---@class EnumUtil
---@field enums table<string, Enum>

local util_game = require("HitboxViewer.util.game.util")
local util_table = require("HitboxViewer.util.misc.table")
local logger = require("HitboxViewer.util.misc.logger").g
local util_ref = require("HitboxViewer.util.ref.init")

---@class EnumUtil
local this = {
    enums = {},
}

---@generic T
---@class Enum<T> : {[string]: T}, {[integer]: string}
---@field field_to_enum table<string, integer>
---@field enum_to_field table<integer, string>
---@field ok boolean
local Enum = {}
---@diagnostic disable-next-line: inject-field
Enum.__index = function(self, key)
    if rawget(Enum, key) then
        return rawget(Enum, key)
    end

    if type(key) == "string" then
        return rawget(self, "field_to_enum")[key]
    elseif type(key) == "number" then
        return rawget(self, "enum_to_field")[key]
    end
end
Enum.__pairs = function(self)
    return pairs(rawget(self, "field_to_enum"))
end

---@generic T
---@param enum_type `T`
---@param predicate (fun(key: string, value: integer): boolean)?
---@param duplicate_ok boolean?
---@return Enum<T>
function Enum:new(enum_type, predicate, duplicate_ok)
    ---@type Enum
    local o = {
        enum_to_field = {},
        field_to_enum = util_game.get_fields(enum_type, predicate),
        ok = true,
    }
    o.ok = not util_table.empty(o.field_to_enum)

    local type_def = util_ref.types.get(enum_type)
    local keys = util_table.sort(util_table.keys(o.field_to_enum), function(a, b)
        return type_def:get_field(a):get_offset_from_base()
            < type_def:get_field(b):get_offset_from_base()
    end)

    for i = 1, #keys do
        local key = keys[i]
        local value = o.field_to_enum[key]

        if not duplicate_ok and o.enum_to_field[value] then
            logger:warn(
                string.format(
                    "Enum %s: Duplicate values - %s, %s",
                    enum_type,
                    key,
                    o.enum_to_field[value]
                )
            )
        end

        o.enum_to_field[value] = key
    end

    setmetatable(o, self)
    return o
end

---@param key string
---@param enum integer
function Enum:add(key, enum)
    if self.field_to_enum[key] then
        logger:warn(string.format("Enum %s: Duplicate field - %s", key))
    end

    if self.enum_to_field[enum] then
        logger:warn(string.format("Enum %s: Duplicate values - %s", key, self.enum_to_field[enum]))
    end

    self.field_to_enum[key] = enum
    self.enum_to_field[enum] = key
end

---@param bit integer
---@return string[]
function Enum:get_flags(bit)
    ---@type string[]
    local ret = {}
    for name, value in
        pairs(self --[[@as table<string, integer>]])
    do
        if bit & (1 << value) ~= 0 then
            table.insert(ret, name)
        end
    end

    return ret
end

---@generic T
---@param fixed_type `T`
---@param enum_value integer
---@return T
function this.to_fixed(fixed_type, enum_value)
    ---@cast fixed_type string
    local enum_type = fixed_type:match("(.+)_Fixed$")
    local fixed_enum = this.get(fixed_type) --[[@as {[string]: integer}]]
    local enum = this.get(enum_type) --[[@as {[integer]: string}]]
    local enum_field = enum[enum_value]
    return fixed_enum[enum_field]
end

---@generic T
---@param enum_type `T`
---@param fixed_value integer
---@return T
function this.to_enum(enum_type, fixed_value)
    ---@cast enum_type string
    local fixed_type = enum_type .. "_Fixed"
    local fixed_enum = this.get(fixed_type) --[[@as {[integer]: string}]]
    local enum = this.get(enum_type) --[[@as {[string]: integer}]]
    local fixed_field = fixed_enum[fixed_value]
    return enum[fixed_field]
end

---@generic T
---@param enum_type `T`
---@return fun(): string, T
function this.iter(enum_type)
    local enum = this.get(enum_type)
    local iter, state, key = pairs(enum)
    return function()
        local value
        key, value = iter(state, key)
        return key, value
    end
end

---@param enum_types string[]
---@return fun(): string, integer
function this.iter_many(enum_types)
    local type_index = 1
    local current_enum = this.get(enum_types[type_index])
    local iter, state, key = pairs(current_enum)

    return function()
        while type_index <= #enum_types do
            local value
            key, value = iter(state, key)

            if key ~= nil then
                ---@diagnostic disable-next-line: return-type-mismatch
                return key, value
            end

            type_index = type_index + 1
            if type_index <= #enum_types then
                current_enum = this.get(enum_types[type_index])
                iter, state, key = pairs(current_enum)
            end
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

---@generic T
---@param enum_type `T`
---@return Enum<T>
function this.get(enum_type)
    if not this.enums[enum_type] then
        ---@diagnostic disable-next-line: assign-type-mismatch
        this.enums[enum_type] = Enum:new(enum_type)
    end

    return this.enums[enum_type]
end

---@generic T
---@param enum_type `T`
---@param predicate (fun(key: string, value: integer): boolean)?
---@param duplicate_ok boolean?
---@return Enum<T>
function this.new(enum_type, predicate, duplicate_ok)
    local ret = Enum:new(enum_type, predicate, duplicate_ok)
    ---@diagnostic disable-next-line: assign-type-mismatch
    this.enums[enum_type] = ret
    return ret
end

return this
