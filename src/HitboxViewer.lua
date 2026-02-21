local attack_log = require("HitboxViewer.gui.attack_log")
local box = require("HitboxViewer.box.init")
local char = require("HitboxViewer.character.init")
local collision_log = require("HitboxViewer.gui.collision_log")
local config = require("HitboxViewer.config.init")
local config_menu = require("HitboxViewer.gui.init")
local data = require("HitboxViewer.data.init")
local draw_queue = require("HitboxViewer.draw_queue")
local hurtbox_info = require("HitboxViewer.gui.hurtbox_info")
local update = require("HitboxViewer.update")
local util_imgui = require("HitboxViewer.util.imgui.init")
local util_misc = require("HitboxViewer.util.misc.init")
local util_ref = require("HitboxViewer.util.ref.init")
local logger = util_misc.logger.g
local bind = require("HitboxViewer.bind.init")
local timescale = require("HitboxViewer.util.game.timescale")

local mod = data.mod
---@class MethodUtil
local m = require("HitboxViewer.util.ref.methods")
local init = util_misc.init_chain:new(
    "MAIN",
    data.init,
    config.init,
    box.hurtbox.conditions.init,
    config_menu.init,
    box.collision.init,
    bind.init,
    data.mod.init,
    function()
        timescale.set(config.current.mod.timescale.timescale)
        return true
    end
)

hb_draw.register(function()
    draw_queue:draw()
end)

m.getEnemyNameGuid = m.wrap(m.get("app.EnemyDef.EnemyName(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Guid]]
m.getNpcName = m.wrap(m.get("app.NpcUtil.getNpcName(app.NpcDef.ID)")) --[[@as fun(npc_id: app.NpcDef.ID): System.String]]
m.EmPartsName = m.wrap(m.get("app.EnemyDef.EmPartsName(app.EnemyDef.PARTS_TYPE)")) --[[@as fun(part_type: app.EnemyDef.PARTS_TYPE): System.Guid]]
m.calcCollidableCenter =
    m.wrap(m.get("app.CollisionUtil.calcCollidableCenter(via.physics.Collidable)")) --[[@as fun(col: via.physics.Collidable): Vector3f]]
m.isCollidableValid = m.wrap(m.get("ace.AceUtil.isCollidableValid(via.physics.Collidable)")) --[[@as fun(col: via.physics.Collidable): System.Boolean]]
m.isPorterRiding = m.wrap(m.get("app.NpcUtil.isPorterRiding(app.HunterCharacter)")) --[[@as fun(char: app.HunterCharacter): System.Boolean]]

m.hook(m.get("app.CharacterBase.doStart"), util_ref.capture_this, char.hook.get_base_post)
m.hook(
    m.get(
        "app.ColliderSwitcher.activateAttack(System.Boolean, System.UInt32, System.UInt32, "
            .. "System.Nullable`1<System.Boolean>, app.Hit.HIT_ID_GROUP, System.Nullable`1<System.Single>, System.Nullable`1<System.Single>)"
    ),
    box.hitbox.hook.get_attack_pre
)
m.hook(
    m.get("app.mcShellColHit.setupCollision()"),
    util_ref.capture_this,
    box.hitbox.hook.get_shell_post
)
m.hook(
    m.get("app.Wp10Insect.requestActiveAttackCol(app.Wp10InsectDef.INSECT_ATK_TYPE)"),
    util_ref.capture_this,
    box.hitbox.hook.get_kinsect_attack_post
)

if mod.in_game() then
    char.create_all_chars()
end

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) and init.ok then
        local gui_main = config.gui.current.gui.main
        gui_main.is_opened = not gui_main.is_opened
    end

    if not init.failed then
        local errors = logger:format_errors()
        if errors then
            imgui.same_line()
            imgui.text_colored("Error!", data.gui.colors.bad)
            util_imgui.tooltip_exclamation(errors)
        elseif not init.ok then
            imgui.same_line()
            imgui.text_colored("Initializing...", data.gui.colors.info)
        end
    else
        imgui.same_line()
        imgui.text_colored("Init failed!", data.gui.colors.bad)
    end
end)

---@diagnostic disable-next-line: param-type-mismatch name has too many possibilities so ls fails to find it??
re.on_application_entry("EndPhysics", function()
    if not init.ok then
        return
    end

    if mod.in_game() then
        update.characters()
        update.queues()
        bind.monitor:monitor()
    else
        update.clear()
    end
end)

re.on_frame(function()
    if not init:init() then
        return
    end

    local config_gui = config.gui.current.gui

    if not reframework:is_drawing_ui() then
        config_gui.main.is_opened = false
        config_gui.attack_log.is_opened = false
        config_gui.hurtbox_info.is_opened = false
        config_gui.collision_log.is_opened = false
    end

    if config_gui.main.is_opened then
        config_menu.draw()
    end

    if config_gui.attack_log.is_opened then
        attack_log.draw()
    end

    if config_gui.hurtbox_info.is_opened then
        hurtbox_info.draw()
    end

    if config_gui.collision_log.is_opened then
        collision_log.draw()
    end

    config.run_save()
end)

re.on_config_save(function()
    if data.mod.initialized then
        config.save_no_timer_global()
        timescale.reset()
    end
end)
