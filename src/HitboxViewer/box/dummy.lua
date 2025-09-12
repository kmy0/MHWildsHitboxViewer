local box_base = require("HitboxViewer.box.box_base")
local character = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local draw_queue = require("HitboxViewer.draw_queue")
local util_table = require("HitboxViewer.util.misc.table")

local mod = data.mod

local this = {}

---@type table<ShapeType, DummyBox>
local active_dummies = {}
local dummy_shapes = {
    ---@type SphereShape
    [mod.enum.shape.Sphere] = {
        pos = Vector3f.new(0, 1, 0),
        radius = 2,
    },
    ---@type CylinderShape
    [mod.enum.shape.Cylinder] = {
        pos_a = Vector3f.new(-1, 2, 0),
        pos_b = Vector3f.new(3, 1, 0),
        radius = 2,
    },
    ---@type CylinderShape
    [mod.enum.shape.Capsule] = {
        pos_a = Vector3f.new(-1, 2, 0),
        pos_b = Vector3f.new(3, 1, 0),
        radius = 2,
    },
    ---@type BoxShape
    [mod.enum.shape.Box] = {
        pos = Vector3f.new(0, 2, 0),
        extent = Vector3f.new(3, 1, 2),
        rot = Matrix4x4f.new(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    },
    ---@type BoxShape
    [mod.enum.shape.Triangle] = {
        pos = Vector3f.new(0, 2, 0),
        extent = Vector3f.new(3, 1, 2),
        rot = Matrix4x4f.new(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    },
}

---@class DummyBox : BoxBase
local DummyBox = {}
DummyBox.__index = DummyBox
setmetatable(DummyBox, { __index = box_base })

---@param box_type BoxType
---@param shape_type ShapeType
---@return DummyBox
function DummyBox:new(box_type, shape_type)
    local o = box_base.new(self, box_type, shape_type)
    ---@cast o DummyBox
    setmetatable(o, self)
    local pos = character.get_master_player():get_pos()

    o.shape_data = util_table.deep_copy(dummy_shapes[shape_type]) --[[@as ShapeData]]
    if o.shape_type == mod.enum.shape.Cylinder or o.shape_type == mod.enum.shape.Capsule then
        o.shape_data.pos_a = o.shape_data.pos_a + pos
        o.shape_data.pos_b = o.shape_data.pos_b + pos
        o.pos = (o.shape_data.pos_a + o.shape_data.pos_b) * 0.5
    else
        o.shape_data.pos = o.shape_data.pos + pos
        o.pos = o.shape_data.pos
    end
    return o
end

function DummyBox:update_data()
    self.color = config.current.mod.hurtboxes.color.one_color
    return mod.enum.box_state.Draw
end

function DummyBox:update_shape()
    local master_player = character.get_master_player()
    if not master_player then
        return mod.enum.box_state.None
    end

    local pos = master_player:get_pos()
    if (self.pos - pos):length() > config.current.mod.draw.distance then
        return mod.enum.box_state.None
    end
    return mod.enum.box_state.Draw
end

function this.get()
    for _, dummy_box in pairs(active_dummies) do
        local box_state = dummy_box:update()
        if box_state == mod.enum.box_state.Draw then
            draw_queue:extend({ dummy_box })
        end
    end
end

function this.clear()
    active_dummies = {}
end

---@param shape_enum ShapeType
function this.spawn(shape_enum)
    if not character.get_master_player() then
        return
    end
    active_dummies[shape_enum] = DummyBox:new(mod.enum.box.DummyBox, shape_enum)
end

return this
