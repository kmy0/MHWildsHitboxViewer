---@class (exact) BigEnemyHurtBox : HurtBoxBase
---@field part_group PartGroup

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local hurtbox_base = require("HitboxViewer.box.hurt.hurtbox_base")
local part_group = require("HitboxViewer.box.hurt.part_group")

local rt = data.runtime

---@class BigEnemyHurtBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hurtbox_base })

---@param collidable via.physics.Collidable
---@param parent BigEnemy
---@param meat_data app.col_user_data.DamageParamEm
---@return BigEnemyHurtBox?
function this:new(collidable, parent, meat_data)
    if meat_data:get_RuntimeData()._PartsIndex < 0 then
        return
    end

    local o = hurtbox_base.new(self, collidable, parent)

    if not o then
        return
    end

    ---@cast o BigEnemyHurtBox
    setmetatable(o, self)
    o.part_group = part_group:new(parent.parts, parent.ctx, parent.mc_holder, self, meat_data)

    if not o.part_group then
        return
    end
    return o
end

---@return BoxState
function this:update_data()
    if not self.part_group.is_show and self.part_group.condition ~= rt.enum.condition_result.Highlight then
        return rt.enum.box_state.None
    end

    if self.part_group.is_highlight then
        self.color = config.current.hurtboxes.color.highlight
    elseif self.part_group.condition == rt.enum.condition_result.Highlight then
        self.color = self.part_group.condition_color
    else
        return hurtbox_base.update_data(self)
    end

    return rt.enum.box_state.Draw
end

return this
