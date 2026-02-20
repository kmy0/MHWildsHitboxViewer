---@class (exact) MainSettings : SettingsBase
---@field version string
---@field mod ModSettings

---@class (exact) BoxSettings
---@field disable table<string, boolean>
---@field color table<string, integer>
---@field color_enable table<string, boolean>
---@field trail_enable table<string, CheckboxTri>

---@class (exact) HurtboxSettings : BoxSettings
---@field conditions table<string, any>[]
---@field default_state integer DefaultHurtboxState
---@field guard_type GuardboxType

---@class (exact) GuardboxType : BoxSettings
---@field disable_top boolean
---@field disable_bottom boolean

---@class (exact) HitboxSettings : BoxSettings
---@field damage_type BoxSettings
---@field damage_angle BoxSettings
---@field guard_type BoxSettings
---@field misc_type BoxSettings
---@field pause_attack_log boolean

---@class (exact) PressboxSettings : BoxSettings
---@field press_level BoxSettings
---@field layer BoxSettings

---@class (exact) DummyboxSettings
---@field combo_shape integer
---@field color integer

---@class (exact) TrailboxSettings
---@field draw_dur integer
---@field step integer
---@field fade boolean
---@field outline boolean

---@class (exact) CollisionboxSettings
---@field color_col_a integer
---@field color_col_b integer
---@field draw_dur integer
---@field update_once boolean
---@field replace_existing boolean
---@field color_col_point integer
---@field draw_contact_point boolean
---@field disable_damage boolean
---@field disable_press boolean
---@field disable_sensor boolean
---@field disable_undefined boolean
---@field pause_collision_log boolean
---@field disable_damage_enemy boolean
---@field disable_damage_player boolean
---@field ignore_new boolean
---@field ignore_failed boolean

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
---@field enabled_collisionboxes boolean
---@field hurtboxes HurtboxSettings
---@field hitboxes HitboxSettings
---@field pressboxes PressboxSettings
---@field dummyboxes DummyboxSettings
---@field collisionboxes CollisionboxSettings
---@field trailboxes TrailboxSettings
---@field draw DrawSettings

local version = require("HitboxViewer.config.version")

---@param default_color integer
---@param default_highlight_color integer
---@return  MainSettings
return function(default_color, default_highlight_color, default_collision_color)
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
            enabled_collisionboxes = false,
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
                    one_color = default_color,
                },
                color_enable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                press_level = {
                    disable = {},
                    color = {},
                    color_enable = {},
                    trail_enable = {},
                },
                layer = {
                    disable = {},
                    color = {},
                    color_enable = {},
                    trail_enable = {},
                },
                trail_enable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
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
                color_enable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                guard_type = {
                    disable = {},
                    color = {
                        one_color = default_highlight_color,
                    },
                    color_enable = {},
                    disable_top = false,
                    disable_bottom = false,
                    trail_enable = {},
                },
                trail_enable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                conditions = {},
                default_state = 1,
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
                color_enable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                damage_type = {
                    disable = {},
                    color = {},
                    color_enable = {},
                    trail_enable = {},
                },
                damage_angle = {
                    disable = {},
                    color = {},
                    color_enable = {},
                    trail_enable = {},
                },
                guard_type = {
                    disable = {},
                    color = {},
                    color_enable = {},
                    trail_enable = {},
                },
                misc_type = {
                    disable = {},
                    color = {},
                    color_enable = {},
                    trail_enable = {},
                },
                trail_enable = {
                    SmallMonster = false,
                    BigMonster = false,
                    Pet = false,
                    Player = false,
                    MasterPlayer = false,
                    Npc = false,
                },
                pause_attack_log = false,
            },
            collisionboxes = {
                color_col_a = default_color,
                color_col_b = default_highlight_color,
                draw_dur = 3,
                update_once = false,
                replace_existing = false,
                color_col_point = default_collision_color,
                draw_contact_point = true,
                disable_damage = false,
                disable_sensor = false,
                disable_press = false,
                disable_undefined = false,
                pause_collision_log = false,
                disable_damage_enemy = false,
                disable_damage_player = false,
                ignore_new = false,
                ignore_failed = false,
            },
            dummyboxes = {
                combo_shape = 1,
                color = default_color,
            },
            draw = {
                distance = 50,
                outline = true,
                outline_color = 4278190079,
            },
            trailboxes = {
                draw_dur = 30,
                step = 2,
                fade = true,
                outline = true,
            },
        },
    }
end
