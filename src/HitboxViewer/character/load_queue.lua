---@class (exact) CharLoadQueue : QueueBase
---@field queue HitBoxLoadData[]
---@field enqueue fun(self: CharLoadQueue , load_data: CharLoadData)

---@class CharLoadData : QueueDataBase
---@field game_object via.GameObject?
---@field char_base app.CharacterBase?
---@field tick integer

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local queue_base = require("HitboxViewer.queue_base")

local rt = data.mod

---@class CharLoadQueue
local this = queue_base:new()

---@return fun(): CharLoadData
function this:get()
    return self:_get(
        function()
            return not rt.in_transition()
        end,
        config.max_char_creates,
        function(load_data)
            ---@cast load_data CharLoadData
            return rt.state.tick_count - load_data.tick <= 60
        end
    )
end

return this
