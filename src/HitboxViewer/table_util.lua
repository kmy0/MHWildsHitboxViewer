---@diagnostic disable: no-unknown

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
---@param ... any
---@return boolean
function this.table_contains(list, ...)
    local t = { ... }
    for _, v in pairs(list) do
        for _, test in pairs(t) do
            if v == test then
                return true
            end
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
            if type(value) == "table" and not this.empty(value) then
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

---@param t table
---@param value_getter (fun(o): any)?
---@return any[]
function this.values(t, value_getter)
    local ret = {}
    for _, o_value in pairs(t) do
        local value = o_value
        if value_getter then
            value = value_getter(o_value)
        end
        table.insert(ret, value)
    end
    return ret
end

---@generic T
---@param t table<T, any>
---@return T[]
function this.keys(t)
    local ret = {}
    for key, _ in pairs(t) do
        table.insert(ret, key)
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

---@generic T
---@param t T[]
---@return T[]
function this.set(t)
    local d = {}
    for _, value in pairs(t) do
        d[value] = 1
    end
    return this.keys(d)
end

---@param t table
---@param keys any[]
---@param value any
---@return table
function this.insert_nested_value(t, keys, value)
    local current = t
    local size = #keys

    for i = 1, size do
        local key = keys[i]
        if current[key] == nil then
            current[key] = {}
        end
        current = current[key]
    end

    table.insert(current, value)
    return t
end

---@param t table
---@param keys any[]
---@param value any
---@return table
function this.set_nested_value(t, keys, value)
    local current = t
    local size = #keys

    for i = 1, size - 1 do
        local key = keys[i]
        if current[key] == nil then
            current[key] = {}
        end
        current = current[key]
    end
    current[keys[size]] = value
    return t
end

---@param t table
---@param keys any[]
---@return any
function this.get_nested_value(t, keys)
    local ret = t
    local size = #keys

    for i = 1, size - 1 do
        ret = ret[keys[i]]
        if ret == nil then
            return
        end
    end
    return ret[keys[size]]
end

---@param ... any[]
---@return any[]
function this.array_merge(...)
    local arrays_to_merge = { ... }
    local ret = {}

    for i = 1, #arrays_to_merge do
        local t = arrays_to_merge[i]
        for j = 1, #t do
            table.insert(ret, t[j])
        end
    end
    return ret
end

---@param t table
---@param keys any[]
---@param t_merge table
---@return table
function this.merge_nested_array(t, keys, t_merge)
    local current = t
    local size = #keys

    for i = 1, size do
        local key = keys[i]
        if current[key] == nil then
            current[key] = {}
        end
        current = current[key]
    end

    return this.array_merge(current, t_merge)
end

---@param t any[]
---@param sort boolean?
---@return string[]
function this.to_strings(t, sort)
    local ret = {}
    for _, v in ipairs(t) do
        table.insert(ret, tostring(v))
    end
    if sort then
        table.sort(ret)
    end
    return ret
end

---@generic T
---@param t table<any, T> | T[]
---@param predicate fun(o: T) : boolean
---@return boolean
function this.all(t, predicate)
    for _, value in pairs(t) do
        if not predicate(value) then
            return false
        end
    end
    return true
end

---@generic T
---@param t T[]
---@param key (fun(o: T): any)?
---@param value (fun(o: T): any)?
---@return table<string, any>
function this.map_array(t, key, value)
    local ret = {}
    for _, v in pairs(t) do
        ret[key and key(v) or tostring(v)] = value and value(v) or v
    end
    return ret
end

---@generic K
---@generic V
---@param t table<K, V>
---@param key (fun(o: K): any)?
---@param value (fun(o: V): any)?
---@return table<string, any>
function this.map_table(t, key, value)
    local ret = {}
    for k, v in pairs(t) do
        ret[key and key(k) or tostring(k)] = value and value(v) or v
    end
    return ret
end

---@param t table<any, any>
---@return integer
function this.size(t)
    local ret = 0
    for _, _ in pairs(t) do
        ret = ret + 1
    end
    return ret
end

---@generic K
---@generic V
---@param t table<K, V>
---@param key K | fun(value: V): boolean
---@return V?
function this.pop_item(t, key)
    for k, v in pairs(t) do
        if (type(key) == "function" and key(v)) or k == key then
            t[k] = nil
            return v
        end
    end
end

---@param t table
function this.clear(t)
    for i, _ in pairs(t) do
        t[i] = nil
    end
end

---@param t table
---@return boolean
function this.empty(t)
    return next(t) == nil
end

---@generic T
---@param t T[]
---@param index1 integer
---@param index2 integer
---@param strict boolean?
---@return T[]?
function this.slice(t, index1, index2, strict)
    local ret = {}
    for i = index1, index2 do
        table.insert(ret, t[i])
    end

    if strict and this.empty(ret) then
        return
    end
    return ret
end

---@generic T
---@param t T[]
---@param sort_func (fun(a:any, b:any): boolean)?
---@return T[]
function this.sort(t, sort_func)
    table.sort(t, sort_func)
    return t
end

return this
