---@diagnostic disable: no-unknown

local this = {}

---@generic T: table
---@param t T
---@param fn_keep fun(t: T, i: integer, j: integer): boolean
---@return T
function this.remove(t, fn_keep)
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

---@generic K, V
---@param t table<K, V>
---@param ... V
---@return boolean
function this.contains(t, ...)
    local values = { ... }
    for _, v in pairs(t) do
        for _, v2 in pairs(values) do
            if v == v2 then
                return true
            end
        end
    end
    return false
end

---@generic T: table
---@param original T
---@param copies nil
---@return T
function this.deep_copy(original, copies)
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
                copy[this.deep_copy(original_key, copies)] = this.deep_copy(original_value, copies)
            end
            setmetatable(copy, this.deep_copy(getmetatable(original), copies))
        end
    else -- number, string, boolean, etc
        copy = original
    end
    return copy
end

---@param ... table
---@return table
function this.merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for key, table in ipairs(tables_to_merge) do
        assert(
            type(table) == "table",
            string.format("Expected a table as function parameter %d", key)
        )
    end

    local result = this.deep_copy(tables_to_merge[1])

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for key, value in pairs(from) do
            if type(value) == "table" then
                result[key] = result[key] or {}
                assert(type(result[key]) == "table", string.format("Expected a table: '%s'", key))
                result[key] = this.merge(result[key], value)
            else
                result[key] = value
            end
        end
    end

    return result
end

---@generic T: table
---@param ... T
---@return T
function this.merge_t(...)
    return this.merge(...)
end

---@param protected string[]?
---@param ignore_empty boolean?
---@param ... table
---@return table
function this.merge2(protected, ignore_empty, ...)
    if protected == nil then
        protected = {}
    end

    if ignore_empty == nil then
        ignore_empty = false
    end

    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for key, table in ipairs(tables_to_merge) do
        assert(
            type(table) == "table",
            string.format("Expected a table as function parameter %d", key)
        )
    end

    local result = this.deep_copy(tables_to_merge[1])

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for key, value in pairs(from) do
            if this.contains(protected, key) or ignore_empty and result[key] == nil then
                goto continue
            end

            if
                type(value) == "table"
                and (not ignore_empty or (ignore_empty and not this.empty(value)))
            then
                result[key] = result[key] or {}
                assert(type(result[key]) == "table", string.format("Expected a table: '%s'", key))
                result[key] = this.merge2(protected, ignore_empty, result[key], value)
            else
                result[key] = value
            end
            ::continue::
        end
    end

    return result
end

---@generic T: table
---@param protected string[]?
---@param ignore_empty boolean?
---@param ... T
---@return T
function this.merge2_t(protected, ignore_empty, ...)
    return this.merge2(protected, ignore_empty, ...)
end

---@generic K, V, R
---@param t table<K,  V>
---@param value_getter (fun(o: V): R)?
---@return R|V[]
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

---@generic K, V
---@param t table<K, V>
---@return K[]
function this.keys(t)
    local ret = {}
    for key, _ in pairs(t) do
        table.insert(ret, key)
    end
    return ret
end

---@generic T
---@param t T[]
---@param value T | fun(o: T): boolean
---@return integer?
function this.index(t, value)
    local is_fn = type(value) == "function"

    for i, v in pairs(t) do
        if (is_fn and value(v)) or v == value then
            return i
        end
    end
end

---@generic T: table
---@param t T[]
---@param key (fun(o: T): any)?
---@param ... T[]
---@return T[]
function this.unique(t, key, ...)
    local tables = { t, ... }
    local ret = {}
    for _, tbl in pairs(tables) do
        for _, value in pairs(tbl) do
            if key then
                ret[key(value)] = value
            else
                ret[value] = 1
            end
        end
    end

    if key then
        return this.values(ret)
    end

    return this.keys(ret)
end

---@generic T: table
---@param t T
---@param keys any[]
---@param value any
---@return T
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

