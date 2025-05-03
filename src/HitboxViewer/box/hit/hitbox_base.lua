---@class (exact) HitBoxBase : CollidableBase
---@field log_entry AttackLogEntry
---@field shellcolhit app.mcShellColHit?
---@field is_shown boolean
---@field tick integer

local colldable_base = require("HitboxViewer.box.collidable_base")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local rt = data.runtime
local rl = data.util.reverse_lookup

---@class HitBoxBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = colldable_base })

---@param collidable via.physics.Collidable
---@param parent Character
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@param log_entry AttackLogEntry
---@param shellcolhit app.mcShellColHit?
---@return HitBoxBase?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx, log_entry, shellcolhit)
    local o = colldable_base.new(self, collidable, parent, rt.enum.box.HitBox, resource_idx, set_idx, collidable_idx)

    if not o then
        return
    end

    ---@cast o HitBoxBase
    setmetatable(o, self)
    o.log_entry = log_entry
    o.shellcolhit = shellcolhit
    o.is_shown = false
    o.tick = rt.state.tick_count
    return o
end

---@return BoxState
function this:update_data()
    if config.current.hitboxes.use_one_color then
        self.color = config.current.hitboxes.color.one_color
    elseif config.current.hitboxes.misc_type.color_enable[self.log_entry.misc_type] then
        self.color = config.current.hitboxes.misc_type.color[self.log_entry.misc_type]
    elseif config.current.hitboxes.guard_type.color_enable[self.log_entry.guard_type] then
        self.color = config.current.hitboxes.guard_type.color[self.log_entry.guard_type]
    elseif config.current.hitboxes.damage_angle.color_enable[self.log_entry.damage_angle] then
        self.color = config.current.hitboxes.damage_angle.color[self.log_entry.damage_angle]
    elseif config.current.hitboxes.damage_type.color_enable[self.log_entry.damage_type] then
        self.color = config.current.hitboxes.damage_type.color[self.log_entry.damage_type]
    else
        self.color = config.current.hitboxes.color[rl(rt.enum.char, self.parent.type)]
    end

    return rt.enum.box_state.Draw
end

---@return BoxState, BoxBase[]
function this:update()
    if
        self.shellcolhit and self.shellcolhit:get_reference_count() <= 1
        or not self.is_shown and rt.state.tick_count - self.tick > 1200
    then
        return rt.enum.box_state.Dead, { self }
    end

    local box_state, boxes = colldable_base.update(self)
    if box_state == rt.enum.box_state.Draw then
        self.is_shown = true
    elseif box_state == rt.enum.box_state.None and self.is_shown then
        box_state = rt.enum.box_state.Dead
    end
    return box_state, boxes
end

return this
