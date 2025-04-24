---@class RuntimeData
---@field playman app.PlayerManager?
---@field flowman app.GameFlowManager?
---@field state State

---@class State
---@field missing_shapes table<string, boolean>
---@field tick_count integer

local table_util = require("HitboxViewer.table_util")

---@class RuntimeData
local this = {
    state = { missing_shapes = {}, tick_count = 0 },
    enum = {},
}

---@enum BaseCharType
this.enum.base_char = {
    Hunter = 1,
    BigMonster = 2,
    Pet = 3,
    SmallMonster = 4,
    OtherSmallMonster = 5,
}
---@enum ShapeType
this.enum.shape = {
    Sphere = 1,
    Capsule = 2,
    Box = 3,
    Cylinder = 4,
    Triangle = 5,
    ContinuousCapsule = 6,
    ContinuousSphere = 7,
}
---@enum ShapeDummy
this.enum.shape_dummy = {
    [1] = "Sphere",
    [2] = "Capsule",
    [3] = "Box",
    [4] = "Cylinder",
    [5] = "Triangle",
}
---@enum CharType
this.enum.char = {
    Player = 1,
    MasterPlayer = 2,
    SmallMonster = 3,
    BigMonster = 4,
    Pet = 5,
    Npc = 6,
}
---@enum BoxType
this.enum.box = {
    HurtBox = 1,
    HitBox = 2,
    ScarBox = 3,
    GuardBox = 4,
    DummyBox = 5,
}
---@enum ConditionType
this.enum.condition_type = {
    Element = 1,
    Break = 2,
    Scar = 3,
    Weak = 4,
    Extract = 5,
}
---@enum ElementType
this.enum.element = {
    All = 1,
    Blow = 2,
    Dragon = 3,
    Fire = 4,
    Ice = 5,
    LightPlant = 6,
    Shot = 7,
    Slash = 8,
    Stun = 9,
    Thunder = 10,
    Water = 11,
}
---@enum ConditionResult
this.enum.condition_result = {
    None = 1,
    Highlight = 2,
    Hide = 3,
}
---@enum ExtractType
this.enum.extract = {
    RED = 1,
    WHITE = 2,
    ORANGE = 3,
    GREEN = 4,
}
---@enum ScarType
this.enum.scar = {
    NORMAL = 1,
    RAW = 2,
    TEAR = 3,
    OLD = 4,
    HEAL = 5,
}
---@enum BreakType
this.enum.break_state = {
    Yes = 1,
    No = 2,
    Broken = 3,
}
---@enum BoxState
this.enum.box_state = {
    None = 1,
    Draw = 2,
    Dead = 3,
}
---@enum DefaultHurtboxState
this.enum.default_hurtbox_state = {
    Draw = 1,
    Hide = 2,
}
---@enum ConditionState
this.enum.condition_state = {
    Highlight = 1,
    Hide = 2,
}
---@enum HitBoxLoadDataType
this.enum.hitbox_load_data = {
    rsc = 1,
    shell = 2,
}

---@return app.GameFlowManager
function this.get_flowman()
    if not this.flowman then
        local obj = sdk.get_managed_singleton("app.GameFlowManager")
        ---@cast obj app.GameFlowManager
        this.flowman = obj
    end
    return this.flowman
end

---@return app.PlayerManager
function this.get_playman()
    if not this.playman then
        local obj = sdk.get_managed_singleton("app.PlayerManager")
        ---@cast obj app.PlayerManager?
        this.playman = obj
    end
    return this.playman
end

---@return boolean
function this.in_game()
    if not this.get_flowman() then
        return false
    end
    return this.get_flowman():get_CurrentGameScene() > 0
end

---@return boolean
function this.in_transition()
    if not this.get_flowman() then
        return true
    end
    return this.get_flowman():get_NextGameStateType() ~= nil
end

---@return string?
function this.get_missing_shapes()
    local t = table_util.keys(this.state.missing_shapes)
    table.sort(t)
    if next(t) then
        return table.concat(t, ", ")
    end
end

return this
