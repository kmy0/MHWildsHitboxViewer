---@class (exact) Character
---@field type CharType
---@field type_name string
---@field base app.CharacterBase
---@field game_object via.GameObject
---@field distance number
---@field pos Vector3f
---@field name string
---@field id integer
---@field hurtboxes table<via.physics.Collidable, HurtBoxBase>
---@field hitboxes table<via.physics.Collidable, HitBoxBase>
---@field pressboxes table<via.physics.Collidable, PressBoxBase>
---@field collisionboxes table<via.physics.Collidable | CollisionBox | ContactPoint, CollisionBox | ContactPoint>
---@field dummyboxes table<ShapeType, DummyBox>
---@field hitbox_userdata_cache table<app.col_user_data.AttackParam | app.col_user_data.DamageParam, AttackLogEntry>
---@field collidable_to_indexes table<via.physics.Collidable, {
--- resource_idx: integer,
--- set_idx: integer,
--- collidable_idx: integer,
--- }>
---@field order integer
---@field last_update_tick integer

local collisionbox = require("HitboxViewer.box.collision.collisionbox")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local util_misc = require("HitboxViewer.util.misc.init")
local util_ref = require("HitboxViewer.util.ref.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

local count = 0

---@class Character
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param type CharType
---@param base app.CharacterBase
---@param name string
---@param game_object via.GameObject?
---@return Character
function this:new(type, base, name, game_object)
    game_object = not game_object and base:get_GameObject() or game_object --[[@as via.GameObject]]

    ---@type Character
    local o = {
        type = type,
        type_name = mod_enum.char[type],
        base = base,
        game_object = game_object,
        name = name,
        id = game_object:get_address(),
        order = count,
        pos = Vector3f.new(0, 0, 0),
        distance = 0,
        hurtboxes = {},
        hitboxes = {},
        pressboxes = {},
        dummyboxes = {},
        collisionboxes = {},
        hitbox_userdata_cache = {},
        collidable_to_indexes = {},
        last_update_tick = 0,
    }
    count = count + 1
    setmetatable(o, self)
    return o
end

---@return Vector3f
function this:get_pos()
    self.pos = self.base:get_Pos()
    return self.pos
end

---@return boolean
function this:is_dead()
    return not self:is_valid()
end

---@param box HurtBoxBase
function this:add_hurtbox(box)
    self.hurtboxes[box.collidable] = box
end

---@param box HitBoxBase
function this:add_hitbox(box)
    self.hitboxes[box.collidable] = box
end

---@param box PressBoxBase
function this:add_pressbox(box)
    self.pressboxes[box.collidable] = box
end

---@param key via.physics.Collidable | CollisionBox | ContactPoint
---@param box CollisionBox | ContactPoint
function this:add_collisionbox(key, box)
    self.collisionboxes[key] = box
end

---@param box DummyBox
function this:add_dummybox(box)
    self.dummyboxes[box.shape_type] = box
end

function this:clear_dummyboxes()
    self.dummyboxes = {}
end

---@param box_shape ShapeType
---@return DummyBox?
function this:get_dummy(box_shape)
    return self.dummyboxes[box_shape]
end

---@param key_a via.physics.Collidable | CollisionBox
---@param key_b via.physics.Collidable | CollisionBox
function this:remove_contact_point(key_a, key_b)
    local box = self.collisionboxes[key_a] or self.collisionboxes[key_b] --[[@as CollisionBox?]]
    if box then
        box:remove_contact_point()
    end
end

---@param col via.physics.Collidable
---@return boolean
function this:has_hitbox(col)
    return self.hitboxes[col] ~= nil
end

---@param col via.physics.Collidable
---@return boolean
function this:has_collisionbox(col)
    return self.collisionboxes[col] ~= nil
end

---@return boolean
function this:any_collisionbox()
    return not util_table.empty(self.collisionboxes)
end

---@param pos Vector3f
---@return boolean
function this:update_distance(pos)
    self.distance = (pos - self:get_pos()):length()
    return not self:is_out_of_range()
end

---@return boolean
function this:is_out_of_range()
    return self.distance > config.current.mod.draw.distance
end

---@return boolean
function this:is_disabled()
    return self:is_hurtbox_disabled()
        and self:is_hitbox_disabled()
        and self:is_pressbox_disabled()
        and self:is_collisionbox_disabled()
        and self:is_dummybox_disabled()
end

---@return boolean
function this:is_hurtbox_disabled()
    return config.current.mod.hurtboxes.disable[self.type_name]
end

---@return boolean
function this:is_hitbox_disabled()
    return config.current.mod.hitboxes.disable[self.type_name]
end

---@return boolean
function this:is_pressbox_disabled()
    return config.current.mod.pressboxes.disable[self.type_name]
end

---@return boolean
function this:is_collisionbox_disabled()
    return not config.current.mod.enabled_collisionboxes
end

function this:is_dummybox_disabled()
    return true
end

---@protected
---@param boxes table<via.physics.Collidable, CollidableBase>
---@param on_remove_callback fun(key: any, box: BoxBase)?
---@return HurtBoxBase[]?
function this:_update_boxes(boxes, on_remove_callback)
    local ret = {}
    for col, box in pairs(boxes) do
        local box_state = box:update()
        if box_state == mod_enum.box_state.Draw then
            table.insert(ret, box)
        elseif box_state == mod_enum.box_state.Dead then
            boxes[col] = nil
            if on_remove_callback then
                on_remove_callback(col, box)
            end
        end
    end

    if not util_table.empty(ret) then
        return ret
    end
end

---@return HurtBoxBase[]?
function this:update_hurtboxes()
    if self:is_hurtbox_disabled() then
        return
    end
    return self:_update_boxes(self.hurtboxes)
end

---@return HitBoxBase[]?
function this:update_hitboxes()
    if self:is_hitbox_disabled() then
        return
    end

    return self:_update_boxes(self.hitboxes)
end

---@return PressBoxBase[]?
function this:update_pressboxes()
    if self:is_pressbox_disabled() then
        return
    end

    return self:_update_boxes(self.pressboxes)
end

---@return CollisionBox | ContactPoint[]?
function this:update_collisionboxes()
    if self:is_collisionbox_disabled() then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    return self:_update_boxes(self.collisionboxes, collisionbox.on_remove_callback)
end

---@return DummyBox[]?
function this:update_dummyboxes()
    if self:is_dummybox_disabled() then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    return self:_update_boxes(self.dummyboxes)
end

---@param char app.CharacterBase?
function this:is_valid(char)
    local ret = false
    util_misc.try(function()
        char = char or self.base
        if not char then
            return
        end

        ret = char:get_Valid() and not util_ref.is_only_my_ref(char)
    end)
    return ret
end

return this
