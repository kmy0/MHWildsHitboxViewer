---@class FrameCounter
---@field frame integer
---@field last_time integer
---@field fps number

---@class FrameCounter
local this = {
    frame = 0,
    last_time = os.clock(),
    fps = 0,
}

function this.update()
    this.frame = this.frame + 1

    local delta = os.clock()
    local last_time = delta - this.last_time

    if last_time > 0 then
        this.fps = 1.0 / last_time
    end

    this.last_time = delta
end

function this.reset()
    this.frame = 0
    this.last_time = os.clock()
    this.fps = 0
end

re.on_frame(function()
    this.update()
end)

return this
