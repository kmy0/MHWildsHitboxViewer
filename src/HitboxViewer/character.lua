---@class (exact) Character
---@field type CharType
---@field base app.CharacterBase
---@field distance number
---@field name string
---@field id integer
---@field hurtboxes Hurtbox[]
---@field hitboxes table<via.physics.Collidable, Hitbox>
---@field hitbox_userdata_cache table<app.col_user_data.AttackParam , AttackLogEntry>
---@field order integer

---@class (exact) Pet : Character
---@class (exact) Npc : Character
---@class (exact) Player : Character
---@field is_master boolean

---@class (exact) MasterPlayer : Player
---@field pos Vector3f
---@field get_pos fun(self: MasterPlayer): Vector3f

---@class (exact) EnemyCharacter : Character
---@field ctx app.cEnemyContext

---@class (exact) SmallEnemy : EnemyCharacter
---@class (exact) BigEnemy : EnemyCharacter
---@field parts table<string, PartGroup>
---@field mc_holder app.EnemyCharacter.MINI_COMPONENT_HOLDER
---@field browser app.cEnemyBrowser

---@class CharLoadData
---@field game_object via.GameObject?
---@field char_base app.CharacterBase
---@field tick integer

---@alias Enemy BigEnemy | SmallEnemy
---@alias Friend Player | Pet | Npc | MasterPlayer
---@alias CharObj Friend | Enemy

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local hbdraw = require("HitboxViewer.hb_draw")
local utilities = require("HitboxViewer.utilities")
---@module "HitboxViewer.hurtboxes"
local hurtboxes
---@module "HitboxViewer.hitboxes"
local hitboxes
---@module "HitboxViewer.gui.menu"
local config_menu

---@class CharController
local this = {
    ---@type MasterPlayer?
    master_player = nil,
    ---@type table<via.GameObject, CharObj>
    characters = {},
    ---@type table<CharType, table<via.GameObject, CharObj>>
    characters_grouped = {},
    ---@type CharLoadData[]
    load_queue = {},
}

---@param self MasterPlayer
---@return Vector3f
local function get_pos(self)
    self.pos = self.base:get_Pos()
    return self.pos
end

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
        return utilities.getNpcName:call(nil, id) or data.name_missing
    end
    ---@cast hunter_extend app.HunterCharacter.cHunterExtendPlayer
    local ctx_holder = hunter_extend._ContextHolder
    return ctx_holder:get_Pl():get_PlayerName() or data.name_missing
end

---@param char_base app.HunterCharacter
---@return (Player | Npc)?
local function get_hunter_data(char_base)
    local hunter_extend = char_base:get_HunterExtend()
    if hunter_extend:get_IsNpc() then
        if hunter_extend:get_IsNpc() then
            ---@cast hunter_extend app.HunterCharacter.cHunterExtendNpc
            ---@type Npc
            return {
                type = data.char_enum.Npc,
                base = char_base,
                distance = 0,
                name = get_hunter_name(hunter_extend),
                id = char_base:get_address(),
                hurtboxes = {},
                hitboxes = {},
                hitbox_userdata_cache = {},
                order = #this.characters,
            }
        end
    end
    ---@cast hunter_extend app.HunterCharacter.cHunterExtendPlayer
    ---@type Player
    local ret = {
        type = data.char_enum.Player,
        base = char_base,
        is_master = char_base:get_IsMaster(),
        distance = 0,
        name = get_hunter_name(hunter_extend),
        id = char_base:get_address(),
        hurtboxes = {},
        hitboxes = {},
        hitbox_userdata_cache = {},
        order = #this.characters,
    }
    if ret.is_master then
        ---@cast ret MasterPlayer
        ret.type = data.char_enum.MasterPlayer
        ret.get_pos = get_pos
        ret.pos = ret:get_pos()
    end
    return ret
end

---@param char_base app.OtomoCharacter
---@return Pet?
local function get_pet_data(char_base)
    local owner = char_base:get_OwnerHunterCharacter()
    if not owner then
        return
    end
    local hunter_extend = owner:get_HunterExtend()
    ---@type Pet
    return {
        type = data.char_enum.Pet,
        base = char_base,
        distance = 0,
        name = get_hunter_name(hunter_extend) .. " - Pet",
        id = char_base:get_address(),
        hurtboxes = {},
        hitboxes = {},
        hitbox_userdata_cache = {},
        order = #this.characters,
    }
