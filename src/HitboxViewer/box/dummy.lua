---@class DummyBox
---@field sort integer
---@field distance integer
---@field color integer
---@field pos Vector3f
---@field shape_data ShapeData
---@field shape_type ShapeType

local character = require("HitboxViewer.character")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local hb_draw = require("HitboxViewer.hb_draw")
local table_util = require("HitboxViewer.table_util")

local this = {}

---@type table<ShapeType, DummyBox>
local active_dummies = {}
local dummy_shapes = {
    ---@type SphereShape
    [data.shape_enum.Sphere] = {
        pos = Vector3f.new(0, 1, 0),
        radius = 2,
    },
    ---@type CylinderShape
    [data.shape_enum.Cylinder] = {
        pos_a = Vector3f.new(-1, 2, 0),
        pos_b = Vector3f.new(3, 1, 0),
        radius = 2,
    },
    ---@type CylinderShape
    [data.shape_enum.Capsule] = {
        pos_a = Vector3f.new(-1, 2, 0),
        pos_b = Vector3f.new(3, 1, 0),
        radius = 2,
    },
    ---@type BoxShape
    [data.shape_enum.Box] = {
        pos = Vector3f.new(0, 2, 0),
        extent = Vector3f.new(3, 1, 2),
        rot = Matrix4x4f.new(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    },
    ---@type BoxShape
    [data.shape_enum.Triangle] = {
        pos = Vector3f.new(0, 2, 0),
        extent = Vector3f.new(3, 1, 2),
        rot = Matrix4x4f.new(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    },
}

function this.get()
    local mp = character.get_master_player()
    if not next(active_dummies) or not mp then
        return
    end

    local pos = mp:get_pos()
    for _, col_data in pairs(active_dummies) do
        if (col_data.pos - pos):length() > config.current.draw.distance then
            goto next
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        hb_draw.enqueue(col_data)
        ::next::
    end
end

function this.clear()
    active_dummies = {}
end

---@param shape_enum ShapeType
function this.spawn(shape_enum)
    local mp = character.get_master_player()
    if not mp then
        return
    end

    ---@type DummyBox
    local dummy_box = {
        sort = 0,
        distance = 0,
        pos = Vector3f.new(0, 0, 0),
        color = config.current.hurtboxes.color.MasterPlayer,
        shape_data = table_util.table_copy(dummy_shapes[shape_enum]),
        shape_type = shape_enum,
    }
    local pos = mp:get_pos()
    if pos then
        if shape_enum == data.shape_enum.Cylinder or shape_enum == data.shape_enum.Capsule then
            dummy_box.shape_data.pos_a = dummy_box.shape_data.pos_a + pos
            dummy_box.shape_data.pos_b = dummy_box.shape_data.pos_b + pos
            dummy_box.pos = (dummy_box.shape_data.pos_a + dummy_box.shape_data.pos_b) * 0.5
        else
            dummy_box.shape_data.pos = dummy_box.shape_data.pos + pos
            dummy_box.pos = dummy_box.shape_data.pos
        end

        active_dummies[shape_enum] = dummy_box
    end
end

return this
