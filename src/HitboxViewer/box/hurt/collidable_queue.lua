---@class (exact) HurtBoxColLoadQueue : QueueBase
---@field queue HurtBoxColLoadData[]
---@field enqueue fun(self: HurtBoxColLoadQueue , load_data: HurtBoxColLoadData)

---@class (exact) HurtBoxColLoadData : QueueDataBase
---@field char Character
---@field rsc via.physics.RequestSetCollider

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.runtime

---@class HurtBoxColLoadQueue
local this = queue_base:new()

---@return fun(): HurtBoxColLoadData
function this:get()
    return this:_get(function()
        return not rt.in_transition()
    end, config.max_char_loads)
end

return this