---@generic T: table
---@param t T
---@param keys any[]
---@param value any
---@return T
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
    local ret = arrays_to_merge[1]
    for i = 2, #arrays_to_merge do
        local t = arrays_to_merge[i]
        table.move(t, 1, #t, #ret + 1, ret)
    end
    return ret
end

---@generic T
---@param ... T[]
---@return T[]
function this.array_merge_t(...)
    return this.array_merge(...)
end

---@param ... any[]
---@return any[]
function this.array_merge_copy(...)
    local arrays_to_merge = { ... }
    local ret = this.deep_copy(arrays_to_merge[1])
    for i = 2, #arrays_to_merge do
        local t = arrays_to_merge[i]
        table.move(t, 1, #t, #ret + 1, ret)
    end
    return ret
end

---@generic T
---@param ... T[]
---@return T[]
function this.array_merge_copy_t(...)
    return this.array_merge_copy(...)
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

---@generic K, V
---@param t table<K, V>
---@param predicate fun(o: V) : boolean
---@return boolean
function this.all(t, predicate)
    for _, value in pairs(t) do
        if not predicate(value) then
            return false
        end
    end
    return true
end

---@generic K, V
---@param t table<K, V>
---@param predicate (fun(key: K, value: V) : boolean)?
---@return boolean
function this.any(t, predicate)
    for key, value in pairs(t) do
        if (predicate and predicate(key, value)) or (not predicate and value == true) then
            return true
        end
    end
    return false
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

---@generic K, V
---@param t table<K, V>
---@param key (fun(o: K): any)?
---@param value (fun(o: V): any)?
---@return table<any, any>
function this.map_table(t, key, value)
    local ret = {}
    for k, v in pairs(t) do
        ret[key and key(k) or k] = value and value(v) or v
    end
    return ret
end

---@param t table
---@return integer
function this.size(t)
    local ret = 0
    for _, _ in pairs(t) do
        ret = ret + 1
    end
    return ret
end

---@generic K, V
---@param t table<K, V>
---@param key K | fun(key: K, value: V): boolean
---@return V?
function this.pop_item(t, key)
    local is_fn = type(key) == "function"

    for k, v in pairs(t) do
        if (is_fn and key(k, v)) or k == key then
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
---@param sort_func (fun(a: T, b: T): boolean)?
---@return T[]
function this.sort(t, sort_func)
    table.sort(t, sort_func)
    return t
end

---@generic K, V
---@param t table<K, V>
---@param predicate fun(key: K, value: V): boolean
---@return V?
function this.value(t, predicate)
    for k, v in pairs(t) do
        if predicate(k, v) then
            return v
        end
    end
end

---@generic K, V
---@param t table<K, V>
---@param predicate fun(key: K, value: V): boolean
---@return K?
function this.key(t, predicate)
    for k, v in pairs(t) do
        if predicate(k, v) then
            return k
        end
    end
end

---@generic K, V
---@param t table<K, V>
---@param func fun(t: table<K, V>, key: K, value: V): boolean?
---@return boolean
function this.do_something(t, func)
    for k, v in pairs(t) do
        if func(t, k, v) == false then
            return false
        end
    end
    return true
end

---@param t table
---@param indent integer?
---@param visited table<table, boolean>?
function this.print(t, indent, visited)
    indent = indent or 2
    visited = visited or {}
    local spacing = string.rep("  ", indent)

    if visited[t] then
        print(spacing .. "[Circular Ref]")
        return
    end

    visited[t] = true
    for k, v in pairs(t) do
        local key = tostring(k)
        if type(v) == "table" then
            print(spacing .. key .. " = {")
            this.print(v, indent + 1, visited)
            print(spacing .. "}")
        elseif type(v) == "string" then
            print(spacing .. key .. ' = "' .. v .. '"')
        else
            print(spacing .. key .. " = " .. tostring(v))
        end
    end

    visited[t] = nil
end

---@generic T
---@param t T[]
---@param n integer
---@return T[][]
function this.chunks(t, n)
    local ret = {}
    local chunk = {}
    local size = #t

    for i = 1, size do
        table.insert(chunk, t[i])
        if #chunk == n or i == size then
            table.insert(ret, chunk)
            chunk = {}
        end
    end

    return ret
end

---@generic K, V, R
---@param t table<K, V>
---@param splitter fun(t: table<K, V>, key: K, value: V): R
---@return {[R]: {[K]: V}}
function this.split(t, splitter)
    local ret = {}
    for k, v in pairs(t) do
        local key = splitter(t, k, v)
        this.insert_nested_value(ret, { key, k }, v)
    end

    return ret
end

---@generic K, V
---@param t table<K, V>
---@param predicate fun(key: K, value: V): boolean
---@return table<K, V>
function this.filter(t, predicate)
    local ret = {}
    for k, v in pairs(t) do
        if predicate(k, v) then
            ret[k] = v
        end
    end

    return ret
end

---@param key string
---@return string | integer
function this.parse_key(key)
    local pattern = "^int:(%d+)$"
    if string.match(key, pattern) then
        return tonumber(string.match(key, pattern)) --[[@as integer]]
    end
    return key
end

---@param key string
---@return string[]
function this.split_key(key)
    local ret = {}
    for i in string.gmatch(key, "([^%.]+)") do
        table.insert(ret, i)
    end
    return ret
end

---@param t table
---@param key string
---@return any
function this.get_by_key(t, key)
    local ret = t
    if not key:find(".") then
        return ret[this.parse_key(key)]
    end

    local keys = this.split_key(key)
    for i = 1, #keys do
        if not ret then
            return
        end
        ret = ret[this.parse_key(keys[i])] --[[@as any]]
    end
    return ret
end

---@param t table
---@param key string
---@param value any
function this.set_by_key(t, key, value)
    if not key:find(".") then
        ---@diagnostic disable-next-line: no-unknown
        t[this.parse_key(key)] = value
        return
    end

    local keys = this.split_key(key)
    for i = 1, #keys do
        ---@diagnostic disable-next-line: assign-type-mismatch
        keys[i] = this.parse_key(keys[i])
    end
    this.set_nested_value(t, keys, value)
end

---@generic T
---@param t T[]
---@param ... T
---@return T
function this.insert_front(t, ...)
    local values = { ... }
    for i = #values, 1, -1 do
        table.insert(t, 1, values[i])
    end
    return t
end

---@generic T
---@param t T[]?
---@return T?
function this.normalize(t)
    if type(t) == "table" then
        return t[1]
    end
    return t
end

---@generic T
---@param t table<integer, T>
---@return table<T, integer>
function this.array_to_map(t)
    local ret = {}
    for k, v in pairs(t) do
        ret[v] = k
    end
    return ret
end

---@param t table
---@return string
function this.to_string(t)
    if type(t) == "table" then
        local parts = {}
        for i, v in ipairs(t) do
            parts[i] = this.to_string(v)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif type(t) == "string" then
        return '"' .. t .. '"'
    else
        return tostring(t)
    end
end

return this
