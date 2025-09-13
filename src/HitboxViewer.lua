local box = require("HitboxViewer.box.init")
local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local config_menu = require("HitboxViewer.gui.init")
local data = require("HitboxViewer.data.init")
local draw_queue = require("HitboxViewer.draw_queue")
local update = require("HitboxViewer.update")

---@class MethodUtil
local m = require("HitboxViewer.util.ref.methods")

data.init()
config.init()
box.hurtbox.conditions.init()

local mod = data.mod

hb_draw.register(function()
    draw_queue:draw()
end)

m.getEnemyNameGuid = m.wrap(m.get("app.EnemyDef.EnemyName(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Guid]]
m.getNpcName = m.wrap(m.get("app.NpcUtil.getNpcName(app.NpcDef.ID)")) --[[@as fun(npc_id: app.NpcDef.ID): System.String]]
m.EmPartsName = m.wrap(m.get("app.EnemyDef.EmPartsName(app.EnemyDef.PARTS_TYPE)")) --[[@as fun(part_type: app.EnemyDef.PARTS_TYPE): System.Guid]]
m.calcCollidableCenter =
    m.wrap(m.get("app.CollisionUtil.calcCollidableCenter(via.physics.Collidable)")) --[[@as fun(col: via.physics.Collidable): Vector3f]]
m.isCollidableValid = m.wrap(m.get("ace.AceUtil.isCollidableValid(via.physics.Collidable)")) --[[@as fun(col: via.physics.Collidable): System.Boolean]]

m.hook(m.get("app.CharacterBase.doStart"), char.hook.get_base_pre, char.hook.get_base_post)
m.hook(
    m.get(
        "app.ColliderSwitcher.activateAttack(System.Boolean, System.UInt32, System.UInt32, "
            .. "System.Nullable`1<System.Boolean>, app.Hit.HIT_ID_GROUP, System.Nullable`1<System.Single>, System.Nullable`1<System.Single>)"
    ),
    box.hitbox.hook.get_attack_pre
)
m.hook(
    m.get("app.mcShellColHit.setupCollision()"),
    box.hitbox.hook.get_shell_pre,
    box.hitbox.hook.get_shell_post
)
m.hook(
    m.get("app.Wp10Insect.requestActiveAttackCol(app.Wp10InsectDef.INSECT_ATK_TYPE)"),
    box.hitbox.hook.get_kinsect_attack_pre,
    box.hitbox.hook.get_kinsect_attack_post
)

if config.current.enabled_hurtboxes or config.current.enabled_pressboxes and mod.in_game() then
    char.create_all_chars()
end

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.version)) then
        config.current.gui.main.is_opened = not config.current.gui.main.is_opened
    end
end)

---@diagnostic disable-next-line: param-type-mismatch name has too many possibilities so ls fails to find it??
re.on_application_entry("EndPhysics", function()
    if mod.in_game() then
        update.characters()
        update.queues()
    else
        update.clear()
    end
end)

re.on_frame(function()
    if not reframework:is_drawing_ui() then
        config.current.gui.main.is_opened = false
    end

    if config.current.gui.main.is_opened then
        config_menu.draw()
    end
end)

re.on_config_save(config.save)