end

---@param base_char_type BaseCharType
---@param char_base app.EnemyBossCharacter|app.EnemyZakoCharacter
---@return Enemy?
local function get_enemy_data(base_char_type, char_base)
    local holder = char_base._Context
    local ctx = holder:get_Em()
    if base_char_type == data.base_char_enum.BigMonster then
        ---@cast char_base app.EnemyBossCharacter
        ---@type BigEnemy
        return {
            type = data.char_enum.BigMonster,
            base = char_base,
            distance = 0,
            ctx = ctx,
            name = utilities.getMessageLocal:call(
                nil,
                utilities.getEnemyNameGuid:call(nil, ctx:get_EmID()),
                data.get_language()
            ) or data.name_missing,
            id = char_base:get_address(),
            parts = {},
            hurtboxes = {},
            hitboxes = {},
            hitbox_userdata_cache = {},
            order = #this.characters,
            mc_holder = char_base._MiniComponentHolder,
            browser = ctx:get_Browser(),
        }
    end

    if base_char_type == data.base_char_enum.SmallMonster then
        ---@cast char_base app.EnemyZakoCharacter
        ---@type SmallEnemy
        return {
            type = data.char_enum.SmallMonster,
            base = char_base,
            distance = 0,
            ctx = ctx,
            name = utilities.getMessageLocal:call(
                nil,
                utilities.getEnemyNameGuid:call(nil, ctx:get_EmID()),
                data.get_language()
            ) or data.name_missing,
            id = char_base:get_address(),
            hurtboxes = {},
            hitboxes = {},
            hitbox_userdata_cache = {},
            order = #this.characters,
        }
    end
end

---@param base_char_type BaseCharType
---@param char_base app.CharacterBase
---@return CharObj?
local function get_character_data(base_char_type, char_base)
    if base_char_type == data.base_char_enum.Hunter then
        ---@cast char_base app.HunterCharacter
        return get_hunter_data(char_base)
    end

    if base_char_type == data.base_char_enum.Pet then
        ---@cast char_base app.OtomoCharacter
        return get_pet_data(char_base)
    end

    if base_char_type == data.base_char_enum.BigMonster or base_char_type == data.base_char_enum.SmallMonster then
        ---@cast char_base app.EnemyBossCharacter|app.EnemyZakoCharacter
        return get_enemy_data(base_char_type, char_base)
    end
end

---@param game_object via.GameObject
---@param char_base app.CharacterBase?
---@return CharObj?
function this.character_ctor(game_object, char_base)
    if this.characters[game_object] then
        return this.characters[game_object]
    end

    if not char_base then
        char_base = utilities.get_component(game_object, "app.CharacterBase")
    end

    if not char_base or not char_base:get_Started() or not char_base:get_Valid() then
        return
    end

    ---@type via.physics.RequestSetCollider?
    local rsc = utilities.get_component(game_object, "via.physics.RequestSetCollider")
    if not rsc then
        return
    end

    local base_char_type = data.base_char_enum[data.char_type_to_name[char_base:get_type_definition():get_full_name()]]
    if base_char_type then
        this.characters[game_object] = get_character_data(base_char_type, char_base)

        if this.characters[game_object] then
            if not this.characters_grouped[this.characters[game_object].type] then
                this.characters_grouped[this.characters[game_object].type] = {}
            end

            this.characters_grouped[this.characters[game_object].type][game_object] = this.characters[game_object]
            table.insert(hurtboxes.load_queue, { char_obj = this.characters[game_object], rsc = rsc })
        end
        return this.characters[game_object]
    end
end

