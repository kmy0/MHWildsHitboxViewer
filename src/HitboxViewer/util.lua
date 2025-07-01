local this = {}

local msg_id = {
    extract_pattern = "<REF (.-)>",
    strip_pattern = "(<REF.->)",
    bad_pattern = "#Rejected#",
}

this.getEnemyNameGuid = sdk.find_type_definition("app.EnemyDef"):get_method("EnemyName(app.EnemyDef.ID)") --[[@as REMethodDefinition]]
this.getNpcName = sdk.find_type_definition("app.NpcUtil"):get_method("getNpcName(app.NpcDef.ID)") --[[@as REMethodDefinition]]
this.getMessage = sdk.find_type_definition("via.gui.message"):get_method("get(System.Guid)") --[[@as REMethodDefinition]]
this.getMessageLocal = sdk.find_type_definition("via.gui.message"):get_method("get(System.Guid, via.Language)") --[[@as REMethodDefinition]]
this.EmPartsName = sdk.find_type_definition("app.EnemyDef"):get_method("EmPartsName(app.EnemyDef.PARTS_TYPE)") --[[@as REMethodDefinition]]
this.calcCollidableCenter = sdk.find_type_definition("app.CollisionUtil")
    :get_method("calcCollidableCenter(via.physics.Collidable)") --[[@as REMethodDefinition]]
this.getPARTS_TYPEFromFixed = sdk.find_type_definition("app.EnemyDef"):get_method(
    "getPARTS_TYPEFromFixed(app.EnemyDef.PARTS_TYPE_Fixed, app.EnemyDef.PARTS_TYPE)"
) --[[@as REMethodDefinition]]
this.isCollidableValid = sdk.find_type_definition("ace.AceUtil"):get_method("isCollidableValid(via.physics.Collidable)") --[[@as REMethodDefinition]]

---@generic T
---@param array System.Array<T>
---@return System.ArrayEnumerator<T>
function this.get_array_enum(array)
    local enum
    local success, arr = pcall(function()
        return array:ToArray()
    end)

    if not success then
        arr = array
    end

    success, enum = pcall(function()
        return arr:GetEnumerator()
    end)

    if not success then
        enum = sdk.create_instance("System.ArrayEnumerator", true) --[[@as System.ArrayEnumerator]]
        enum:call(".ctor", arr)
    end
    return enum
end

---@param part_fixed app.EnemyDef.PARTS_TYPE_Fixed
---@return app.EnemyDef.PARTS_TYPE
function this.get_part_type(part_fixed)
    local o = ValueType.new(sdk.find_type_definition("app.EnemyDef.PARTS_TYPE") --[[@as RETypeDefinition]])
    this.getPARTS_TYPEFromFixed:call(nil, part_fixed, o)
    return o:get_field("value__")
end

---@param obj REManagedObject
---@return boolean
function this.is_only_my_ref(obj)
    if obj:read_qword(0x8) <= 0 then
        return true
    end
    local gameobject_addr = obj:read_qword(0x10)
    if gameobject_addr == 0 then
        return true
    end
    return false
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

---@param game_object via.GameObject
---@param type_name string
---@return REManagedObject?
function this.get_component(game_object, type_name)
    local t = sdk.typeof(type_name)

    if not t then
        return
    end

    return game_object:call("getComponent(System.Type)", t)
end

---@return via.Scene
function this.get_scene()
    return sdk.call_native_func(
        sdk.get_native_singleton("via.SceneManager"),
        sdk.find_type_definition("via.SceneManager") --[[@as RETypeDefinition]],
        "get_CurrentScene()"
    )
end

---@param type string?
---@return System.Array<REManagedObject>
function this.get_all_components(type)
    if not type then
        type = "via.Transform"
    end
    return this.get_scene():call("findComponents(System.Type)", sdk.typeof(type))
end

---@return via.Language
function this.get_language()
    return sdk.call_native_func(
        sdk.get_native_singleton("via.gui.GUISystem"),
        sdk.find_type_definition("via.gui.GUISystem") --[[@as RETypeDefinition]],
        "get_MessageLanguage()"
    )
end

---@param guid_name string
---@param lang via.Language
---@param fallback boolean?
---@return string
function this.get_message_local_from_name(guid_name, lang, fallback)
    local msg_guid = this.getGuidByName:call(nil, guid_name) --[[@as System.Guid]]
    return this.get_message_local(msg_guid, lang, fallback)
end

---@param guid System.Guid
---@param lang via.Language
---@param fallback boolean?
---@return string
function this.get_message_local(guid, lang, fallback)
    local parts = {}
    local msg = this.getMessageLocal:call(nil, guid, lang)
    ---@cast msg string
    for match in msg:gmatch(msg_id.extract_pattern) do
        local part = this.get_message_local_from_name(match, lang, fallback)
        if part:len() > 0 then
            table.insert(parts, part)
        end
    end

    msg = msg:gsub(msg_id.strip_pattern, "")
    table.insert(parts, msg)
    msg = table.concat(parts, " "):gsub("^%s*(.-)%s*$", "%1")

    if msg:len() == 0 and fallback then
        return this.get_message_local(guid, 1)
    elseif msg:match(msg_id.bad_pattern) then
        return ""
    end
    return msg
end

---@generic T
---@param system_array System.Array<T>
---@return T[]
function this.system_array_to_lua(system_array)
    local ret = {}
    local enum = this.get_array_enum(system_array)

    while enum:MoveNext() do
        local o = enum:get_Current()
        table.insert(ret, o)
    end
    return ret
end

---@param s string
---@param sep string?
---@return string[]
function this.split_string(s, sep)
    if not sep then
        sep = "%s"
    end

    local ret = {}
    for i in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(ret, i)
    end
    return ret
end

---@param char app.CharacterBase?
---@return boolean
function this.is_char_valid(char)
    local ok, ret = pcall(function()
        if char then
            return char:get_Valid()
        end
        return false
    end)

    if not ok then
        return false
    end

    return ret
end

return this
