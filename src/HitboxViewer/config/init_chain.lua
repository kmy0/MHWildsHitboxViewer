---@class InitChainFatal : InitChain
---@field fatal_error boolean
---@field checks (fun(): boolean)[]

local config = require("HitboxViewer.config.init")
local init_chain = require("HitboxViewer.util.misc.init_chain")
local util_table = require("HitboxViewer.util.misc.table")

---@class InitChainFatal
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = init_chain })

---@param name string
---@param ... fun(): boolean
---@return InitChainFatal
function this:new(name, ...)
    local o = init_chain.new(self, name, ...)
    setmetatable(o, self)
    ---@cast o InitChainFatal
    o.fatal_error = false
    o.checks = {
        function()
            if not debug then
                re.msg(
                    string.format(
                        'Some other mod is overwriting lua global "debug"! %s wont be able to initialize until the offending mod is fixed/removed.',
                        config.name
                    )
                )
                return true
            end
            return false
        end,
        function()
            if
                util_table.empty(config.lang.files) and not config.lang:try_create_default_file()
            then
                re.msg(
                    string.format(
                        "%s is unable to load default language file! If you are using a mod manager you might need to install the mod manually.",
                        config.name
                    )
                )
                return true
            end
            return false
        end,
    }

    return o
end

---@return boolean
function this:init()
    if self.failed then
        return false
    end

    init_chain.init(self)

    for _, fn in ipairs(self.checks) do
        if fn() then
            self.failed = true
            self.fatal_error = true
            self.ok = false
        end
    end

    return self.ok
end

return this
