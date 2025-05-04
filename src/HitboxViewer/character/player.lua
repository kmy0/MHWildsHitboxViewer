---@class (exact) Player : FriendCharacter
---@field status_flags ace.cSafeContinueFlagGroup
---@field base app.HunterCharacter
---@field weapon Weapon
---@field guard_type GuardType?
---@field direction Vector3f
---@field front_col via.physics.Collidable
---@field center_col via.physics.Collidable
---@field hurtboxes table<via.physics.Collidable, PlayerHurtBox>

---@class (exact) Weapon
---@field userdata app.user_data.WpActionParamBase
---@field type app.WeaponDef.TYPE

local char_base = require("HitboxViewer.character.char_base")
local data = require("HitboxViewer.data")
local table_util = require("HitboxViewer.table_util")
local util = require("HitboxViewer.util")

local rt = data.runtime

---@class Player
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = char_base })

---@param type CharType
---@param base app.HunterCharacter
---@param name string
---@return Player
function this:new(type, base, name)
    local o = char_base.new(self, type, base, name)
    ---@cast o Player
    setmetatable(o, self)

    local status = base:get_HunterStatus()
    local rsc = util.get_component(o.game_object, "via.physics.RequestSetCollider") --[[@as via.physics.RequestSetCollider]]

    o.status_flags = status._HunterStatusFlag
    o.direction = Vector3f.new(0, 0, 0)
    o.front_col = rsc:getCollidableFromIndex(2, 0, 0)
    o.center_col = rsc:getCollidableFromIndex(2, 2, 0)

    this.update_weapon(o)
    return o
end

function this:update_weapon()
    if not self.weapon then
        ---@diagnostic disable-next-line: missing-fields
        self.weapon = {}
    end

    local weapon_type = self.base:get_WeaponType()
    if weapon_type ~= self.weapon.type then
        self.weapon.userdata = rt.get_catalog():getWeaponActionParam(weapon_type)
        self.weapon.type = weapon_type
    end
end

function this:update_guard_type()
    self.guard_type = nil
    for i = 0, #rt.map.guard_order do
        local guard_type = rt.map.guard_order[i]
        if self.status_flags:check(guard_type) then
            self.guard_type = guard_type
            return
        end
    end
end

function this:update_direction()
    local front_pos = util.calcCollidableCenter:call(nil, self.front_col) --[[@as Vector3f]]
    local center_pos = util.calcCollidableCenter:call(nil, self.center_col) --[[@as Vector3f]]
    local dir = front_pos - center_pos
    dir:normalize()
    self.direction.x = dir.x
    self.direction.z = dir.z
    self.direction.y = dir.y
end

---@return HurtBoxBase[]?
function this:update_hurtboxes()
    if self:is_hurtbox_disabled() then
        return
    end

    self:update_weapon()
    self:update_guard_type()

    if self.guard_type then
        self:update_direction()
    end

    local ret = {}
    for col, box in pairs(self.hurtboxes) do
        local box_state, boxes = box:update()
        if box_state == rt.enum.box_state.Draw and boxes then
            table.move(boxes, 1, #boxes, #ret + 1, ret)
        elseif box_state == rt.enum.box_state.Dead then
            self.hurtboxes[col] = nil
        end
    end

    if not table_util.empty(ret) then
        return ret
    end
end

return this
