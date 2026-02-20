---@class CallQueue<T> : Queue
---@field protected _queue (fun(): boolean)[]
---@field protected _in_queue table<fun(): boolean, boolean>

local queue = require("HitboxViewer.util.misc.queue")
local util_table = require("HitboxViewer.util.misc.table")

---@class CallQueue
local this = {
    _queue = {},
    _in_queue = {},
}
table.insert(queue.instances, this)

---@param fn fun(): boolean
function this:push_back(fn)
    table.insert(self._queue, fn)
    self._in_queue[fn] = true
end

---@param fn fun(): boolean
---@return boolean
function this:has(fn)
    if self._in_queue[fn] then
        return true
    end

    return false
end

function this:execute()
    if util_table.empty(self._queue) then
        return
    end

    local next_queue = {}
    for i = 1, #self._queue do
        local fn = self._queue[i]
        local res = fn()
        if res then
            table.insert(next_queue, fn)
        else
            self._in_queue[fn] = nil
        end
    end

    self._queue = next_queue
end

function this:clear()
    self._queue = {}
    self._in_queue = {}
end

return this
