---@class (exact) ScarBox : BoxBase
---@field show boolean
---@field highlight boolean
---@field state string
---@field hitzone table<string, integer>
---@field condition ConditionResult
---@field condition_color integer
---@field protected _scar app.EnemyScar
---@field protected _scar_part app.cEmModuleScar.cScarParts

local box_base = require("HitboxViewer.box.box_base")
local conditions = require("HitboxViewer.box.hurt.conditions.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")

local mod = data.mod
local ace = data.ace

---@class ScarBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param hitzone table<string, integer>
---@param scar app.EnemyScar
---@param scar_part app.cEmModuleScar.cScarParts
---@return ScarBox
function this:new(hitzone, scar, scar_part)
    local o = box_base.new(self, mod.enum.box.ScarBox, mod.enum.shape.Sphere)
    ---@cast o ScarBox
    setmetatable(o, self)
    o.show = false
    o.highlight = false
    o.hitzone = hitzone
    o.condition = mod.enum.condition_result.None
    o.condition_color = 0
    o._scar = scar
    o._scar_part = scar_part
    o.shape_data.radius = scar._ColSizeRadius
    return o
end

function this:update_shape()
    self.shape_data.pos = self._scar:get_Pos()
    self.pos = self.shape_data.pos
    self.distance = (mod.camera.origin - self.pos):length()
    return mod.enum.box_state.Draw
end

function this:update_data()
    if
        not self.is_enabled
        or (not self.show and self.condition ~= mod.enum.condition_result.Highlight)
    then
        return mod.enum.box_state.None
    end

    if config.current.hurtboxes.use_one_color then
        self.color = config.current.hurtboxes.color.one_color
    elseif self.highlight then
        self.color = config.current.hurtboxes.color.highlight
    elseif self.condition == mod.enum.condition_result.Highlight then
        self.color = self.condition_color
    else
        self.color = config.current.hurtboxes.color.BigMonster
    end
    return mod.enum.box_state.Draw
end

---@return BoxState
function this:update()
    self.state = ace.enum.scar[self._scar_part:get_State()]
    self.is_enabled = not self._scar_part:get_IsForceDisableCollision()
    self.condition, self.condition_color = conditions.check_scar(self.state)
    return box_base.update(self)
end

return this
