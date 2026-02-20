---@class (exact) PlayerHurtBox : HurtBoxBase
---@field guard_box GuardBox

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local guard_box = require("HitboxViewer.box.hurt.guard")
local hurtbox_base = require("HitboxViewer.box.hurt.hurtbox_base")
local m = require("HitboxViewer.util.ref.methods")

local mod_enum = data.mod.enum

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
    if
        self.set_idx == 3 and not m.isPorterRiding(self.parent.base --[[@as app.HunterCharacter]])
    then
        return mod_enum.box_state.None
    end

    local config_mod = config.current.mod
    local box_state = hurtbox_base.update(self)
    ---@type HurtBoxBase[]?
    local ret

    if box_state == mod_enum.box_state.Draw then
        ret = {}
        table.insert(ret, self)
    end

    if
        box_state == mod_enum.box_state.Draw
        and (
            (self.set_idx == 1 and not config_mod.hurtboxes.guard_type.disable_top)
            or (self.set_idx == 2 and not config_mod.hurtboxes.guard_type.disable_bottom)
        )
    then
        local guard_state = self.guard_box:update()
        if guard_state == mod_enum.box_state.Draw then
            ---@cast ret HurtBoxBase[]
            table.insert(ret, self.guard_box)
        end
    end

    local trail = self.guard_box:update_trail()
    if trail then
        if not ret then
            ret = {}
        end
        table.move(trail, 1, #trail, #ret + 1, ret)
    end

    return box_state, ret
end

return this
