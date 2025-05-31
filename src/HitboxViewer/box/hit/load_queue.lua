---@class (exact) HitBoxLoadQueue : QueueBase
---@field queue HitBoxLoadData[]
---@field enqueue fun(self: HitBoxLoadQueue , load_data: HitBoxLoadDataRsc | HitBoxLoadDataShell | HitBoxLoadData)

---@class (exact) HitBoxLoadData : QueueDataBase
---@field type HitBoxLoadDataType
---@field char Character
---@field rsc via.physics.RequestSetCollider

---@class (exact) HitBoxLoadDataRsc : HitBoxLoadData
---@field res_idx integer
---@field req_idx integer

---@class (exact) HitBoxLoadDataShell : HitBoxLoadData
---@field res_idx integer
---@field colliders via.physics.Collidable[]
---@field shellcolhit app.mcShellColHit

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.runtime

---@class HitBoxLoadQueue
local this = queue_base:new()

---@return fun(): HitBoxLoadDataRsc | HitBoxLoadDataShell | HitBoxLoadData
function this:get()
    return self:_get(function()
        return config.current.enabled_hitboxes and not rt.in_transition()
    end)
end

return this