function this.get_attack_idx(args)
    if not config.current.enabled_hitboxes or sdk.to_int64(args[3]) & 1 == 0 then
        return
    end

    local collider_switcher = sdk.to_managed_object(args[2])
    ---@cast collider_switcher app.ColliderSwitcher
    local game_object = collider_switcher._HitController:get_Owner()
    local char_obj = this.character_ctor(game_object)

    if
        not char_obj
        or char_obj.distance > config.current.draw.distance
        or config.current.hitboxes.disable[data.reverse_lookup(data.char_enum, char_obj.type)]
    then
        return
    end

    table.insert(hitboxes.load_queue, {
        type = hitboxes.load_data_enum.rsc,
        char_obj = char_obj,
        rsc = collider_switcher._RequestSetCollider,
        res_idx = sdk.to_int64(args[4]) & 0xFFFFFFFF,
        req_idx = sdk.to_int64(args[5]) & 0xFFFFFFFF,
    })
end

function this.get_shell_pre(args)
    if not config.current.enabled_hitboxes then
        return
    end
    ---@diagnostic disable-next-line: missing-parameter
    thread.get_hook_storage()["shellcolhit"] = sdk.to_managed_object(args[2])
end

function this.get_shell_post(retval)
    if not config.current.enabled_hitboxes then
        return
    end

    ---@diagnostic disable-next-line: missing-parameter
    local storage = thread.get_hook_storage()
    if not storage or not storage["shellcolhit"] then
        return
    end

    local shellcolhit = storage["shellcolhit"]
    ---@cast shellcolhit app.mcShellColHit

    --FIXME: surely there must be better way to get actual owner of the shell???
    local shellcol_owner = shellcolhit:get_Owner()
    local shell_base = utilities.get_component(shellcol_owner, "ace.ShellBase")
    ---@cast shell_base ace.ShellBase
    local shell_owner = shell_base:get_ShellOwner()
    local shell_transform = shell_owner:get_Transform()

    while 1 do
        local parent = shell_transform:get_Parent()
        if parent then
            shell_transform = parent
        else
            break
        end
    end

    local actual_owner = shell_transform:get_GameObject()
    local char_obj = this.character_ctor(actual_owner)

    if
        not char_obj
        or char_obj.distance > config.current.draw.distance
        or config.current.hitboxes.disable[data.reverse_lookup(data.char_enum, char_obj.type)]
    then
        return
    end

    table.insert(hitboxes.load_queue, {
        type = hitboxes.load_data_enum.shell,
        char_obj = char_obj,
        first_colider = shellcolhit._FirstCollider,
        sub_colliders = shellcolhit._SubColliders,
        shellcolhit = shellcolhit,
    })

    return retval
end

function this.get_all_chars()
    local transforms = data.get_all_transforms()
    local size = transforms:get_Count()

    for i = 0, size - 1 do
        ---@type via.Transform
        local transform = transforms:get_Item(i)
        this.character_ctor(transform:get_GameObject())
    end
end

function this.get_base_pre(args)
    ---@diagnostic disable-next-line: missing-parameter
    thread.get_hook_storage()["charbase"] = sdk.to_managed_object(args[2])
end

function this.get_base_post(retval)
    ---@diagnostic disable-next-line: missing-parameter
    local char_base = thread.get_hook_storage()["charbase"]
    if not char_base then
        return
    end
    ---@cast char_base app.CharacterBase
    table.insert(this.load_queue, { tick = data.tick_count, char_base = char_base })
    return retval
end

---@param char_enum CharType
---@return CharObj[]?
function this.get_sorted_chars(char_enum)
    local ret = {}
    if not this.characters_grouped[char_enum] then
        return
    end

    for _, char_obj in pairs(this.characters_grouped[char_enum]) do
        table.insert(ret, char_obj)
    end

    ---@param x CharObj
    ---@param y CharObj
    ---@return boolean
    table.sort(ret, function(x, y)
        if x.order < y.order then
            return true
        end
        return false
    end)
    return ret
end

---@param enemy_char BigEnemy
---@return PartGroup[]
function this.get_sorted_part_groups(enemy_char)
    local ret = {}
    for _, part_group in pairs(enemy_char.parts) do
        table.insert(ret, part_group)
    end

    ---@param x PartGroup
    ---@param y PartGroup
    ---@return boolean
    table.sort(ret, function(x, y)
        if x.part_data.guid < y.part_data.guid then
            return true
        end
        return false
    end)
    return ret
