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

local char_cls = require("HitboxViewer.character.char_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local m = require("HitboxViewer.util.ref.methods")
local s = require("HitboxViewer.util.ref.singletons")
local util_game = require("HitboxViewer.util.game.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum
local ace = data.ace

---@class Player
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = char_cls })

---@param type CharType
---@param base app.HunterCharacter
---@param name string
---@return Player
function this:new(type, base, name)
    local o = char_cls.new(self, type, base, name)
    ---@cast o Player
    setmetatable(o, self)

    local status = base:get_HunterStatus()
    local rsc = util_game.get_component(o.game_object, "via.physics.RequestSetCollider") --[[@as via.physics.RequestSetCollider]]

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
        local playman = s.get("app.PlayerManager")
        local catalog = playman:get_Catalog()
        self.weapon.userdata = catalog:getWeaponActionParam(weapon_type)
        self.weapon.type = weapon_type
        self.weapon.handling = self.base:get_WeaponHandling()
    end
end

function this:update_guard_type()
    self.guard_type = nil
    for i = 1, #ace.map.guard_names do
        local guard_type = ace.map.guard_names[i]
        local guard_flag = e.get("app.HunterDef.STATUS_FLAG")[guard_type]

        if self.status_flags:check(guard_flag) then
            self.guard_type = guard_type
            if not config.current.mod.hurtboxes.guard_type.disable[self.guard_type] then
                return
            end
        end
    end
end

function this:update_direction()
    local front_pos = m.calcCollidableCenter(self.front_col) --[[@as Vector3f]]
    local center_pos = m.calcCollidableCenter(self.center_col) --[[@as Vector3f]]
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

function this:is_dummybox_disabled()
    if self.type == mod_enum.char.MasterPlayer then
        return util_table.empty(self.dummyboxes)
    end
    return char_cls.is_dummybox_disabled(self)
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
        if box_state == mod_enum.box_state.Draw and boxes then
            table.move(boxes, 1, #boxes, #ret + 1, ret)
        elseif box_state == mod_enum.box_state.Dead then
            self.hurtboxes[col] = nil
        end
    end

    if not util_table.empty(ret) then
        return ret
    end
end

return this
