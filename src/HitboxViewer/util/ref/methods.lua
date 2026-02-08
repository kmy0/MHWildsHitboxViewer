---@class (partial) MethodUtil
---@field methods table<string, REMethodDefinition>

local types = require("HitboxViewer.util.ref.types")
local util_misc = require("HitboxViewer.util.misc.init")
local util_ref = require("HitboxViewer.util.ref.util")
local logger = require("HitboxViewer.util.misc.logger").g

---@class MethodUtil
local this = {
    methods = {},
}

---@param name string
---@return REMethodDefinition
function this.get(name)
    local type_def, method = util_ref.split_type_def(name)
    local ret = types.get(type_def):get_method(method) --[[@as REMethodDefinition]]

    if not ret then
        logger:error(string.format('Failed to get "%s" method from "%s" type.', method, type_def))
    end

    return ret
end

---@param type_def RETypeDefinition | string
---@param regex string
---@return REMethodDefinition?
function this.get_by_regex(type_def, regex)
    if type(type_def) == "string" then
        type_def = sdk.find_type_definition(type_def) --[[@as RETypeDefinition]]
    end

    local methods = type_def:get_methods()

    for _, m in pairs(methods) do
        local name = m:get_name()
        if string.match(name, regex) then
            return m
        end
    end

    logger:error(
        string.format('Failed to get method with "%s" regex from "%s" type.', regex, type_def)
    )
end

---@param type_def RETypeDefinition | string
---@param name string
---@return REMethodDefinition
function this.t_get(type_def, name)
    ---@type string
    local type_name
    if type(type_def) == "string" then
        type_name = type_def
        type_def = types.get(type_name)
    else
        type_name = type_def:get_full_name()
    end
    ---@cast type_def RETypeDefinition

    local key = string.format("%s.%s", type_name, name)
    if not this.methods[key] then
        this.methods[key] = type_def:get_method(name)
    end

    if not this.methods[key] then
        logger:error(string.format('Failed to get "%s" method from "%s" type.', name, type_name))
    end

    return this.methods[key]
end

---@param method REMethodDefinition
---@return fun(...): any
function this.wrap(method)
    return function(...)
        return method:call(nil, ...)
    end
end

---@param method REMethodDefinition
---@return fun(...): any
function this.wrap_obj(method)
    return function(...)
        return method:call(...)
    end
end

---@param method string | REMethodDefinition
---@param pre_cb (fun(args?: userdata[]): PreHookResult?)?
---@param post_cb (fun(retval?: userdata): any?)?
---@param ignore_jmp_object? boolean
function this.hook(method, pre_cb, post_cb, ignore_jmp_object)
    if not pre_cb and not post_cb then
        ---@diagnostic disable-next-line: param-type-mismatch
        local method_name = type(method) == "string" and method or method:get_name()
        logger:error("No callbacks: " .. method_name)
    end

    util_misc.try(function()
        sdk.hook(
            ---@diagnostic disable-next-line: param-type-mismatch
            type(method) == "string" and this.get(method) or method,
            pre_cb or function(_) end,
            post_cb and util_ref.hook_ret(post_cb) or nil,
            ignore_jmp_object
        )
    end, function(err)
        ---@diagnostic disable-next-line: param-type-mismatch
        local method_name = type(method) == "string" and method or method:get_name()
        logger:error(string.format("Failed to hook %s: %s", method_name, err))
    end)
end

return this
