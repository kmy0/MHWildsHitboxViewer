---@meta

---@class app.user_data.EmParamParts.cPartsBase : via.clr.ManagedObject
---@class app.user_data.EmParamParts.cDataBase : via.clr.ManagedObject
---@class app.user_data.EmParamParts.cPartsBreak : app.user_data.EmParamParts.cDataBase
---@class app.user_data.EmParamParts.cMeat : app.user_data.EmParamParts.cDataBase
---@class app.cEmModuleBase : via.clr.ManagedObject
---@class app.cGameContextHolder : via.clr.ManagedObject
---@class app.cCharacterExtendBase : via.clr.ManagedObject
---@class app.EnemyZakoCharacter : app.EnemyCharacter
---@class app.EnemyBossCharacter : app.EnemyCharacter
---@class app.NpcCharacter : app.CharacterBase
---@class app.col_user_data.DamageParam : via.physics.RequestSetColliderUserData
---@class app.col_user_data.AttackParam : via.physics.RequestSetColliderUserData
---@class app.col_user_data.AttackParamPl : app.col_user_data.AttackParamPlBase
---@class app.user_data.WpActionParamBase : via.UserData
---@class app.col_user_data.AttackParamPlShell : app.col_user_data.AttackParamPlBase
---@class app.cGameContext : via.clr.ManagedObject

---@class app.GUIManager : ace.GUIManagerBase
---@field getSystemLanguageToApp fun(self: app.GUIManager) : via.Language

---@class app.AppBehavior : via.Behavior
---@field get_Pos fun(self: app.AppBehavior): Vector3f

---@class app.cNpcContext : app.cGameContext
---@field NpcID app.NpcDef.ID

---@class app.EnemyDef.PARTS_TYPE_Serializable : via.clr.ManagedObject
---@field get_Value fun(self: app.EnemyDef.PARTS_TYPE_Serializable) : System.Int32

---@class app.user_data.EmParamParts.cParts : app.user_data.EmParamParts.cPartsBase
---@field _MeatGuidNormal System.Guid
---@field _MeatGuidBreak System.Guid
---@field _MeatGuidCustom1 System.Guid
---@field _MeatGuidCustom2 System.Guid
---@field _MeatGuidCustom3 System.Guid
---@field _RodExtract app.Hit.ROD_EXTRACT
---@field _PartsType app.EnemyDef.PARTS_TYPE_Serializable

---@class app.cEmModuleParts.cBreakParts : via.clr.ManagedObject
---@field get_MaxBreakCount fun(self: app.cEmModuleParts.cBreakParts) : System.Int32
---@field get_IsBreakAll fun(self: app.cEmModuleParts.cBreakParts) : System.Boolean

---@class app.user_data.EmParamParts.cWeakPoint : app.user_data.EmParamParts.cPartsBase
---@field _MeatGuid System.Guid

---@class app.user_data.EmParamParts : via.UserData
---@field getPartsIndex fun(self: app.user_data.EmParamParts, guid: System.Guid) : System.Nullable<System.Int32>
---@field get_PartsList fun(self: app.user_data.EmParamParts) : System.Array<app.user_data.EmParamParts.cParts>
---@field getMeatIndex fun(self: app.user_data.EmParamParts, guid: System.Guid) : System.Nullable<System.Int32>
---@field getMeatIndex fun(self: app.user_data.EmParamParts, guid: System.Guid) : System.Nullable<System.Int32>
---@field get_MeatList fun(self: app.user_data.EmParamParts) : System.Array<app.user_data.EmParamParts.cMeat>
---@field getLinkPartsIndexByBreakPartsIndex fun(self: app.user_data.EmParamParts, i: System.Int32): System.Array<System.Int32>
---@field get_PartsBreakList fun(self: app.user_data.EmParamParts) : System.Array<app.user_data.EmParamParts.cPartsBreak>
---@field get_WeakPointList fun(self: app.user_data.EmParamParts) : System.Array<app.user_data.EmParamParts.cWeakPoint>

---@class app.cEmModuleParts.cDamageParts : app.cEmModuleBase
---@field get_MeatSlot fun(self: app.cEmModuleParts.cDamageParts) : app.user_data.EmParamParts.MEAT_SLOT
---@field get_IsEnable fun(self: app.cEmModuleParts.cDamageParts) : System.Boolean