end

function this.clear()
    this.characters = {}
    this.characters_grouped = {}
    this.load_queue = {}
    this.master_player = nil
end

---@return MasterPlayer?
function this.get_master_player()
    if not this.master_player or utilities.is_only_my_ref(this.master_player.base) then
        if not data.get_playman() then
            return
        end
        local player_info = data.get_playman():getMasterPlayer()
        if player_info then
            local hunter_char = player_info:get_Character()
            local game_object = hunter_char:get_GameObject()
            local ret = this.character_ctor(game_object, hunter_char)
            ---@cast ret MasterPlayer?
            this.master_player = ret
        end
    end
    return this.master_player
end

--FIXME: when chars are created trough app.CharacterBase.doStart hook, some elements are not created yet
-- and things throw exceptions, couldnt find anything better to hook
function this.get()
    if not data.in_transition() then
        local counter = 0
        for idx, load_data in pairs(this.load_queue) do
            if data.tick_count - load_data.tick <= 60 then
                goto continue
            end

            if load_data.char_base:get_Valid() then
                this.character_ctor(load_data.char_base:get_GameObject(), load_data.char_base)
            end
            this.load_queue[idx] = nil

            ::continue::
            counter = counter + 1
            if counter == config.max_updates then
                return
            end
        end
    end
end

function this.update()
    if
        (not config.current.enabled_hurtboxes and not config.current.enabled_hitboxes)
        or not this.get_master_player()
        or data.in_transition()
    then
        return
    end

    local mp_pos = this.get_master_player():get_pos()
    local do_parts = config_menu.is_opened or next(config.sorted_conditions) ~= nil
    for char_type, characters in pairs(this.characters_grouped) do
        local name = data.reverse_lookup(data.char_enum, char_type)
        for game_object, char_obj in pairs(characters) do
            --FIXME: this sometimes throws, i guess its getting called when object is getting destroyed?
            local _, is_dead = pcall(function()
                return not char_obj.base:get_Valid()
                    or (char_obj.type == data.char_enum.BigMonster and char_obj.browser:get_IsDie())
            end)

            if utilities.is_only_my_ref(char_obj.base) or is_dead then
                this.characters[game_object] = nil
                this.characters_grouped[char_obj.type][game_object] = nil
                goto continue
            end

            if config.current.hurtboxes.disable[name] and config.current.hitboxes.disable[name] then
                goto continue
            end

            local pos = char_obj.base:get_Pos()
            if pos and char_obj.type ~= data.char_enum.MasterPlayer then
                char_obj.distance = (mp_pos - pos):length()
            end

            if char_obj.distance > config.current.draw.distance then
                goto continue
            end

            if config.current.enabled_hurtboxes and not config.current.hurtboxes.disable[name] then
                if char_obj.type == data.char_enum.BigMonster and do_parts then
                    for _, part in pairs(char_obj.parts) do
                        part:update()
                        if part.part_data.scars then
                            for _, scar in pairs(part.part_data.scars) do
                                if scar.box_state == data.box_state.Draw then
                                    hbdraw.enqueue(scar.box)
                                end
                            end
                        end
                    end
                end

                for idx, box in pairs(char_obj.hurtboxes) do
                    local state = box:update()
                    if state == data.box_state.Dead then
                        char_obj.hurtboxes[idx] = nil
                    elseif state == data.box_state.Draw then
                        hbdraw.enqueue(box)
                    end
                end
            end

            if config.current.enabled_hitboxes and not config.current.hitboxes.disable[name] then
                for col, box in pairs(char_obj.hitboxes) do
                    local state = box:update()
                    if state ~= data.box_state.Draw and box:is_done() then
                        char_obj.hitboxes[col] = nil
                    elseif state == data.box_state.Draw then
                        hbdraw.enqueue(box)
                        box.shown = true
                    end
                end
            end
            ::continue::
        end
    end
end

function this.init()
    hurtboxes = require("HitboxViewer.box.hurt")
    hitboxes = require("HitboxViewer.box.hit")
    config_menu = require("HitboxViewer.gui.init")
end

return this
