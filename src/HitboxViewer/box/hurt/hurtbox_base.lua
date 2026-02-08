---@class (exact) HurtBoxBase : CollidableBase

local colldable_base = require("HitboxViewer.box.collidable_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")

local mod_enum = data.mod.enum

---@class HurtBoxBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = colldable_base })

---@param collidable via.physics.Collidable
---@param parent Character
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@return HurtBoxBase?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx)
    local o = colldable_base.new(
        self,
        collidable,
        parent,
        mod_enum.box.HurtBox,
        resource_idx,
        set_idx,
        collidable_idx
    )

    if not o then
        return
    end

    ---@cast o HurtBoxBase
    setmetatable(o, self)
    return o
end

---@return BoxState
function this:update_data()
    local config_mod = config.current.mod

    if config_mod.hurtboxes.color_enable[mod_enum.char[self.parent.type]] then
        self.color = config_mod.hurtboxes.color[mod_enum.char[self.parent.type]]
    else
        self.color = config_mod.hurtboxes.color.one_color
    end
    return mod_enum.box_state.Draw
end

return this
