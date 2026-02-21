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

---@class ace.UNIVERSAL_COLLISION_INFO : System.ValueType
---@field CollidableA via.physics.Collidable
---@field CollidableB via.physics.Collidable
---@field ContactPoint ace.UNIVERSAL_CONTACT_POINT

---@class ace.UNIVERSAL_CONTACT_POINT : System.ValueType
---@field UniversalPosition via.Position

---@class ace.PadManager : ace.GAElement
---@field get_MainPad fun(self: ace.PadManager): ace.cPadInfo

---@class ace.cPadInfo : via.clr.ManagedObject
---@field get_KeyOn fun(self: ace.cPadInfo): ace.ACE_PAD_KEY.BITS

---@class ace.MouseKeyboardManager : ace.GAElement
---@field get_MainMouseKeyboard fun(self: ace.MouseKeyboardManager): ace.cMouseKeyboardInfo

---@class ace.cMouseKeyboardInfo : via.clr.ManagedObject
---@field isOn fun(self: ace.cMouseKeyboardInfo, key: ace.ACE_MKB_KEY.INDEX): System.Boolean

---@class ace.GUIManagerBase : ace.GAElement
---@field get_LastInputDeviceIgnoreMouseMove fun(self: ace.GUIManagerBase): ace.GUIDef.INPUT_DEVICE
