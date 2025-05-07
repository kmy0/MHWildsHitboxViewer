---@class DrawQueue : QueueBase
---@field queue BoxBase[]
---@field sorted boolean
---@field enqueue fun(self: DrawQueue , boxes: BoxBase[]?)

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.runtime

---@class DrawQueue
local this = queue_base:new()
this.sorted = false

---@param x BoxBase
---@param y BoxBase
---@return boolean
local function sort_boxes(x, y)
    if x.distance > y.distance then
        return true
    elseif x.distance == y.distance then
        return x.sort < y.sort
    end
    return false
end

---@param box BoxBase
local function draw_shape(box)
    if box.shape_type == rt.enum.shape.Capsule or box.shape_type == rt.enum.shape.ContinuousCapsule then
        hb_draw.capsule(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == rt.enum.shape.Sphere or box.shape_type == rt.enum.shape.ContinuousSphere then
        hb_draw.sphere(
            box.shape_data.pos,
            box.shape_data.radius,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == rt.enum.shape.Box then
        hb_draw.box(
            box.shape_data.pos,
            box.shape_data.extent,
            box.shape_data.rot,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == rt.enum.shape.Cylinder then
        hb_draw.cylinder(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == rt.enum.shape.Triangle then
        hb_draw.triangle(
            box.shape_data.pos,
            box.shape_data.extent,
            box.shape_data.rot,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == rt.enum.shape.SlicedCylinder then
        hb_draw.sliced_cylinder(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.shape_data.direction,
            box.shape_data.degrees,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    end
end

---@param boxes BoxBase[]?
function this:enqueue(boxes)
    if boxes then
        table.move(boxes, 1, #boxes, #self.queue + 1, self.queue)
        self.sorted = false
    end
end

function this:sort()
    table.sort(self.queue, sort_boxes)
    self.sorted = true
end

function this:draw()
    if not self.sorted then
        self:sort()
    end

    for i = 1, #self.queue do
        local box = self.queue[i]
        box.sort = i
        draw_shape(box)
    end
end

function this.clear()
    this.queue = {}
end

return this
