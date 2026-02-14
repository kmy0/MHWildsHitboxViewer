---@class ModData
---@field map ModMap
---@field enum ModEnum
---@field initialized boolean

---@class (exact) ModMap
---@field update_order CharType[]

---@class (exact) ModEnum
---@field base_char BaseCharType.*
---@field shape ShapeType.*
---@field shape_dummy ShapeDummy.*
---@field char CharType.*
---@field box BoxType.*
---@field condition_type ConditionType.*
---@field element ElementType.*
---@field condition_result ConditionResult.*
---@field extract ExtractType.*
---@field scar ScarType.*
---@field break_state BreakType.*
---@field box_state BoxState.*
---@field default_hurtbox_state DefaultHurtboxState.*
---@field condition_state ConditionState.*
---@field hitbox_load_data HitBoxLoadDataType.*

local frame_cache = require("HitboxViewer.util.misc.frame_cache")
local s = require("HitboxViewer.util.ref.singletons")
local util_misc = require("HitboxViewer.util.misc.init")

---@class ModData
local this = {
    ---@diagnostic disable-next-line: missing-fields
    enum = {},
    ---@diagnostic disable-next-line: missing-fields
    map = {},
}

---@enum BaseCharType
this.enum.base_char = { ---@class BaseCharType.* : {[string]: integer}, {[integer]: string}
    Hunter = 1,
    BigMonster = 2,
    Pet = 3,
    SmallMonster = 4,
    OtherSmallMonster = 5,
}
---@enum ShapeType
this.enum.shape = { ---@class ShapeType.* : {[string]: integer}, {[integer]: string}
    Sphere = 1,
    Capsule = 2,
    Box = 3,
    Cylinder = 4,
    Triangle = 5,
    ContinuousCapsule = 6,
    ContinuousSphere = 7,
    SlicedCylinder = 8,
}
---@enum ShapeDummy
this.enum.shape_dummy = { ---@class ShapeDummy.* : {[integer]: string}, {[string]: integer}
    [1] = "Sphere",
    [2] = "Capsule",
    [3] = "Box",
    [4] = "Cylinder",
    [5] = "Triangle",
    [8] = "SlicedCylinder",
}
---@enum CharType
this.enum.char = { ---@class CharType.* : {[string]: integer}, {[integer]: string}
    Player = 1,
    MasterPlayer = 2,
    SmallMonster = 3,
    BigMonster = 4,
    Pet = 5,
    Npc = 6,
}
---@enum BoxType
this.enum.box = { ---@class BoxType.* : {[string]: integer}, {[integer]: string}
    HurtBox = 1,
    HitBox = 2,
    ScarBox = 3,
    GuardBox = 4,
    DummyBox = 5,
}
---@enum ConditionType
this.enum.condition_type = { ---@class ConditionType.* : {[string]: integer}, {[integer]: string}
    Element = 1,
    Break = 2,
    Scar = 3,
    Weak = 4,
    Extract = 5,
}
---@enum ElementType
this.enum.element = { ---@class ElementType.* : {[string]: integer}, {[integer]: string}
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
-- stylua: ignore
this.enum.condition_result = { ---@class ConditionResult.* : {[string]: integer}, {[integer]: string}
    None = 1,
    Highlight = 2,
    Hide = 3,
}
---@enum ExtractType
this.enum.extract = { ---@class ExtractType.* : {[string]: integer}, {[integer]: string}
    RED = 1,
    WHITE = 2,
    ORANGE = 3,
    GREEN = 4,
}
---@enum ScarType
this.enum.scar = { ---@class ScarType.* : {[string]: integer}, {[integer]: string}
    NORMAL = 1,
    RAW = 2,
    TEAR = 3,
    OLD = 4,
    HEAL = 5,
}
---@enum BreakType
this.enum.break_state = { ---@class BreakType.* : {[string]: integer}, {[integer]: string}
    Yes = 1,
    No = 2,
    Broken = 3,
}
---@enum BoxState
this.enum.box_state = { ---@class BoxState.* : {[string]: integer}, {[integer]: string}
    None = 1,
    Draw = 2,
    Dead = 3,
}
---@enum DefaultHurtboxState
-- stylua: ignore
this.enum.default_hurtbox_state = { ---@class DefaultHurtboxState.* : {[string]: integer}, {[integer]: string}
    Draw = 1,
    Hide = 2,
}
---@enum ConditionState
this.enum.condition_state = { ---@class ConditionState.* : {[string]: integer}, {[integer]: string}
    Highlight = 1,
    Hide = 2,
}
---@enum HitBoxLoadDataType
-- stylua: ignore
this.enum.hitbox_load_data = { ---@class HitBoxLoadDataType.* : {[string]: integer}, {[integer]: string}
    base = 1,
    rsc = 2,
    shell = 3,
}
this.map.update_order = {
    this.enum.char.MasterPlayer,
    this.enum.char.BigMonster,
    this.enum.char.Player,
    this.enum.char.Pet,
    this.enum.char.Npc,
    this.enum.char.SmallMonster,
}

---@return boolean
function this.is_ok()
    return this.in_game() and not this.in_transition()
end

---@return boolean
function this.in_game()
    local flowman = s.get("app.GameFlowManager")
    if not flowman then
        return false
    end
    return flowman:get_CurrentGameScene() > 0
end

---@return boolean
function this.in_transition()
    local flowman = s.get("app.GameFlowManager")
    if not flowman then
        return true
    end
    return flowman:get_NextGameStateType() ~= nil
end

---@return boolean
function this.init()
    this.initialized = true
    return true
end

this.is_ok = frame_cache.memoize(this.is_ok)
this.in_game = frame_cache.memoize(this.in_game)
this.in_transition = frame_cache.memoize(this.in_transition)

this.enum.base_char = util_misc.make_lookup(this.enum.base_char)
this.enum.shape = util_misc.make_lookup(this.enum.shape)
this.enum.shape_dummy = util_misc.make_lookup(this.enum.shape_dummy)
this.enum.char = util_misc.make_lookup(this.enum.char)
this.enum.box = util_misc.make_lookup(this.enum.box)
this.enum.condition_type = util_misc.make_lookup(this.enum.condition_type)
this.enum.element = util_misc.make_lookup(this.enum.element)
this.enum.condition_result = util_misc.make_lookup(this.enum.condition_result)
this.enum.extract = util_misc.make_lookup(this.enum.extract)
this.enum.break_state = util_misc.make_lookup(this.enum.break_state)
this.enum.scar = util_misc.make_lookup(this.enum.scar)
this.enum.default_hurtbox_state = util_misc.make_lookup(this.enum.default_hurtbox_state)
this.enum.condition_state = util_misc.make_lookup(this.enum.condition_state)
this.enum.hitbox_load_data = util_misc.make_lookup(this.enum.hitbox_load_data)

return this
