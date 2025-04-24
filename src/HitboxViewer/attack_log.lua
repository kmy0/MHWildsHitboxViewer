---@class AttackLogEntry
---@field char_type string
---@field char_id string | integer
---@field char_name string
---@field motion_value integer
---@field element number | string
---@field status number | string
---@field part_break number | string
---@field mount number | string
---@field damage_type string
---@field damage_angle string
---@field guard_type string
---@field misc_type string?
---@field stun number
---@field sharpness integer | string
---@field attack_id integer
---@field more_data table<string, any>

---@class AttackLog
---@field entries AttackLogEntry[]
---@field this_tick table<integer, boolean>
---@field open_entries table<integer, boolean>
---@field last_tick integer
---@field entries_start integer
---@field row_count integer

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local ace = data.ace
local rt = data.runtime
local gui = data.gui
local rl = data.util.reverse_lookup

---@class AttackLog
local this = {
    entries = {},
    this_tick = {},
    open_entries = {},
    last_tick = -1,
    entries_start = 1,
    row_count = 0,
}
local actual_max = config.max_table_size + 50

---@param t table<string, any>
local function fix_data(t)
    for k, v in pairs(t) do
        local value_t = type(v)
        if value_t == "boolean" then
            t[k] = tostring(v)
        elseif value_t == "number" and string.find(v, "%.") then
            local precision = 10 ^ -2
            t[k] = math.floor((v + precision / 2) / precision) * precision
        end
    end
end

---@protected
function this:_resize()
    local size = #self.entries
    if size >= config.max_table_size then
        self.entries_start = size - config.max_table_size + 2
    end
    if size > actual_max then
        local t = {}
        for i = size - config.max_table_size + 2, size do
            table.insert(t, self.entries[i])
        end
        self.entries_start = 1
        self.entries = t
    end
end

---@param entry AttackLogEntry
---@return boolean
function this:log(entry)
    if rt.state.tick_count ~= self.last_tick then
        self.last_tick = rt.state.tick_count
        self.this_tick = {}
        self:_resize()
    end
    if not self.this_tick[entry.attack_id] then
        if not config.current.gui.attack_log.pause then
            table.insert(self.entries, entry)
            self.row_count = self.row_count + 1
        end
        self.this_tick[entry.attack_id] = true
        return true
    end
    return false
end

function this:clear()
    self.entries = {}
    self.this_tick = {}
    self.open_entries = {}
    self.last_tick = -1
    self.row_count = 0
end

