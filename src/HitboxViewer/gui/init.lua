local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local character = require("HitboxViewer.character")
local dummies = require("HitboxViewer.box.dummy")
local util = require("HitboxViewer.gui.util")
local hurtbox_info = require("HitboxViewer.gui.hurtbox_info")
local attack_log_gui = require("HitboxViewer.gui.attack_log")
local conditions = require("HitboxViewer.conditions")
local table_util = require("HitboxViewer.table_util")

local this = {
	is_opened = false,
}
local window = {
	flags = 0,
	condition = 1 << 1,
}

local function draw_hurtboxes_header()
	if imgui.collapsing_header("Hurtboxes") then
		imgui.indent(10)
		imgui.spacing()

		imgui.begin_rect()
		util.checkbox("Disable Small Monsters##Hurtbox", config.current.hurtboxes.disable, "SmallMonster")
		util.checkbox("Disable Big Monsters##Hurtbox", config.current.hurtboxes.disable, "BigMonster")
		util.checkbox("Disable Pets##Hurtbox", config.current.hurtboxes.disable, "Pet")
		util.checkbox("Disable Self##Hurtbox", config.current.hurtboxes.disable, "MasterPlayer")
		util.checkbox("Disable Players##Hurtbox", config.current.hurtboxes.disable, "Player")
		util.checkbox("Disable Npc##Hurtbox", config.current.hurtboxes.disable, "Npc")
		imgui.end_rect(5, 10)

		imgui.same_line()
		util.set_pos(5)

		imgui.begin_rect()
		imgui.push_item_width(250)

		if config.current.hurtboxes.use_one_color then
			imgui.push_style_var(0, 0.4)
		end

		util.color_edit("Small Monsters##Hurtbox", config.current.hurtboxes.color, "SmallMonster")
		util.color_edit("Big Monsters##Hurtbox", config.current.hurtboxes.color, "BigMonster")
		util.color_edit("Pets##Hurtbox", config.current.hurtboxes.color, "Pet")
		util.color_edit("Self##Hurtbox", config.current.hurtboxes.color, "MasterPlayer")
		util.color_edit("Players##Hurtbox", config.current.hurtboxes.color, "Player")
		util.color_edit("Npc##Hurtbox", config.current.hurtboxes.color, "Npc")

		if config.current.hurtboxes.use_one_color then
			imgui.pop_style_var(1)
		end

		imgui.pop_item_width()
		imgui.end_rect(5, 10)

		imgui.spacing()
		imgui.spacing()

		if imgui.tree_node("Conditions") then
			if imgui.button(util.spaced_string("Create", 3)) then
				local condition = conditions.ctor()
				config.current.hurtboxes.conditions[tostring(condition.key)] = condition
				config.save()
				config.sort_conditions()
			end
			imgui.same_line()
			imgui.push_item_width(200)
			if
				util.combo(
					"Default Hurtbox State",
					config.current.hurtboxes,
					"default_state",
					table_util.keys(data.default_hurtbox_enum)
				)
			then
				for _, monster in pairs(character.characters_grouped[data.char_enum.BigMonster]) do
					for _, part in pairs(monster.parts) do
						part.show = config.current.hurtboxes.default_state == data.default_hurtbox_enum.Draw
					end
				end
			end
			imgui.pop_item_width()
			util.tooltip("Conditions work only for Big Monsters\nConditions are evaluated from bottom to the top", true)

			imgui.separator()
			---@type string[]
			local sorted = {}
			for k, _ in pairs(config.current.hurtboxes.conditions) do
				table.insert(sorted, k)
			end

			table.sort(sorted, function(x, y)
				if tonumber(x) > tonumber(y) then
					return true
				end
				return false
			end)

			local swap
			local key
			local dir
			for _, k in ipairs(sorted) do
				swap = hurtbox_info.draw_condition(k)
				if swap ~= nil then
					key = k
					dir = swap
				end
			end
			if key then
				local index = table_util.index(sorted, key)
				if index then
					local new_index = dir and index - 1 or index + 1
					if new_index <= #sorted and new_index >= 1 then
						conditions.swap(key, sorted[new_index])
						config.save()
						config.sort_conditions()
					end
				end
			end

			imgui.tree_pop()
		else
			imgui.separator()
		end
		imgui.unindent(10)
		imgui.spacing()
	end
