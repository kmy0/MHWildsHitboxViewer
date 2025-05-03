local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local rt = data.runtime

---@type BoxBase[]
local draw_queue = {}

local this = {}

---@param boxes BoxBase[]?
function this.enqueue(boxes)
    if not boxes then
        return
    end
    table.move(boxes, 1, #boxes, #draw_queue + 1, draw_queue)
end

function this.clear()
    draw_queue = {}
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

function this.draw()
    table.sort(draw_queue, sort_boxes)
    for i = 1, #draw_queue do
        local box = draw_queue[i]
        box.sort = i
        draw_shape(box)
        draw_queue[i] = nil
    end
end

return this