---@param char Character
---@param userdata app.col_user_data.AttackParamPl
function this.get_player_data(char, userdata)
    if not char.hitbox_userdata_cache[userdata] then
        char.hitbox_userdata_cache[userdata] = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            char_type = rt.enum.char.MasterPlayer == char.type and "Self" or rl(rt.enum.char, char.type),
            char_id = char.id,
            char_name = char.name,
            motion_value = userdata._Attack,
            element = userdata._StatusAttrRate,
            status = userdata._StatusConditionRate,
            damage_type = ace.enum.damage_type[userdata:get_DamageType()],
            damage_angle = ace.enum.damage_angle[userdata:get_DamageAngle()],
            guard_type = ace.enum.guard_type[userdata:get_GuardType()],
            part_break = userdata._PartsBreakRate,
            mount = userdata._RideDamage,
            stun = userdata._StunDamage,
            sharpness = userdata._CustomKireajiReduce / 10,
            attack_id = userdata._RuntimeData._AttackUniqueID,
            more_data = {
                _DamageTypeCustom = ace.enum.damage_type_custom[userdata:get_DamageTypeCustom()],
                _AttackAttr = ace.enum.attack_attr[userdata:get_AttackAttr()],
                _AttackCond = ace.enum.attack_condition[userdata:get_AttackCond()],
                _Type = ace.enum.action_type[userdata:get_Type()],
                _AttrRate = userdata:get_AttrRate(),
                _FixAttack = userdata._FixAttack,
                _AttrValue = userdata._AttrValue,
                _AttrLevel = userdata._AttrLevel,
                _TerrainHitOnly = userdata._RuntimeData._TerrainHitOnly,
                _ActionType = ace.enum.action_type[userdata:get_ActionType()],
                _BattleRidingAttackType = ace.enum.ride_attack_type[userdata:get_BattleRidingAttackType()],
                _FriendDamageType = ace.enum.action_type[userdata:get_FriendDamageType()],
                _ParryDamage = userdata._ParryDamage,
                _RidingSuccessDamage = userdata._RidingSuccessDamage,
                _RidingSuccessDamageRawScar = userdata._RidingSuccessDamageRawScar,
                _IsSkillHien = userdata._IsSkillHien,
                _IsPointAttack = userdata._IsPointAttack,
                _IsPrePointHitReaction = userdata._IsPrePointHitReaction,
                _TearScarCreateRate = userdata._TearScarCreateRate,
                _TearScarDamageRate = userdata._TearScarDamageRate,
                _RawScarDamageRate = userdata._RawScarDamageRate,
                _OldScarDamageRate = userdata._OldScarDamageRate,
                _IsScarForceChange = userdata._IsScarForceChange,
                _IsRawScarForce = userdata._IsRawScarForce,
                _IsRawScarLimit = userdata._IsRawScarLimit,
                _IsWeakPointLimit = userdata._IsWeakPointLimit,
                _NoDamageReaction = userdata._NoDamageReaction,
                _IsMultiHitEmParts = userdata._IsMultiHitEmParts,
                _MultiHitEmPartsMaxNum = userdata._MultiHitEmPartsMaxNum,
                _IsMultiHitEmWeak = userdata._IsMultiHitEmWeak,
                _MultiHitEmWeakMaxNum = userdata._MultiHitEmWeakMaxNum,
                _IsLaserGuardCounter = userdata._IsLaserGuardCounter,
                _IsWpPhysicalAttack = userdata._IsWpPhysicalAttack,
                _IsNoUseKireaji = userdata._IsNoUseKireaji,
                _IsForceUseKireajiAttackRate = userdata._IsForceUseKireajiAttackRate,
                _IsCustomKireajiReduce = userdata._IsCustomKireajiReduce,
                _UseStatusAttackPower = userdata._UseStatusAttackPower,
                _UseStatusAttrPower = userdata._UseStatusAttrPower,
                _UseSkillAdditionalDamage = userdata._UseSkillAdditionalDamage,
                _UseSkillContinuousAttack = userdata._UseSkillContinuousAttack,
                _IsNoCritical = userdata._IsNoCritical,
                _IsCustomShockAbsorberRate = userdata._IsCustomShockAbsorberRate,
                _CustomShockAbsorberRate = userdata._CustomShockAbsorberRate,
            },
        }
        fix_data(char.hitbox_userdata_cache[userdata])
        fix_data(char.hitbox_userdata_cache[userdata].more_data)
    end
    return char.hitbox_userdata_cache[userdata]
end

---@param char Character
---@param userdata app.col_user_data.AttackParamEm
function this.get_enemy_data(char, userdata)
    if not char.hitbox_userdata_cache[userdata] then
        char.hitbox_userdata_cache[userdata] = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            char_type = rl(rt.enum.char, char.type),
            char_id = char.id,
            char_name = char.name,
            motion_value = userdata._Attack,
            element = gui.data_missing,
            status = gui.data_missing,
            part_break = gui.data_missing,
            mount = gui.data_missing,
            stun = userdata._StunDamage,
            sharpness = gui.data_missing,
            damage_type = ace.enum.damage_type[userdata:get_DamageType()],
            damage_angle = ace.enum.damage_angle[userdata:get_DamageAngle()],
            guard_type = ace.enum.guard_type[userdata:get_GuardType()],
            attack_id = userdata._RuntimeData._AttackUniqueID,
            more_data = {
                _DamageTypeCustom = ace.enum.damage_type_custom[userdata:get_DamageTypeCustom()],
                _AttackAttr = ace.enum.attack_attr[userdata:get_AttackAttr()],
                _AttackCond = ace.enum.attack_condition[userdata:get_AttackCond()],
                _Type = ace.enum.action_type[userdata:get_Type()],
                _AttrRate = userdata:get_AttrRate(),
                _FixAttack = userdata._FixAttack,
                _AttrValue = userdata._AttrValue,
                _AttrLevel = userdata._AttrLevel,
                _TerrainHitOnly = userdata._RuntimeData._TerrainHitOnly,
                _EnemyDamageType = ace.enum.enemy_damage_type[userdata:get_EnemyDamageType()],
                _DamageLevel = userdata._DamageLevel,
                _ToEmDamageRate = userdata._ToEmDamageRate,
                _FrenzyOutbreakPoint = userdata._FrenzyOutbreakPoint,
                _AttackFilterType = ace.enum.attack_filter_type[userdata._AttackFilterType],
                _IsParryFix = userdata._IsParryFix,
                _IsParryStockOnly = userdata._IsParryStockOnly,
                _IsParryBreak = userdata._IsParryBreak,
                _IsTechGuardBreak = userdata._IsTechGuardBreak,
                _IsBlockEnable = userdata._IsBlockEnable,
                _IsNoWakeUpPl = userdata._IsNoWakeUpPl,
                _IsDropDamage = userdata._IsDropDamage,
                _IsAffectScarVital = userdata._IsAffectScarVital,
                _IsTearScarForce = userdata._IsTearScarForce,
                _IsCoercionEnemyDamage = userdata._IsCoercionEnemyDamage,
                _IsKillable = userdata._IsKillable,
                _IsUseCondValueEm = userdata._IsUseCondValueEm,
                _CondValueEm = userdata._CondValueEm,
                _IsForceCondEm = userdata._IsForceCondEm,
                _IsUseStunDamageEm = userdata._IsUseStunDamageEm,
                _StunDamageEm = userdata._StunDamageEm,
                _IsForceStunEm = userdata._IsForceStunEm,
                _EmRateAttack = userdata._EmRateAttack,
                _LaserContinueDamageRate = userdata._LaserContinueDamageRate,
                _FriendHitType = ace.enum.friend_hit_type[userdata._FriendHitType],
                _IsEnergyAttack = userdata._IsEnergyAttack,
            },
        }
        fix_data(char.hitbox_userdata_cache[userdata])
        fix_data(char.hitbox_userdata_cache[userdata].more_data)
    end
    return char.hitbox_userdata_cache[userdata]
