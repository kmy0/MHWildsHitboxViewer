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
---@field table_size integer

---@class (exact) PressboxSettings : BoxSettings
---@field press_level HitboxType
---@field layer HitboxType

---@class (exact) DrawSettings
---@field distance integer
---@field outline boolean
---@field outline_color integer

---@class (exact) WindowState
---@field pos_x integer
---@field pos_y integer
---@field size_x integer
---@field size_y integer
---@field is_opened boolean

---@class (exact) MonitorState : WindowState
---@field detach boolean

---@class (exact) AttackLogState : MonitorState
---@field pause boolean

---@class (exact) GuiState
---@field main WindowState
---@field hurtbox_info MonitorState
---@field attack_log AttackLogState
---@field dummy_shape integer

---@class (exact) Settings
---@field enabled_hurtboxes boolean
---@field enabled_hitboxes boolean
---@field enabled_pressboxes boolean
---@field hurtboxes HurtboxSettings
---@field hitboxes HitboxSettings
---@field pressboxes PressboxSettings
---@field draw DrawSettings
---@field gui GuiState

---@class (exact) Config
---@field version string
---@field name string
---@field config_path string
---@field default_color integer
---@field default_highlight_color integer
---@field max_table_size integer
---@field max_char_loads integer
---@field max_char_updates integer
---@field max_hurtbox_loads integer
---@field max_pressbox_loads integer
---@field min_char_interval integer
---@field max_char_interval integer
---@field max_char_creates integer
---@field max_part_group_updates integer
---@field default Settings
---@field current Settings
---@field init fun()
---@field load fun()
---@field save fun()
---@field restore fun()
---@field get fun(key: string): any
---@field set fun(key: string, value: any)

local table_util = require("HitboxViewer.table_util")
local util = require("HitboxViewer.util")

---@class Config
local this = {}

this.version = "0.0.5"
this.name = "HitboxViewer"
this.config_path = this.name .. "/config.json"
this.default_color = 1020343074
this.default_highlight_color = 1021633775
this.max_table_size = 100
this.max_char_loads = 1
this.max_hurtbox_loads = 3
this.max_pressbox_loads = 3
this.max_part_group_updates = 1
this.max_char_updates = 3
this.max_char_creates = 3
this.min_char_interval = 10
this.max_char_interval = 60

---@diagnostic disable-next-line: missing-fields
this.current = {}
this.default = {
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
            SmallMonster = this.default_color,
            BigMonster = this.default_color,
            Pet = this.default_color,
            Player = this.default_color,
            MasterPlayer = this.default_color,
            Npc = this.default_color,
            highlight = this.default_highlight_color,
            one_color = this.default_color,
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
            SmallMonster = this.default_color,
            BigMonster = this.default_color,
            Pet = this.default_color,
            Player = this.default_color,
            MasterPlayer = this.default_color,
            Npc = this.default_color,
            highlight = this.default_highlight_color,
            one_color = this.default_color,
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
                color = this.default_highlight_color,
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
            SmallMonster = this.default_color,
            BigMonster = this.default_color,
            Pet = this.default_color,
            Player = this.default_color,
            MasterPlayer = this.default_color,
            Npc = this.default_color,
            one_color = this.default_color,
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
        table_size = 25,
        use_one_color = false,
    },
    draw = {
        distance = 50,
        outline = true,
        outline_color = 4261412864,
    },
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
        dummy_shape = 1,
    },
}

---@param key string
---@return any
function this.get(key)
    local ret = this.current
    if not key:find(".") then
        return ret[key]
    end

    local keys = util.split_string(key, "%.")
    for i = 1, #keys do
        ret = ret[keys[i]] --[[@as any]]
    end
    return ret
end

---@param key string
---@param value any
function this.set(key, value)
    local t = this.current
    if not key:find(".") then
        ---@diagnostic disable-next-line: no-unknown
        t[key] = value
        return
    end
    table_util.set_nested_value(t, util.split_string(key, "%."), value)
end

function this.load()
    local loaded_config = json.load_file(this.config_path)
    if loaded_config then
        if not loaded_config.hurtboxes.conditions then
            loaded_config.hurtboxes.conditions = {}
        end
        ---@diagnostic disable-next-line: assign-type-mismatch
        this.current = table_util.table_merge(this.default, loaded_config)
    else
        ---@diagnostic disable-next-line: assign-type-mismatch
        this.current = table_util.table_deep_copy(this.default)
    end
end

function this.save()
    json.dump_file(this.config_path, this.current)
end

function this.restore()
    ---@diagnostic disable-next-line: assign-type-mismatch
    this.current = table_util.table_deep_copy(this.default)
    this.save()
end

function this.init()
    this.load()
end

return this