end

local function draw_settings_header()
	if imgui.collapsing_header("General Settings") then
		imgui.indent(10)

		imgui.push_item_width(250)
		util.combo("Shape Spawner", config.current.gui, "dummy_shape", data.shape_dummy)
		imgui.pop_item_width()
		imgui.same_line()

		if imgui.button(util.spaced_string("Go", 7)) then
			dummies.spawn(config.current.gui.dummy_shape)
		end
		imgui.same_line()
		if imgui.button(util.spaced_string("Clear", 6)) then
			dummies.clear()
		end

		imgui.push_item_width(519)
		util.slider_float("Draw Distance", config.current.draw, "distance", 0, 10000, "%.0f")
		imgui.pop_item_width()
		util.checkbox("Show Outline", config.current.draw, "outline")

		if imgui.tree_node("Colors") then
			util.color_edit("Outline", config.current.draw, "outline_color")
			util.checkbox("Use Single Color##Hitbox", config.current.hitboxes.color, "use_one")
			imgui.same_line()

			if imgui.button(util.spaced_string("Apply Hitbox Color To All Hitbox Colors", 3)) then
				imgui.open_popup("confirm_all_colors_hitbox")
			end

			if util.popup_yesno("Are you sure?", "confirm_all_colors_hitbox") then
				for key, _ in pairs(config.current.hitboxes.color) do
					config.current.hitboxes.color[key] = config.current.hitboxes.color.one_color
				end
				for key, _ in pairs(config.current.hitboxes.damage_type.color) do
					config.current.hitboxes.damage_type.color[key] = config.current.hitboxes.color.one_color
				end
				for key, _ in pairs(config.current.hitboxes.damage_angle.color) do
					config.current.hitboxes.damage_angle.color[key] = config.current.hitboxes.color.one_color
				end
				for key, _ in pairs(config.current.hitboxes.guard_type.color) do
					config.current.hitboxes.guard_type.color[key] = config.current.hitboxes.color.one_color
				end
			end

			if not config.current.hitboxes.use_one_color then
				imgui.push_style_var(0, 0.4)
			end
			util.color_edit("Hitbox", config.current.hitboxes.color, "one_color")
			if not config.current.hitboxes.use_one_color then
				imgui.pop_style_var(1)
			end

			imgui.spacing()
			imgui.spacing()

			util.checkbox("Use Single Color##Hurtbox", config.current.hurtboxes.color, "use_one")
			imgui.same_line()

			if imgui.button(util.spaced_string("Apply Hurtbox Color To All Hurtbox Colors", 3)) then
				imgui.open_popup("confirm_all_colors_hurtbox")
			end

			if util.popup_yesno("Are you sure?", "confirm_all_colors_hurtbox") then
				for key, _ in pairs(config.current.hurtboxes.color) do
					config.current.hurtboxes.color[key] = config.current.hurtboxes.color.one_color
				end
			end

			if not config.current.hurtboxes.use_one_color then
				imgui.push_style_var(0, 0.4)
			end
			util.color_edit("Hurtbox", config.current.hurtboxes.color, "one_color")
			if not config.current.hurtboxes.use_one_color then
				imgui.pop_style_var(1)
			end
			imgui.tree_pop()
		end

		if imgui.button(util.spaced_string("Restore Defaults", 3)) then
			imgui.open_popup("confirm_restore")
		end

		if util.popup_yesno("Are you sure?", "confirm_restore") then
			config.restore()
		end

		imgui.unindent(10)
		imgui.separator()
		imgui.spacing()
	end
