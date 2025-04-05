---@class (exact) BoxSettings
---@field disable table<string, boolean>
---@field color table<string, integer>
---@field use_one_color boolean

---@class (exact) HurtboxSettings : BoxSettings
---@field conditions table<string, Condition>
---@field default_state DefaultHurtboxState

---@class (exact) HitboxType
---@field disable table<string, boolean>
---@field color table<string, integer>
---@field color_enable table<string, integer>

---@class (exact) HitboxSettings : BoxSettings
---@field damage_type HitboxType
---@field damage_angle HitboxType
---@field guard_type HitboxType
---@field misc_type HitboxType
---@field table_size integer

---@class (exact) DrawSettings
---@field distance integer
---@field outline boolean
---@field outline_color integer

---@class (exact) WindowState
---@field pos_x integer
---@field pos_y integer
---@field size_x integer
---@field size_y integer

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
---@field hurtboxes HurtboxSettings
---@field hitboxes HitboxSettings
---@field draw DrawSettings
---@field gui GuiState

---@class (exact) Config
---@field version string
---@field name string
---@field config_path string
---@field default_color integer
---@field default_highlight_color integer
---@field max_table_size integer
---@field max_updates integer
---@field sorted_conditions Condition[]
---@field default Settings
---@field current Settings
---@field init fun()
---@field sort_conditions fun()
---@field load fun()
---@field save fun()
---@field restore fun()

local table_util = require("HitboxViewer.table_util")

---@class Config
local this = {}

this.version = "0.0.1"
this.name = "HitboxViewer"
this.config_path = this.name .. "/config.json"
this.default_color = 1020343074
this.default_highlight_color = 1021633775
this.max_table_size = 100
this.max_updates = 1
this.sorted_conditions = {}

---@diagnostic disable-next-line: missing-fields
this.current = {}
this.default = {
    enabled_hitboxes = true,
    enabled_hurtboxes = true,
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
            highlight = 1021633775,
            one_color = this.default_color,
        },
        conditions = {
            ["1"] = {
                color = 1011041213,
                from = 45,
                key = 1,
                main_type = 3,
                state = 1,
                sub_type = 1,
                to = 300,
            },
            ["2"] = {
                color = 1021633775,
                from = 0,
                key = 2,
                main_type = 4,
                state = 1,
                sub_type = 8,
                to = 300,
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
        outline_color = 4278190080,
    },
    gui = {
        main = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
        },
        hurtbox_info = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            detach = false,
        },
        attack_log = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            detach = false,
            pause = false,
        },
        dummy_shape = 1,
    },
}

function this.sort_conditions()
    ---@type Condition[]
    local sorted = {}
    this.sorted_conditions = {}
    for _, v in pairs(this.current.hurtboxes.conditions) do
        table.insert(sorted, v)
    end

    table.sort(sorted, function(a, b)
        return a.key < b.key
    end)

    for _, condition in ipairs(sorted) do
        table.insert(this.sorted_conditions, condition)
    end
end

function this.load()
    local loaded_config = json.load_file(this.config_path)
    if loaded_config then
        this.current = table_util.table_merge(this.default, loaded_config)
    else
        this.current = table_util.table_deep_copy(this.default)
    end
    this.sort_conditions()
end

function this.save()
    json.dump_file(this.config_path, this.current)
end

function this.restore()
    this.current = table_util.table_deep_copy(this.default)
    this.save()
    this.sort_conditions()
end

function this.init()
    this.load()
end

return this
