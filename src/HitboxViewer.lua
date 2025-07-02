local box = require("HitboxViewer.box")
local char = require("HitboxViewer.character")
local config = require("HitboxViewer.config")
local config_menu = require("HitboxViewer.gui")
local data = require("HitboxViewer.data")
local draw_queue = require("HitboxViewer.draw_queue")
local update = require("HitboxViewer.update")

data.init()
config.init()
box.hurtbox.conditions.init()

local rt = data.runtime

hb_draw.register(function()
    draw_queue:draw()
end)

sdk.hook(
    sdk.find_type_definition("app.CharacterBase"):get_method("doStart") --[[@as REMethodDefinition]],
    char.hook.get_base_pre,
    char.hook.get_base_post
)
sdk.hook(
    sdk.find_type_definition("app.ColliderSwitcher"):get_method(
        "activateAttack(System.Boolean, System.UInt32, System.UInt32, System.Nullable`1<System.Boolean>, app.Hit.HIT_ID_GROUP, System.Nullable`1<System.Single>, System.Nullable`1<System.Single>)"
    ) --[[@as REMethodDefinition]],
    box.hitbox.hook.get_attack_pre
)
sdk.hook(
    sdk.find_type_definition("app.mcShellColHit"):get_method("setupCollision") --[[@as REMethodDefinition]],
    box.hitbox.hook.get_shell_pre,
    box.hitbox.hook.get_shell_post
)
sdk.hook(
    sdk.find_type_definition("app.Wp10Insect"):get_method("requestActiveAttackCol(app.Wp10InsectDef.INSECT_ATK_TYPE)") --[[@as REMethodDefinition]],
    box.hitbox.hook.get_kinsect_attack_pre,
    box.hitbox.hook.get_kinsect_attack_post
)

if config.current.enabled_hurtboxes or config.current.enabled_pressboxes and rt.in_game() then
    char.create_all_chars()
end

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.version)) then
        config.current.gui.main.is_opened = not config.current.gui.main.is_opened
    end
end)

---@diagnostic disable-next-line: param-type-mismatch name has too many possibilities so ls fails to find it??
re.on_application_entry("EndPhysics", function()
    if rt.in_game() then
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
