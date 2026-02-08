local s = require("HitboxViewer.util.ref.singletons")
---@class MethodUtil
local m = require("HitboxViewer.util.ref.methods")
local util_misc = require("HitboxViewer.util.misc.init")
local util_ref = require("HitboxViewer.util.ref.init")

local cache = util_misc.cache
local frame_cache = util_misc.frame_cache

local this = {}

---@return System.Single
function this.get_time_delta()
    return s.get_native("via.Application"):get_DeltaTime() / 60
end

---@return via.Scene
function this.get_scene()
    return s.get_native("via.SceneManager"):get_CurrentScene()
end

---@return via.SceneView
function this.get_main_view()
    return s.get_native("via.SceneManager"):get_MainView()
end

---@return {x: number, y:number}
function this.get_screen_size()
    local size = this.get_main_view():get_WindowSize()
    return { x = size.w, y = size.h }
end

---@return {x: number, y:number}
function this.get_screen_center()
    local size = this.get_screen_size()
    size.x = size.x / 2
    size.y = size.y / 2
    return size
end

---@param guid System.Guid
---@return string
function this.format_guid(guid)
    return string.format(
        "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
        guid.mData1,
        guid.mData2,
        guid.mData3,
        guid.mData4_0,
        guid.mData4_1,
        guid.mData4_2,
        guid.mData4_3,
        guid.mData4_4,
        guid.mData4_5,
        guid.mData4_6,
        guid.mData4_7
    )
end

---@generic T
---@param type `T`?
---@return System.Array<T>
function this.get_all_components(type)
    if not type then
        type = "via.Transform"
    end
    return this.get_scene():call("findComponents(System.Type)", sdk.typeof(type))
end

---@generic T
---@param type `T`
---@return T?
function this.get_component_any(type)
    local arr = this.get_scene():call("findComponents(System.Type)", sdk.typeof(type))
    if arr:get_Count() > 0 then
        return arr:get_Item(0)
    end
end

---@generic T
---@param game_object via.GameObject
---@param type_name `T`
---@return T?
function this.get_component(game_object, type_name)
    local t = sdk.typeof(type_name)

    if not t then
        return
    end

    return game_object:call("getComponent(System.Type)", t)
end

---@param game_object via.GameObject
---@param type_name string
---@return System.Array<REManagedObject>?
function this.get_components(game_object, type_name)
    local t = sdk.typeof(type_name)

    if not t then
        return
    end

    return game_object:call("findComponents(System.Type)", t)
end

---@generic T
---@param system_array System.Array<T>
---@return T[]
function this.system_array_to_lua(system_array)
    local ret = {}
    local enum = this.get_array_enum(system_array)

    while enum:MoveNext() do
        table.insert(ret, enum:get_Current())
    end
    return ret
end

---@generic T
---@param lua_array T[]
---@param type_name `T`
---@return System.Array<T>
function this.lua_array_to_system_array(lua_array, type_name)
    local ret = sdk.create_managed_array(type_name, #lua_array):add_ref() --[[@as System.Array]]
    for i = 0, #lua_array - 1 do
        ret:set_Item(i, lua_array[i + 1])
    end
    return ret
end

---@generic T
---@param array System.Array<T>
---@return System.ArrayEnumerator<T>
function this.get_array_enum(array)
    ---@type System.ArrayEnumerator
    local enum
    local arr = array

    util_misc.try(function()
        arr = array:ToArray()
    end)

    if not util_misc.try(function()
        enum = arr:GetEnumerator()
    end) then
        enum = util_ref.ctor("System.ArrayEnumerator", true)
        enum:call(".ctor", arr)
    end
    return enum
end

---@generic T
---@param system_array T[]
---@param something fun(system_array: System.Array<T>, index: integer, value: T): boolean?
---@param reverse boolean?
function this.do_something(system_array, something, reverse)
    ---@diagnostic disable-next-line: undefined-field, no-unknown
    local size = system_array:get_Count() - 1
    if reverse then
        for i = size, 0, -1 do
            ---@diagnostic disable-next-line: undefined-field
            if something(system_array, i, system_array:get_Item(i)) == false then
                break
            end
        end
    else
        for i = 0, size do
            ---@diagnostic disable-next-line: undefined-field
            if something(system_array, i, system_array:get_Item(i)) == false then
                break
            end
        end
    end
end

---@generic T
---@param type `T`
---@return T?
function this.get_component_any_cached(type)
    return this.get_component_any(type)
end

---@return via.Transform
function this.get_camera()
    local main_view = this.get_main_view()
    local camera = main_view:get_PrimaryCamera()
    local game_object = camera:get_GameObject()
    return game_object:get_Transform()
end

---@return Vector3f
function this.get_camera_origin()
    return this.get_camera():get_Position()
end

---@param type_def_name string
---@param predicate (fun(key: string, value: any): boolean)?
---@return table<string, any>
function this.get_fields(type_def_name, predicate)
    ---@type table<string, any>
    local ret = {}
    local type_def = util_ref.types.get(type_def_name)
    if not type_def then
        return ret
    end

    local bad_keys = { max = 1, value__ = 1, invalid = 1 }
    local fields = type_def:get_fields()
    for _, field in pairs(fields) do
        local name = field:get_name()
        local name_lower = string.lower(name)
        local data = field:get_data()

        if bad_keys[name_lower] or (predicate and not predicate(name, data)) then
            goto continue
        end

        ret[name] = data
        ::continue::
    end

    return ret
end

this.get_component_any_cached = cache.memoize(this.get_component_any_cached)
this.get_camera = cache.memoize(this.get_camera)
this.get_camera_origin = frame_cache.memoize(this.get_camera_origin)

return this
