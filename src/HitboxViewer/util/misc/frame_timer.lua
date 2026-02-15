---@class FrameTimer : Timer

local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local timer = require("HitboxViewer.util.misc.timer")

---@class FrameTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = timer })

---@param timeout integer
---@param callback fun()?
---@param auto_start boolean? by default, false
---@param auto_restart boolean? by default, false
function this:new(timeout, callback, auto_start, auto_restart)
    local o = timer.new(self, timeout, callback, auto_start, auto_restart)
    setmetatable(o, self)
    ---@cast o FrameTimer
    return o
end

---@protected
---@return number
function this:_update()
    self._now = frame_counter.frame
    return self._now
end

---@param timeout integer?
---@param callback fun()?
---@param auto_restart boolean?
function this:start(timeout, callback, auto_restart)
    self:update_args(timeout, callback, auto_restart)
    if not self._started then
        local now = frame_counter.frame
        self._now = now
        self._started_at = now
        self._started = true
    end
end

return this
