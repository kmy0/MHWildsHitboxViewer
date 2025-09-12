---@class Characters
---@field master_player MasterPlayer?
---@field by_gameobject table<via.GameObject, Character>
---@field by_type_by_gameobject table<CharType, table<via.GameObject, Character>>

local char_cls = require("HitboxViewer.character.char_base")
local char_ctor = require("HitboxViewer.character.char_ctor")
local col_queue = require("HitboxViewer.box.load_queue")
local data = require("HitboxViewer.data.init")
local s = require("HitboxViewer.util.ref.singletons")
local util_game = require("HitboxViewer.util.game.init")
local util_ref = require("HitboxViewer.util.ref.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod = data.mod
local ace = data.ace

---@class Characters
local this = {
    master_player = nil,
    by_gameobject = {},
    by_type_by_gameobject = {},
}

function this.clear()
    this.by_gameobject = {}
    this.by_type_by_gameobject = {}
    this.master_player = nil
end

---@param char_type CharType
function this.is_empty(char_type)
    return not this.by_type_by_gameobject[char_type]
        or util_table.empty(this.by_type_by_gameobject[char_type])
end

---@param char Character
function this.remove(char)
    this.by_gameobject[char.game_object] = nil
    this.by_type_by_gameobject[char.type][char.game_object] = nil
end

---@param game_object via.GameObject
---@param char_base app.CharacterBase?
---@return Character?
function this.get_char(game_object, char_base)
    if this.by_gameobject[game_object] then
        return this.by_gameobject[game_object]
    end

    if not char_base then
        char_base = util_game.get_component(game_object, "app.CharacterBase") --[[@as app.CharacterBase?]]
    end

    if not char_base or not char_base:get_Started() or not char_cls:is_valid(char_base) then
        return
    end

    local rsc = util_game.get_component(game_object, "via.physics.RequestSetCollider") --[[@as via.physics.RequestSetCollider?]]
    if not rsc then
        return
    end

    local base_char_type = mod.enum.base_char[ace.map.char_type_to_name[util_ref.whoami(char_base)]]
    if base_char_type then
        local o = char_ctor.get_character(base_char_type, char_base)
        if o then
            this.by_gameobject[game_object] = o
            util_table.set_nested_value(this.by_type_by_gameobject, { o.type, game_object }, o)
            col_queue:push_back({ char = o, rsc = rsc })
            return o
        end
    end
end

---@return MasterPlayer?
function this.get_master_player()
    if not this.master_player or not char_cls:is_valid(this.master_player.base) then
        local playman = s.get("app.PlayerManager")
        if not playman then
            return
        end

        local player_info = playman:getMasterPlayer()
        if player_info then
            local hunter_char = player_info:get_Character()
            local game_object = hunter_char:get_GameObject()
            local ret = this.get_char(game_object, hunter_char)
            ---@cast ret MasterPlayer?
            this.master_player = ret
        end
    end
    return this.master_player
end

return this
