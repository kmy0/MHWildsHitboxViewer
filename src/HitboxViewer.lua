local data = require("HitboxViewer.data")
local dummies = require("HitboxViewer.box.dummy")
local drawing = require("HitboxViewer.hb_draw")
local config = require("HitboxViewer.config")
local config_menu = require("HitboxViewer.gui.init")
local hurtboxes = require("HitboxViewer.box.hurt")
local hitboxes = require("HitboxViewer.box.hit")
local character = require("HitboxViewer.character")

data.init()
config.init()
character.init()

sdk.hook(
	sdk.find_type_definition("app.CharacterBase"):get_method("doStart") --[[@as REMethodDefinition]],
	character.get_base_pre,
	character.get_base_post
)
sdk.hook(
	sdk.find_type_definition("app.ColliderSwitcher"):get_method(
		"activateAttack(System.Boolean, System.UInt32, System.UInt32, System.Nullable`1<System.Boolean>, app.Hit.HIT_ID_GROUP, System.Nullable`1<System.Single>, System.Nullable`1<System.Single>)"
	) --[[@as REMethodDefinition]],
	character.get_attack_idx
)
sdk.hook(
	sdk.find_type_definition("app.mcShellColHit"):get_method("setupCollision") --[[@as REMethodDefinition]],
	character.get_shell_pre,
	character.get_shell_post
)

if config.current.enabled_hurtboxes and data.in_game() then
	character.get_all_chars()
end

re.on_draw_ui(function()
	if imgui.button(string.format("%s %s", config.name, config.version)) then
		config_menu.is_opened = not config_menu.is_opened
	end

	local missing_shapes = data.get_missing_shapes()
	if missing_shapes then
		imgui.same_line()
		imgui.text("Missing Shapes: " .. missing_shapes)
	end
end)


---@diagnostic disable-next-line: param-type-mismatch name has too many possibilities so ls fails to find it??
re.on_application_entry("EndRendering", function()
	if data.in_game() then
		data.tick_count = data.tick_count + 1
		character.get()
		hurtboxes.get()
		hitboxes.get()
		dummies.get()
		character.update()
		drawing.draw()
	else
		data.tick_count = 0
		character.clear()
		dummies.clear()
	end
end)

re.on_frame(function()
	if not reframework:is_drawing_ui() then
		config_menu.is_opened = false
	end

	if config_menu.is_opened then
		config_menu.draw()
	end
end)

re.on_config_save(config.save)
