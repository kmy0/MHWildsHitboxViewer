local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local dummybox = require("HitboxViewer.box.dummy")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local state = require("HitboxViewer.gui.state")

local mod_enum = data.mod.enum

local this = {}

---@param label string
---@param value Vector3f
---@param min number?
---@param max number?
local function drag_float3(label, value, min, max)
    min = min or math.min(value.x, value.y, value.z) - 1000
    max = max or math.max(value.x, value.y, value.z) + 1000
    local _, ret = imgui.drag_float3(label, value, 0.1, min, max)
    return ret
end

---@param label string
---@param value number
---@param min number?
---@param max number?
local function drag_float(label, value, min, max)
    min = min or 0.1
    max = max or value + 1000
    local _, ret = imgui.drag_float(label, value, 0.1, min, max)
    return ret
end

---@param vec Vector3f
---@return Matrix4x4f
local function euler_to_matrix(vec)
    local x = math.rad(vec.x)
    local y = math.rad(vec.y)
    local z = math.rad(vec.z)
    local cx = math.cos(x)
    local sx = math.sin(x)
    local cy = math.cos(y)
    local sy = math.sin(y)
    local cz = math.cos(z)
    local sz = math.sin(z)

    return Matrix4x4f.new(
        cy * cz,
        -cy * sz,
        sy,
        0,
        cx * sz + sx * sy * cz,
        cx * cz - sx * sy * sz,
        -sx * cy,
        0,
        sx * sz - cx * sy * cz,
        sx * cz + cx * sy * sz,
        cx * cy,
        0,
        0,
        0,
        0,
        1
    )
end

---@param matrix Matrix4x4f
---@return Vector3f
local function matrix_to_euler(matrix)
    ---@type number, number, number
    local m11, m12, m13 = matrix[0].x, matrix[0].y, matrix[0].z
    ---@type number, number, number
    local _, _, m23 = matrix[1].x, matrix[1].y, matrix[1].z
    ---@type number, number, number
    local _, _, m33 = matrix[2].x, matrix[2].y, matrix[2].z

    local y = math.asin(m13)
    local x = math.atan(-m23, m33)
    local z = math.atan(-m12, m11)

    return Vector3f.new(math.deg(x), math.deg(y), math.deg(z))
end

function this.draw()
    if imgui.collapsing_header(gui_util.tr("mod.header_dummyboxes")) then
        local master_player = char.get_master_player()
        local config_mod = config.current.mod
        set:combo("##dummy_shape_spawner", "mod.dummyboxes.combo_shape", state.combo.shape.values)
        local shape = state.combo.shape:get_key(config_mod.dummyboxes.combo_shape)
        imgui.same_line()

        if imgui.button(gui_util.tr("mod.button_spawn")) then
            if master_player then
                master_player:add_dummybox(dummybox:new(shape, master_player))
            end
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("mod.button_clear")) then
            if master_player then
                master_player:clear_dummyboxes()
            end
        end

        set:color_edit(gui_util.tr("mod.color_dummy"), "mod.dummyboxes.color")

        ---@type DummyBox?
        local dummy_shape
        if master_player then
            dummy_shape = master_player:get_dummy(shape)
        end

        imgui.begin_disabled(not dummy_shape)

        local shape_data = dummy_shape and dummy_shape.shape_data or {}

        if shape == mod_enum.shape.Sphere then
            shape_data.pos =
                drag_float3(gui_util.tr("mod.slider_pos"), shape_data.pos or Vector3f.new(0, 0, 0))
            shape_data.radius = drag_float(gui_util.tr("mod.slider_radius"), shape_data.radius or 0)
        elseif shape == mod_enum.shape.Capsule or shape == mod_enum.shape.Cylinder then
            shape_data.pos_a = drag_float3(
                gui_util.tr("mod.slider_pos_a"),
                shape_data.pos_a or Vector3f.new(0, 0, 0)
            )
            shape_data.pos_b = drag_float3(
                gui_util.tr("mod.slider_pos_b"),
                shape_data.pos_b or Vector3f.new(0, 0, 0)
            )
            shape_data.radius = drag_float(gui_util.tr("mod.slider_radius"), shape_data.radius or 0)
        elseif shape == mod_enum.shape.SlicedCylinder then
            shape_data.pos_a = drag_float3(
                gui_util.tr("mod.slider_pos_a"),
                shape_data.pos_a or Vector3f.new(0, 0, 0)
            )
            shape_data.pos_b = drag_float3(
                gui_util.tr("mod.slider_pos_b"),
                shape_data.pos_b or Vector3f.new(0, 0, 0)
            )
            shape_data.radius = drag_float(gui_util.tr("mod.slider_radius"), shape_data.radius or 0)
            shape_data.direction = drag_float3(
                gui_util.tr("mod.slider_direction"),
                shape_data.direction or Vector3f.new(0, 0, 0),
                0,
                1
            )
            shape_data.degrees =
                drag_float(gui_util.tr("mod.slider_degrees"), shape_data.degrees or 0, nil, 360)
        elseif shape == mod_enum.shape.Box or shape == mod_enum.shape.Triangle then
            shape_data.pos =
                drag_float3(gui_util.tr("mod.slider_pos"), shape_data.pos or Vector3f.new(0, 0, 0))
            shape_data.extent = drag_float3(
                gui_util.tr("mod.slider_extent"),
                shape_data.extent or Vector3f.new(0, 0, 0)
            )
            local rot = drag_float3(
                gui_util.tr("mod.slider_rot"),
                matrix_to_euler(shape_data.rot or Matrix4x4f.new()),
                0,
                180
            )
            shape_data.rot = euler_to_matrix(rot)
        elseif shape == mod_enum.shape.Triangle then
        end

        imgui.end_disabled()
    end
end

return this
