---@class (exact) GuiSettings : SettingsBase
---@field gui WindowSettings

---@class (exact) WindowSettings
---@field main WindowState
---@field hurtbox_info MonitorState
---@field attack_log AttackLogState

---@class (exact) MonitorState : WindowState
---@field detach boolean

---@class (exact) AttackLogState : MonitorState
---@field pause boolean

---@class (exact) WindowState
---@field pos_x integer
---@field pos_y integer
---@field size_x integer
---@field size_y integer
---@field is_opened boolean

---@class GuiConfig : ConfigBase
---@field current GuiSettings
---@field default GuiSettings

---@type GuiSettings
return {
    gui = {
        main = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            is_opened = false,
        },
        hurtbox_info = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            detach = false,
            is_opened = false,
        },
        attack_log = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            detach = false,
            pause = false,
            is_opened = false,
        },
    },
}
