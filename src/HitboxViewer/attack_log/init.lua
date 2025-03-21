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

local data = require("HitboxViewer.data")
local config = require("HitboxViewer.config")

---@class AttackLog
local this = {
	---@type AttackLogEntry[]
	entries = {},
	---@type table<integer, boolean>
	this_tick = {},
	---@type table<integer, boolean>
	open_entries = {},
	last_tick = -1,
	entries_start = 1,
	row_count = 0,
}
local actual_max = config.max_table_size + 50

local function resize()
	local size = #this.entries
	if size >= config.max_table_size then
		this.entries_start = size - config.max_table_size + 2
	end
	if size > actual_max then
		local t = {}
		for i = size - config.max_table_size + 2, size do
			table.insert(t, this.entries[i])
		end
		this.entries_start = 1
		this.entries = t
	end
end

---@param entry AttackLogEntry
---@return boolean
function this.log(entry)
	if data.tick_count ~= this.last_tick then
		this.last_tick = data.tick_count
		this.this_tick = {}
		resize()
	end
	if not this.this_tick[entry.attack_id] then
		if not config.current.gui.attack_log.pause then
			table.insert(this.entries, entry)
			this.row_count = this.row_count + 1
		end
		entry.misc_type = nil
		this.this_tick[entry.attack_id] = true
		return true
	end
	return false
end

function this.clear()
	this.entries = {}
	this.this_tick = {}
	this.open_entries = {}
	this.last_tick = -1
	this.row_count = 0
end

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

