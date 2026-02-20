---@class TimeCounter
---@field time number
---@field protected _app userdata
---@field protected _app_type_def RETypeDefinition

---@class TimeCounter
local this = {
    time = 0,
}

function this.update()
    if not this._app then
        this._app = sdk.get_native_singleton("via.Application")
        this._app_type_def = sdk.find_type_definition("via.Application") --[[@as RETypeDefinition]]
    end

    this.time = this.time
        + sdk.call_native_func(this._app, this._app_type_def, "get_DeltaTime()") / 60
end

function this.reset()
    this.time = 0
end

re.on_frame(function()
    this.update()
end)

return this
