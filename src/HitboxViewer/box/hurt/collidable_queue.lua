---@class (exact) HurtBoxColLoadQueue : LoadQueueBase
---@field queue HurtBoxColLoadData[]
---@field enqueue fun(self: HurtBoxColLoadQueue , load_data: HurtBoxColLoadData)

---@class (exact) HurtBoxColLoadData : LoadDataBase
---@field char Character
---@field rsc via.physics.RequestSetCollider

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local load_queue_base = require("HitboxViewer.load_queue_base")

local rt = data.runtime

---@class HurtBoxColLoadQueue
local this = load_queue_base:new()

---@return fun(): HurtBoxColLoadData
function this:get()
    return this:_get(function()
        return not rt.in_transition()
    end, config.max_char_loads)
end

return this
