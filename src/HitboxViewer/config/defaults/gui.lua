---@class (exact) GuiSettings : SettingsBase
---@field gui WindowSettings

---@class (exact) WindowSettings
---@field main WindowState
---@field hurtbox_info WindowState
---@field attack_log WindowState
---@field collision_log WindowState

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
            is_opened = false,
        },
        attack_log = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            is_opened = false,
        },
        collision_log = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            is_opened = false,
        },
    },
}
