local base = require("HitboxViewer.box.hit.hitbox_base")
local util = require("HitboxViewer._util")
local enemy = { big_enemy = base, small_enemy = base }
local friend = { player = base, npc = base, pet = base }
local attack_log = require("HitboxViewer.attack_log")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")

local rt = data.mod

local this = {
    hook = require("HitboxViewer.box.hit.hook"),
    queue = require("HitboxViewer.box.hit.load_queue"),
}

---@param load_data HitBoxLoadData
---@return fun(): via.physics.Collidable, via.physics.RequestSetColliderUserData, integer, integer, integer
local function get_collidable(load_data)
    return coroutine.wrap(function()
        if load_data.type == rt.enum.hitbox_load_data.rsc then
            ---@cast load_data HitBoxLoadDataRsc
            for i = 0, load_data.rsc:getNumCollidables(load_data.res_idx, load_data.req_idx) - 1 do
                local col = load_data.rsc:getCollidable(load_data.res_idx, load_data.req_idx, i)
                if col then
                    coroutine.yield(
                        col,
                        col:get_UserData(),
                        load_data.res_idx,
                        load_data.req_idx,
                        i
                    )
                end
            end
        elseif load_data.type == rt.enum.hitbox_load_data.base then
            ---@cast load_data HitBoxLoadData
            for i = 0, load_data.rsc:get_NumRequestSets() - 1 do
                for j = 0, load_data.rsc:getNumRequestSetsFromIndex(i) - 1 do
                    for k = 0, load_data.rsc:getNumCollidablesFromIndex(i, j) - 1 do
                        local col = load_data.rsc:getCollidableFromIndex(i, j, k)
                        if col and util.isCollidableValid:call(nil, col) then
                            coroutine.yield(col, col:get_UserData(), i, j, k)
                        end
                    end
                end
            end
        else
            ---@cast load_data HitBoxLoadDataShell
            for j = 0, load_data.rsc:getNumRequestSetsFromIndex(load_data.res_idx) - 1 do
                for k = 0, load_data.rsc:getNumCollidablesFromIndex(load_data.res_idx, j) - 1 do
                    local col = load_data.rsc:getCollidableFromIndex(load_data.res_idx, j, k)
                    if col then
                        coroutine.yield(col, col:get_UserData(), load_data.res_idx, j, k)
                    end
                end
            end

            for _, col in pairs(load_data.colliders) do
                coroutine.yield(col, col:get_UserData(), load_data.res_idx, -1, -1)
            end
        end
    end)
end

function this.get()
    for load_data in this.queue:get() do
        local char = load_data.char

        for col, userdata, resource_idx, set_idx, collidable_idx in get_collidable(load_data) do
            local log_entry = attack_log.get_log_entry(char, userdata, load_data.rsc, resource_idx)
            ---@type HitBoxBase?
            local box

            if
                char:has_hitbox(col)
                or not log_entry
                or config.current.hitboxes.misc_type.disable[data.custom_attack_type.check(
                    log_entry
                )]
                or config.current.hitboxes.guard_type.disable[log_entry.guard_type]
                or config.current.hitboxes.damage_angle.disable[log_entry.damage_angle]
                or config.current.hitboxes.damage_type.disable[log_entry.damage_type]
            then
                goto continue
            end

            if not log_entry.userdata_type:is_a("app.col_user_data.DamageParam") then
                attack_log:log(log_entry)
            end

            if char.type == rt.enum.char.Npc then
                ---@cast char Npc
                box = friend.npc:new(
                    col,
                    char,
                    resource_idx,
                    set_idx,
                    collidable_idx,
                    log_entry,
                    load_data.shellcolhit
                )
            elseif char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
                ---@cast char Player
                box = friend.player:new(
                    col,
                    char,
                    resource_idx,
                    set_idx,
                    collidable_idx,
                    log_entry,
                    load_data.shellcolhit
                )
            elseif char.type == rt.enum.char.Pet then
                ---@cast char Pet
                box = friend.pet:new(
                    col,
                    char,
                    resource_idx,
                    set_idx,
                    collidable_idx,
                    log_entry,
                    load_data.shellcolhit
                )
            elseif char.type == rt.enum.char.BigMonster then
                ---@cast char BigEnemy
                box = enemy.big_enemy:new(
                    col,
                    char,
                    resource_idx,
                    set_idx,
                    collidable_idx,
                    log_entry,
                    load_data.shellcolhit
                )
            elseif char.type == rt.enum.char.SmallMonster then
                ---@cast char SmallEnemy
                box = enemy.small_enemy:new(
                    col,
                    char,
                    resource_idx,
                    set_idx,
                    collidable_idx,
                    log_entry,
                    load_data.shellcolhit
                )
            end

            if box then
                char:add_hitbox(box)
            end
            ::continue::
        end
    end
end

return this
