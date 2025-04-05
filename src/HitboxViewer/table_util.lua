local this = {}

---@param t table
---@param fn_keep function
---@return table
function this.table_remove(t, fn_keep)
    local i, j, n = 1, 1, #t
    while i <= n do
        if fn_keep(t, i, j) then
            local k = i
            repeat
                i = i + 1
            until i > n or not fn_keep(t, i, j + i - k)
            --if (k ~= j) then
            table.move(t, k, i - 1, j)
            --end
            j = j + i - k
        end
        i = i + 1
    end
    table.move(t, n + 1, n + n - j + 1, j)
    return t
end

---@param list any[]
---@param x any
---@return boolean
function this.table_contains(list, x)
    for _, v in pairs(list) do
        if v == x then
            return true
        end
    end
    return false
end

---@param t table
---@return table
function this.table_copy(t)
    local newtable = {}
    for k, v in pairs(t) do
        newtable[k] = v
    end
    return newtable
end

---@param t table
---@return string
function this.join_table(t)
    local str = nil
    for k, v in pairs(t) do
        local l = k .. " " .. v
        if not str then
            str = l .. "\n"
        else
            str = str .. l
        end
    end
    return str
end

---@param original table
---@param copies table?
---@return table
function this.table_deep_copy(original, copies)
    copies = copies or {}
    local original_type = type(original)
    local copy
    if original_type == "table" then
        if copies[original] then
            copy = copies[original]
        else
            copy = {}
            copies[original] = copy
            for original_key, original_value in next, original, nil do
                copy[this.table_deep_copy(original_key, copies)] = this.table_deep_copy(original_value, copies)
            end
            setmetatable(copy, this.table_deep_copy(getmetatable(original), copies))
        end
    else -- number, string, boolean, etc
        copy = original
    end
    return copy
end

---@param ... table
---@return table
function this.table_merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for key, table in ipairs(tables_to_merge) do
        assert(type(table) == "table", string.format("Expected a table as function parameter %d", key))
    end

    local result = this.table_deep_copy(tables_to_merge[1])

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for key, value in pairs(from) do
            if type(value) == "table" then
                result[key] = result[key] or {}
                assert(type(result[key]) == "table", string.format("Expected a table: '%s'", key))
                result[key] = this.table_merge(result[key], value)
            else
                result[key] = value
            end
        end
    end

    return result
end

---@generic T
---@param t table<any, T>
---@return T[]
function this.values(t)
    local ret = {}
    for _, value in pairs(t) do
        table.insert(ret, value)
    end
    return ret
end

---@generic T
---@param t table<T, any>
---@param sort boolean?
---@return T[]
function this.keys(t, sort)
    local ret = {}
    for key, _ in pairs(t) do
        table.insert(ret, key)
    end

    if sort then
        table.sort(ret)
    else
        table.sort(ret, function(a, b)
            return t[a] < t[b]
        end)
    end
    return ret
end

---@generic T
---@param t T[]
---@param value T
---@return integer?
function this.index(t, value)
    for i, v in pairs(t) do
        if v == value then
            return i
        end
    end
end

return this
