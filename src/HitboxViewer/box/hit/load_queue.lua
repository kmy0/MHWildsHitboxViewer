---@class HitBoxQueue : Queue
---@field push_back fun(self: HitBoxQueue, value: HitBoxLoadDataRsc | HitBoxLoadDataShell | HitBoxLoadData)
---@field iter fun(self: HitBoxQueue, n: integer?): fun(): HitBoxLoadDataRsc | HitBoxLoadDataShell | HitBoxLoadData

---@class (exact) HitBoxLoadData
---@field type HitBoxLoadDataType
---@field char Character
---@field rsc via.physics.RequestSetCollider

---@class (exact) HitBoxLoadDataRsc : HitBoxLoadData
---@field res_idx integer
---@field req_idx integer

---@class (exact) HitBoxLoadDataShell : HitBoxLoadData
---@field res_idx integer
---@field colliders via.physics.Collidable[]
---@field shellcolhit app.mcShellColHit

local attack_log = require("HitboxViewer.attack_log")
local base = require("HitboxViewer.box.hit.hitbox_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local m = require("HitboxViewer.util.ref.methods")
local queue = require("HitboxViewer.util.misc.queue")

local mod_enum = data.mod.enum
local enemy = { big_enemy = base, small_enemy = base }
local friend = { player = base, npc = base, pet = base }

---@class HitBoxQueue
local this = queue:new()

---@param load_data HitBoxLoadData
---@return fun(): via.physics.Collidable, via.physics.RequestSetColliderUserData, integer, integer, integer
local function get_collidable(load_data)
    ---@type [via.physics.Collidable, via.physics.RequestSetColliderUserData, integer, integer, integer][]
    local ret = {}
    local index = 1

    if load_data.type == mod_enum.hitbox_load_data.rsc then
        ---@cast load_data HitBoxLoadDataRsc
        for i = 0, load_data.rsc:getNumCollidables(load_data.res_idx, load_data.req_idx) - 1 do
            local col = load_data.rsc:getCollidable(load_data.res_idx, load_data.req_idx, i)
            if col then
                table.insert(
                    ret,
                    { col, col:get_UserData(), load_data.res_idx, load_data.req_idx, i }
                )
            end
        end
    elseif load_data.type == mod_enum.hitbox_load_data.base then
        ---@cast load_data HitBoxLoadData
        for i = 0, load_data.rsc:get_NumRequestSets() - 1 do
            for j = 0, load_data.rsc:getNumRequestSetsFromIndex(i) - 1 do
                for k = 0, load_data.rsc:getNumCollidablesFromIndex(i, j) - 1 do
                    local col = load_data.rsc:getCollidableFromIndex(i, j, k)
                    if col and m.isCollidableValid(col) then
                        table.insert(ret, { col, col:get_UserData(), i, j, k })
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
                    table.insert(ret, { col, col:get_UserData(), load_data.res_idx, j, k })
                end
            end
        end

        for _, col in pairs(load_data.colliders) do
            table.insert(ret, { col, col:get_UserData(), load_data.res_idx, -1, -1 })
        end
    end

    return function()
        if index <= #ret then
            local item = ret[index]
            index = index + 1
            return item[1], item[2], item[3], item[4], item[5]
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

function this.get()
    local config_mod = config.current.mod

    for load_data in this:iter() do
        local char = load_data.char

        for col, userdata, resource_idx, set_idx, collidable_idx in get_collidable(load_data) do
            local log_entry = attack_log.get_log_entry(char, userdata, load_data.rsc, resource_idx)
            ---@type HitBoxBase?
            local box

            if
                char:has_hitbox(col)
                or not log_entry
                or config_mod.hitboxes.misc_type.disable[data.custom_attack_type.check(log_entry)]
                or config_mod.hitboxes.guard_type.disable[log_entry.guard_type]
                or config_mod.hitboxes.damage_angle.disable[log_entry.damage_angle]
                or config_mod.hitboxes.damage_type.disable[log_entry.damage_type]
            then
                goto continue
            end

            if not log_entry.userdata_type:is_a("app.col_user_data.DamageParam") then
                attack_log:log(log_entry)
            end

            if char.type == mod_enum.char.Npc then
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
            elseif char.type == mod_enum.char.Player or char.type == mod_enum.char.MasterPlayer then
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
            elseif char.type == mod_enum.char.Pet then
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
            elseif char.type == mod_enum.char.BigMonster then
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
            elseif char.type == mod_enum.char.SmallMonster then
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
