---@class (exact) PlayerHurtBox : HurtBoxBase

local hurtbox_base = require("HitboxViewer.box.hurt.hurtbox_base")

---@class PlayerHurtBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hurtbox_base })

---@param collidable via.physics.Collidable
---@param parent Player
---@return PlayerHurtBox?
function this:new(collidable, parent)
    local o = hurtbox_base.new(self, collidable, parent)

    if not o then
        return
    end

    ---@cast o PlayerHurtBox
    setmetatable(o, self)
    return o
end

return this
