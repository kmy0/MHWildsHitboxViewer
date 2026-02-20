---@class GuardBox : BoxBase
---@field parent Player
---@field parent_hurtbox PlayerHurtBox

local box_base = require("HitboxViewer.box.box_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local util_game = require("HitboxViewer.util.game.init")
local util_imgui = require("HitboxViewer.util.imgui.init")

local mod_enum = data.mod.enum
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
    local o = box_base.new(self, mod_enum.box.GuardBox, mod_enum.shape.SlicedCylinder)
    setmetatable(o, self)
    ---@cast o GuardBox
    o.parent = parent
    o.parent_hurtbox = parent_hurtbox
    return o
end

---@return boolean
function this:is_trail_disabled()
    local tri = util_imgui.get_checkbox_tri_value(
        config.current.mod.hurtboxes.guard_type.trail_enable[self.parent.guard_type]
    )

    if tri ~= nil then
        return not tri
    end
    return true
end

---@return BoxState
function this:update_shape()
    if not self.parent.guard_type then
        return mod_enum.box_state.None
    end

    local userdata = self.parent.weapon.userdata
    local field_name = ace.map.guard_name_to_field_name[self.parent.guard_type]
        or ace.map.guard_name_to_field_name["GUARD"]
    local angle = ace.map.guard_name_to_angle[self.parent.guard_type]
        or userdata:get_field(field_name)

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
    self.distance = (util_game.get_camera_origin() - self.pos):length()

    local dir = self.shape_data.pos_a - self.shape_data.pos_b
    dir:normalize()

    self.shape_data.pos_a = self.shape_data.pos_a + dir * self.parent_hurtbox.shape_data.radius
    self.shape_data.pos_b = self.shape_data.pos_b - dir * self.parent_hurtbox.shape_data.radius

    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update_data()
    local config_mod = config.current.mod

    if not self.parent.guard_type then
        return mod_enum.box_state.None
    end

    if config_mod.hurtboxes.guard_type.disable[self.parent.guard_type] then
        return mod_enum.box_state.None
    end

    if config_mod.hurtboxes.guard_type.color_enable[self.parent.guard_type] then
        ---@diagnostic disable-next-line: no-unknown
        self.color = config_mod.hurtboxes.guard_type.color[self.parent.guard_type]
    else
        self.color = config_mod.hurtboxes.guard_type.color.one_color
    end
    return mod_enum.box_state.Draw
end

return this
