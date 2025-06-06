---@class GuardBox : BoxBase
---@field parent Player
---@field parent_hurtbox PlayerHurtBox

local box_base = require("HitboxViewer.box.box_base")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local rt = data.runtime
local ace = data.ace

---@class GuardBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = box_base })

---@param parent Player
---@param parent_hurtbox PlayerHurtBox
---@return GuardBox
function this:new(parent, parent_hurtbox)
    local o = box_base.new(self, rt.enum.box.GuardBox, rt.enum.shape.SlicedCylinder)
    setmetatable(o, self)
    ---@cast o GuardBox
    o.parent = parent
    o.parent_hurtbox = parent_hurtbox
    return o
end

---@return BoxState
function this:update_shape()
    if not self.parent.guard_type then
        return rt.enum.box_state.None
    end

    local userdata = self.parent.weapon.userdata
    local field_name = ace.map.guard_name_to_field_name[self.parent.guard_type]
        or ace.map.guard_name_to_field_name["GUARD"]
    local angle = ace.map.guard_name_to_angle[self.parent.guard_type] or userdata:get_field(field_name)

    if not angle then
        angle = userdata:get_field(ace.map.guard_name_to_field_name["GUARD"])
    end

    self.shape_data.degrees = angle
    self.shape_data.direction = self.parent:get_guard_direction()
    self.shape_data.direction.y = 0
    self.shape_data.radius = self.parent_hurtbox.shape_data.radius + 0.02

    self.shape_data.pos_a = self.parent_hurtbox.shape_data.pos_a + self.parent.direction * 0.01
    self.shape_data.pos_b = self.parent_hurtbox.shape_data.pos_b + self.parent.direction * 0.01
    self.pos = (self.shape_data.pos_a + self.shape_data.pos_b) * 0.5
    self.distance = (rt.camera.origin - self.pos):length()

    local dir = self.shape_data.pos_a - self.shape_data.pos_b
    dir:normalize()

    self.shape_data.pos_a = self.shape_data.pos_a + dir * self.parent_hurtbox.shape_data.radius
    self.shape_data.pos_b = self.shape_data.pos_b - dir * self.parent_hurtbox.shape_data.radius

    return rt.enum.box_state.Draw
end

---@return BoxState
function this:update_data()
    if not self.parent.guard_type then
        return rt.enum.box_state.None
    end

    if config.current.hurtboxes.guard_type.disable[self.parent.guard_type] then
        return rt.enum.box_state.None
    end

    if config.current.hurtboxes.use_one_color then
        self.color = config.current.hurtboxes.color.one_color
    elseif config.current.hurtboxes.guard_type.color_enable[self.parent.guard_type] then
        self.color = config.current.hurtboxes.guard_type.color[self.parent.guard_type]
    else
        self.color = config.current.hurtboxes.color.highlight
    end
    return rt.enum.box_state.Draw
end

return this
