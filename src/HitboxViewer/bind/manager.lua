---@class ModBindManager : BindManager
---@field action fun(bind: ModBind)

local bind_manager = require("HitboxViewer.util.game.bind.manager")
local util_table = require("HitboxViewer.util.misc.table")

---@class ModBindManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = setmetatable(this, { __index = bind_manager })

---@param name string?
---@param action fun(bind: Bind)
---@return ModBindManager
function this:new(name, action)
    local o = bind_manager.new(self, name)
    setmetatable(o, self)
    ---@cast o ModBindManager
    o.action = action
    return o
end

---@param binds ModBindBase[]
function this:load(binds)
    local res = util_table.deep_copy(binds) --[=[@as ModBind[]]=]
    for _, bind in pairs(res) do
        bind.action = function()
            self.action(bind)
        end
    end

    bind_manager.load(self, res)
end

---@param bind ModBind
---@return boolean, ModBindBase?
function this:register(bind)
    bind.action = function()
        self.action(bind)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return bind_manager.register(self, bind)
end

return this
