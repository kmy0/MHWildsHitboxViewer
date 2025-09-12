---@class (exact) MainSettings : SettingsBase
---@field version string
---@field mod ModSettings

---@class (exact) BoxSettings
---@field disable table<string, boolean>
---@field color table<string, integer>
---@field use_one_color boolean

---@class (exact) HurtboxSettings : BoxSettings
---@field conditions table<string, table<string, any>>
---@field default_state DefaultHurtboxState
---@field guard_type GuardboxType

---@class (exact) GuardboxType : HitboxType
---@field disable_top boolean
---@field disable_bottom boolean

---@class (exact) HitboxType
---@field disable table<string, boolean>
---@field color table<string, integer>
---@field color_enable table<string, boolean>

---@class (exact) HitboxSettings : BoxSettings
---@field damage_type HitboxType
---@field damage_angle HitboxType
---@field guard_type HitboxType
---@field misc_type HitboxType

---@class (exact) PressboxSettings : BoxSettings
---@field press_level HitboxType
---@field layer HitboxType

---@class (exact) DrawSettings
---@field distance integer
---@field outline boolean
---@field outline_color integer

---@class (exact) ModLanguage
---@field file string
---@field fallback boolean

---@class (exact) ModSettings
---@field lang ModLanguage
---@field enabled_hurtboxes boolean
---@field enabled_hitboxes boolean
---@field enabled_pressboxes boolean
---@field hurtboxes HurtboxSettings
---@field hitboxes HitboxSettings
---@field pressboxes PressboxSettings
---@field draw DrawSettings

local version = require("HitboxViewer.config.version")

---@param default_color integer
---@param default_highlight_color integer
---@return  MainSettings
return function(default_color, default_highlight_color)
    return {
        version = version.version,
        mod = {
            lang = {
                file = "en-us",
                fallback = true,
            },
            enabled_hitboxes = true,
            enabled_hurtboxes = true,
            enabled_pressboxes = false,
            pressboxes = {
                disable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                color = {
                    SmallMonster = default_color,
                    BigMonster = default_color,
                    Pet = default_color,
                    Player = default_color,
                    MasterPlayer = default_color,
                    Npc = default_color,
                    highlight = default_highlight_color,
                    one_color = default_color,
                },
                press_level = {
                    disable = {},
                    color = {},
                    color_enable = {},
                },
                layer = {
                    disable = {},
                    color = {},
                    color_enable = {},
                },
                use_one_color = false,
            },
            hurtboxes = {
                disable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                color = {
                    SmallMonster = default_color,
                    BigMonster = default_color,
                    Pet = default_color,
                    Player = default_color,
                    MasterPlayer = default_color,
                    Npc = default_color,
                    highlight = default_highlight_color,
                    one_color = default_color,
                },
                guard_type = {
                    disable = {},
                    color = {},
                    color_enable = {},
                    disable_top = false,
                    disable_bottom = false,
                },
                conditions = {
                    {
                        color = 1011041213,
                        key = 1,
                        type = 3,
                        state = 1,
                        sub_type = 2,
                    },
                    {
                        color = default_highlight_color,
                        key = 2,
                        type = 4,
                        state = 1,
                    },
                },
                default_state = 1,
                use_one_color = false,
            },
            hitboxes = {
                disable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                color = {
                    SmallMonster = default_color,
                    BigMonster = default_color,
                    Pet = default_color,
                    Player = default_color,
                    MasterPlayer = default_color,
                    Npc = default_color,
                    one_color = default_color,
                },
                damage_type = {
                    disable = {},
                    color = {},
                    color_enable = {},
                },
                damage_angle = {
                    disable = {},
                    color = {},
                    color_enable = {},
                },
                guard_type = {
                    disable = {},
                    color = {},
                    color_enable = {},
                },
                misc_type = {
                    disable = {},
                    color = {},
                    color_enable = {},
                },
                use_one_color = false,
            },
            draw = {
                distance = 50,
                outline = true,
                outline_color = 4261412864,
            },
        },
    }
end
