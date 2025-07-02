---@class (exact) PressBoxLoadQueue : QueueBase
---@field queue PressBoxLoadData[]
---@field enqueue fun(self: PressBoxLoadQueue , load_data: PressBoxLoadData)

---@class (exact) PressBoxLoadData : BoxLoadData
---@field userdata app.col_user_data.PressParam

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.runtime

---@class PressBoxLoadQueue
local this = queue_base:new()

---@return fun(): PressBoxLoadData
function this:get()
    return this:_get(function()
        return not rt.in_transition()
    end, config.max_pressbox_loads)
end

return this
