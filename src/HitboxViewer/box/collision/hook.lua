local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local load_queue = require("HitboxViewer.box.collision.load_queue")
local util_game = require("HitboxViewer.util.game.init")
local util_ref = require("HitboxViewer.util.ref.init")

local mod_enum = data.mod.enum

local this = {}

---@param info ace.UNIVERSAL_COLLISION_INFO
---@param caller string
---@return CollisionBoxLoadData?
local function parse_collison_info(info, caller)
    local config_col = config.current.mod.collisionboxes
    local pos = info.ContactPoint.UniversalPosition

    local char_a = char.cache.get_char(info.CollidableA:get_GameObject(), nil, true)
    local char_b = char.cache.get_char(info.CollidableB:get_GameObject(), nil, true)

    if (not char_a or not char_b) or char_a == char_b then
        return
    end

    if caller == "app.HitInfo" then
        if char_a.type == mod_enum.char.BigMonster and config_col.disable_damage_enemy then
            return
        elseif
            (char_a.type == mod_enum.char.Player or char_a.type == mod_enum.char.MasterPlayer)
            and config_col.disable_damage_player
        then
            return
        end
    end

    ---@type CollisionBoxLoadData
    return {
        col_point = Vector3f.new(pos.x, pos.y, pos.z),
        caller = info,
        col_a = {
            char = char_a,
            col = info.CollidableA,
            is_shell = util_game.get_component(char_a.game_object, "ace.ShellBase") ~= nil,
        },
        col_b = {
            char = char_b,
            col = info.CollidableB,
            is_shell = util_game.get_component(char_b.game_object, "ace.ShellBase") ~= nil,
        },
    }
end

---@param info app.HitInfo
---@return CollisionBoxLoadData?
local function parse_hit_info(info)
    local config_col = config.current.mod.collisionboxes

    local attack = info:getActualAttackOwner()
    local damage = info:getActualDamageOwner()

    -- longsword checks against player hitbox for whatever reason
    if attack == damage then
        return
    end

    local col_a = info:get_AttackCollidable()
    local col_b = info:get_DamageCollidable()
    local game_object_a = col_a:get_GameObject()
    local game_object_b = col_b:get_GameObject()
    local char_a = char.cache.get_char(game_object_a, nil, true)
    local char_b = char.cache.get_char(game_object_b, nil, true)

    if not char_a or not char_b then
        return
    end

    ---@type Character?
    local parent_a
    ---@type Character?
    local parent_b

    if game_object_a ~= attack then
        parent_a = char.cache.get_char(attack, nil, true)
    end

    if game_object_b ~= damage then
        parent_b = char.cache.get_char(damage, nil, true)
    end

    if
        config_col.disable_damage_enemy
        and (
            (char_a.type == mod_enum.char.BigMonster)
            or (parent_a and parent_a.type == mod_enum.char.BigMonster)
        )
    then
        return
    elseif
        config_col.disable_damage_player
        and (
            (char_a.type == mod_enum.char.Player or char_a.type == mod_enum.char.MasterPlayer)
            or (
                parent_a
                and (
                    parent_a.type == mod_enum.char.Player
                    or parent_a.type == mod_enum.char.MasterPlayer
                )
            )
        )
    then
        return
    end

    ---@type CollisionBoxLoadData
    return {
        col_point = info:get_Position(),
        caller = info,
        col_a = {
            char = char_a,
            parent_char = parent_a,
            col = col_a,
            is_shell = util_game.get_component(char_a.game_object, "ace.ShellBase") ~= nil,
        },
        col_b = {
            char = char_b,
            parent_char = parent_b,
            col = col_b,
            is_shell = util_game.get_component(char_b.game_object, "ace.ShellBase") ~= nil,
        },
    }
end

function this.hitinfo_post(retval)
    local config_col = config.current.mod.collisionboxes

    if
        config.current.mod.enabled_collisionboxes
        and not config_col.disable_damage
        and not config_col.ignore_failed
    then
        if config_col.ignore_failed and not util_ref.to_bool(retval) then
            return
        end

        ---@type CollisionBoxLoadData?
        local o
        local hit_info = sdk.to_managed_object(util_ref.deref_ptr(util_ref.thread_get()[2])) --[[@as app.HitInfo]]
        if hit_info then
            hit_info:add_ref()
            o = parse_hit_info(hit_info)
        else
            local col_info = sdk.to_valuetype(
                util_ref.get_raw_address(util_ref.thread_get()[1]),
                "ace.UNIVERSAL_COLLISION_INFO"
            ) --[[@as ace.UNIVERSAL_COLLISION_INFO ]]
            o = parse_collison_info(col_info, "app.HitInfo")
        end

        if o then
            load_queue:push_back(o)
        end
    end
