---@class CollisionBoxQueue : Queue
---@field push_back fun(self: CollisionBoxQueue, value: CollisionBoxLoadData)
---@field iter fun(self: CollisionBoxQueue): fun(): CollisionBoxLoadData

---@class (exact) CollisionBoxLoad
---@field char Character
---@field parent_char Character?
---@field col via.physics.Collidable
---@field is_shell boolean

---@class CollisionBoxLoadData
---@field caller REManagedObject
---@field col_a CollisionBoxLoad
---@field col_b CollisionBoxLoad
---@field col_point Vector3f

local collision_log = require("HitboxViewer.collision_log")
local collisionbox = require("HitboxViewer.box.collision.collisionbox")
local config = require("HitboxViewer.config.init")
local contact_point = require("HitboxViewer.box.collision.contact_point")
local queue = require("HitboxViewer.util.misc.queue")
local util_game = require("HitboxViewer.util.game.init")
local util_table = require("HitboxViewer.util.misc.table")

---@class CollisionBoxQueue
local this = queue:new()

---@param char Character
local function set_collidable_data(char)
    local rsc = util_game.get_component(char.game_object, "via.physics.RequestSetCollider") --[[@as via.physics.RequestSetCollider]]
    for i = 0, rsc:get_NumRequestSets() - 1 do
        for j = 0, rsc:getNumRequestSetsFromIndex(i) - 1 do
            for k = 0, rsc:call("getNumCollidablesFromIndex(System.UInt32, System.UInt32)", i, j) - 1 do
                local col =
                    rsc:call("getCollidable(System.UInt32, System.UInt32, System.UInt32)", i, j, k) --[[@as via.physics.Collidable]]

                if not col then
                    goto continue
                end

                char.collidable_to_indexes[col] = {
                    resource_idx = i,
                    set_idx = j,
                    collidable_idx = k,
                }
                ::continue::
            end
        end
    end
end

function this.get()
    local config_mod = config.current.mod
    for load_data in this:iter() do
        ---@type ContactPoint?
        local col_point
        ---@type via.physics.Collidable | CollisionBox
        local key_a
        ---@type via.physics.Collidable | CollisionBox
        local key_b
        local a = load_data.col_a
        local b = load_data.col_b

        if util_table.empty(a.char.collidable_to_indexes) then
            set_collidable_data(a.char)
        end

        if util_table.empty(b.char.collidable_to_indexes) then
            set_collidable_data(b.char)
        end

        if
            config_mod.collisionboxes.ignore_new
            and (a.char:any_collisionbox() or b.char:any_collisionbox())
        then
            goto continue
        end

        local log_entry = collision_log.get_log_entry(load_data)
        if not log_entry or not collision_log:log(log_entry) then
            goto continue
        end

        if config_mod.collisionboxes.draw_contact_point then
            col_point = contact_point:new(
                load_data.col_point,
                0.05,
                config_mod.collisionboxes.color_col_point,
                config_mod.collisionboxes.draw_dur
            )
        end

        local box_a = collisionbox:new(
            a.col,
            config_mod.collisionboxes.color_col_a,
            config_mod.collisionboxes.draw_dur,
            col_point
        )
        local box_b = collisionbox:new(
            b.col,
            config_mod.collisionboxes.color_col_b,
            config_mod.collisionboxes.draw_dur,
            col_point
        )

        if box_a and box_b then
            local holder = a.char

            if config_mod.collisionboxes.replace_existing then
                key_a = a.col
                key_b = b.col

                holder:remove_contact_point(key_a, key_b)
            elseif config_mod.collisionboxes.ignore_new then
                key_a = a.col
                key_b = b.col
            else
                key_a = box_a
                key_b = box_b
            end

            holder:add_collisionbox(key_a, box_a)
            holder:add_collisionbox(key_b, box_b)

            if col_point then
                holder:add_collisionbox(col_point, col_point)
            end
        end
        ::continue::
    end
end

return this
