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
---@field hitbox_userdata_cache table<app.col_user_data.AttackParam | app.col_user_data.DamageParam, AttackLogEntry>
---@field order integer
---@field last_update_tick integer

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local table_util = require("HitboxViewer.table_util")
local util = require("HitboxViewer.util")

local rl = data.util.reverse_lookup
local rt = data.runtime

local count = 0

---@class Character
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param type CharType
---@param base app.CharacterBase
---@param name string
---@return Character
function this:new(type, base, name)
    ---@type Character
    local o = {
        type = type,
        type_name = rl(rt.enum.char, type),
        base = base,
        game_object = base:get_GameObject(),
        name = name,
        id = base:get_address(),
        order = count,
        pos = Vector3f.new(0, 0, 0),
        distance = 0,
        hurtboxes = {},
        hitboxes = {},
        hitbox_userdata_cache = {},
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
    local _, is_dead = pcall(function()
        return not self.base:get_Valid()
    end)
    return is_dead or util.is_only_my_ref(self.base)
end

---@param box HurtBoxBase
function this:add_hurtbox(box)
    self.hurtboxes[box.collidable] = box
end

---@param box HitBoxBase
function this:add_hitbox(box)
    self.hitboxes[box.collidable] = box
end

---@param col via.physics.Collidable
---@return boolean
function this:has_hitbox(col)
    return self.hitboxes[col] ~= nil
end

---@param pos Vector3f
---@return boolean
function this:update_distance(pos)
    self.distance = (pos - self:get_pos()):length()
    return not self:is_out_of_range()
end

---@return boolean
function this:is_out_of_range()
    return self.distance > config.current.draw.distance
end

---@return boolean
function this:is_disabled()
    return self:is_hurtbox_disabled() and self:is_hitbox_disabled()
end

---@return boolean
function this:is_hurtbox_disabled()
    return config.current.hurtboxes.disable[self.type_name]
end

---@return boolean
function this:is_hitbox_disabled()
    return config.current.hitboxes.disable[self.type_name]
end

---@protected
---@param boxes table<via.physics.Collidable, CollidableBase>
---@return HurtBoxBase[]?
function this:_update_boxes(boxes)
    local ret = {}
    for col, box in pairs(boxes) do
        local box_state = box:update()
        if box_state == rt.enum.box_state.Draw then
            table.insert(ret, box)
        elseif box_state == rt.enum.box_state.Dead then
            boxes[col] = nil
        end
    end

    if not table_util.empty(ret) then
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

---@return HurtBoxBase[]?
function this:update_hitboxes()
    if self:is_hitbox_disabled() then
        return
    end

    return self:_update_boxes(self.hitboxes)
end

return this
