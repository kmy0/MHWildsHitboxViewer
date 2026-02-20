---@class (exact) HitBoxBase : CollidableBase
---@field log_entry AttackLogEntry
---@field shellcolhit app.mcShellColHit?
---@field is_shown boolean
---@field timer Timer

local colldable_base = require("HitboxViewer.box.collidable_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local timer = require("HitboxViewer.util.misc.timer")
local util_imgui = require("HitboxViewer.util.imgui.init")

local mod_enum = data.mod.enum

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
    local o = colldable_base.new(
        self,
        collidable,
        parent,
        mod_enum.box.HitBox,
        resource_idx,
        set_idx,
        collidable_idx
    )

    if not o then
        return
    end

    ---@cast o HitBoxBase
    setmetatable(o, self)
    o.log_entry = log_entry
    o.shellcolhit = shellcolhit
    o.is_shown = false
    o.timer = timer:new(20, nil, true, false, true, "time_delta")
    return o
end

---@return boolean
function this:is_trail_disabled()
    local config_hitboxes = config.current.mod.hitboxes

    local order = {
        config_hitboxes.misc_type.trail_enable[self.log_entry.misc_type],
        config_hitboxes.guard_type.trail_enable[self.log_entry.guard_type],
        config_hitboxes.damage_type.trail_enable[self.log_entry.damage_type],
        config_hitboxes.trail_enable[mod_enum.char[self.parent.type]],
    }

    for i = 1, #order do
        local tri = util_imgui.get_checkbox_tri_value(order[i])
        if tri ~= nil then
            return not tri
        end
    end

    return true
end

---@return BoxState
function this:update_data()
    local config_mod = config.current.mod

    if config_mod.hitboxes.misc_type.color_enable[self.log_entry.misc_type] then
        self.color = config_mod.hitboxes.misc_type.color[self.log_entry.misc_type]
    elseif config_mod.hitboxes.guard_type.color_enable[self.log_entry.guard_type] then
        self.color = config_mod.hitboxes.guard_type.color[self.log_entry.guard_type]
    elseif config_mod.hitboxes.damage_type.color_enable[self.log_entry.damage_type] then
        self.color = config_mod.hitboxes.damage_type.color[self.log_entry.damage_type]
    elseif config_mod.hitboxes.color_enable[mod_enum.char[self.parent.type]] then
        self.color = config_mod.hitboxes.color[mod_enum.char[self.parent.type]]
    else
        self.color = config_mod.hitboxes.color.one_color
    end

    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update()
    if
        self.shellcolhit and self.shellcolhit:get_reference_count() <= 1
        or self.timer:finished()
    then
        return mod_enum.box_state.Dead
    end

    local box_state = colldable_base.update(self)
    if box_state == mod_enum.box_state.Draw then
        self.is_shown = true
    elseif box_state == mod_enum.box_state.None and self.is_shown then
        box_state = mod_enum.box_state.Dead
    end
    return box_state
end

return this