end

---@param char Character
---@param userdata app.col_user_data.AttackParamOt
function this.get_pet_data(char, userdata)
    if not char.hitbox_userdata_cache[userdata] then
        char.hitbox_userdata_cache[userdata] = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            char_type = rl(rt.enum.char, char.type),
            char_id = char.id,
            char_name = char.name,
            motion_value = userdata._Attack,
            element = gui.data_missing,
            status = gui.data_missing,
            part_break = gui.data_missing,
            mount = gui.data_missing,
            stun = userdata._StunDamage,
            sharpness = gui.data_missing,
            damage_type = ace.enum.damage_type[userdata:get_DamageType()],
            damage_angle = ace.enum.damage_angle[userdata:get_DamageAngle()],
            guard_type = ace.enum.guard_type[userdata:get_GuardType()],
            attack_id = userdata._RuntimeData._AttackUniqueID,
            more_data = {
                _DamageTypeCustom = ace.enum.damage_type_custom[userdata:get_DamageTypeCustom()],
                _AttackAttr = ace.enum.attack_attr[userdata:get_AttackAttr()],
                _AttackCond = ace.enum.attack_condition[userdata:get_AttackCond()],
                _Type = ace.enum.action_type[userdata:get_Type()],
                _AttrRate = userdata:get_AttrRate(),
                _FixAttack = userdata._FixAttack,
                _AttrValue = userdata._AttrValue,
                _AttrLevel = userdata._AttrLevel,
                _TerrainHitOnly = userdata._RuntimeData._TerrainHitOnly,
                _ActionType = ace.enum.action_type[userdata:get_ActionType()],
                _IsUseFixedActionType = userdata._IsUseFixedActionType,
                _IsUseFixedAttributeType = userdata._IsUseFixedAttributeType,
                _IsUseFixedBadConditionRate = userdata._IsUseFixedBadConditionRate,
                _BadConditionRate = userdata._BadConditionRate,
                _IsRangeAttack = userdata._IsRangeAttack,
                _IsUseBombThrowCalc = userdata._IsUseBombThrowCalc,
                _PartsVitalRate = userdata._PartsVitalRate,
                _TearScarCreateRate = userdata._TearScarCreateRate,
                _RawScarCreateRate = userdata._RawScarCreateRate,
                _IsDetectAttackHit = userdata._IsDetectAttackHit,
                _IsStealAttack = userdata._IsStealAttack,
            },
        }
        fix_data(char.hitbox_userdata_cache[userdata])
        fix_data(char.hitbox_userdata_cache[userdata].more_data)
    end
    return char.hitbox_userdata_cache[userdata]
end

---@param char Character
---@param userdata via.physics.RequestSetColliderUserData
---@return AttackLogEntry?
function this.get_log_entry(char, userdata)
    local p_data = userdata:get_ParentUserData()
    local t_def = p_data:get_type_definition()

    if not t_def then
        return
    end
    if t_def:is_a("app.col_user_data.AttackParamPl") or t_def:is_a("app.col_user_data.AttackParamPlShell") then
        ---@cast p_data app.col_user_data.AttackParamPl
        return this.get_player_data(char, p_data)
    elseif t_def:is_a("app.col_user_data.AttackParamEm") then
        ---@cast p_data app.col_user_data.AttackParamEm
        return this.get_enemy_data(char, p_data)
    elseif t_def:is_a("app.col_user_data.AttackParamOt") then
        ---@cast p_data app.col_user_data.AttackParamOt
        return this.get_pet_data(char, p_data)
    end
end

return this
