---@class (exact) HurtBoxLoadQueue : LoadQueueBase
---@field queue HurtBoxLoadData[]
---@field enqueue fun(self: HurtBoxLoadQueue , load_data: HurtBoxLoadData)

---@class (exact) HurtBoxLoadData : LoadDataBase
---@field char Character
---@field rsc via.physics.RequestSetCollider

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local load_queue_base = require("HitboxViewer.load_queue_base")

local rt = data.runtime

---@class HurtBoxLoadQueue
local this = load_queue_base:new()

---@return fun(): HurtBoxLoadData
function this:get()
    return this:_get(function()
        return not rt.in_transition()
    end, config.max_char_loads)
end

return this
