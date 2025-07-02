local col_queue = require("HitboxViewer.box.collidable_queue")
local data = require("HitboxViewer.data")

local rt = data.runtime

local this = {
    hitbox = require("HitboxViewer.box.hit"),
    hurtbox = require("HitboxViewer.box.hurt"),
    pressbox = require("HitboxViewer.box.press"),
    dummy = require("HitboxViewer.box.dummy"),
}

---@param char Character
---@param rsc via.physics.RequestSetCollider
---@return fun(): integer, integer, integer
local function get_collidable(char, rsc)
    return coroutine.wrap(function()
        for i = 0, rsc:get_NumRequestSets() - 1 do
            for j = 0, rsc:getNumRequestSetsFromIndex(i) - 1 do
                for k = 0, rsc:getNumCollidablesFromIndex(i, j) - 1 do
                    coroutine.yield(i, j, k)
                end
            end
        end
    end)
end

function this.clear()
    col_queue:clear()
    this.pressbox.queue:clear()
    this.hurtbox.queue:clear()
    this.hitbox.queue:clear()
    this.dummy.clear()
end

function this.get()
    for load_data in col_queue:get() do
        for resource_idx, set_idx, collidable_idx in get_collidable(load_data.char, load_data.rsc) do
            local col = load_data.rsc:getCollidableFromIndex(resource_idx, set_idx, collidable_idx)

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

            if
                data_type:is_a("app.col_user_data.DamageParam")
                or (
                    (load_data.char.type == rt.enum.char.Player or load_data.char.type == rt.enum.char.MasterPlayer)
                    and resource_idx == 0
                    and collidable_idx == 0
                    and (set_idx == 1 or set_idx == 2)
                )
            then
                ---@cast p_data app.col_user_data.DamageParam
                this.hurtbox.queue:enqueue({
                    col = col,
                    char = load_data.char,
                    rsc = load_data.rsc,
                    resource_idx = resource_idx,
                    set_idx = set_idx,
                    collidable_idx = collidable_idx,
                    userdata = p_data,
                })
            elseif data_type:is_a("app.col_user_data.PressParam") then
                ---@cast p_data app.col_user_data.PressParam
                this.pressbox.queue:enqueue({
                    col = col,
                    char = load_data.char,
                    rsc = load_data.rsc,
                    resource_idx = resource_idx,
                    set_idx = set_idx,
                    collidable_idx = collidable_idx,
                    userdata = p_data,
                })
            end

            ::continue::
        end
    end

    this.hurtbox.get()
    this.pressbox.get()
    this.hitbox.get()
    this.dummy.get()
end

return this
