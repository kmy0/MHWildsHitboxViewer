---@meta

---@class via.Object : REManagedObject
---@class via.vec3 : Vector3f
---@class via.clr.ManagedObject : via.Object
---@class via.UserData : via.clr.ManagedObject
---@class via.physics.CollidableBase : via.Component
---@class via.physics.UserData : via.clr.ManagedObject
---@class via.Camera : via.Component
---@class via.physics.Collider : via.physics.Collidable

---@class via.Component : via.clr.ManagedObject
---@field get_GameObject fun(self: via.Component): via.GameObject

---@class via.Behavior : via.Component
---@field get_Started fun(self: via.Behavior): System.Boolean
---@field get_Valid fun(self: via.Behavior): System.Boolean

---@class via.Scene : via.clr.ManagedObject
---@field get_FrameCount fun(self: via.Scene): System.UInt32

---@class via.GameObject : via.clr.ManagedObject
---@field get_Name fun(self: via.GameObject): string
---@field get_Transform fun(self: via.GameObject): via.Transform

---@class via.Transform : via.Component
---@field get_GameObject fun(self: via.Transform): via.GameObject
---@field get_Parent fun(self: via.Transform): via.Transform?
---@field get_Position fun(self: via.Transform): via.vec3

---@class via.physics.Shape : via.clr.ManagedObject
---@field get_ShapeType fun(self: via.physics.Shape) : via.physics.ShapeType

---@class via.physics.RequestSetColliderUserData : via.physics.UserData
---@field get_ParentUserData fun(self: via.physics.RequestSetColliderUserData): via.physics.UserData

---@class via.physics.RequestSetCollider : via.physics.CollidableBase
---@field get_NumRequestSets fun(self: via.physics.RequestSetCollider) : System.UInt32
---@field getNumRequestSetsFromIndex fun(self: via.physics.RequestSetCollider, i: System.UInt32) : System.UInt32
---@field getNumCollidablesFromIndex fun(self: via.physics.RequestSetCollider, i: System.UInt32, j: System.UInt32) : System.UInt32
---@field getCollidableFromIndex fun(self: via.physics.RequestSetCollider, i: System.UInt32, j: System.UInt32, k : System.UInt32) : via.physics.Collidable
---@field getNumCollidables fun(self: via.physics.RequestSetCollider, i: System.UInt32, j: System.UInt32) : System.UInt32
---@field getCollidable fun(self: via.physics.RequestSetCollider, i: System.UInt32, j: System.UInt32, k : System.UInt32) : via.physics.Collidable
---@field getRequestSetGroups fun(self: via.physics.RequestSetCollider, i: System.UInt32): via.physics.RequestSetCollider.RequestSetGroup

---@class via.physics.RequestSetCollider.RequestSetGroup : via.clr.ManagedObject
---@field get_Resource fun(self: via.physics.RequestSetCollider.RequestSetGroup): via.physics.RequestSetColliderResourceHolder

---@class via.physics.RequestSetColliderResourceHolder : via.clr.ManagedObject
---@field get_ResourcePath fun(self: via.physics.RequestSetColliderResourceHolder): System.String

---@class via.physics.Collidable : via.clr.ManagedObject
---@field get_TransformedShape fun(self: via.physics.Collidable): via.physics.Shape
---@field get_UserData fun(self: via.physics.Collidable): via.physics.UserData
---@field get_Enabled fun(self: via.physics.Collidable): System.Boolean
---@field get_FilterInfo fun(self: via.physics.Collidable): via.physics.FilterInfo
---@field get_GameObject fun(self: via.physics.Collidable): via.GameObject

---@class via.physics.FilterInfo : via.clr.ManagedObject
---@field get_Layer fun(self: via.physics.FilterInfo): app.CollisionFilter.LAYER

---@class via.Size
---@field w System.Single
---@field h System.Single

---@class via.SceneView : via.clr.ManagedObject
---@field get_PrimaryCamera fun(self: via.SceneView): via.Camera
---@field get_WindowSize fun(self: via.SceneView): via.Size

---@class via.SceneManager : NativeSingleton
---@field get_MainView fun(self: via.SceneManager): via.SceneView
---@field get_CurrentScene fun(self: via.SceneManager): via.Scene

---@class via.Application : NativeSingleton
---@field get_DeltaTime fun(self: via.Application): System.Single
---@field set_GlobalSpeed fun(self: via.Application, value: System.Single)

---@class via.Position : System.ValueType
---@field x System.Double
---@field y System.Double
---@field z System.Double
