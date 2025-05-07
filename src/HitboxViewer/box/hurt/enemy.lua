---@class (exact) EnemyHurtBox : HurtBoxBase

local hurtbox_base = require("HitboxViewer.box.hurt.hurtbox_base")

---@class EnemyHurtBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hurtbox_base })

---@param collidable via.physics.Collidable
---@param parent EnemyCharacter
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@param meat_data app.col_user_data.DamageParamEm
---@return EnemyHurtBox?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx, meat_data)
    if meat_data:get_RuntimeData()._PartsIndex < 0 then
        return
    end

    return hurtbox_base.new(self, collidable, parent, resource_idx, set_idx, collidable_idx) --[[@as EnemyHurtBox?]]
end

return this