---@class app.cEmModuleParts.cWeakPointParts : app.cEmModuleParts.cDamageParts
---@field isColEnable fun(self: app.cEmModuleParts.cWeakPointParts) : System.Boolean

---@class app.cEmModuleParts : app.cEmModuleBase
---@field _ParamParts app.user_data.EmParamParts
---@field get_DmgParts fun(self: app.cEmModuleParts) : System.Array<app.cEmModuleParts.cDamageParts>
---@field get_BreakPartsByPartsIdx fun(self: app.cEmModuleParts) : System.Array<app.cEmModuleParts.cBreakParts>
---@field get_WeakPointParts fun(self: app.cEmModuleParts) : System.Array<app.cEmModuleParts.cDamageParts>
---@field getActiveWeakPointIndexList fun(self: app.cEmModuleParts) : System.Array<System.Int32>
---@field get_WeakPointPartsNum fun(self: app.cEmModuleParts) : System.Int32
---@field getLostPartsCount fun(self: app.cEmModuleParts) : System.Int32
---@field getLostPartsIndex fun(self: app.cEmModuleParts, lost_part_index: System.Int32) : System.Int32

---@class app.cEnemyContextHolder : app.cGameContextHolder
---@field get_Em fun(self: app.cEnemyContextHolder) : app.cEnemyContext

---@class app.cEmModuleScar : app.cEmModuleBase
---@field get_ScarParts fun(self: app.cEmModuleScar) : System.Array<app.cEmModuleScar.cScarParts>

---@class app.cEnemyBrowser : ace.cNonCycleTypeObject
---@field get_IsDie fun(self: app.cEnemyBrowser) : System.Boolean

---@class app.cEnemyContext : app.cGameContext
---@field Parts app.cEmModuleParts
---@field get_EmID app.EnemyDef.ID
---@field Scar app.cEmModuleScar
---@field get_UniqueIndex fun(self: app.cEnemyContext) : System.Int32
---@field get_Browser fun(self: app.cEnemyContext) : app.cEnemyBrowser

---@class app.cPlayerContext : app.cGameContext
---@field get_UniqueID fun(self: app.cPlayerContext): System.Guid
---@field get_PlayerName fun(self: app.cPlayerContext) : System.String

---@class app.cOtomoContext : app.cGameContext
---@field get_UniqueID fun(self: app.cOtomoContext): System.Guid

---@class app.cNpcContextHolder : app.cGameContextHolder
---@field get_Npc fun(self: app.cNpcContextHolder): app.cNpcContext

---@class app.cPlayerContextHolder : app.cGameContextHolder
---@field get_Pl fun(self: app.cPlayerContextHolder) : app.cPlayerContext

---@class app.HunterCharacter.cHunterExtendBase : app.cCharacterExtendBase
---@field get_IsNpc fun(self: app.HunterCharacter.cHunterExtendBase): System.Boolean

---@class app.HunterCharacter.cHunterExtendNpc : app.HunterCharacter.cHunterExtendBase
---@field _ContextHolder app.cNpcContextHolder

---@class app.HunterCharacter.cHunterExtendPlayer : app.HunterCharacter.cHunterExtendBase
---@field _ContextHolder app.cPlayerContextHolder

---@class app.EnemyCharacter : app.CharacterBase
---@field _Context app.cEnemyContextHolder
---@field _MiniComponentHolder app.EnemyCharacter.MINI_COMPONENT_HOLDER

---@class app.CharacterBase : app.AppBehavior
---@field get_GameObject fun(self: app.CharacterBase): via.GameObject

---@class app.HunterCharacter : app.CharacterBase
---@field get_IsMaster fun(self: app.HunterCharacter): System.Boolean
---@field get_IsUserControl fun(self: app.HunterCharacter): System.Boolean
---@field get_HunterExtend fun(self: app.HunterCharacter): app.HunterCharacter.cHunterExtendBase
---@field get_HunterStatus fun(self: app.HunterCharacter): app.cHunterStatus
---@field get_WeaponType fun(self: app.HunterCharacter): app.WeaponDef.TYPE
---@field get_WeaponHandling fun(self: app.HunterCharacter): app.cHunterWeaponHandlingBase

