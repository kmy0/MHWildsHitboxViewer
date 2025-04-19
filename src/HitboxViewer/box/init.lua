---@class (exact) Box
---@field parent CharObj
---@field enabled boolean
---@field sort integer
---@field collidable via.physics.Collidable
---@field pos Vector3f
---@field distance number
---@field shape via.physics.Shape
---@field color integer
---@field type BoxType
---@field userdata via.physics.UserData
---@field shape_type ShapeType
---@field shape_data ShapeData
---@field update fun(self: Box): BoxState
---@field _update_data fun(self: Box): BoxState
---@field _update_shape fun(self: Box): BoxState

---@class (exact) FriendHurtbox : Box
---@class (exact) EnemyHurtbox : FriendHurtbox
---@field meat_data app.col_user_data.DamageParamEm
---@field part_group PartGroup?

---@class (exact) Hitbox : Box
---@field log_entry AttackLogEntry
---@field shellcolhit app.mcShellColHit?
---@field shown boolean
---@field tick integer
---@field is_done fun(self: Hitbox): boolean

---@class (partial) Scarbox : Box
---@field pos Vector3f
---@field sort integer
---@field distance number
---@field color integer
---@field type BoxType
---@field shape_type ShapeType
---@field shape_data ShapeData
---@field scar Scar
---@field update fun(self: Scarbox): BoxState
---@field _update_data fun(self: Scarbox): BoxState
---@field _update_shape fun(self: Scarbox): BoxState

---@class (exact) CylinderShape
---@field pos_a Vector3f
---@field pos_b Vector3f
---@field radius number

---@class (exact) BoxShape
---@field pos Vector3f
---@field extent Vector3f
---@field rot Matrix4x4f

---@class (exact) SphereShape
---@field pos Vector3f
---@field radius number

---@alias ShapeData CylinderShape | BoxShape | SphereShape
---@alias Hurtbox FriendHurtbox | EnemyHurtbox
---@alias BoxObj Hurtbox | Hitbox | Scarbox

local character = require("HitboxViewer.character")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local rt = data.runtime
local ace = data.ace

local this = {}

---@param self BoxObj
---@return BoxState
local function update(self)
    if
        self.type ~= rt.enum.box.Scarbox
        and (
            self.collidable:get_reference_count() <= 1
            -- For whatever reason shell collidable reference count sometimes stays forever at 2.

            -- Collidable also stays forever enabled, even when its clearly not. 'isCollidableValid' sometimes returns false

            -- for new shells

            or self.shellcolhit and self.shellcolhit:get_reference_count() <= 1
        )
    then
        return rt.enum.box_state.Dead
    end

    if self:_update_data() == rt.enum.box_state.Draw then
        return self:_update_shape()
    end
    return rt.enum.box_state.None
end

---@param self Box
---@return BoxState
local function update_shape(self)
    self.enabled = self.collidable:read_byte(0x10) ~= 0
    if self.enabled then
        if
            self.shape_type == rt.enum.shape.Capsule
            or self.shape_type == rt.enum.shape.Cylinder
            or self.shape_type == rt.enum.shape.ContinuousCapsule
        then
            self.shape_data.pos_a.x = self.shape:read_float(0x60)
            self.shape_data.pos_a.y = self.shape:read_float(0x64)
            self.shape_data.pos_a.z = self.shape:read_float(0x68)
            self.shape_data.pos_b.x = self.shape:read_float(0x70)
            self.shape_data.pos_b.y = self.shape:read_float(0x74)
            self.shape_data.pos_b.z = self.shape:read_float(0x78)
            self.shape_data.radius = self.shape:read_float(0x80)

            self.pos = (self.shape_data.pos_a + self.shape_data.pos_b) * 0.5
        elseif self.shape_type == rt.enum.shape.Sphere or self.shape_type == rt.enum.shape.ContinuousSphere then
            self.shape_data.pos.x = self.shape:read_float(0x60)
            self.shape_data.pos.y = self.shape:read_float(0x64)
            self.shape_data.pos.z = self.shape:read_float(0x68)
            self.shape_data.radius = self.shape:read_float(0x6c)

            self.pos = self.shape_data.pos
        elseif self.shape_type == rt.enum.shape.Box or self.shape_type == rt.enum.shape.Triangle then
            self.shape_data.pos.x = self.shape:read_float(0x90)
            self.shape_data.pos.y = self.shape:read_float(0x94)
            self.shape_data.pos.z = self.shape:read_float(0x98)
            self.shape_data.extent.x = self.shape:read_float(0xa0)
            self.shape_data.extent.y = self.shape:read_float(0xa4)
            self.shape_data.extent.z = self.shape:read_float(0xa8)
            self.shape_data.rot[0].x = self.shape:read_float(0x60)
            self.shape_data.rot[0].y = self.shape:read_float(0x64)
            self.shape_data.rot[0].z = self.shape:read_float(0x68)
            self.shape_data.rot[1].x = self.shape:read_float(0x70)
            self.shape_data.rot[1].y = self.shape:read_float(0x74)
            self.shape_data.rot[1].z = self.shape:read_float(0x78)
            self.shape_data.rot[2].x = self.shape:read_float(0x80)
            self.shape_data.rot[2].y = self.shape:read_float(0x84)
            self.shape_data.rot[2].z = self.shape:read_float(0x88)

            self.pos = self.shape_data.pos
        end

        self.distance = (character.get_master_player().pos - self.pos):length()
        return rt.enum.box_state.Draw
    end
    return rt.enum.box_state.None
