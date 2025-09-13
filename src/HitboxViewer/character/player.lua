---@class (exact) Player : FriendCharacter
---@field status_flags ace.cSafeContinueFlagGroup
---@field base app.HunterCharacter
---@field weapon Weapon
---@field guard_type string?
---@field direction Vector3f
---@field overwrite_guard_direction Vector3f?
---@field front_col via.physics.Collidable
---@field center_col via.physics.Collidable
---@field hurtboxes table<via.physics.Collidable, PlayerHurtBox>

---@class (exact) Weapon
---@field userdata app.user_data.WpActionParamBase
---@field handling app.cHunterWeaponHandlingBase
---@field type app.WeaponDef.TYPE

local char_base = require("HitboxViewer.character.char_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local game_data = require("HitboxViewer.util.game.data")
local util = require("HitboxViewer._util")
local util_table = require("HitboxViewer.util.misc.table")

local mod = data.mod
local rl = game_data.reverse_lookup
local ace = data.ace

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
        self.weapon.userdata = s.get("app.PlayerManager"):getWeaponActionParam(weapon_type)
        self.weapon.type = weapon_type
        self.weapon.handling = self.base:get_WeaponHandling()
    end
end

function this:update_guard_type()
    self.guard_type = nil
    for i = 1, #ace.map.guard_names do
        local guard_type = ace.map.guard_names[i]
        local guard_flag = rl(data.ace.enum.hunter_status_flag, guard_type)

        if self.status_flags:check(guard_flag) then
            self.guard_type = guard_type
            if not config.current.hurtboxes.guard_type.disable[self.guard_type] then
                return
            end
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

function this:update_overwrite_guard_direction()
    self.overwrite_guard_direction = self.weapon.handling:getOverwriteGuardDir()
    if
        self.overwrite_guard_direction.x == 0
        and self.overwrite_guard_direction.y == 0
        and self.overwrite_guard_direction.z == 0
    then
        self.overwrite_guard_direction = nil
    else
        -- its inverted for whatever reason
        self.overwrite_guard_direction.x = -self.overwrite_guard_direction.x
        self.overwrite_guard_direction.y = -self.overwrite_guard_direction.y
        self.overwrite_guard_direction.z = -self.overwrite_guard_direction.z
    end
end

function this:get_guard_direction()
    if self.overwrite_guard_direction then
        return self.overwrite_guard_direction
    end
    return self.direction
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
        self:update_overwrite_guard_direction()
    end

    local ret = {}
    for col, box in pairs(self.hurtboxes) do
        local box_state, boxes = box:update()
        if box_state == mod.enum.box_state.Draw and boxes then
            table.move(boxes, 1, #boxes, #ret + 1, ret)
        elseif box_state == mod.enum.box_state.Dead then
            self.hurtboxes[col] = nil
        end
    end

    if not util_table.empty(ret) then
        return ret
    end
end

return this
