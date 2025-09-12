---@class TypeDefUtil
---@field types table<string, RETypeDefinition>

---@class TypeDefUtil
local this = {
    types = {},
}

---@param type string
---@return RETypeDefinition
function this.get(type)
    if not this.types[type] then
        this.types[type] = sdk.find_type_definition(type)
    end

    return this.types[type]
end

return this
