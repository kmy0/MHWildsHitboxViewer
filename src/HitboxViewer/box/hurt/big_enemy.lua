---@class (exact) BigEnemyHurtBox : EnemyHurtBox
---@field part_group PartGroup

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local enemy_hurtbox = require("HitboxViewer.box.hurt.enemy")
local part_group = require("HitboxViewer.box.hurt.part_group")

local mod_enum = data.mod.enum

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
    local o = enemy_hurtbox.new(
        self,
        collidable,
        parent,
        resource_idx,
        set_idx,
        collidable_idx,
        meat_data
    )

    if not o then
        return
    end

    ---@cast o BigEnemyHurtBox
    setmetatable(o, self)
    o.part_group = part_group:new(parent.parts, parent.ctx, parent.mc_holder, o, meat_data)

    if not o.part_group then
        return
    end
    return o
end

---@return BoxState
function this:update_data()
    local config_mod = config.current.mod

    if not self.part_group.is_show then
        return mod_enum.box_state.None
    end

    if
        not self.part_group.is_highlight
        and (
            (
                config_mod.hurtboxes.default_state ~= mod_enum.default_hurtbox_state.Draw
                and self.part_group.condition ~= mod_enum.condition_result.Highlight
            ) or self.part_group.condition == mod_enum.condition_result.Hide
        )
    then
        return mod_enum.box_state.None
    end

    if self.part_group.is_highlight then
        self.color = config_mod.hurtboxes.color.highlight
    elseif self.part_group.condition == mod_enum.condition_result.Highlight then
        self.color = self.part_group.condition_color
    else
        return enemy_hurtbox.update_data(self)
    end

    return mod_enum.box_state.Draw
end

return this
