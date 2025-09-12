---@class (exact) HurtBoxLoadQueue : QueueBase
---@field queue HurtBoxLoadData[]
---@field enqueue fun(self: HurtBoxLoadQueue , load_data: HurtBoxLoadData)

---@class (exact) HurtBoxLoadData : BoxLoadData
---@field userdata app.col_user_data.DamageParam

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.mod

---@class HurtBoxLoadQueue
local this = queue_base:new()

---@return fun(): HurtBoxLoadData
function this:get()
    return this:_get(function()
        return not rt.in_transition()
    end, config.max_hurtbox_loads)
end

return this
