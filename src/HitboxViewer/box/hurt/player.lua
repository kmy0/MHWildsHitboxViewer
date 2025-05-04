---@class (exact) PlayerHurtBox : HurtBoxBase
---@field guard_box GuardBox

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local guard_box = require("HitboxViewer.box.hurt.guard")
local hurtbox_base = require("HitboxViewer.box.hurt.hurtbox_base")

local rt = data.runtime

---@class PlayerHurtBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hurtbox_base })

---@param collidable via.physics.Collidable
---@param parent Player
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@return PlayerHurtBox?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx)
    local o = hurtbox_base.new(self, collidable, parent, resource_idx, set_idx, collidable_idx)

    if not o then
        return
    end

    ---@cast o PlayerHurtBox
    setmetatable(o, self)
    o.guard_box = guard_box:new(parent, o)
    return o
end

---@return BoxState, HurtBoxBase[]?
function this:update()
    local box_state = hurtbox_base.update(self)
    ---@type HurtBoxBase[]?
    local ret

    if box_state == rt.enum.box_state.Draw then
        ret = {}
        table.insert(ret, self)
    end

    if
        box_state == rt.enum.box_state.Draw
        and (
            (self.set_idx == 1 and not config.current.hurtboxes.guard_type.disable_top)
            or (self.set_idx == 2 and not config.current.hurtboxes.guard_type.disable_bottom)
        )
    then
        local guard_state = self.guard_box:update()
        if guard_state == rt.enum.box_state.Draw then
            ---@cast ret HurtBoxBase[]
            table.insert(ret, self.guard_box)
        end
    end
    return box_state, ret
end

return this
