local config = require("HitboxViewer.config.init")
local timescale = require("HitboxViewer.util.game.timescale")
local util_misc = require("HitboxViewer.util.misc.init")

local this = {}

function this.timescale_freeze(...)
    timescale.freeze()
end

function this.timescale_enable(...)
    timescale.enable()
end

function this.timescale_disable(...)
    timescale.disable()
end

function this.timescale_step(...)
    timescale.step()
end

function this.timescale_increment(...)
    local config_ts = config.current.mod.timescale
    timescale.increment(util_misc.round(config_ts.step, 3))
    config_ts.timescale = timescale.get_timescale()
end
function this.timescale_decrement(...)
    local config_ts = config.current.mod.timescale
    timescale.decrement(util_misc.round(config_ts.step, 3))
    config_ts.timescale = timescale.get_timescale()
end

function this.timescale_toggle(...)
    timescale.toggle()
end

---@param bind Bind
---@param monitor BindMonitor
function this.timescale_hold(bind, monitor)
    timescale.enable()
    monitor:register_on_release_callback({ bind.name }, function()
        timescale.disable()
    end)
end

return this
