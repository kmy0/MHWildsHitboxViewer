---@class (exact) Queue<T> : {[integer]: T}
---@field clear_all fun()
---@field protected _queue any[]
---@field protected _last integer
---@field protected _first integer
---@field protected _size integer

---@class Queue
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
---@type Queue[]
---@diagnostic disable-next-line: inject-field
this.instances = setmetatable({}, { __mode = "v" })

---@return Queue
function this:new()
    local o = { _first = 0, _last = -1, _queue = {}, _size = 0 }
    setmetatable(o, self)
    ---@cast o Queue
    table.insert(this.instances, o)
    return o
end

function this:__len()
    return self._size
end

---@param arr any[]
function this:extend_front(arr)
    for i = #arr, 1, -1 do
        self:push_front(arr[i])
    end
end

---@param arr any[]
function this:extend_back(arr)
    for i = 1, #arr do
        self:push_back(arr[i])
    end
end

---@param value any
function this:push_front(value)
    local first = self._first - 1
    self._first = first
    self._queue[first] = value
    self._size = self._size + 1
end

---@param value any
function this:push_back(value)
    local last = self._last + 1
    self._last = last
    self._queue[last] = value
    self._size = self._size + 1
end

---@return any?
function this:pop_front()
    local first = self._first

    if first > self._last then
        return
    end

    local value = self._queue[first]
    self._queue[first] = nil
    self._first = first + 1
    self._size = self._size - 1
    return value
end

---@return any?
function this:pop_back()
    local last = self._last

    if self._first > last then
        return
    end

    local value = self._queue[last]
    self._queue[last] = nil
    self._last = last - 1
    self._size = self._size - 1
    return value
end

---@param n integer?
---@return fun(): any
function this:iter(n)
    local count = 0
    local max_items = math.min(n or self._size, self._size)

    return function()
        if count >= max_items or self:empty() then
            return
        end

        count = count + 1
        return self:pop_front()
    end
end

---@param n integer?
---@return fun(): any
function this:reverse_iter(n)
    local count = 0
    local max_items = math.min(n or self._size, self._size)

    return function()
        if count >= max_items or self:empty() then
            return
        end

        count = count + 1
        return self:pop_back()
    end
end

---@return boolean
function this:empty()
    return self._size == 0
end

function this:clear()
    self._queue = {}
    self._last = -1
    self._first = 0
    self._size = 0
end

function this.clear_all()
    for _, o in pairs(this.instances) do
        o:clear()
    end
end

return this
