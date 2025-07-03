---@class (exact) PressBoxBase : CollidableBase
---@field press_level string
---@field layer string

local colldable_base = require("HitboxViewer.box.collidable_base")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local ace = data.ace
local rt = data.runtime
local rl = data.util.reverse_lookup

---@class PressBoxBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = colldable_base })

---@param collidable via.physics.Collidable
---@param parent Character
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@param press_data app.col_user_data.PressParam
---@return PressBoxBase?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx, press_data)
    local o = colldable_base.new(self, collidable, parent, rt.enum.box.HurtBox, resource_idx, set_idx, collidable_idx)

    if not o then
        return
    end

    ---@cast o PressBoxBase
    setmetatable(o, self)
    o.press_level = ace.enum.press_level[press_data:get_PressLevel()]

    local filter_info = collidable:get_FilterInfo()
    o.layer = ace.enum.col_layer[filter_info:get_Layer()]

    return o
end

---@return BoxState
function this:update_data()
    if
        config.current.pressboxes.press_level.disable[self.press_level]
        or config.current.pressboxes.layer.disable[self.layer]
    then
        return rt.enum.box_state.None
    end

    if config.current.pressboxes.use_one_color then
        self.color = config.current.pressboxes.color.one_color
    elseif config.current.pressboxes.press_level.color_enable[self.press_level] then
        self.color = config.current.pressboxes.press_level.color[self.press_level]
    elseif config.current.pressboxes.layer.color_enable[self.layer] then
        self.color = config.current.pressboxes.layer.color[self.layer]
    else
        self.color = config.current.pressboxes.color[rl(rt.enum.char, self.parent.type)]
    end

    return rt.enum.box_state.Draw
end

return this
