---@class Logger
---@field console_output boolean
---@field output_file string?
---@field level_names table<LoggerLevel, string>
---@field name string
---@field g Logger global logger
---@field levels table<string, integer>
---@field error_cache table<string, integer>
---@field throttle_sec integer
---@field protected _log_cache table<string, {count: integer, time: integer}>
---@field protected _last_log_clear integer

local util_misc = require("HitboxViewer.util.misc.util")
local util_table = require("HitboxViewer.util.misc.table")

---@class Logger
local this = {}
this.__index = this

---@enum LoggerLevel
this.levels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
}

this.level_names = {
    [this.levels.debug] = "DEBUG",
    [this.levels.info] = "INFO",
    [this.levels.warn] = "WARN",
    [this.levels.error] = "ERROR",
}

---@param level LoggerLevel
---@param throttle_sec integer?
---@param name string?
---@param output_file string?
---@param console_output boolean?
---@return Logger
function this:new(level, throttle_sec, name, output_file, console_output)
    local o = {
        level = level or this.levels.info,
        output_file = output_file,
        console_output = console_output ~= false,
        name = name or this.get_mod_root(),
        error_cache = {},
        throttle_sec = throttle_sec or 5,
        _last_log_clear = 0,
        _log_cache = {},
    }
    setmetatable(o, self)
    ---@cast o Logger
    return o
end

---@protected
---@param level LoggerLevel
---@param message string
function this:_log(level, message)
    if level < self.level then
        return
    end

    local time = os.clock()
    local last_log = self._log_cache[message]
    local rep = ""

    if last_log and time - last_log.time >= self.throttle_sec then
        if last_log.count > 0 then
            rep = string.format(" (repeated %s times)", last_log.count)
        end

        self._log_cache[message] = { count = 0, time = time }
    elseif last_log then
        last_log.count = last_log.count + 1
        return
    else
        self._log_cache[message] = { count = 0, time = time }
    end

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local level_name = self.level_names[level]
    local formatted_message = string.format("[%s] [%s] [%s] %s%s", timestamp, self.name, level_name, message, rep)

    if self.console_output then
        log.debug(formatted_message)
    end

    if level == this.levels.error then
        self.error_cache[message] = time
    end

    if self.output_file then
        local file = io.open(self.output_file, "a")
        if file then
            file:write(formatted_message .. "\n")
            file:close()
        end
    end

    for k, v in pairs(self._log_cache) do
        if time - v.time >= self.throttle_sec + 1 then
            self._log_cache[k] = nil
        end
    end
end

---@param message string
function this:debug(message)
    self:_log(this.levels.debug, message)
end

---@param message string
function this:info(message)
    self:_log(this.levels.info, message)
end

---@param message string
function this:warn(message)
    self:_log(this.levels.warn, message)
end

---@param message string
function this:error(message)
    self:_log(this.levels.error, message)
end

---@param level LoggerLevel
function this:set_level(level)
    self.level = level
end

---@return string?
function this:format_errors()
    if util_table.empty(self.error_cache) then
        return
    end

    local errors = util_table.sort(util_table.keys(self.error_cache), function(a, b)
        return self.error_cache[a] < self.error_cache[b]
    end)

    return table.concat(errors, "\n")
end

function this.get_mod_root()
    local ret = "Unknown"
    util_misc.try(function()
        local info = debug.getinfo(1, "S")
        local name = info.source:match("[/\\]autorun[/\\]([^/\\]+)")
        if name then
            ret = name
        end
    end)

    return ret
end

this.g = this:new(this.levels.debug)

return this
