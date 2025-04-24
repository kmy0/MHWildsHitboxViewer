---@class (exact) LoadDataBase
---@class (exact) LoadQueueBase
---@field queue LoadDataBase[]

---@class LoadQueueBase
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

---@param load_data LoadDataBase
function this:enqueue(load_data)
    table.insert(self.queue, load_data)
end

---@protected
---@param is_enabled (fun(): boolean)?
---@param max integer?
---@param is_skip (fun(load_data: LoadDataBase): boolean)?
---@return fun(): LoadDataBase
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

return this
