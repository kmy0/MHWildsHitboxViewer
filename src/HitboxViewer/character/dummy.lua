---@class (exact) DummyChar : Character
---@field base nil
---@field transform via.Transform

local char_cls = require("HitboxViewer.character.char_base")
local data = require("HitboxViewer.data.init")
local util_misc = require("HitboxViewer.util.misc.init")
local util_ref = require("HitboxViewer.util.ref.init")

local mod_enum = data.mod.enum

---@class DummyChar
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = char_cls })

---@param game_object via.GameObject
---@param name string
---@return DummyChar
function this:new(game_object, name)
    ---@diagnostic disable-next-line: param-type-mismatch
    local o = char_cls.new(self, mod_enum.char.Dummy, nil, name, game_object)
    ---@cast o DummyChar
    setmetatable(o, self)

    o.transform = game_object:get_Transform()
    return o
end

---@param char app.CharacterBase?
---@diagnostic disable-next-line: unused-local
function this:is_valid(char)
    local ret = false
    util_misc.try(function()
        ret = not util_ref.is_only_my_ref(self.game_object)
    end)
    return ret
end

---@return Vector3f
function this:get_pos()
    self.pos = self.transform:get_Position()
    return self.pos
end

---@return boolean
function this:is_disabled()
    return false
end

---@return boolean
function this:is_hurtbox_disabled()
    return true
end

---@return boolean
function this:is_hitbox_disabled()
    return true
end

---@return boolean
function this:is_pressbox_disabled()
    return true
end

return this
