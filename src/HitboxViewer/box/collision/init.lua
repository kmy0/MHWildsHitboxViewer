local config = require("HitboxViewer.config.init")
local load_queue = require("HitboxViewer.box.collision.load_queue")
local m = require("HitboxViewer.util.ref.methods")

local this = {
    hook = require("HitboxViewer.box.collision.hook"),
}

function this.get()
    load_queue:get()
end

---@return boolean
function this.init()
    if config.current.mod.enabled_collisionboxes then
        m.hook(
            "app.HitController.checkHitSuccess(ace.UNIVERSAL_COLLISION_INFO, app.CollisionFilter.LAYER, app.HitInfo)",
            this.hook.hitinfo_pre,
            this.hook.hitinfo_post
        )
        m.hook("app.HitController.notifyHitProc(app.HitInfo)", this.hook.notifyhit_pre)
        m.hook(
            "app.SensorHitInfo.makeFromColliderInfo(ace.UNIVERSAL_COLLISION_INFO, app.SensorDef.CONTACT_TYPE)",
            this.hook.sensorhitinfo_pre,
            this.hook.sensorhitinfo_post
        )
        m.hook("app.PhysicsManager.doUpdatePressController()", nil, this.hook.press_post)
    end

    return true
end

return this