end

---@param collidable via.physics.Collidable
---@param parent CharObj
---@param update_data_func fun(box: Box): BoxState
---@return Box?
function this.box_ctor(collidable, parent, update_data_func)
    local shape = collidable:get_TransformedShape()
    local shape_name = ace.enum.shape[shape:get_ShapeType()]
    local shape_type = rt.enum.shape[shape_name]

    if not shape_type then
        rt.state.missing_shapes[shape_name] = true
        return
    end

    ---@type Box
    local ret = {
        parent = parent,
        enabled = true,
        collidable = collidable,
        sort = 0,
        pos = Vector3f.new(0, 0, 0),
        distance = 0,
        shape = shape,
        type = rt.enum.box.Hurtbox,
        userdata = collidable:get_UserData(),
        color = config.default_color,
        shape_type = shape_type,
        ---@diagnostic disable-next-line: missing-fields
        shape_data = {},
        update = update,
        _update_shape = update_shape,
        _update_data = update_data_func,
    }

    if
        shape_type == rt.enum.shape.Capsule
        or shape_type == rt.enum.shape.Cylinder
        or shape_type == rt.enum.shape.ContinuousCapsule
    then
        ret.shape_data.pos_a = Vector3f.new(0, 0, 0)
        ret.shape_data.pos_b = Vector3f.new(0, 0, 0)
        ret.shape_data.radius = 0
    elseif shape_type == rt.enum.shape.Sphere or shape_type == rt.enum.shape.ContinuousSphere then
        ret.shape_data.pos = Vector3f.new(0, 0, 0)
        ret.shape_data.radius = 0
    elseif shape_type == rt.enum.shape.Box or shape_type == rt.enum.shape.Triangle then
        ret.shape_data.pos = Vector3f.new(0, 0, 0)
        ret.shape_data.extent = Vector3f.new(0, 0, 0)
        ret.shape_data.rot = Matrix4x4f.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
    end

    return ret
end

---@param collidable via.physics.Collidable
---@param parent CharObj
---@param update_data_func fun(box: Hitbox): BoxState
---@param log_entry AttackLogEntry
---@param shellcolhit app.mcShellColHit?
---@return Hitbox?
function this.hitbox_ctor(collidable, parent, update_data_func, log_entry, shellcolhit)
    local hitbox = this.box_ctor(collidable, parent, update_data_func)
    if hitbox then
        ---@cast hitbox Hitbox
        hitbox.log_entry = log_entry
        hitbox.type = rt.enum.box.Hitbox
        hitbox.shellcolhit = shellcolhit
        hitbox.shown = false
        hitbox.tick = rt.state.tick_count
        hitbox.is_done = function(self)
            return self.shown or (not self.shown and rt.state.tick_count - self.tick > 1200)
        end
    end
    return hitbox
end

---@param collidable via.physics.Collidable
---@param parent CharObj
---@param update_data_func fun(box: EnemyHurtbox): BoxState
---@param userdata app.col_user_data.DamageParamEm
---@return EnemyHurtbox?
function this.enemy_hurtbox_ctor(collidable, parent, update_data_func, userdata)
    if userdata:get_RuntimeData()._PartsIndex < 0 then
        return
    end

    local hurtbox = this.box_ctor(collidable, parent, update_data_func)
    ---@cast hurtbox EnemyHurtbox
    hurtbox.meat_data = userdata
    return hurtbox
end

---@param scar Scar
---@param radius number
---@param update_data_func fun(box: Scarbox): BoxState
---@param update_shape_func fun(box: Scarbox): BoxState
---@return Scarbox
function this.scarbox_ctor(scar, radius, update_data_func, update_shape_func)
    ---@type Scarbox
    return {
        sort = 0,
        pos = Vector3f.new(0, 0, 0),
        distance = 0,
        scar = scar,
        type = rt.enum.box.Scarbox,
        color = config.default_color,
        shape_type = rt.enum.shape.Sphere,
        shape_data = {
            pos = Vector3f.new(0, 0, 0),
            radius = radius,
        },
        update = update,
        _update_shape = update_shape_func,
        _update_data = update_data_func,
    }
end

return this
