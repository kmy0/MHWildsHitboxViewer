---@class (exact) TrailBox : BoxBase
---@field trail_buffer nil
---@field last_pos nil
---@field o_color integer
---@field o_outline_color integer
---@field outline_color integer
---@field draw_outline boolean
---@field timer Timer
---@field updated boolean

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local timer = require("HitboxViewer.util.misc.timer")
local util_game = require("HitboxViewer.util.game.init")

local mod_enum = data.mod.enum

---@class TrailBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param box BoxBase
---@param life integer
---@return TrailBox
function this:new(box, life)
    local o = {
        o_color = box.color,
        color = box.color,
        o_outline_color = config.current.mod.draw.outline_color,
        outline_color = config.current.mod.draw.outline_color,
        draw_outline = config.current.mod.trailboxes.outline,
        timer = timer:new(life, nil, true, false, true, "time_delta"),
        shape_data = {},
        shape_type = box.shape_type,
        type = box.type,
        distance = box.distance,
        pos = box.pos:clone(),
        sort = -1,
        is_enabled = true,
        updated = false,
    }
    ---@cast o TrailBox
    setmetatable(o, self)

    o:_update_shape(box.shape_data)
    return o
end

---@protected
---@param shape_data ShapeData
function this:_update_shape(shape_data)
    for k, v in
        pairs(shape_data --[[@as table<string, userdata | number>]])
    do
        if type(v) == "userdata" then
            ---@diagnostic disable-next-line: no-unknown
            self.shape_data[k] = (v --[[@as Vector3f | Matrix4x4f]]):clone()
        else
            ---@diagnostic disable-next-line: no-unknown
            self.shape_data[k] = v
        end
    end
end

---@protected
---@param color integer
---@return integer
function this:_update_color(color)
    local life_ratio = 1.0 - (self.timer:elapsed() / self.timer.timeout)

    local a = math.floor(((color >> 24) & 0xFF) * life_ratio)
    local r = (color >> 16) & 0xFF --[[@as integer]]
    local g = (color >> 8) & 0xFF --[[@as integer]]
    local b = color & 0xFF --[[@as integer]]

    return (a << 24) | (r << 16) | (g << 8) | b
end

---@return BoxState
function this:update_data()
    if self.updated and self.timer:finished() then
        return mod_enum.box_state.Dead
    end

    if config.current.mod.trailboxes.fade then
        self.color = self:_update_color(self.o_color)
        self.outline_color = self:_update_color(self.o_outline_color)
    end

    self.updated = true
    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update_shape()
    self.distance = (util_game.get_camera_origin() - self.pos):length()
    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update()
    self:update_shape()
    return self:update_data()
end

return this
