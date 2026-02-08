---@class FrameCache : Cache
---@field protected _map_frame table<any, integer>
---@field max_frame integer
---@field jitter integer

local cache = require("HitboxViewer.util.misc.cache")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local hash = require("HitboxViewer.util.misc.hash")

---@class FrameCache
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = cache })

---@param max_frame integer? by default, 0
---@param jitter integer? by default, 0
---@return FrameCache
function this:new(max_frame, jitter)
    local o = cache.new(self)
    setmetatable(o, self)
    ---@cast o FrameCache
    o.max_frame = max_frame or 0
    o.jitter = jitter or 0
    o._map_frame = {}
    return o
end

---@param key any
---@param value any
function this:set(key, value)
    self._map[key] = value
    self._map_frame[key] = frame_counter.frame + self.max_frame + math.random(0, self.jitter)
end

---@param key any
---@return any
function this:get(key)
    local max_frame = self._map_frame[key]
    if max_frame then
        if frame_counter.frame <= max_frame then
            return self._map[key]
        else
            self._map[key] = nil
            self._map_frame[key] = nil
        end
    end
end

function this:clear()
    self._map_frame = {}
    cache.clear(self)
end

---@generic T: fun(...): any
---@param func T
---@param max_frame integer?
---@param do_hash boolean?
---@param deep_hash_table boolean?
---@param jitter integer?
---@param key_index integer?
---@return T
function this.memoize(func, max_frame, do_hash, deep_hash_table, jitter, key_index)
    local frame_cache = this:new(max_frame, jitter)

    local wrapped = {
        clear = function()
            frame_cache:clear()
        end,
    }
    setmetatable(wrapped, {
        __call = function(_, ...)
            ---@type any
            local key
            if do_hash then
                key =
                    ---@diagnostic disable-next-line: param-type-mismatch
                    hash.hash_args(deep_hash_table, not key_index and ... or select(key_index, ...))
            else
                if select("#", ...) > 0 then
                    ---@diagnostic disable-next-line: no-unknown
                    key = select(key_index or 1, ...)
                else
                    key = 1
                end
            end

            local cached = frame_cache:get(key)

            if cached ~= nil then
                return cached
            end

            ---@diagnostic disable-next-line: no-unknown
            local ret = func(...)
            frame_cache:set(key, ret)
            return ret
        end,
    })

    ---@diagnostic disable-next-line: return-type-mismatch
    return wrapped
end

return this
