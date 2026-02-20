---@class (exact) BigEnemy : EnemyCharacter
---@field parts table<string, PartGroup>
---@field mc_holder app.EnemyCharacter.MINI_COMPONENT_HOLDER
---@field browser app.cEnemyBrowser
---@field ctx app.cEnemyContext
---@field pg_queue PGUpdateQueue
---@field scars table<string, ScarBox[]>

---@class (exact) PGUpdateQueue : Queue
---@field queue string[]
---@field get fun(self: PGUpdateQueue): fun(): string

local char_cls = require("HitboxViewer.character.char_base")
local conditions = require("HitboxViewer.box.hurt.conditions.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local queue = require("HitboxViewer.util.misc.queue")
local util_misc = require("HitboxViewer.util.misc.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

---@class BigEnemy
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = char_cls })

---@param base app.EnemyBossCharacter
---@param name string
---@param ctx app.cEnemyContext
---@return BigEnemy
function this:new(base, name, ctx)
    local o = char_cls.new(self, mod_enum.char.BigMonster, base, name)
    ---@cast o BigEnemy
    setmetatable(o, self)
    o.mc_holder = base._MiniComponentHolder
    o.browser = ctx:get_Browser()
    o.parts = {}
    o.ctx = ctx
    o.pg_queue = queue:new() --[[@as PGUpdateQueue]]
    o.scars = {}

    return o
end

---@return boolean
function this:is_dead()
    local ret = false
    util_misc.try(function()
        ret = not self:is_valid()
            or self.browser:get_reference_count() <= 1
            or self.browser:get_IsDie()
    end)

    return ret
end

---@return PartGroup[]
function this:get_sorted_part_groups()
    local ret = {}
    for _, part_group in pairs(self.parts) do
        table.insert(ret, part_group)
    end

    ---@param x PartGroup
    ---@param y PartGroup
    ---@return boolean
    table.sort(ret, function(x, y)
        if x.guid < y.guid then
            return true
        end
        return false
    end)
    return ret
end

function this:reset_conditions()
    for _, part in pairs(self.parts) do
        part.condition = mod_enum.condition_result.None
        part.condition_color = 0
    end
end

---@return HurtBoxBase[]?
function this:update_hurtboxes()
    if self:is_hurtbox_disabled() then
        return
    end

    local ret = {}
    if config.gui.current.gui.hurtbox_info.is_opened or not conditions:empty() then
        if self.pg_queue:empty() then
            self.pg_queue:extend_back(util_table.keys(self.parts))
        end

        ---@type table<string, integer>
        local updated = {}
        for part_key in self.pg_queue:iter(config.max_part_group_updates) do
            local part_group = self.parts[part_key]
            if part_group then
                self.scars[part_key] = self.parts[part_key]:update()
                updated[part_key] = 1
            else
                self.scars[part_key] = nil
            end
        end

        for part_key, scars in pairs(self.scars) do
            if not updated[part_key] then
                for _, scar in pairs(scars) do
                    scar:update_shape()
                end
            end
            table.move(scars, 1, #scars, #ret + 1, ret)
        end
    else
        self.pg_queue:clear()
        self.scars = {}
    end

    local boxes = self:_update_boxes(self.hurtboxes)
    if boxes then
        table.move(boxes, 1, #boxes, #ret + 1, ret)
    end

    if not util_table.empty(ret) then
        return ret
    end
end

return this
