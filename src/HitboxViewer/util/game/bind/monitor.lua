---@class BindMonitor
---@field managers table<string, MonitoredManager>
---@field execute_order string[] manager names
---@field key_buffer KeyBuffer
---@field on_release_callbacks table<string, fun()[]> key_name, cb
---@field protected _buffer_max integer
---@field protected _pause boolean
---@field protected _on_release_callbacks string[] key names
---@field protected _all_keys {PAD: table<integer, boolean>, KEYBOARD: table<integer, boolean>}

---@class (exact) KeyBuffer
---@field device string
---@field keys table<integer, boolean>
---@field snapshot table<integer, boolean>
---@field frame integer

---@class (exact) BindMap
---@field by_key table<string, Bind>
---@field by_name table<string, boolean>

---@class (exact) MonitoredManager
---@field manager BindManager
---@field held BindMap
---@field triggered BindMap
---@field actions Bind[]

local e = require("HitboxViewer.util.game.enum")
local singletons = require("HitboxViewer.util.ref.singletons")
local util_bind = require("HitboxViewer.util.game.bind.util")
local util_table = require("HitboxViewer.util.misc.table")

---@class BindMonitor
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param ... BindManager
---@return BindMonitor
function this:new(...)
    local o = {
        managers = {},
        _pause = false,
        _buffer_max = 3,
        key_buffer = {
            device = "PAD",
            keys = {},
            frame = 0,
            snapshot = {},
        },
        _all_keys = {
            PAD = {},
            KEYBOARD = {},
        },
        on_release_callbacks = {},
        _on_release_callbacks = {},
        execute_order = {},
    }
    setmetatable(o, self)
    ---@cast o BindMonitor
    local managers = { ... }
    for i = 1, #managers do
        o:add_manager(managers[i])
    end

    return o
end

---@param manager BindManager
function this:add_manager(manager)
    self.managers[manager.name] = {
        manager = manager,
        held = {
            by_key = {},
            by_name = {},
        },
        triggered = {
            by_key = {},
            by_name = {},
        },
        actions = {},
    }

    local function on_data_changed(_)
        self._all_keys = {
            PAD = {},
            KEYBOARD = {},
        }

        for _, m in pairs(self.managers) do
            for _, b in pairs(m.manager.binds) do
                for _, k in pairs(b.keys) do
                    self._all_keys[b.device][k] = true
                end
            end
        end
    end

    on_data_changed(manager)
    manager:register_on_data_changed_callback(on_data_changed)
    manager:set_owner(self)

    table.insert(self.execute_order, manager.name)
end

---@overload fun(manager_name: string, bind: Bind?): boolean
---@overload fun(): boolean
---@param manager_name string?
---@param bind Bind?
---@return boolean
function this:is_held(manager_name, bind)
    if not manager_name then
        return util_table.any(self.managers, function(_, value)
            return not util_table.empty(value.held.by_key)
        end)
    end

    if bind then
        return self.managers[manager_name].held.by_key[self:_get_bind_key(bind)] ~= nil
    end

    return not util_table.empty(self.managers[manager_name].held.by_key)
end

---@overload fun(manager_name: string, bind: Bind?): boolean
---@overload fun(): boolean
---@param manager_name string?
---@param bind Bind?
---@return boolean
function this:is_triggered(manager_name, bind)
    if not manager_name then
        return util_table.any(self.managers, function(_, value)
            return not util_table.empty(value.triggered.by_key)
        end)
    end

    if bind then
        return self.managers[manager_name].triggered.by_key[self:_get_bind_key(bind)] ~= nil
    end

    return not util_table.empty(self.managers[manager_name].triggered.by_key)
end

---@param manager_name string?
---@return string[]
function this:get_held_key_names(manager_name)
    if manager_name then
        return util_table.keys(self.managers[manager_name].held.by_name)
    end

    ---@type table<string, boolean>
    local ret = {}
    for _, m in pairs(self.managers) do
        util_table.merge_t(ret, util_table.keys(m.held.by_name))
    end

    return util_table.keys(ret)
end

---@protected
---@param bind Bind
---@return string
function this:_get_bind_key(bind)
    return string.format("%s_%s", bind.name, bind.bound_value)
end

---@param key_name string | string[]
---@param callback fun()
function this:register_on_release_callback(key_name, callback)
    if type(key_name) ~= "table" then
        key_name = { key_name }
    end

    for _, k in pairs(key_name) do
        if not self.on_release_callbacks[k] then
            self.on_release_callbacks[k] = {}
        end

        table.insert(self.on_release_callbacks[k], callback)
    end
end

function this:execute_actions()
    for i = 1, #self.execute_order do
        local manager_name = self.execute_order[i]
        local actions = self.managers[manager_name].actions

        for j, bind in pairs(actions) do
            bind.action()
            actions[j] = nil
        end
    end
end

function this:execute_on_release_callbacks()
    for _, bind_name in pairs(self._on_release_callbacks) do
        local callbacks = self.on_release_callbacks[bind_name]

        if callbacks then
            for _, cb in pairs(callbacks) do
                cb()
            end
            self.on_release_callbacks[bind_name] = nil
        end
    end

    self._on_release_callbacks = {}
