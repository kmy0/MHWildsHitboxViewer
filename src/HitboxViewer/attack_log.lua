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
---@field guard_type string
---@field misc_type string?
---@field stun number | string
---@field sharpness integer | string
---@field more_data table<string, any>

---@class (exact) AttackLogEntry : AttackLogEntryData, AttackLogEntryBase

---@class (exact) Timestamp
---@field os_clock number

---@class (exact) AttackLogEntryWithTimestamp : AttackLogEntry, Timestamp

---@class AttackLog
---@field entries CircularBuffer<AttackLogEntry>
---@field this_tick table<string, boolean>
---@field open_entries table<integer, boolean>
---@field last_tick integer
---@field entries_start integer
---@field row_count integer

local circular_buffer = require("HitboxViewer.util.misc.circular_buffer")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

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
            local precision = 10 ^ -3
            t[k] = math.floor((v + precision / 2) / precision) * precision
        end
    end
end

---@param entry AttackLogEntryWithTimestamp
---@return boolean
function this:log(entry)
    if frame_counter.frame ~= self.last_tick then
        self.last_tick = frame_counter.frame
        self.this_tick = {}
    end

    if not self.this_tick[entry.resource_path] then
        if not config.current.mod.hitboxes.pause_attack_log then
            self.entries:push_back(entry)
        end

        self.this_tick[entry.resource_path] = true
        return true
    end
    return false
end

