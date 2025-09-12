local this = {}

---@param ptr integer
---@return integer
function this.deref_ptr(ptr)
    local fake_int64 = sdk.to_valuetype(ptr, "System.UInt64")
    ---@cast fake_int64 ValueType
    local deref = fake_int64:get_field("m_value")

    return deref
end

---@param obj REManagedObject
function this.print_fields(obj)
    ---@type RETypeDefinition[]
    local types = {}
    local def = obj:get_type_definition()

    while def do
        table.insert(types, def)
        def = def:get_parent_type()
    end

    ---@type {type: string, data: {name: string, data: any}[]}[]
    local res = {}
    for i = 1, #types do
        local type = types[i]
        local fields = type:get_fields()
        local data = { type = type:get_full_name(), data = {} }

        for j = 1, #fields do
            local field = fields[j]
            table.insert(data.data, { name = field:get_name(), data = field:get_data(obj) })
        end

        table.insert(res, data)
    end

    local max_len = 0
    for _, t in pairs(res) do
        for _, d in pairs(t.data) do
            max_len = math.max(max_len, #d.name)
        end
    end

    print(obj)
    for i = 1, #res do
        local type = res[i]
        print(type.type)
        print(string.rep("_", max_len))

        for j = 1, #type.data do
            local data = type.data[j]
            print(
                string.format(
                    "%s: %s",
                    data.name .. string.rep(" ", max_len - #data.name),
                    data.data
                )
            )
        end
    end
    print("\n")
end

---@generic T
---@param name `T`
---@param simplify_obj boolean?
---@return T
function this.ctor(name, simplify_obj)
    return sdk.create_instance(name, simplify_obj)
end

---@generic T
---@param name `T`
---@return T
function this.value_type(name)
    return ValueType.new(sdk.find_type_definition(name) --[[@as RETypeDefinition]])
end

---@param obj REManagedObject
---@return string
function this.whoami(obj)
    return obj:get_type_definition():get_full_name()
end

---@param obj REManagedObject
---@param type string
---@return boolean
function this.is_a(obj, type)
    local obj_type = obj:get_type_definition() --[[@as RETypeDefinition]]
    return obj_type:is_a(type)
end

---@param obj REManagedObject
---@param ... string
---@return string?
function this.is_any(obj, ...)
    local t = { ... }
    for i = 1, #t do
        if this.is_a(obj, t[i]) then
            return t[i]
        end
    end
end

---@param args userdata[]
---@param index integer?
function this.capture_this(args, index)
    index = index or 2
    ---@diagnostic disable-next-line: no-unknown
    thread.get_hook_storage()["this"] = args[index]
end

---@return REManagedObject?
function this.get_this()
    local userdata = thread.get_hook_storage()["this"] --[[@as userdata]]
    if not userdata then
        return
    end
    return sdk.to_managed_object(userdata)
end

---@param name string
---@return string, string
function this.split_type_def(name)
    local paren_pos = name:find("%(")
    local search_end = paren_pos and (paren_pos - 1) or #name

    for i = search_end, 1, -1 do
        if name:sub(i, i) == "." then
            return name:sub(1, i - 1), name:sub(i + 1)
        end
    end

    return name, ""
end

---@param f fun(retval: userdata): any
---@return fun(retval: userdata): userdata
function this.hook_ret(f)
    return function(retval)
        local ret = f(retval)
        if ret ~= nil then
            return sdk.to_ptr(ret)
        end

        return retval
    end
end

---@param ptr userdata
---@return boolean
function this.to_bool(ptr)
    return sdk.to_int64(ptr) & 1 == 1
end

---@param ptr userdata
---@return integer
function this.to_byte(ptr)
    return sdk.to_int64(ptr) & 0xff
end

---@param ptr userdata
---@return integer
function this.to_short(ptr)
    return sdk.to_int64(ptr) & 0xffff
end

---@param ptr userdata
---@return integer
function this.to_int(ptr)
    return sdk.to_int64(ptr) & 0xfffffff
end

return this
