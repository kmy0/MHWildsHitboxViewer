---@class (exact) ColLoadQueue : QueueBase
---@field queue ColLoadData[]
---@field enqueue fun(self: ColLoadQueue , load_data: ColLoadData)

---@class (exact) ColLoadData : QueueDataBase
---@field char Character
---@field rsc via.physics.RequestSetCollider

---@class (exact) BoxLoadData : ColLoadData
---@field col via.physics.Collidable
---@field resource_idx integer
---@field set_idx integer
---@field collidable_idx integer
---@field userdata via.physics.UserData

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.runtime

---@class ColLoadQueue
local this = queue_base:new()

---@return fun(): ColLoadData
function this:get()
    return this:_get(function()
        return not rt.in_transition()
    end, config.max_char_loads)
end

return this
