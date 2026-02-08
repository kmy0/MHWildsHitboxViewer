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
local e = require("HitboxViewer.util.game.enum")
local util_game = require("HitboxViewer.util.game.init")

local mod_enum = data.mod.enum

---@class ScarBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param hitzone table<string, integer>
---@param scar app.EnemyScar
---@param scar_part app.cEmModuleScar.cScarParts
---@return ScarBox
function this:new(hitzone, scar, scar_part)
    local o = box_base.new(self, mod_enum.box.ScarBox, mod_enum.shape.Sphere)
    ---@cast o ScarBox
    setmetatable(o, self)
    o.show = false
    o.highlight = false
    o.hitzone = hitzone
    o.condition = mod_enum.condition_result.None
    o.condition_color = 0
    o._scar = scar
    o._scar_part = scar_part
    o.shape_data.radius = scar._ColSizeRadius
    return o
end

function this:update_shape()
    self.shape_data.pos = self._scar:get_Pos()
    self.pos = self.shape_data.pos
    self.distance = (util_game.get_camera_origin() - self.pos):length()
    return mod_enum.box_state.Draw
end

function this:update_data()
    local config_mod = config.current.mod

    if
        not self.is_enabled
        or (not self.show and self.condition ~= mod_enum.condition_result.Highlight)
    then
        return mod_enum.box_state.None
    end

    if self.highlight then
        self.color = config_mod.hurtboxes.color.highlight
    elseif self.condition == mod_enum.condition_result.Highlight then
        self.color = self.condition_color
    else
        self.color = config_mod.hurtboxes.color.BigMonster
    end
    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update()
    self.state = e.get("app.cEmModuleScar.cScarParts.STATE")[self._scar_part:get_State()]
    self.is_enabled = not self._scar_part:get_IsForceDisableCollision()
    self.condition, self.condition_color = conditions.check_scar(self.state)
    return box_base.update(self)
end

return this
