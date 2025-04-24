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
local queue = require("HitboxViewer.box.hurt.load_queue")

local rt = data.runtime

local this = {
    conditions = require("HitboxViewer.box.hurt.conditions"),
}

---@param char Character
---@param rsc via.physics.RequestSetCollider
---@return fun(): via.physics.Collidable, via.physics.UserData
local function get_collidable(char, rsc)
    return coroutine.wrap(function()
        if char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
            for j = 1, 2 do
                local col = rsc:getCollidableFromIndex(0, j, 0)
                if col then
                    coroutine.yield(col, col:get_UserData())
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

                        coroutine.yield(col, p_data)
                        ::continue::
                    end
                end
            end
        end
    end)
end

function this.clear()
    queue:clear()
end

function this.get()
    ---@type HurtBoxBase?
    local box
    for load_data in queue:get() do
        local char = load_data.char

        for col, userdata in get_collidable(char, load_data.rsc) do
            local data_type = userdata:get_type_definition() --[[@as RETypeDefinition]]

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
                ---@cast char Npc
                box = friend.npc:new(col, char)
            elseif char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
                ---@cast char Player
                box = friend.player:new(col, char)
            elseif char.type == rt.enum.char.Pet and data_type:is_a("app.col_user_data.DamageParamOt") then
                ---@cast char Pet
                box = friend.pet:new(col, char)
            elseif char.type == rt.enum.char.BigMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
                ---@cast char BigEnemy
                ---@cast userdata app.col_user_data.DamageParamEm
                box = enemy.big_enemy:new(col, char, userdata)
            elseif char.type == rt.enum.char.SmallMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
                ---@cast char SmallEnemy
                box = enemy.small_enemy:new(col, char)
            end

            if box then
                char:add_hurtbox(box)
            end
        end
    end
end

return this
