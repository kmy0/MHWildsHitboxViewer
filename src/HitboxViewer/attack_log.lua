---@class (exact) AttackLogEntryBase
---@field char_type string
---@field char_id string | integer
---@field char_name string
---@field userdata_type RETypeDefinition
---@field resource_path string
---@field resource_idx integer

---@class (exact) AttackLogEntryData
---@field motion_value integer
---@field element number | string
---@field status number | string
---@field part_break number | string
---@field mount number | string
---@field damage_type string
---@field damage_angle string
---@field guard_type string
---@field misc_type string?
---@field stun number | string
---@field sharpness integer | string
---@field attack_id integer
---@field more_data table<string, any>

---@class (exact) AttackLogEntry : AttackLogEntryData, AttackLogEntryBase

---@class AttackLog
---@field entries CircularBuffer<AttackLogEntry>
---@field this_tick table<integer, boolean>
---@field open_entries table<integer, boolean>
---@field last_tick integer
---@field entries_start integer
---@field row_count integer

local circular_buffer = require("HitboxViewer.circular_buffer")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local table_util = require("HitboxViewer.table_util")

local ace = data.ace
local rt = data.runtime
local gui = data.gui
local rl = data.util.reverse_lookup

---@class AttackLog
local this = {
    entries = circular_buffer:new(config.max_table_size),
    this_tick = {},
    open_entries = {},
    last_tick = -1,
    entries_start = 1,
}

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

---@param entry AttackLogEntry
---@return boolean
function this:log(entry)
    if rt.state.tick_count ~= self.last_tick then
        self.last_tick = rt.state.tick_count
        self.this_tick = {}
    end

    if not self.this_tick[entry.attack_id] then
        if not config.current.gui.attack_log.pause then
            self.entries:push_back(entry)
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
end

---@param userdata app.col_user_data.AttackParamPl
---@return AttackLogEntryData
function this.get_player_data(userdata)
    return {
        motion_value = userdata._Attack,
        element = userdata._StatusAttrRate,
        status = userdata._StatusConditionRate,
        damage_type = ace.enum.damage_type[userdata:get_DamageType()],
        damage_angle = ace.enum.damage_angle[userdata:get_DamageAngle()],
        guard_type = ace.enum.guard_type[userdata:get_GuardType()],
        part_break = userdata._PartsBreakRate,
        mount = userdata._RideDamage,
        stun = userdata._StunDamage,
        sharpness = userdata._CustomKireajiReduce / 10 --[[@as number]],
        attack_id = userdata._RuntimeData._AttackUniqueID,
        more_data = {
            _DamageTypeCustom = ace.enum.damage_type_custom[userdata:get_DamageTypeCustom()],
            _AttackAttr = ace.enum.attack_attr[userdata:get_AttackAttr()],
            _AttackCond = ace.enum.attack_condition[userdata:get_AttackCond()],
            _Type = ace.enum.attack_param[userdata:get_Type()],
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
end

---@param userdata app.col_user_data.AttackParamEm
---@return AttackLogEntryData
function this.get_enemy_data(userdata)
    return {
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
            _Type = ace.enum.attack_param[userdata:get_Type()],
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
end

---@param userdata app.col_user_data.AttackParamOt
---@return AttackLogEntryData
function this.get_pet_data(userdata)
    return {
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
            _Type = ace.enum.attack_param[userdata:get_Type()],
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
end

---@param userdata app.col_user_data.DamageParam
---@return AttackLogEntryData
function this.get_hurtbox_data(userdata)
    return {
        motion_value = 0,
        element = gui.data_missing,
        status = gui.data_missing,
        part_break = gui.data_missing,
        mount = gui.data_missing,
        stun = gui.data_missing,
        sharpness = gui.data_missing,
        damage_type = gui.data_missing,
        damage_angle = gui.data_missing,
        guard_type = gui.data_missing,
        attack_id = 0,
        more_data = {},
    }
end

---@param char Character
---@param userdata via.physics.RequestSetColliderUserData
---@param rsc via.physics.RequestSetCollider
---@param resource_idx integer
---@return AttackLogEntry?
function this.get_log_entry(char, userdata, rsc, resource_idx)
    if char.hitbox_userdata_cache[userdata] then
        return char.hitbox_userdata_cache[userdata]
    end

    local p_data = userdata:get_ParentUserData()
    local p_data_def = p_data:get_type_definition()

    if not p_data_def then
        return
    end

    ---@type AttackLogEntryData
    local entry_data

    if
        p_data_def:is_a("app.col_user_data.AttackParamPl") or p_data_def:is_a("app.col_user_data.AttackParamPlShell")
    then
        ---@cast p_data app.col_user_data.AttackParamPl
        entry_data = this.get_player_data(p_data)
    elseif p_data_def:is_a("app.col_user_data.AttackParamEm") then
        ---@cast p_data app.col_user_data.AttackParamEm
        entry_data = this.get_enemy_data(p_data)
    elseif p_data_def:is_a("app.col_user_data.AttackParamOt") then
        ---@cast p_data app.col_user_data.AttackParamOt
        entry_data = this.get_pet_data(p_data)
    elseif p_data_def:is_a("app.col_user_data.DamageParam") then
        ---@cast p_data app.col_user_data.DamageParam
        entry_data = this.get_hurtbox_data(p_data)
    end

    if not entry_data then
        return
    end

    fix_data(entry_data)
    fix_data(entry_data.more_data)
    local set_group = rsc:getRequestSetGroups(resource_idx)
    local resource = set_group:get_Resource()

    ---@type AttackLogEntryBase
    local entry_base = {
        char_type = rt.enum.char.MasterPlayer == char.type and "Self" or rl(rt.enum.char, char.type),
        char_id = char.id,
        char_name = char.name,
        userdata_type = p_data_def,
        resource_idx = resource_idx,
        resource_path = resource:get_ResourcePath(),
    }
    local ret = table_util.table_merge(entry_base, entry_data) --[[@as AttackLogEntry]]
    ---@cast userdata app.col_user_data.AttackParam | app.col_user_data.DamageParam
    char.hitbox_userdata_cache[userdata] = ret
    return ret
end

return this