---@param char_obj CharObj
---@param userdata app.col_user_data.AttackParamPl
function this.get_player_data(char_obj, userdata)
	if not char_obj.hitbox_userdata_cache[userdata] then
		char_obj.hitbox_userdata_cache[userdata] = {
			---@diagnostic disable-next-line: assign-type-mismatch
			char_type = data.char_enum.MasterPlayer == char_obj.type and "Self"
				or data.reverse_lookup(data.char_enum, char_obj.type),
			char_id = char_obj.id,
			char_name = char_obj.name,
			motion_value = userdata._Attack,
			element = userdata._StatusAttrRate,
			status = userdata._StatusConditionRate,
			damage_type = data.ace_damage_type_enum[userdata:get_DamageType()],
			damage_angle = data.ace_damage_angle_enum[userdata:get_DamageAngle()],
			guard_type = data.ace_guard_type_enum[userdata:get_GuardType()],
			part_break = userdata._PartsBreakRate,
			mount = userdata._RideDamage,
			stun = userdata._StunDamage,
			sharpness = userdata._CustomKireajiReduce / 10,
			attack_id = userdata._RuntimeData._AttackUniqueID,
			more_data = {
				--FIXME: some of these seem to be runtime only
				_DamageTypeCustom = data.ace_damage_type_custom_enum[userdata:get_DamageTypeCustom()],
				_AttackAttr = data.ace_attack_attr_enum[userdata:get_AttackAttr()],
				_AttackCond = data.ace_attack_cond_enum[userdata:get_AttackCond()],
				_Type = data.ace_action_type_enum[userdata:get_Type()],
				_AttrRate = userdata:get_AttrRate(),
				_FixAttack = userdata._FixAttack,
				_AttrValue = userdata._AttrValue,
				_AttrLevel = userdata._AttrLevel,
				_TerrainHitOnly = userdata._RuntimeData._TerrainHitOnly,
				_ActionType = data.ace_action_type_enum[userdata:get_ActionType()],
				_BattleRidingAttackType = data.ace_ride_attack_type_enum[userdata:get_BattleRidingAttackType()],
				_FriendDamageType = data.ace_action_type_enum[userdata:get_FriendDamageType()],
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
		fix_data(char_obj.hitbox_userdata_cache[userdata])
		fix_data(char_obj.hitbox_userdata_cache[userdata].more_data)
	end
	return char_obj.hitbox_userdata_cache[userdata]
end

---@param char_obj CharObj
---@param userdata app.col_user_data.AttackParamEm
function this.get_enemy_data(char_obj, userdata)
	if not char_obj.hitbox_userdata_cache[userdata] then
		char_obj.hitbox_userdata_cache[userdata] = {
			---@diagnostic disable-next-line: assign-type-mismatch
			char_type = data.reverse_lookup(data.char_enum, char_obj.type),
			char_id = char_obj.id,
			char_name = char_obj.name,
			motion_value = userdata._Attack,
			element = data.data_missing,
			status = data.data_missing,
			part_break = data.data_missing,
			mount = data.data_missing,
			stun = userdata._StunDamage,
			sharpness = data.data_missing,
			damage_type = data.ace_damage_type_enum[userdata:get_DamageType()],
			damage_angle = data.ace_damage_angle_enum[userdata:get_DamageAngle()],
			guard_type = data.ace_guard_type_enum[userdata:get_GuardType()],
			attack_id = userdata._RuntimeData._AttackUniqueID,
			more_data = {
				_DamageTypeCustom = data.ace_damage_type_custom_enum[userdata:get_DamageTypeCustom()],
				_AttackAttr = data.ace_attack_attr_enum[userdata:get_AttackAttr()],
				_AttackCond = data.ace_attack_cond_enum[userdata:get_AttackCond()],
				_Type = data.ace_action_type_enum[userdata:get_Type()],
				_AttrRate = userdata:get_AttrRate(),
				_FixAttack = userdata._FixAttack,
				_AttrValue = userdata._AttrValue,
				_AttrLevel = userdata._AttrLevel,
				_TerrainHitOnly = userdata._RuntimeData._TerrainHitOnly,
				_EnemyDamageType = data.ace_enemy_damage_type_enum[userdata:get_EnemyDamageType()],
				_DamageLevel = userdata._DamageLevel,
				_ToEmDamageRate = userdata._ToEmDamageRate,
				_FrenzyOutbreakPoint = userdata._FrenzyOutbreakPoint,
				_AttackFilterType = data.ace_enemy_attack_filter_type_enum[userdata._AttackFilterType],
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
				_FriendHitType = data.ace_enemy_friend_hit_type_enum[userdata._FriendHitType],
				_IsEnergyAttack = userdata._IsEnergyAttack,
			},
		}
		fix_data(char_obj.hitbox_userdata_cache[userdata])
		fix_data(char_obj.hitbox_userdata_cache[userdata].more_data)
	end
	return char_obj.hitbox_userdata_cache[userdata]
end

---@param char_obj CharObj
---@param userdata app.col_user_data.AttackParamOt
function this.get_pet_data(char_obj, userdata)
	if not char_obj.hitbox_userdata_cache[userdata] then
		char_obj.hitbox_userdata_cache[userdata] = {
			---@diagnostic disable-next-line: assign-type-mismatch
			char_type = data.reverse_lookup(data.char_enum, char_obj.type),
			char_id = char_obj.id,
			char_name = char_obj.name,
			motion_value = userdata._Attack,
			element = data.data_missing,
			status = data.data_missing,
			part_break = data.data_missing,
			mount = data.data_missing,
			stun = userdata._StunDamage,
			sharpness = data.data_missing,
			damage_type = data.ace_damage_type_enum[userdata:get_DamageType()],
			damage_angle = data.ace_damage_angle_enum[userdata:get_DamageAngle()],
			guard_type = data.ace_guard_type_enum[userdata:get_GuardType()],
			attack_id = userdata._RuntimeData._AttackUniqueID,
			more_data = {
				_DamageTypeCustom = data.ace_damage_type_custom_enum[userdata:get_DamageTypeCustom()],
				_AttackAttr = data.ace_attack_attr_enum[userdata:get_AttackAttr()],
				_AttackCond = data.ace_attack_cond_enum[userdata:get_AttackCond()],
				_Type = data.ace_action_type_enum[userdata:get_Type()],
				_AttrRate = userdata:get_AttrRate(),
				_FixAttack = userdata._FixAttack,
				_AttrValue = userdata._AttrValue,
				_AttrLevel = userdata._AttrLevel,
				_TerrainHitOnly = userdata._RuntimeData._TerrainHitOnly,
				_ActionType = data.ace_action_type_enum[userdata:get_ActionType()],
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
		fix_data(char_obj.hitbox_userdata_cache[userdata])
		fix_data(char_obj.hitbox_userdata_cache[userdata].more_data)
	end
	return char_obj.hitbox_userdata_cache[userdata]
end

---@param char_obj CharObj
---@param userdata via.physics.RequestSetColliderUserData
---@return AttackLogEntry?
function this.get_log_entry(char_obj, userdata)
	local p_data = userdata:get_ParentUserData()
	local t_def = p_data:get_type_definition()

	if not t_def then
		return
	end
	if t_def:is_a("app.col_user_data.AttackParamPl") or t_def:is_a("app.col_user_data.AttackParamPlShell") then
		---@cast p_data app.col_user_data.AttackParamPl
		return this.get_player_data(char_obj, p_data)
	elseif t_def:is_a("app.col_user_data.AttackParamEm") then
		---@cast p_data app.col_user_data.AttackParamEm
		return this.get_enemy_data(char_obj, p_data)
	elseif t_def:is_a("app.col_user_data.AttackParamOt") then
		---@cast p_data app.col_user_data.AttackParamOt
		return this.get_pet_data(char_obj, p_data)
	end
end

return this
