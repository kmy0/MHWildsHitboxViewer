local this = {}

this.getEnemyNameGuid = sdk.find_type_definition("app.EnemyDef"):get_method("EnemyName(app.EnemyDef.ID)") --[[@as REMethodDefinition]]
this.getNpcName = sdk.find_type_definition("app.NpcUtil"):get_method("getNpcName(app.NpcDef.ID)") --[[@as REMethodDefinition]]
this.getMessage = sdk.find_type_definition("via.gui.message"):get_method("get(System.Guid)") --[[@as REMethodDefinition]]
this.getMessageLocal = sdk.find_type_definition("via.gui.message"):get_method("get(System.Guid, via.Language)") --[[@as REMethodDefinition]]
this.EmPartsName = sdk.find_type_definition("app.EnemyDef"):get_method("EmPartsName(app.EnemyDef.PARTS_TYPE)") --[[@as REMethodDefinition]]
this.isCollidableValid = sdk.find_type_definition("ace.AceUtil"):get_method("isCollidableValid(via.physics.Collidable)") --[[@as REMethodDefinition]]

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
---@return any | nil
function this.get_component(game_object, type_name)
    local t = sdk.typeof(type_name)

    if t == nil then
        return nil
    end

    return game_object:call("getComponent(System.Type)", t)
end

return this
