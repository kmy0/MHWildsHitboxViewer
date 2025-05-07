local data = require("HitboxViewer.data")
local enemy = {
    big_enemy = require("HitboxViewer.box.hurt.big_enemy"),
    small_enemy = require("HitboxViewer.box.hurt.hurtbox_base"),
}
local friend = {
    player = require("HitboxViewer.box.hurt.player"),
    npc = require("HitboxViewer.box.hurt.hurtbox_base"),
    pet = require("HitboxViewer.box.hurt.hurtbox_base"),
}
local box_queue = require("HitboxViewer.box.hurt.box_queue")
local col_queue = require("HitboxViewer.box.hurt.collidable_queue")

local rt = data.runtime

local this = {
    conditions = require("HitboxViewer.box.hurt.conditions"),
}

---@param char Character
---@param rsc via.physics.RequestSetCollider
---@return fun(): integer, integer, integer
local function get_collidable(char, rsc)
    return coroutine.wrap(function()
        if char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
            coroutine.yield(0, 1, 0)
            coroutine.yield(0, 2, 0)
        else
            for i = 0, rsc:get_NumRequestSets() - 1 do
                for j = 0, rsc:getNumRequestSetsFromIndex(i) - 1 do
                    for k = 0, rsc:getNumCollidablesFromIndex(i, j) - 1 do
                        coroutine.yield(i, j, k)
                    end
                end
            end
        end
    end)
end

function this.clear()
    col_queue:clear()
end

function this.get()
    for load_data in col_queue:get() do
        for resource_idx, set_idx, collidable_idx in get_collidable(load_data.char, load_data.rsc) do
            box_queue:enqueue({
                char = load_data.char,
                rsc = load_data.rsc,
                resource_idx = resource_idx,
                set_idx = set_idx,
                collidable_idx = collidable_idx,
            })
        end
    end

    for load_data in box_queue:get() do
        ---@type HurtBoxBase?
        local box
        local char = load_data.char
        local col =
            load_data.rsc:getCollidableFromIndex(load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)

        if not col then
            goto continue
        end

        local userdata = col:get_UserData()
        ---@cast userdata via.physics.RequestSetColliderUserData
        local p_data = userdata:get_ParentUserData()

        if not p_data then
            goto continue
        end

        local data_type = p_data:get_type_definition() --[[@as RETypeDefinition]]

        -- stylua: ignore start
        if
            char.type == rt.enum.char.Npc
            and (
                data_type:is_a("app.col_user_data.DamageParamNpc")
                ---@diagnostic disable-next-line: cast-type-mismatch
                ---@cast p_data app.col_user_data.DamageParamNpc
                and p_data._IsAttackDetector
            )
        -- stylua: ignore end
        then
            ---@cast char Npc
            box = friend.npc:new(col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
            ---@cast char Player
            box = friend.player:new(col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.Pet and data_type:is_a("app.col_user_data.DamageParamOt") then
            ---@cast char Pet
            box = friend.pet:new(col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.BigMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
            ---@cast char BigEnemy
            box = enemy.big_enemy:new(
                col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                p_data --[[@as app.col_user_data.DamageParamEm]]
            )
        elseif char.type == rt.enum.char.SmallMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
            ---@cast char SmallEnemy
            box = enemy.small_enemy:new(col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        end

        if box then
            char:add_hurtbox(box)
        end
        ::continue::
    end
end

return this