function this:clear()
    self.entries:clear()
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
        damage_type = e.get("app.HitDef.DAMAGE_TYPE")[userdata:get_DamageType()],
        guard_type = e.get("app.Hit.GUARD_TYPE")[userdata:get_GuardType()],
        part_break = userdata._PartsBreakRate,
        mount = userdata._RideDamage,
        stun = userdata._StunDamage,
        sharpness = userdata._CustomKireajiReduce / 10 --[[@as number]],
        more_data = {
            _DamageTypeCustom = e.get("app.HitDef.DAMAGE_TYPE_CUSTOM")[userdata:get_DamageTypeCustom()],
            _AttackAttr = e.get("app.HitDef.ATTR")[userdata:get_AttackAttr()],
            _AttackCond = e.get("app.HitDef.CONDITION")[userdata:get_AttackCond()],
            _Type = e.get("app.Hit.ATTACK_PARAM_TYPE")[userdata:get_Type()],
            _AttrRate = userdata:get_AttrRate(),
            _FixAttack = userdata._FixAttack,
            _AttrValue = userdata._AttrValue,
            _AttrLevel = userdata._AttrLevel,
            _ActionType = e.get("app.HitDef.ACTION_TYPE")[userdata:get_ActionType()],
            _BattleRidingAttackType = e.get("app.HitDef.BATTLE_RIDING_ATTACK_TYPE")[userdata:get_BattleRidingAttackType()],
            _FriendDamageType = e.get("app.HitDef.ACTION_TYPE")[userdata:get_FriendDamageType()],
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
    local data_missing_string = config.lang:tr("misc.text_data_missing")
    return {
        motion_value = userdata._Attack,
        element = data_missing_string,
        status = data_missing_string,
        part_break = data_missing_string,
        mount = data_missing_string,
        stun = userdata._StunDamage,
        sharpness = data_missing_string,
        damage_type = e.get("app.HitDef.DAMAGE_TYPE")[userdata:get_DamageType()],
        guard_type = e.get("app.Hit.GUARD_TYPE")[userdata:get_GuardType()],
        more_data = {
            _DamageTypeCustom = e.get("app.HitDef.DAMAGE_TYPE_CUSTOM")[userdata:get_DamageTypeCustom()],
            _AttackAttr = e.get("app.HitDef.ATTR")[userdata:get_AttackAttr()],
            _AttackCond = e.get("app.HitDef.CONDITION")[userdata:get_AttackCond()],
            _Type = e.get("app.Hit.ATTACK_PARAM_TYPE")[userdata:get_Type()],
            _AttrRate = userdata:get_AttrRate(),
            _FixAttack = userdata._FixAttack,
            _AttrValue = userdata._AttrValue,
            _AttrLevel = userdata._AttrLevel,
            _EnemyDamageType = e.get("app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE")[userdata:get_EnemyDamageType()],
            _DamageLevel = userdata._DamageLevel,
            _ToEmDamageRate = userdata._ToEmDamageRate,
            _FrenzyOutbreakPoint = userdata._FrenzyOutbreakPoint,
            _AttackFilterType = e.get("app.EnemyDef.ATTACK_FILTER_TYPE")[userdata._AttackFilterType],
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
            _FriendHitType = e.get("app.EnemyDef.Damage.FRIEND_HIT_TYPE")[userdata._FriendHitType],
            _IsEnergyAttack = userdata._IsEnergyAttack,
        },
    }
end

---@param userdata app.col_user_data.AttackParamOt
---@return AttackLogEntryData
function this.get_pet_data(userdata)
    local data_missing_string = config.lang:tr("misc.text_data_missing")
    return {
        motion_value = userdata._Attack,
        element = data_missing_string,
        status = data_missing_string,
        part_break = data_missing_string,
        mount = data_missing_string,
        stun = userdata._StunDamage,
        sharpness = data_missing_string,
        damage_type = e.get("app.HitDef.DAMAGE_TYPE")[userdata:get_DamageType()],
        guard_type = e.get("app.Hit.GUARD_TYPE")[userdata:get_GuardType()],
        more_data = {
            _DamageTypeCustom = e.get("app.HitDef.DAMAGE_TYPE_CUSTOM")[userdata:get_DamageTypeCustom()],
            _AttackAttr = e.get("app.HitDef.ATTR")[userdata:get_AttackAttr()],
            _AttackCond = e.get("app.HitDef.CONDITION")[userdata:get_AttackCond()],
            _Type = e.get("app.Hit.ATTACK_PARAM_TYPE")[userdata:get_Type()],
            _AttrRate = userdata:get_AttrRate(),
            _FixAttack = userdata._FixAttack,
            _AttrValue = userdata._AttrValue,
            _AttrLevel = userdata._AttrLevel,
            _ActionType = e.get("app.HitDef.ACTION_TYPE")[userdata:get_ActionType()],
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
---@diagnostic disable-next-line: unused-local
function this.get_hurtbox_data(userdata)
    local data_missing_string = config.lang:tr("misc.text_data_missing")
    return {
        motion_value = 0,
        element = data_missing_string,
        status = data_missing_string,
        part_break = data_missing_string,
        mount = data_missing_string,
        stun = data_missing_string,
        sharpness = data_missing_string,
        damage_type = data_missing_string,
        guard_type = data_missing_string,
        more_data = {},
    }
end

---@param char Character
---@param userdata via.physics.RequestSetColliderUserData
---@param rsc via.physics.RequestSetCollider
---@param resource_idx integer
---@return AttackLogEntryWithTimestamp?
function this.get_log_entry(char, userdata, rsc, resource_idx)
    if char.hitbox_userdata_cache[userdata] then
        return this.attach_timestamp_to_log_entry(char.hitbox_userdata_cache[userdata])
    end

    local p_data = userdata:get_ParentUserData()
    local p_data_def = p_data:get_type_definition()

    if not p_data_def then
        return
    end

    ---@type AttackLogEntryData
    local entry_data

    if
        p_data_def:is_a("app.col_user_data.AttackParamPl")
        or p_data_def:is_a("app.col_user_data.AttackParamPlShell")
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
        char_type = mod_enum.char.MasterPlayer == char.type and "Self" or mod_enum.char[char.type],
        char_id = char.id,
        char_name = char.name,
        userdata_type = p_data_def,
        resource_idx = resource_idx,
        resource_path = resource:get_ResourcePath(),
    }

    local attack_log_entry = util_table.merge(entry_base, entry_data) --[[@as AttackLogEntry]]
    ---@cast userdata app.col_user_data.AttackParam | app.col_user_data.DamageParam
    char.hitbox_userdata_cache[userdata] = attack_log_entry

    return this.attach_timestamp_to_log_entry(attack_log_entry)
end

---@param attack_log_entry AttackLogEntry
---@return AttackLogEntryWithTimestamp
function this.attach_timestamp_to_log_entry(attack_log_entry)
    return util_table.merge(attack_log_entry, { os_clock = os.clock() })
end

return this