---@class app.cHunterStatus : ace.cNonCycleTypeObject
---@field _HunterStatusFlag ace.cSafeContinueFlagGroup

---@class app.OtomoCharacter : app.CharacterBase
---@field get_OwnerHunterCharacter fun(self: app.OtomoCharacter): app.HunterCharacter
---@field get_OtomoContext fun(self: app.OtomoCharacter)

---@class app.PlayerManager : ace.GAElement
---@field getMasterPlayer fun(self: app.PlayerManager): app.cPlayerManageInfo
---@field get_Catalog fun(self: app.PlayerManager): app.cPlayerCatalogHolder

---@class app.GameFlowManager : ace.GameFlowManagerBase
---@field get_CurrentGameScene fun(self: app.GameFlowManager) : app.cFieldSceneParam.SCENE_TYPE
---@field get_NextGameStateType fun(self: app.GameFlowManager) : app.cFieldSceneParam.SCENE_TYPE?

---@class app.col_user_data.DamageParamEm.cParts : via.clr.ManagedObject
---@field get_PartsGuid fun(self: app.col_user_data.DamageParamEm.cParts) : System.Guid
---@field get_Category fun(self: app.col_user_data.DamageParamEm.cParts) : app.user_data.EmParamParts.INDEX_CATEGORY

---@class app.col_user_data.DamageParamEm.cRuntimeDataEm : via.clr.ManagedObject
---@field _PartsIndex System.Int32
---@field _RodExtract app.Hit.ROD_EXTRACT

---@class app.EnemyScar
---@field _RequestState app.cEmModuleScar.cScarParts.STATE
---@field _ColSizeRadius System.Single
---@field _IsActivated System.Boolean
---@field get_Pos fun(self: app.EnemyScar) : via.vec3
---@field get_Parts fun(self: app.EnemyScar) : app.cEmModuleScar.cScarParts

---@class app.EnemyScarHolder : via.clr.ManagedObject
---@field _Parts app.cEmModuleScar.cScarParts
---@field _ScarCompList System.Array<app.EnemyScar>

---@class app.mcEnemyScarManager: ace.minicomponent.cOrderedActionBase
---@field _ScarList System.Array<app.EnemyScarHolder>

---@class app.EnemyCharacter.MINI_COMPONENT_HOLDER : System.ValueType
---@field _ScarManager app.mcEnemyScarManager

---@class app.col_user_data.DamageParamEm : app.col_user_data.DamageParam
---@field get_Parts fun(self: app.col_user_data.DamageParamEm) : app.col_user_data.DamageParamEm.cParts
---@field get_RuntimeData fun(self: app.col_user_data.DamageParamEm) : app.col_user_data.DamageParamEm.cRuntimeDataEm

---@class app.cPlayerManageInfo : via.clr.ManagedObject
---@field get_Character fun(self:app.cPlayerManageInfo): app.HunterCharacter

---@class app.cEmModuleScar.cScarParts : via.clr.ManagedObject
---@field get_PartsIndex_1 fun(self: app.cEmModuleScar.cScarParts) : System.Int32
---@field get_PartsIndex_2 fun(self: app.cEmModuleScar.cScarParts) : System.Int32
---@field get_State fun(self: app.cEmModuleScar.cScarParts) : app.cEmModuleScar.cScarParts.STATE
---@field get_IsForceDisableCollision fun(self: app.cEmModuleScar.cScarParts) : System.Boolean
---@field _MeatGuid_1 System.Guid

---@class app.col_user_data.AttackParam.cRuntimeData : via.clr.ManagedObject
---@field _AttackUniqueID System.Int32
---@field _TerrainHitOnly System.Boolean

---@class app.cAttackParamBase : via.clr.ManagedObject
---@field _RuntimeData app.col_user_data.AttackParam.cRuntimeData
---@field get_UserData app.col_user_data.AttackParam

