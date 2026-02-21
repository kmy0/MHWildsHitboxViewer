---@class (exact) BindListener
---@field protected _bind_base BindBase
---@field protected _last_device string

local e = require("HitboxViewer.util.game.enum")
local s = require("HitboxViewer.util.ref.singletons")
local util_bind = require("HitboxViewer.util.game.bind.util")
local util_misc = require("HitboxViewer.util.misc.util")
local util_table = require("HitboxViewer.util.misc.table")

---@class BindListener
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

function this:new()
    local o = { _current_keys = {}, _last_device = "PAD" }
    setmetatable(o, self)
    ---@cast o BindListener
    return o
end

function this:clear()
    self._bind_base.keys = {}
    self._bind_base.name = ""
    self._bind_base.name_display = ""
end

---@param type string
---@return BindBase
function this:bind_base_ctor(type)
    return {
        keys = {},
        name = "",
        name_display = "",
        device = type,
        bound_value = -1,
    }
end

---@param bind_base BindBase
---@return string
function this:get_name_ordered(bind_base)
    local btn_enum = bind_base.device == "KEYBOARD" and e.get("ace.ACE_MKB_KEY.INDEX")
        or e.get("ace.ACE_PAD_KEY.BITS")
    ---@type string[]
    local names = {}
    for i = 1, #bind_base.keys do
        local btn = bind_base.keys[i]
        table.insert(names, btn_enum[btn])
    end

    table.sort(names, function(a, b)
        return btn_enum[a] < btn_enum[b]
    end)
    return table.concat(names, " + ")
end

---@protected
---@param names string[]
function this:_concat_key_names(names)
    if self._bind_base.name_display ~= "" then
        table.insert(names, 1, self._bind_base.name_display)
    end

    self._bind_base.name = self:get_name_ordered(self._bind_base)
    self._bind_base.name_display = table.concat(names, " + ")
end

---@return BindBase
function this:listen_keyboard()
    if not self._bind_base or self._bind_base.device ~= "KEYBOARD" then
        self._bind_base = self:bind_base_ctor("KEYBOARD")
    end

    local kb = util_bind.get_kb()
    ---@type string[]
    local btn_names = {}
    local enum = e.get("ace.ACE_MKB_KEY.INDEX")
    local sorted = util_table.sort(util_table.values(e.get("ace.ACE_MKB_KEY.INDEX").field_to_enum))

    for i = 1, #sorted do
        local index = sorted[i]
        local name = enum[index]

        if
            not name:match("CLICK")
            and kb:isOn(index)
            and not util_table.contains(self._bind_base.keys, index)
        then
            table.insert(self._bind_base.keys, index)
            table.insert(btn_names, enum[index])
        end
    end

    table.sort(btn_names, function(a, b)
        return enum[a] < enum[b]
    end)
    self:_concat_key_names(btn_names)
    return self._bind_base
end

---@return BindBase
function this:listen_pad()
    if not self._bind_base or self._bind_base.device ~= "PAD" then
        self._bind_base = self:bind_base_ctor("PAD")
    end

    local pad = util_bind.get_pad()
    local btn = pad:get_KeyOn()

    if btn == 0 then
        return self._bind_base
    end

    ---@type string[]
    local btn_names = {}
    local enum = e.get("ace.ACE_PAD_KEY.BITS")
    for _, bit in pairs(util_misc.extract_bits(btn)) do
        if enum[bit] and not util_table.contains(self._bind_base.keys, bit) then
            table.insert(btn_names, enum[bit])
            table.insert(self._bind_base.keys, bit)
        end
    end

    table.sort(btn_names, function(a, b)
        return enum[a] < enum[b]
    end)
    self:_concat_key_names(btn_names)
    return self._bind_base
end

---@return BindBase
function this:listen()
    local device = e.get("ace.GUIDef.INPUT_DEVICE")[s.get("app.GUIManager")
        :get_LastInputDeviceIgnoreMouseMove()]
    if device == "KEYBOARD" or device == "PAD" then
        self._last_device = device
    end

    if self._last_device == "KEYBOARD" then
        self._bind_base = self:listen_keyboard()
    elseif self._last_device == "PAD" then
        self._bind_base = self:listen_pad()
    end

    return self._bind_base
end

return this
