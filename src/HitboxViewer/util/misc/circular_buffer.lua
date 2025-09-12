---@class (exact) CircularBuffer<T> : {[integer]: T}
---@field clear_all fun()
---@field protected _buffer any[]
---@field protected _size integer
---@field protected _start integer
---@field protected _count integer

---@class CircularBuffer
local this = {}

---@param idx integer
---@param max integer
---@return integer
local function wrap_index(idx, max)
    return ((idx - 1) % max) + 1
end

---@diagnostic disable-next-line: inject-field
function this.__index(self, key)
    if type(key) == "number" then
        if key == 0 or math.abs(key) > self._count then
            return nil
        end

        ---@type integer
        local actual_idx
        if key > 0 then
            actual_idx = wrap_index(self._start + key - 1, self._size)
        else
            actual_idx = wrap_index(self._start + self._count + key, self._size)
        end

        return self._buffer[actual_idx]
    end

    return this[key]
end

---@type CircularBuffer[]
---@diagnostic disable-next-line: inject-field
this.instances = setmetatable({}, { __mode = "v" })

---@param size integer
---@return CircularBuffer
function this:new(size)
    local o = {
        _buffer = {},
        _size = size,
        _start = 1,
        _count = 0,
    }
    setmetatable(o, self)
    ---@cast o CircularBuffer
    table.insert(this.instances, o)
    return o
end

function this:__len()
    return self._count
end

function this:__ipairs()
    return self._iter, self, 0
end

---@protected
---@param idx integer
---@return integer?, any?
function this:_iter(idx)
    idx = idx + 1
    local value = self[idx] --[[@as any]]
    if value ~= nil then
        return idx, value
    end
end

---@param new_size integer
function this:resize(new_size)
    if new_size == self._size then
        return
    end

    ---@type any[]
    local new_buffer = {}
    local new_count = math.min(self._count, new_size)
    local new_start = 1

    for i = 1, new_count do
        local old_idx = wrap_index(self._start + i - 1, self._size)
        new_buffer[i] = self._buffer[old_idx]
    end

    self._buffer = new_buffer
    self._size = new_size
    self._count = new_count
    self._start = new_start
end

---@param value any
---@return any?
function this:push_back(value)
    local idx = wrap_index(self._start + self._count, self._size)
    local ret = nil

    if self._count == self._size then
        ret = self._buffer[idx]
        self._start = wrap_index(self._start + 1, self._size)
    else
        self._count = self._count + 1
    end

    self._buffer[idx] = value
    return ret
end

---@param value any
---@return any?
function this:push_front(value)
    local idx = wrap_index(self._start - 1, self._size)
    local ret = nil

    if self._count == self._size then
        ret = self._buffer[idx]
    else
        self._count = self._count + 1
    end

    self._start = idx
    self._buffer[self._start] = value
    return ret
end

---@return any?
function this:pop_back()
    if self._count == 0 then
        return nil
    end

    local idx = wrap_index(self._start + self._count - 1, self._size)
    local ret = self._buffer[idx]

    self._buffer[idx] = nil
    self._count = self._count - 1
    return ret
end

---@return any?
function this:pop_front()
    if self._count == 0 then
        return nil
    end

    local ret = self._buffer[self._start]
    self._buffer[self._start] = nil
    self._start = wrap_index(self._start + 1, self._size)
    self._count = self._count - 1
    return ret
end

---@return boolean
function this:is_full()
    return self._count >= self._size
end

function this:clear()
    self._buffer = {}
    self._start = 1
    self._count = 0
end

function this.clear_all()
    for _, o in pairs(this.instances) do
        o:clear()
    end
end

return this
