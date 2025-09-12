local util_table = require("HitboxViewer.util.misc.table")

local this = {}

---@param value any
---@param deep_hash_table boolean?
---@return string
function this.hash_value(value, deep_hash_table)
    local t = type(value)

    if t == "nil" then
        return "nil"
    elseif t == "boolean" then
        return tostring(value)
    elseif t == "number" then
        return "n:" .. tostring(value)
    elseif t == "string" then
        return "s:" .. value
    elseif t == "table" then
        return deep_hash_table == true and this.hash_table(value) or "t:" .. tostring(value)
    elseif t == "function" then
        return "f:" .. tostring(value)
    else
        return t .. ":" .. tostring(value)
    end
end

---@param tbl table<any, any>
---@return string
function this.hash_table(tbl)
    local keys = util_table.keys(tbl)

    table.sort(keys, function(a, b)
        local ta, tb = type(a), type(b)
        if ta ~= tb then
            return ta < tb
        end
        return tostring(a) < tostring(b)
    end)

    local parts = { "t:{" }
    for i = 1, #keys do
        local k = keys[i]
        table.insert(parts, string.format("[%s]=%s,", this.hash_value(k), this.hash_value(tbl[k])))
    end
    table.insert(parts, "}")

    return table.concat(parts)
end

---@param deep_hash_table boolean?
---@param ... any
---@return string
function this.hash_args(deep_hash_table, ...)
    local args = { ... }
    local parts = {}

    for i = 1, #args do
        table.insert(parts, this.hash_value(args[i], deep_hash_table))
    end

    return table.concat(parts, "|")
end

return this
