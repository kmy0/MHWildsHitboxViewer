---@class GenericCondition
---@field color integer
---@field state ConditionStateEnum
---@field main_type integer
---@field sub_type integer?
---@field key integer

---@class ElementCondition : GenericCondition
---@field from integer
---@field to integer

---@alias Condition ElementCondition | GenericCondition

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")

local this = {}

---@return ElementCondition
function this.ctor()
    local t = {}
    local key
    for k, _ in pairs(config.current.hurtboxes.conditions) do
        table.insert(t, tonumber(k))
    end

    if next(t) ~= nil then
        key = tostring(math.max(table.unpack(t)) + 1)
    else
        key = "1"
    end

    return {
        ---@diagnostic disable-next-line: assign-type-mismatch
        key = tonumber(key),
        from = 0,
        to = 300,
        state = data.condition_state_enum.Highlight,
        main_type = data.condition_type_enum.Element,
        color = config.default.hurtboxes.color.highlight,
        sub_type = data.element_enum.Slash,
    }
end

---@param key1 string
---@param key2 string
function this.swap(key1, key2)
    local tmp = config.current.hurtboxes.conditions[key2]
    ---@diagnostic disable-next-line: assign-type-mismatch
    tmp.key = tonumber(key1)
    config.current.hurtboxes.conditions[key2] = config.current.hurtboxes.conditions[key1]
    ---@diagnostic disable-next-line: assign-type-mismatch
    config.current.hurtboxes.conditions[key1].key = tonumber(key2)
    config.current.hurtboxes.conditions[key1] = tmp
end

---@param scar_state string
---@return ConditionState, integer
function this.check_scar(scar_state)
    local state = data.condition_state.None
    --FIXME: scar conditions should be evaluated differently?
    for _, condition in pairs(config.sorted_conditions) do
        if condition.main_type == data.condition_type_enum.Scar then
            local match = data.reverse_lookup(data.scar_enum, condition.sub_type)
            if match == scar_state then
                state = condition.state == data.condition_state_enum.Highlight and data.condition_state.Highlight
                    or data.condition_state.Hide
                return state, condition.color
            end
        end
    end
    return state, 0
end

---@param part_data PartData
---@return ConditionState, integer
function this.check(part_data)
    local state = data.condition_state.None
    for _, condition in pairs(config.sorted_conditions) do
        if
            (condition.main_type == data.condition_type_enum.Weak and part_data.is_weak)
            or (
                condition.main_type == data.condition_type_enum.Extract
                and data.reverse_lookup(data.extract_enum, condition.sub_type) == part_data.extract
            )
        then
            state = condition.state == data.condition_state_enum.Highlight and data.condition_state.Highlight
                or data.condition_state.Hide
            return state, condition.color
        elseif condition.main_type == data.condition_type_enum.Break then
            local match = (part_data.can_break and (part_data.is_broken and "Broken" or "Yes")) or "No"
            if match == data.reverse_lookup(data.break_enum, condition.sub_type) then
                state = condition.state == data.condition_state_enum.Highlight and data.condition_state.Highlight
                    or data.condition_state.Hide
                return state, condition.color
            end
        elseif
            condition.main_type == data.condition_type_enum.Element and condition.sub_type ~= data.element_enum.All
        then
            local value = part_data.hitzone[data.reverse_lookup(data.element_enum, condition.sub_type)]
            if value >= condition.from and value <= condition.to then
                state = condition.state == data.condition_state_enum.Highlight and data.condition_state.Highlight
                    or data.condition_state.Hide
                return state, condition.color
            end
        elseif condition.main_type == data.condition_type_enum.Element then
            for _, value in pairs(part_data.hitzone) do
                if value >= condition.from and value <= condition.to then
                    state = condition.state == data.condition_state_enum.Highlight and data.condition_state.Highlight
                        or data.condition_state.Hide
                    return state, condition.color
                end
            end
        end
    end

    return state, 0
end

return this
