local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

---@type BoxObj[]
local draw_queue = {}

local this = {}

---@param box BoxObj
function this.enqueue(box)
    table.insert(draw_queue, box)
end

---@param box BoxObj
local function draw_shape(box)
    if box.shape_type == data.shape_enum.Capsule or box.shape_type == data.shape_enum.ContinuousCapsule then
        hb_draw.capsule(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == data.shape_enum.Sphere or box.shape_type == data.shape_enum.ContinuousSphere then
        hb_draw.sphere(
            box.shape_data.pos,
            box.shape_data.radius,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == data.shape_enum.Box then
        hb_draw.box(
            box.shape_data.pos,
            box.shape_data.extent,
            box.shape_data.rot,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == data.shape_enum.Cylinder then
        hb_draw.cylinder(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    elseif box.shape_type == data.shape_enum.Triangle then
        hb_draw.triangle(
            box.shape_data.pos,
            box.shape_data.extent,
            box.shape_data.rot,
            box.color,
            config.current.draw.outline,
            config.current.draw.outline_color
        )
    end
end

---@param x BoxObj
---@param y BoxObj
---@return boolean
local function sort_boxes(x, y)
    if x.distance > y.distance then
        return true
    elseif x.distance == y.distance then
        if x.type == data.box_enum.Hurtbox and y.type == data.box_enum.Hitbox then
            return true
        elseif x.type == y.type then
            return x.sort < y.sort
        end
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
