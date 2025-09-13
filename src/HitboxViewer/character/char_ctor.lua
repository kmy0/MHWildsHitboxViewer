---@class (exact) FriendCharacter : Character
---@class (exact) Pet : FriendCharacter
---@class (exact) Npc : FriendCharacter
---@class (exact) MasterPlayer : Player

---@class (exact) EnemyCharacter : Character
---@class (exact) SmallEnemy : EnemyCharacter

local bigenemy = require("HitboxViewer.character.big_enemy")
local char_base_ = require("HitboxViewer.character.char_base")
local data = require("HitboxViewer.data.init")
local player = require("HitboxViewer.character.player")
local util = require("HitboxViewer._util")

local gui = data.gui
local mod = data.mod

local this = {}

---@param hunter_extend app.HunterCharacter.cHunterExtendNpc
---@return app.NpcDef.ID
local function get_npc_id(hunter_extend)
    local ctx_holder = hunter_extend._ContextHolder
    return ctx_holder:get_Npc().NpcID
end

---@param hunter_extend app.HunterCharacter.cHunterExtendBase
---@return System.String
local function get_hunter_name(hunter_extend)
    if hunter_extend:get_IsNpc() then
        ---@cast hunter_extend app.HunterCharacter.cHunterExtendNpc
        local id = get_npc_id(hunter_extend)
        return util.getNpcName:call(nil, id) or gui.name_missing
    end
    ---@cast hunter_extend app.HunterCharacter.cHunterExtendPlayer
    local ctx_holder = hunter_extend._ContextHolder
    return ctx_holder:get_Pl():get_PlayerName() or gui.name_missing
end

---@param char_base app.HunterCharacter
---@return Player | Npc
local function get_hunter_data(char_base)
    local hunter_extend = char_base:get_HunterExtend()
    local type = hunter_extend:get_IsNpc() and mod.enum.char.Npc
        or (char_base:get_IsMaster() and mod.enum.char.MasterPlayer or mod.enum.char.Player)

    if type == mod.enum.char.Npc then
        ---@type Npc
        return char_base_:new(type, char_base, get_hunter_name(hunter_extend))
    end
    return player:new(type, char_base, get_hunter_name(hunter_extend))
end

---@param char_base app.OtomoCharacter
---@return Pet?
local function get_pet_data(char_base)
    local owner = char_base:get_OwnerHunterCharacter()

    if not owner then
        return
    end

    local hunter_extend = owner:get_HunterExtend()
    local ret =
        char_base_:new(mod.enum.char.Pet, char_base, get_hunter_name(hunter_extend) .. " - Pet")
    ---@type Pet
    return ret
end

---@param base_char_type BaseCharType
---@param char_base app.EnemyBossCharacter | app.EnemyZakoCharacter
---@return SmallEnemy | BigEnemy
local function get_enemy_data(base_char_type, char_base)
    local holder = char_base._Context
    local ctx = holder:get_Em()
    local name = util.get_message_local(
        util.getEnemyNameGuid:call(nil, ctx:get_EmID()),
        util.get_language(),
        true
    ) or gui.name_missing
    if base_char_type == mod.enum.base_char.BigMonster then
        ---@cast char_base app.EnemyBossCharacter
        return bigenemy:new(char_base, name, ctx)
    end
    ---@type SmallEnemy
    return char_base_:new(mod.enum.char.SmallMonster, char_base, name)
end

---@param base_char_type BaseCharType
---@param char_base app.CharacterBase
---@return Character?
function this.get_character(base_char_type, char_base)
    if base_char_type == mod.enum.base_char.Hunter then
        ---@cast char_base app.HunterCharacter
        return get_hunter_data(char_base)
    end

    if base_char_type == mod.enum.base_char.Pet then
        ---@cast char_base app.OtomoCharacter
        return get_pet_data(char_base)
    end

    if
        base_char_type == mod.enum.base_char.BigMonster
        or base_char_type == mod.enum.base_char.SmallMonster
    then
        ---@cast char_base app.EnemyBossCharacter|app.EnemyZakoCharacter
        return get_enemy_data(base_char_type, char_base)
    end
end

return this