end

local function draw_hitboxes_header()
	if imgui.collapsing_header("Hitboxes") then
		imgui.indent(10)
		imgui.spacing()

		imgui.begin_rect()
		util.checkbox("Disable Small Monsters##Hitbox", config.current.hitboxes.disable, "SmallMonster")
		util.checkbox("Disable Big Monsters##Hitbox", config.current.hitboxes.disable, "BigMonster")
		util.checkbox("Disable Pets##Hitbox", config.current.hitboxes.disable, "Pet")
		util.checkbox("Disable Self##Hitbox", config.current.hitboxes.disable, "MasterPlayer")
		util.checkbox("Disable Players##Hitbox", config.current.hitboxes.disable, "Player")
		util.checkbox("Disable Npc##Hitbox", config.current.hitboxes.disable, "Npc")
		imgui.end_rect(5, 10)

		imgui.same_line()
		util.set_pos(5)

		imgui.begin_rect()
		imgui.push_item_width(250)

		if config.current.hitboxes.use_one_color then
			imgui.push_style_var(0, 0.4)
		end

		util.color_edit("Small Monsters##Hitbox", config.current.hitboxes.color, "SmallMonster")
		util.color_edit("Big Monsters##Hitbox", config.current.hitboxes.color, "BigMonster")
		util.color_edit("Pets##Hitbox", config.current.hitboxes.color, "Pet")
		util.color_edit("Self##Hitbox", config.current.hitboxes.color, "MasterPlayer")
		util.color_edit("Players##Hitbox", config.current.hitboxes.color, "Player")
		util.color_edit("Npc##Hitbox", config.current.hitboxes.color, "Npc")

		if config.current.hurtboxes.use_one_color then
			imgui.pop_style_var(1)
		end

		imgui.pop_item_width()
		imgui.end_rect(5, 10)

		imgui.spacing()
		imgui.spacing()

		util.tooltip("Color application order:\nMisc Type > Guard Type > Damage Angle > Damage Type > Char", true)
		if imgui.tree_node("Damage Type") then
			imgui.spacing()
			util.box_type_setup(config.current.hitboxes, "damage_type")
			imgui.tree_pop()
		end
		if imgui.tree_node("Damage Angle") then
			imgui.spacing()
			util.box_type_setup(config.current.hitboxes, "damage_angle")
			imgui.tree_pop()
		end
		if imgui.tree_node("Guard Type") then
			imgui.spacing()
			util.box_type_setup(config.current.hitboxes, "guard_type")
			imgui.tree_pop()
		end
		local node = imgui.tree_node("Misc Type")
		util.tooltip("Evaluated from top to bottom")
		if node then
			imgui.spacing()
			util.box_type_setup(config.current.hitboxes, "misc_type")
			imgui.tree_pop()
		end
		imgui.unindent(10)
		imgui.spacing()
	end
end

local function draw_hurtbox_info_header()
	if config.current.gui.hurtbox_info.detach then
		imgui.set_next_window_pos(
			Vector2f.new(config.current.gui.hurtbox_info.pos_x, config.current.gui.hurtbox_info.pos_y),
			window.condition
		)
		imgui.set_next_window_size(
			Vector2f.new(config.current.gui.hurtbox_info.size_x, config.current.gui.hurtbox_info.size_y),
			window.condition
		)

		hurtbox_info.is_opened = imgui.begin_window("Hurtbox Info", hurtbox_info.is_opened, window.flags)
		imgui.indent(10)
		imgui.spacing()
		hurtbox_info.draw()
		imgui.unindent(10)
		local pos = imgui.get_window_pos()
		local size = imgui.get_window_size()
		config.current.gui.hurtbox_info.pos_x, config.current.gui.hurtbox_info.pos_y = pos.x, pos.y
		config.current.gui.hurtbox_info.size_x, config.current.gui.hurtbox_info.size_y = size.x, size.y
		imgui.end_window()
	end

	if not hurtbox_info.is_opened then
		config.current.gui.hurtbox_info.detach = false
	end

	if imgui.collapsing_header("Hurtbox Info") then
		imgui.indent(10)
		imgui.spacing()
		if not config.current.gui.hurtbox_info.detach then
			if imgui.button(util.spaced_string("Detach", 3) .. "##detatch_hurtbox_info") then
				config.current.gui.hurtbox_info.detach = true
				hurtbox_info.is_opened = true
			end

			hurtbox_info.draw()
		else
			imgui.text("Detached")
		end

		imgui.spacing()
		imgui.unindent(10)
		imgui.separator()
		imgui.spacing()
	end