end

function this.hitinfo_pre(args)
    if
        config.current.mod.enabled_collisionboxes
        and not config.current.mod.collisionboxes.disable_damage
    then
        util_ref.thread_store({ args[3], args[5] })
    end
end

function this.notifyhit_pre(args)
    local config_col = config.current.mod.collisionboxes

    if
        config.current.mod.enabled_collisionboxes
        and not config_col.disable_damage
        and config_col.ignore_failed
    then
        local hit_info = sdk.to_managed_object(args[3]) --[[@as app.HitInfo]]
        hit_info:add_ref()
        local o = parse_hit_info(hit_info)
        if o then
            load_queue:push_back(o)
        end
    end
end

function this.sensorhitinfo_pre(args)
    if
        config.current.mod.enabled_collisionboxes
        and not config.current.mod.collisionboxes.disable_sensor
    then
        util_ref.thread_store({ args[3], args[2] })
    end
end

function this.sensorhitinfo_post(_)
    if
        config.current.mod.enabled_collisionboxes
        and not config.current.mod.collisionboxes.disable_sensor
    then
        local sensor_info = sdk.to_managed_object(util_ref.thread_get()[2]) --[[@as app.SensorHitInfo]]
        if sensor_info then
            sensor_info:add_ref()

            local get = sensor_info:get_GetObj()
            local put = sensor_info:get_PutObj()
            local col_a = sensor_info:get_GetCollidable()
            local col_b = sensor_info:get_PutCollidable()
            local game_object_a = col_a:get_GameObject()
            local game_object_b = col_b:get_GameObject()
            local char_a = char.cache.get_char(game_object_a, nil, true)
            local char_b = char.cache.get_char(game_object_b, nil, true)

            if not char_a or not char_b then
                return
            end

            ---@type Character?
            local parent_a
            ---@type Character?
            local parent_b

            if game_object_a ~= get then
                parent_a = char.cache.get_char(get, nil, true)
            end

            if game_object_b ~= put then
                parent_b = char.cache.get_char(put, nil, true)
            end

            ---@type CollisionBoxLoadData
            local o = {
                col_point = sensor_info:get_Position(),
                caller = sensor_info,
                col_a = {
                    char = char_a,
                    parent_char = parent_a,
                    col = col_a,
                    is_shell = util_game.get_component(char_a.game_object, "ace.ShellBase") ~= nil,
                },
                col_b = {
                    char = char_b,
                    parent_char = parent_b,
                    col = col_b,
                    is_shell = util_game.get_component(char_b.game_object, "ace.ShellBase") ~= nil,
                },
            }
            load_queue:push_back(o)
        else
            local col_info = sdk.to_valuetype(
                util_ref.get_raw_address(util_ref.thread_get()[1]),
                "ace.UNIVERSAL_COLLISION_INFO"
            ) --[[@as ace.UNIVERSAL_COLLISION_INFO ]]
            local o = parse_collison_info(col_info, "app.SensorHitInfo")
            if o then
                load_queue:push_back(o)
            end
        end
    end
end

function this.press_post(_)
    if
        config.current.mod.enabled_collisionboxes
        and not config.current.mod.collisionboxes.disable_press
    then
        local master_player = char.get_master_player()
        if not master_player then
            return
        end

        util_game.do_something(master_player.press_list, function(_, _, value)
            local col_a = value:get_ColliderA()
            local col_b = value:get_ColliderB()
            local game_object_a = col_a:get_GameObject()
            local game_object_b = col_b:get_GameObject()

            local char_a = char.cache.get_char(game_object_a, nil, true)
            local char_b = char.cache.get_char(game_object_b, nil, true)

            if not char_a or not char_b then
                return
            end

            load_queue:push_back({
                col_point = value:get_WorldContactPosition(),
                caller = master_player.press_controller,
                col_a = {
                    char = char_a,
                    col = col_a,
                    is_shell = util_game.get_component(char_a.game_object, "ace.ShellBase") ~= nil,
                },
                col_b = {
                    char = char_b,
                    col = col_b,
                    is_shell = util_game.get_component(char_b.game_object, "ace.ShellBase") ~= nil,
                },
            })
        end)
    end
end

return this
