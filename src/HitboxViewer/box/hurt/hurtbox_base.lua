---@class (exact) HurtBoxBase : CollidableBase

local colldable_base = require("HitboxViewer.box.collidable_base")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local rt = data.runtime
local rl = data.util.reverse_lookup

---@class HurtBoxBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = colldable_base })

---@param collidable via.physics.Collidable
---@param parent Character
---@return HurtBoxBase?
function this:new(collidable, parent)
    local o = colldable_base.new(self, collidable, parent, rt.enum.box.HurtBox)

    if not o then
        return
    end

    ---@cast o HurtBoxBase
    setmetatable(o, self)
    return o
end

function this:update_data()
    if config.current.hurtboxes.use_one_color then
        self.color = config.current.hurtboxes.color.one_color
    else
        self.color = config.current.hurtboxes.color[rl(rt.enum.char, self.parent.type)]
    end
    return rt.enum.box_state.Draw
end

return this
