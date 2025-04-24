---@class Conditions
---@field sorted ConditionBase[]
---@field by_type table<ConditionType, ConditionBase[]>

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local table_util = require("HitboxViewer.table_util")

local rt = data.runtime
---@type table<ConditionType, ConditionBase>
local condition_ctor = {
    [1] = require("HitboxViewer.box.hurt.conditions.element_condition"),
    [2] = require("HitboxViewer.box.hurt.conditions.break_condition"),
    [3] = require("HitboxViewer.box.hurt.conditions.scar_condition"),
    [4] = require("HitboxViewer.box.hurt.conditions.weak_condition"),
    [5] = require("HitboxViewer.box.hurt.conditions.extract_condition"),
}

---@class Conditions
local this = {
    sorted = {},
    by_type = {},
}

function this:sort()
    self.by_type = {}
    table.sort(self.sorted, function(a, b)
        return a.key < b.key
    end)
    for i = 1, #self.sorted do
        local cond = self.sorted[i]
        table_util.insert_nested_value(self.by_type, { cond.type }, cond)
    end
end

function this:init()
    for _, condition_struct in pairs(config.current.hurtboxes.conditions) do
        if not condition_struct.type or not condition_ctor[condition_struct.type] then
            self:restore_default()
            return
        end
        self:new_condition(condition_struct.type, condition_struct)
    end
end

function this:restore_default()
    config.current.hurtboxes.conditions = config.default.hurtboxes.conditions
    self:clear()
    self:init()
end

---@param cond ConditionBase
---@return table<string, any>
function this:_serialize(cond)
    ---@type table<string, any>
    local ret = {}
    ---@diagnostic disable-next-line: no-unknown
    for key, value in pairs(cond) do
        if type(value) ~= "function" then
            ret[key] = value
        end
    end
    return ret
end

function this:save()
    ---@type table<string, table<string, any>>
    local t = {}
    for _, cond in pairs(self.sorted) do
        ---@type table<string, any>
        table.insert(t, self:_serialize(cond))
    end
    config.current.hurtboxes.conditions = t
    config.save()
end

---@param part_group PartGroup
---@return ConditionResult, integer
function this:check_part_group(part_group)
    for i = 1, #self.sorted do
        local cond = self.sorted[i]
        if cond.type ~= rt.enum.condition_type.Scar then
            local state, color = cond:check(part_group)
            if state ~= rt.enum.condition_result.None then
                return state, color
            end
        end
    end
    return rt.enum.condition_result.None, 0
end

---@param scar_state string
---@return ConditionResult, integer
function this:check_scar(scar_state)
    local t = self.by_type[rt.enum.condition_type.Scar] or {}
    for i = 1, #t do
        local cond = t[i]
        ---@cast cond ScarCondition
        local state, color = cond:check(scar_state)
        if state ~= rt.enum.condition_result.None then
            return state, color
        end
    end
    return rt.enum.condition_result.None, 0
end

---@param cond_a ConditionBase?
---@param cond_b ConditionBase?
---@return boolean
function this:swap_order(cond_a, cond_b)
    if not cond_a or not cond_b then
        return false
    end

    local key_a = cond_a.key
    local key_b = cond_b.key
    cond_b.key = key_a
    cond_a.key = key_b
    self:sort()
    self:save()
    return true
end

---@param old_cond ConditionBase
---@param new_cond_type ConditionType
---@return ConditionBase
function this:swap_condition(old_cond, new_cond_type)
    local args = self:_serialize(old_cond)
    self:remove(old_cond)
    return self:new_condition(new_cond_type, args)
end

---@param cond_type ConditionType
---@param serial table<string, any>?
---@return ConditionBase
function this:new_condition(cond_type, serial)
    local ctor = condition_ctor[cond_type]
    ---@type ConditionBase
    local cond
    if serial then
        cond = ctor:new_from_serial(serial)
    else
        ---@diagnostic disable-next-line: missing-parameter
        cond = ctor:new()
    end
    table.insert(self.sorted, cond)
    self:sort()
    self:save()
    return cond
end

---@param cond ConditionBase
function this:remove(cond)
    table_util.table_remove(self.sorted, function(t, i, j)
        return t[i] ~= cond
    end)
    table_util.table_remove(self.by_type[cond.type], function(t, i, j)
        return t[i] ~= cond
    end)
    self:save()
end

---@boolean
function this:empty()
    return table_util.empty(self.sorted)
end

function this:clear()
    self.sorted = {}
    self.by_type = {}
end

return this
