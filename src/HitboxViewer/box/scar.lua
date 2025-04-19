local box = require("HitboxViewer.box")
local character = require("HitboxViewer.character")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local rt = data.runtime

local this = {}

---@param self Scarbox
---@return BoxState
local function update_shape(self)
    self.shape_data.pos = self.scar._scar:get_Pos()
    self.pos = self.shape_data.pos
    self.distance = (character.get_master_player().pos - self.pos):length()
    return rt.enum.box_state.Draw
end

---@param self Scarbox
---@return BoxState
local function update(self)
    if not self.scar.enabled or (not self.scar.show and self.scar.condition ~= rt.enum.condition_state.Highlight) then
        return rt.enum.box_state.None
    end

    if config.current.hurtboxes.use_one_color then
        self.color = config.current.hurtboxes.color.one_color
    elseif self.scar.highlight then
        self.color = config.current.hurtboxes.color.highlight
    elseif self.scar.condition == rt.enum.condition_state.Highlight then
        self.color = self.scar.condition_color
    else
        self.color = config.current.hurtboxes.color.BigMonster
    end
    return rt.enum.box_state.Draw
end

---@param scar Scar
---@param radius number
---@return Scarbox
function this.ctor(scar, radius)
    return box.scarbox_ctor(scar, radius, update, update_shape)
end

return this
