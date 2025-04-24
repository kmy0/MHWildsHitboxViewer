---@class (exact) HitBoxLoadQueue : LoadQueueBase
---@field queue HitBoxLoadData[]
---@field enqueue fun(self: HitBoxLoadQueue , load_data: HitLoadDataRsc | HitLoadDataShell)

---@class (exact) HitBoxLoadData : LoadDataBase
---@field type HitBoxLoadDataType
---@field char Character

---@class (exact) HitLoadDataRsc : HitBoxLoadData
---@field rsc via.physics.RequestSetCollider
---@field res_idx integer
---@field req_idx integer

---@class (exact) HitLoadDataShell : HitBoxLoadData
---@field first_colider via.physics.Collidable
---@field sub_colliders System.Array<via.physics.Collidable>
---@field shellcolhit app.mcShellColHit

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local load_queue_base = require("HitboxViewer.load_queue_base")

local rt = data.runtime

---@class HitBoxLoadQueue
local this = load_queue_base:new()

---@return fun(): HitLoadDataRsc | HitLoadDataShell
function this:get()
    return self:_get(function()
        return config.current.enabled_hitboxes and not rt.in_transition()
    end)
end

return this
