---@class (exact) QueueDataBase
---@class (exact) QueueBase
---@field queue QueueDataBase[]

local util_table = require("HitboxViewer.util.misc.table")

---@class QueueBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

function this:new()
    local o = {
        queue = {},
    }
    setmetatable(o, self)
    return o
end

function this:clear()
    self.queue = {}
end

---@param queue QueueDataBase[]
function this:swap(queue)
    self.queue = queue
end

---@param queue_data QueueDataBase
function this:enqueue(queue_data)
    table.insert(self.queue, queue_data)
end

---@protected
---@param is_enabled (fun(): boolean)?
---@param max integer?
---@param is_skip (fun(load_data: QueueDataBase): boolean)?
---@return fun(): QueueDataBase
function this:_get(is_enabled, max, is_skip)
    local j = 0
    return coroutine.wrap(function()
        if is_enabled and not is_enabled() then
            return
        end

        for i = 1, #self.queue do
            local o = self.queue[i]

            if not o or (is_skip and is_skip(o)) then
                goto continue
            end
            coroutine.yield(o)
            self.queue[i] = nil

            j = j + 1
            if max and j > max then
                break
            end
            ::continue::
        end
    end)
end

function this:get()
    return self:_get()
end

function this:empty()
    return util_table.empty(self.queue)
end

return this
