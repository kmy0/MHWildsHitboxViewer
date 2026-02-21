---@class TimeScale
---@field protected _scene via.Scene
---@field protected _step boolean
---@field protected _scale number
---@field protected _reset boolean
---@field enabled boolean

local s = require("HitboxViewer.util.ref.singletons")

---@class TimeScale
local this = {
    _step = false,
    _scale = 1.0,
    enabled = false,
    _reset = false,
}

---@protected
---@param scale number
function this._set(scale)
    s.get_native("via.Application"):set_GlobalSpeed(scale)
end

---@param scale number
function this.set(scale)
    this._scale = scale
end

function this.step()
    this._step = true
end

---@return number
function this.get_timescale()
    return this._scale
end

function this.toggle()
    this.enabled = not this.enabled
end

function this.enable()
    this.enabled = true
end

function this.disable()
    this.enabled = false
end

function this.reset()
    this._set(1.0)
end

function this.freeze()
    this.enabled = true
    this.set(0.0)
end

---@param value number
function this.increment(value)
    this._scale = math.min(this._scale + value, 1.0)
end

---@param value number
function this.decrement(value)
    this._scale = math.max(this._scale - value, 0.0)
end

re.on_frame(function()
    if this.enabled then
        this._reset = true
        this._set(this._scale)

        if this._step then
            this._set(1.0)
            this._step = false
        end
    elseif this._reset then
        this.reset()
        this._reset = false
    end
end)

return this