end

local function draw_attack_log_header()
	if config.current.gui.attack_log.detach then
		imgui.set_next_window_pos(
			Vector2f.new(config.current.gui.attack_log.pos_x, config.current.gui.attack_log.pos_y),
			window.condition
		)
		imgui.set_next_window_size(
			Vector2f.new(config.current.gui.attack_log.size_x, config.current.gui.attack_log.size_y),
			window.condition
		)

		attack_log_gui.is_opened = imgui.begin_window("Attack Log", attack_log_gui.is_opened, window.flags)
		imgui.indent(10)
		imgui.spacing()
		attack_log_gui.draw()
		imgui.unindent(10)
		local pos = imgui.get_window_pos()
		local size = imgui.get_window_size()
		config.current.gui.attack_log.pos_x, config.current.gui.attack_log.pos_y = pos.x, pos.y
		config.current.gui.attack_log.size_x, config.current.gui.attack_log.size_y = size.x, size.y
		imgui.end_window()
	end

	if not attack_log_gui.is_opened then
		config.current.gui.attack_log.detach = false
	end

	if imgui.collapsing_header("Attack Log") then
		imgui.indent(10)
		imgui.spacing()
		if not config.current.gui.attack_log.detach then
			if imgui.button(util.spaced_string("Detach", 3) .. "##detatch_attack_log") then
				config.current.gui.attack_log.detach = true
				attack_log_gui.is_opened = true
			end
			attack_log_gui.draw()
		else
			imgui.text("Detached")
		end

		imgui.spacing()
		imgui.unindent(10)
		imgui.separator()
		imgui.spacing()
	end
end

function this.draw()
	local changed = false

	imgui.set_next_window_pos(
		Vector2f.new(config.current.gui.main.pos_x, config.current.gui.main.pos_y),
		window.condition
	)
	imgui.set_next_window_size(
		Vector2f.new(config.current.gui.main.size_x, config.current.gui.main.size_y),
		window.condition
	)

	this.is_opened =
		imgui.begin_window(string.format("%s %s", config.name, config.version), this.is_opened, window.flags)

	if not this.is_opened then
		imgui.end_window()
		local pos = imgui.get_window_pos()
		local size = imgui.get_window_size()
		config.current.gui.main.pos_x, config.current.gui.main.pos_y = pos.x, pos.y
		config.current.gui.main.size_x, config.current.gui.main.size_y = size.x, size.y
		config.save()
		return
	end

	imgui.spacing()
	imgui.indent(10)

	changed, config.current.enabled_hitboxes = imgui.checkbox("Draw Hitboxes", config.current.enabled_hitboxes)
	changed, config.current.enabled_hurtboxes = imgui.checkbox("Draw Hurtboxes", config.current.enabled_hurtboxes)
	if changed and config.current.enabled_hurtboxes and data.in_game() then
		character.get_all_chars()
	end

	imgui.separator()
	imgui.spacing()
	imgui.unindent(10)

	draw_hurtboxes_header()
	draw_hitboxes_header()
	draw_settings_header()
	draw_hurtbox_info_header()
	draw_attack_log_header()

	imgui.end_window()
end

return this
