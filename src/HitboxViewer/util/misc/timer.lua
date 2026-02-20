---@class Timer
---@field timeout number
---@field auto_restart boolean
---@field callback fun()?
---@field protected _started_at number
---@field protected _now number
---@field protected _finished boolean
---@field protected _started boolean
---@field protected _auto_instances Timer[]
---@field protected _updated_frame integer
---@field protected _auto_update boolean
---@field protected _timer_type TimerType

---@alias TimerType "os_clock" | "time_delta"

local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local time_counter = require("HitboxViewer.util.misc.time_counter")

---@class Timer
local this = {}
this.__index = this
this._auto_instances = setmetatable({}, { __mode = "v" })

---@param timeout number
---@param callback fun()?
---@param auto_start boolean? by default, false
---@param auto_restart boolean? by default, false
---@param auto_update boolean? by default, false
---@param timer_type TimerType? by default, os_clock
function this:new(timeout, callback, auto_start, auto_restart, auto_update, timer_type)
    local o = {
        auto_restart = auto_restart and true or false,
        timeout = timeout,
        callback = callback,
        _finished = false,
        _started = false,
        _update_frame = 0,
        _auto_update = auto_update,
        _timer_type = timer_type or "os_clock",
    }
    setmetatable(o, self)
    ---@cast o Timer

    if auto_start then
        o:start()
    end

    if auto_update then
        table.insert(this._auto_instances, o)
    end

    o.elapsed = o._update_on_call(o, o.elapsed)
    o.remaining = o._update_on_call(o, o.remaining)
    o.active = o._update_on_call(o, o.active)
    o.finished = o._update_on_call(o, o.finished)

    return o
end

---@protected
---@generic T: fun(...)
---@param fn T
---@return T
function this:_update_on_call(fn)
    return function(...)
        if not self._auto_update then
            self:update()
        end

        return fn(...)
    end
end

---@return number
function this:_get_time()
    return self._timer_type == "os_clock" and os.clock() or time_counter.time
end

---@protected
---@return number
function this:_update()
    self._now = self:_get_time()
    return self._now
end

---@param timeout number?
---@param callback fun()?
---@param auto_restart boolean?
function this:update_args(timeout, callback, auto_restart)
    self.timeout = timeout or self.timeout
    self.callback = callback or self.callback

    if auto_restart ~= nil then
        self.auto_restart = auto_restart
    end
end

---@param timeout number?
---@param callback fun()?
---@param auto_restart boolean?
function this:start(timeout, callback, auto_restart)
    self:update_args(timeout, callback, auto_restart)
    if not self._started then
        local now = self:_get_time()
        self._now = now
        self._started_at = now
        self._started = true
    end
end

---@return number
function this:elapsed()
    if not self._started then
        return 0
    end
    return self._now - self._started_at
end

---@return boolean
function this:started()
    return self._started
end

---@return number
function this:remaining()
    return math.max(0, self.timeout - self:elapsed())
end

---@param timeout number?
---@param callback fun()?
---@param auto_restart boolean?
function this:restart(timeout, callback, auto_restart)
    self._finished = false
    self._started = false
    self:start(timeout, callback, auto_restart)
end

---@return boolean
function this:active()
    return self._started and not self._finished
end

function this:update()
    if frame_counter.frame == self._updated_frame then
        return
    end

    self._updated_frame = frame_counter.frame

    if not self._started or self._finished then
        return
    end

    self:_update()
    self._finished = self:elapsed() >= self.timeout

    if self._finished and self.callback then
        self.callback()
    end

    if self._finished and self.auto_restart then
        self:restart()
    end
end

---@return boolean
function this:finished()
    return self._started and self._finished
end

function this:abort()
    self._finished = true
    self._started = false
    self._now = nil
    self._started_at = nil
end

function this:abort_and_execute()
    if self._started and not self._finished and self.callback then
        self.callback()
    end
    self:abort()
end

re.on_frame(function()
    for _, t in pairs(this._auto_instances) do
        t:update()
    end
end)

return this
