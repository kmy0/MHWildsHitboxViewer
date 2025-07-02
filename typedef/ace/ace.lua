---@meta

---@class ace.GUIManagerBase : ace.GAElement
---@class ace.GAElementBase : via.Behavior
---@class ace.GAElement<T> : ace.GAElementBase
---@class ace.GameFlowManagerBase : ace.GAElement
---@class ace.minicomponent.cOrderedActionBase : ace.minicomponent.cMiniComponent
---@class ace.cLeakCheckObject : via.clr.ManagedObject
---@class ace.cNonCycleTypeObject : ace.cLeakCheckObject
---@class ace.minicomponent.cMiniComponent : ace.cNonCycleTypeObject
---@class ace.mcShellBase : ace.minicomponent.cMiniComponent
---@class ace.mcShellColHitBase : ace.mcShellBase

---@class ace.cSafeContinueFlagGroup : via.clr.ManagedObject
---@field check fun(self: ace.cSafeContinueFlagGroup, flag: System.UInt32): System.Boolean

---@class ace.ShellBase : via.Behavior
---@field get_ShellOwner fun(self: ace.ShellBase): via.GameObject