---@class app.HitInfo : via.clr.ManagedObject
---@field get_AttackOwner fun(self: app.HitInfo): via.GameObject
---@field get_AttackCollidable fun(self: app.HitInfo): via.physics.Collidable
---@field get_AttackData fun(self: app.HitInfo): app.cAttackParamBase
---@field get_HitID fun(self: app.HitInfo): System.Int32

---@class app.HitController : app.AppBehavior
---@field _GroupHitIDs System.Array<System.Int32>
---@field get_Owner fun(self: app.HitController): via.GameObject

---@class app.mcShellColHit : ace.mcShellColHitBase
---@field get_FirstCollider fun(self: app.mcShellColHit): via.physics.Collidable
---@field get_SubColliders fun(self: app.mcShellColHit): System.Array<via.physics.Collidable>
---@field _HitController app.HitController
---@field get_Owner fun(self: app.mcShellColHit): via.GameObject
---@field _FirstCollider via.physics.Collidable
---@field _SubColliders System.Array<via.physics.Collidable>
---@field _ReqSetCol via.physics.RequestSetCollider
---@field _CollisionResourceIndex System.Int32

---@class app.ColliderSwitcher : app.AppBehavior
---@field _HitController app.HitController
---@field _RequestSetCollider via.physics.RequestSetCollider

---@class app.col_user_data.AttackParam : via.physics.RequestSetColliderUserData
---@field get_DamageType fun(self: app.col_user_data.AttackParam): app.HitDef.DAMAGE_TYPE
---@field get_DamageTypeCustom fun(self: app.col_user_data.AttackParam): app.HitDef.DAMAGE_TYPE_CUSTOM
---@field get_DamageAngle fun(self: app.col_user_data.AttackParam): app.HitDef.DAMAGE_ANGLE
---@field get_GuardType fun(self: app.col_user_data.AttackParam): app.Hit.GUARD_TYPE
---@field get_AttackAttr fun(self: app.col_user_data.AttackParam): app.HitDef.ATTR
---@field get_AttackCond fun(self: app.col_user_data.AttackParam): app.HitDef.CONDITION
---@field get_Type fun(self: app.col_user_data.AttackParam): app.Hit.ATTACK_PARAM_TYPE
---@field get_AttrRate fun(self: app.col_user_data.AttackParam): System.Single
---@field _Attack System.Single
---@field _FixAttack System.Single
---@field _AttrValue System.Single
---@field _AttrLevel System.UInt32
---@field _StunDamage System.Single
---@field _RuntimeData app.col_user_data.AttackParam.cRuntimeData

---@class app.col_user_data.AttackParamPlBase : app.col_user_data.AttackParam
---@field get_ActionType fun(self: app.col_user_data.AttackParamPlBase): app.HitDef.ACTION_TYPE
---@field get_BattleRidingAttackType fun(self: app.col_user_data.AttackParamPlBase): app.HitDef.BATTLE_RIDING_ATTACK_TYPE
---@field get_FriendDamageType fun(self: app.col_user_data.AttackParamPlBase): app.HitDef.ACTION_TYPE
---@field _PartsBreakRate System.Single
---@field _ParryDamage System.Single
---@field _RideDamage System.Single
---@field _RidingSuccessDamage System.Single
---@field _RidingSuccessDamageRawScar System.Single
---@field _IsSkillHien System.Boolean
---@field _IsPointAttack System.Boolean
---@field _IsPrePointHitReaction System.Boolean
---@field _TearScarCreateRate System.Single
---@field _TearScarDamageRate System.Single
---@field _RawScarDamageRate System.Single
---@field _OldScarDamageRate System.Single
---@field _IsScarForceChange System.Boolean
---@field _IsRawScarForce System.Boolean
---@field _IsRawScarLimit System.Boolean
---@field _IsWeakPointLimit System.Boolean
---@field _NoDamageReaction System.Boolean
---@field _IsMultiHitEmParts System.Boolean
---@field _MultiHitEmPartsMaxNum System.Int32
---@field _IsMultiHitEmWeak System.Boolean
---@field _MultiHitEmWeakMaxNum System.Int32
---@field _IsLaserGuardCounter System.Boolean
---@field _IsWpPhysicalAttack System.Boolean
---@field _IsNoUseKireaji System.Boolean
---@field _IsForceUseKireajiAttackRate System.Boolean
---@field _IsCustomKireajiReduce System.Boolean
---@field _CustomKireajiReduce System.Int32
---@field _UseStatusAttackPower System.Boolean
---@field _UseStatusAttrPower System.Boolean
---@field _StatusAttrRate System.Single
---@field _StatusConditionRate System.Single
---@field _UseSkillAdditionalDamage System.Boolean
---@field _UseSkillContinuousAttack System.Boolean
---@field _IsNoCritical System.Boolean
---@field _IsCustomShockAbsorberRate System.Boolean
---@field _CustomShockAbsorberRate System.Single