end

---@protected
function this:_buffer_keyboard()
    local kb = util_bind.get_kb()

    for key, _ in pairs(self.key_buffer.snapshot) do
        if not kb:isOn(key) then
            self.key_buffer.snapshot[key] = nil
        end
    end

    for key, _ in pairs(self._all_keys.KEYBOARD) do
        if not self.key_buffer.snapshot[key] and kb:isOn(key) then
            self.key_buffer.keys[key] = true
        else
            self.key_buffer.keys[key] = nil
        end
    end
end

---@protected
function this:_buffer_pad()
    local pad = util_bind.get_pad()
    local btn = pad:get_KeyOn()

    if btn == 0 then
        self.key_buffer.keys = {}
        self.key_buffer.snapshot = {}
        return
    end

    for key, _ in pairs(self.key_buffer.snapshot) do
        if not (btn & key == key) then
            self.key_buffer.snapshot[key] = nil
        end
    end

    for key, _ in pairs(self._all_keys.PAD) do
        if not self.key_buffer.snapshot[key] and btn & key == key then
            self.key_buffer.keys[key] = true
        else
            self.key_buffer.keys[key] = nil
        end
    end
end

---@protected
function this:_clear_buffer()
    self.key_buffer.frame = 0
    self.key_buffer.keys = {}
end

---@protected
function this:_clear_triggers()
    for _, m in pairs(self.managers) do
        m.triggered.by_key = {}
        m.triggered.by_name = {}
    end
end

---@protected
function this:_clear_held()
    for _, m in pairs(self.managers) do
        m.held.by_key = {}
        m.held.by_name = {}
    end
end

---@protected
function this:_clear_actions()
    for _, m in pairs(self.managers) do
        m.actions = {}
    end
end

---@protected
function this:_clear()
    self:_clear_buffer()
    self:_clear_triggers()
    self:_clear_held()
    self:_clear_actions()
    self.on_release_callbacks = {}
    self._on_release_callbacks = {}
    self.key_buffer.snapshot = {}
end

function this:pause()
    self:_clear()
    self._pause = true
end

function this:set_max_buffer_frame(val)
    self:_clear_buffer()
    self._buffer_max = val
end

function this:unpause()
    self:_clear()
    self._pause = false
end

---@protected
function this:_buffer_keys(device)
    if self.key_buffer.device ~= device then
        self.key_buffer.device = device
        self:_clear_buffer()
    end

    if device == "PAD" then
        self:_buffer_pad()
    elseif device == "KEYBOARD" then
        self:_buffer_keyboard()
    end

    if not util_table.empty(self.key_buffer.keys) then
        self.key_buffer.frame = self.key_buffer.frame + 1
    else
        self:_clear_buffer()
    end
end

---@protected
function this:_resolve_held_binds()
    for _, m in pairs(self.managers) do
        for bind_key, bind in pairs(m.held.by_key) do
            if
                bind.device ~= self.key_buffer.device
                or (
                    bind.device == self.key_buffer.device
                    and util_table.all(bind.keys, function(value)
                        return not self.key_buffer.snapshot[value]
                    end)
                )
            then
                table.insert(self._on_release_callbacks, bind.name)
                m.held.by_key[bind_key] = nil
                m.held.by_name[bind.name] = nil
            end
        end
    end
end

---@protected
function this:_resolve_buffer()
    ---@type table<string, boolean>
    local this_frame = {}
    self.key_buffer.snapshot = util_table.merge_t(self.key_buffer.snapshot, self.key_buffer.keys)

    for _, m in pairs(self.managers) do
        for _, bind in pairs(m.manager.sorted) do
            local bind_key = self:_get_bind_key(bind)

            if
                bind.device == self.key_buffer.device
                and not m.held.by_key[bind_key]
                and (
                    this_frame[bind.name]
                    or util_table.all(bind.keys, function(o)
                        return self.key_buffer.keys[o]
                    end)
                )
            then
                table.insert(m.actions, bind)

                if not this_frame[bind.name] then
                    for _, key in pairs(bind.keys) do
                        self.key_buffer.keys[key] = nil
                    end
                end

                this_frame[bind.name] = true
                m.held.by_key[bind_key] = bind
                m.held.by_name[bind.name] = true
                m.triggered.by_key[bind_key] = bind
                m.triggered.by_name[bind.name] = true
            end
        end
    end

    self:_clear_buffer()
end

function this:monitor()
    if
        self._pause
        or util_table.all(self.managers, function(o)
            return util_table.empty(o.manager.binds)
        end)
    then
        return
    end

    local device = e.get("ace.GUIDef.INPUT_DEVICE")[singletons
        .get("app.GUIManager")
        :get_LastInputDeviceIgnoreMouseMove()]

    self:_clear_triggers()
    self:_buffer_keys(device)

    if self:is_held() then
        self:_resolve_held_binds()
    end

    if self.key_buffer.frame == self._buffer_max then
        self:_resolve_buffer()
    end

    self:execute_actions()
    self:execute_on_release_callbacks()
end

return this
