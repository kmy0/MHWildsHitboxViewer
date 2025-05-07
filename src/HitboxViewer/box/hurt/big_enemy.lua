---@class (exact) BigEnemyHurtBox : EnemyHurtBox
---@field part_group PartGroup

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local enemy_hurtbox = require("HitboxViewer.box.hurt.enemy")
local part_group = require("HitboxViewer.box.hurt.part_group")

local rt = data.runtime

---@class BigEnemyHurtBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = enemy_hurtbox })

---@param collidable via.physics.Collidable
---@param parent BigEnemy
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@param meat_data app.col_user_data.DamageParamEm
---@return BigEnemyHurtBox?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx, meat_data)
    local o = enemy_hurtbox.new(self, collidable, parent, resource_idx, set_idx, collidable_idx, meat_data)

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
        return enemy_hurtbox.update_data(self)
    end

    return rt.enum.box_state.Draw
end

return this