---@class app.col_user_data.AttackParamEm : app.col_user_data.AttackParam
---@field get_EnemyDamageType fun(self: app.col_user_data.AttackParamEm): app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE
---@field _DamageLevel System.Int32
---@field _ToEmDamageRate System.Single
---@field _FrenzyOutbreakPoint System.Single
---@field _AttackFilterType app.EnemyDef.ATTACK_FILTER_TYPE
---@field _GroupEm System.Boolean
---@field _IsParryFix System.Boolean
---@field _IsParryStockOnly System.Boolean
---@field _IsParryBreak System.Boolean
---@field _IsTechGuardBreak System.Boolean
---@field _IsBlockEnable System.Boolean
---@field _IsNoWakeUpPl System.Boolean
---@field _IsDropDamage System.Boolean
---@field _IsAffectScarVital System.Boolean
---@field _IsTearScarForce System.Boolean
---@field _IsCoercionEnemyDamage System.Boolean
---@field _IsKillable System.Boolean
---@field _IsUseCondValueEm System.Boolean
---@field _CondValueEm System.Single
---@field _IsForceCondEm System.Boolean
---@field _IsUseStunDamageEm System.Boolean
---@field _StunDamageEm System.Single
---@field _IsForceStunEm System.Boolean
---@field _EmRateAttack System.Single
---@field _LaserContinueDamageRate System.Single
---@field _FriendHitType app.EnemyDef.Damage.FRIEND_HIT_TYPE
---@field _IsEnergyAttack System.Boolean

---@class app.col_user_data.AttackParamOt : app.col_user_data.AttackParam
---@field get_ActionType fun(self: app.col_user_data.AttackParamOt): app.HitDef.ACTION_TYPE
---@field _GroupOT System.Boolean
---@field _IsUseFixedActionType System.Boolean
---@field _IsUseFixedAttributeType System.Boolean
---@field _IsUseFixedBadConditionRate System.Boolean
---@field _BadConditionRate System.Single
---@field _IsRangeAttack System.Boolean
---@field _IsUseBombThrowCalc System.Boolean
---@field _PartsVitalRate System.Single
---@field _TearScarCreateRate System.Single
---@field _RawScarCreateRate System.Single
---@field _IsDetectAttackHit System.Boolean
---@field _IsStealAttack System.Boolean
---@field _OtomoToolType app.OtomoDef.USE_OTOMO_TOOL_TYPE_Fixed

---@class app.col_user_data.DamageParamNpc : app.col_user_data.DamageParam
---@field _IsAttackDetector System.Boolean

---@class app.cPlayerCatalogHolder : via.clr.ManagedObject
---@field getWeaponActionParam fun(self: app.cPlayerCatalogHolder, weapon_type: app.WeaponDef.TYPE): app.user_data.WpActionParamBase

---@class app.cHunterWeaponHandlingBase : via.clr.ManagedObject
---@field getOverwriteGuardDir fun(self: app.cHunterWeaponHandlingBase): via.vec3

---@class app.Wp10Insect : app.AppBehavior
---@field get_Hunter fun(self: app.Wp10Insect): app.HunterCharacter
---@field _Components app.Wp10Insect.COMPONENTS

---@class app.Wp10Insect.COMPONENTS : System.ValueType
---@field _RequestSetCol via.physics.RequestSetCollider

---@class app.col_user_data.PressParam : via.physics.RequestSetColliderUserData
---@field get_PressLevel fun(self: app.col_user_data.PressParam): app.PressDef.PRESS_LEVEL
