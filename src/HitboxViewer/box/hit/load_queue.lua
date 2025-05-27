---@class (exact) HitBoxLoadQueue : QueueBase
---@field queue HitBoxLoadData[]
---@field enqueue fun(self: HitBoxLoadQueue , load_data: HitLoadDataRsc | HitLoadDataShell | HitLoadDataShellRsc)

---@class (exact) HitBoxLoadData : QueueDataBase
---@field type HitBoxLoadDataType
---@field char Character
---@field rsc via.physics.RequestSetCollider
---@field res_idx integer

---@class (exact) HitLoadDataRsc : HitBoxLoadData
---@field req_idx integer

---@class (exact) HitLoadDataShellRsc : HitBoxLoadData
---@field shellcolhit app.mcShellColHit

---@class (exact) HitLoadDataShell : HitLoadDataShellRsc
---@field first_colider via.physics.Collidable
---@field sub_colliders System.Array<via.physics.Collidable>

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.runtime

---@class HitBoxLoadQueue
local this = queue_base:new()

---@return fun(): HitLoadDataRsc | HitLoadDataShell | HitLoadDataShellRsc
function this:get()
    return self:_get(function()
        return config.current.enabled_hitboxes and not rt.in_transition()
    end)
end

return this
