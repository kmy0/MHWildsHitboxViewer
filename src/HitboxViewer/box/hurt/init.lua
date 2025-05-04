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
---@return fun(): via.physics.Collidable, via.physics.UserData, integer, integer, integer
local function get_collidable(char, rsc)
    return coroutine.wrap(function()
        if char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
            for j = 1, 2 do
                local col = rsc:getCollidableFromIndex(0, j, 0)
                if col then
                    coroutine.yield(col, col:get_UserData(), 0, j, 0)
                end
            end
        else
            for i = 0, rsc:get_NumRequestSets() - 1 do
                for j = 0, rsc:getNumRequestSetsFromIndex(i) - 1 do
                    for k = 0, rsc:getNumCollidablesFromIndex(i, j) - 1 do
                        local col = rsc:getCollidableFromIndex(i, j, k)
                        if not col then
                            goto continue
                        end

                        local userdata = col:get_UserData()
                        ---@cast userdata via.physics.RequestSetColliderUserData
                        local p_data = userdata:get_ParentUserData()
                        if not p_data then
                            goto continue
                        end

                        coroutine.yield(col, p_data, i, j, k)
                        ::continue::
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
        local char = load_data.char

        for col, userdata, resource_idx, set_idx, collidable_idx in get_collidable(char, load_data.rsc) do
            local data_type = userdata:get_type_definition() --[[@as RETypeDefinition]]
            local box_data = {
                char = char,
                col = col,
                resource_idx = resource_idx,
                set_idx = set_idx,
                collidable_idx = collidable_idx,
                userdata = userdata,
            }

            -- stylua: ignore start
            if
                char.type == rt.enum.char.Npc
                and (
                    data_type:is_a("app.col_user_data.DamageParamNpc")
                    ---@diagnostic disable-next-line: cast-type-mismatch
                    ---@cast data_type app.col_user_data.DamageParamNpc
                    and data_type._IsAttackDetector
                )
            -- stylua: ignore end
            then
                box_queue:enqueue(box_data)
            elseif char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
                box_queue:enqueue(box_data)
            elseif char.type == rt.enum.char.Pet and data_type:is_a("app.col_user_data.DamageParamOt") then
                box_queue:enqueue(box_data)
            elseif char.type == rt.enum.char.BigMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
                box_queue:enqueue(box_data)
            elseif char.type == rt.enum.char.SmallMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
                box_queue:enqueue(box_data)
            end
        end
    end

    for load_data in box_queue:get() do
        ---@type HurtBoxBase?
        local box
        local char = load_data.char

        if char.type == rt.enum.char.Npc then
            ---@cast char Npc
            box =
                friend.npc:new(load_data.col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
            ---@cast char Player
            box = friend.player:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx
            )
        elseif char.type == rt.enum.char.Pet then
            ---@cast char Pet
            box =
                friend.pet:new(load_data.col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.BigMonster then
            ---@cast char BigEnemy
            box = enemy.big_enemy:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                load_data.userdata --[[@as app.col_user_data.DamageParamEm]]
            )
        elseif char.type == rt.enum.char.SmallMonster then
            ---@cast char SmallEnemy
            box = enemy.small_enemy:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx
            )
        end

        if box then
            char:add_hurtbox(box)
        end
    end
end

return this
