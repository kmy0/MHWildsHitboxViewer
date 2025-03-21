local util = require("HitboxViewer.gui.util")
local character = require("HitboxViewer.character")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local table_util = require("HitboxViewer.table_util")

local this = {}
this.is_opened = false

local table_data = {
	name = "hurtbox_info",
	flags = 1 << 8 | 1 << 7 | 1 << 0 | 1 << 10 | 3 << 13,
	col_count = 18,
	headers = {
		"Scars",
		"Part Name",
		"Show",
		"Highlight",
		"Enabled",
		"Weak",
		"Break",
		"Extract",
		"Slash",
		"Blow",
		"Shot",
		"Stun",
		"Fire",
		"Water",
		"Ice",
		"Thunder",
		"Dragon",
		"LightPlant",
	},
	header_to_key = {
		["Part Name"] = "display_name",
		["Enabled"] = "enabled",
		["Show"] = "show",
		["Highlight"] = "highlight",
		["Extract"] = "extract",
		["Break"] = "can_break",
		["Weak"] = "is_weak",
		["Scars"] = "scars",
		["Slash"] = "Slash",
		["Blow"] = "Blow",
		["Shot"] = "Shot",
		["Fire"] = "Fire",
		["Water"] = "Water",
		["Ice"] = "Ice",
		["Thunder"] = "Thunder",
		["Dragon"] = "Dragon",
		["LightPlant"] = "LightPlant",
		["Stun"] = "Stun",
	},
}

---@param scars Scar[]
---@param row integer
local function draw_scar_rows(scars, row)
	for subrow, scar in ipairs(scars) do
		imgui.table_next_row()

		for col = 1, table_data.col_count do
			imgui.table_set_column_index(col - 1)
			imgui.table_set_bg_color(1, 1011830607, col - 1)
			local header = table_data.headers[col]
			-- local value

			if header == "Part Name" then
				imgui.text(scar.state)
				--FIXME: scar position is not updated when its not in RAW state, which makes sense i guess

				-- elseif header == "Show" or header == "Highlight" then
				-- 	value = scar[table_data.header_to_key[header]]
				-- 	imgui.spacing()
				-- 	if
				-- 		imgui.button(
				-- 			string.format(
				-- 				"%s##%s_%s_%s",
				-- 				util.spaced_string(not value and "No" or "Yes", 3),
				-- 				subrow - 1,
				-- 				header,
				-- 				row - 1
				-- 			)
				-- 		)
				-- 	then
				-- 		scar[table_data.header_to_key[header]] = not value
				-- 	end
				-- 	imgui.spacing()
			elseif header == "Enabled" or header == "Extract" or header == "Weak" or header == "Break" then
				imgui.text(data.data_missing)
			else
				imgui.text(scar.hitzone[table_data.header_to_key[header]] --[[@as string]])
			end
		end
	end
end

---@param monster BigEnemy
local function draw_table(monster)
	local sorted_parts = character.get_sorted_part_groups(monster)

	for _, header in ipairs(table_data.headers) do
		imgui.table_setup_column(header)
	end

	imgui.table_headers_row()

	for row, part in ipairs(sorted_parts) do
		imgui.table_next_row()

		for col = 1, table_data.col_count do
			imgui.table_set_column_index(col - 1)
			local header = table_data.headers[col]
			local value

			if header == "Part Name" then
				imgui.text(part.name)
			elseif header == "Show" or header == "Highlight" then
				value = part[table_data.header_to_key[header]]
				imgui.spacing()
				if
					imgui.button(
						string.format(
							"%s##%s_%s_%s",
							util.spaced_string(not value and "No" or "Yes", 3),
							part.part_data.guid,
							header,
							row - 1
						)
					)
				then
					part[table_data.header_to_key[header]] = not value
				end
				imgui.spacing()
			elseif header == "Break" then
				imgui.text(
					part.part_data[table_data.header_to_key[header]]
					and (part.part_data.is_broken and (part.part_data.is_lost and "Severed" or "Broken") or "Yes")
					or "No"
				)
			elseif header == "Weak" or header == "Enabled" then
				imgui.text(part.part_data[table_data.header_to_key[header]] and "Yes" or "No")
			elseif header == "Extract" then
				imgui.text(part.part_data[table_data.header_to_key[header]])
			elseif header == "Scars" then
				if part.part_data.scars then
					imgui.spacing()
					if imgui.arrow_button("##scars_click" .. row, part.scars_open and 3 or 1) then
						part.scars_open = not part.scars_open
					end
					imgui.spacing()
				end
			else
				imgui.text(part.part_data.hitzone[table_data.header_to_key[header]] --[[@as string]])
			end
		end

		if part.scars_open then
			draw_scar_rows(part.part_data.scars, row)
		end
	end
end

---@param key string
---@return boolean?
function this.draw_condition(key)
	---@type boolean
	local changed, save
	local dir
	if imgui.button(string.format("%s##remove_%s", util.spaced_string("Remove", 3), key)) then
		config.current.hurtboxes.conditions[key] = nil
		config.save()
		config.sort_conditions()
		return
	end
	imgui.same_line()
	if imgui.arrow_button(string.format("##up_%s", key), 2) then
		dir = true
	end
	imgui.same_line()
	if imgui.arrow_button(string.format("##down_%s", key), 3) then
		dir = false
	end

	imgui.same_line()
	imgui.push_item_width(200)
	save = util.combo(
		"##combo_type_" .. key,
		config.current.hurtboxes.conditions[key],
		"main_type",
		table_util.keys(data.condition_type_enum)
	) or save

	imgui.same_line()
	save = util.combo(
		"##condition_state_" .. key,
		config.current.hurtboxes.conditions[key],
		"state",
		table_util.keys(data.condition_state_enum)
	) or save
	imgui.pop_item_width()

	if config.current.hurtboxes.conditions[key].main_type == data.condition_type_enum.Element then
		imgui.same_line()
		imgui.push_item_width(200)
		save = util.combo(
			"##combo_element" .. key,
			config.current.hurtboxes.conditions[key],
			"sub_type",
			table_util.keys(data.element_enum)
		) or save
		imgui.pop_item_width()

		imgui.push_item_width(304)
		changed = util.slider_int(
			"##from_" .. key,
			config.current.hurtboxes.conditions[key],
			"from",
			0,
			300,
			"From " .. config.current.hurtboxes.conditions[key].from
		)
		save = changed or save

		if changed and config.current.hurtboxes.conditions[key].from > config.current.hurtboxes.conditions[key].to then
			config.current.hurtboxes.conditions[key].to = config.current.hurtboxes.conditions[key].from
		end

		imgui.same_line()
		changed = util.slider_int(
			"##to_" .. key,
			config.current.hurtboxes.conditions[key],
			"to",
			0,
			300,
			"To " .. config.current.hurtboxes.conditions[key].to
		)
		save = changed or save

		if changed and config.current.hurtboxes.conditions[key].to < config.current.hurtboxes.conditions[key].from then
			config.current.hurtboxes.conditions[key].from = config.current.hurtboxes.conditions[key].to
		end

		imgui.pop_item_width()
	elseif config.current.hurtboxes.conditions[key].main_type == data.condition_type_enum.Extract then
		imgui.push_item_width(200)
		imgui.same_line()
		save = util.combo(
			"##combo_extract" .. key,
			config.current.hurtboxes.conditions[key],
			"sub_type",
			table_util.keys(data.extract_enum)
		) or save
		imgui.pop_item_width()
	elseif config.current.hurtboxes.conditions[key].main_type == data.condition_type_enum.Break then
		imgui.push_item_width(200)
		imgui.same_line()
		save = util.combo(
			"##combo_break" .. key,
			config.current.hurtboxes.conditions[key],
			"sub_type",
			table_util.keys(data.break_enum)
		) or save
		imgui.pop_item_width()
	elseif config.current.hurtboxes.conditions[key].main_type == data.condition_type_enum.Scar then
		config.current.hurtboxes.conditions[key].sub_type = 2
		-- imgui.push_item_width(200)
		-- imgui.same_line()
		-- save = util.combo(
		-- 	"##combo_scar" .. key,
		-- 	config.current.hurtboxes.conditions[key],
		-- 	"sub_type",
		-- 	misc.keys(data.scar_enum)
		-- ) or save
		-- imgui.pop_item_width()
	end

	if config.current.hurtboxes.conditions[key].state == data.condition_state_enum.Highlight then
		imgui.push_item_width(616)
		save = util.color_edit("##color" .. key, config.current.hurtboxes.conditions[key], "color") or save
		imgui.pop_item_width()
	end

	imgui.separator()

	if save then
		config.save()
		config.sort_conditions()
	end
	return dir
end

function this.draw()
	if
		config.current.enabled_hurtboxes
		and not config.current.hurtboxes.disable.BigMonster
		and character.characters_grouped[data.char_enum.BigMonster]
		and next(character.characters_grouped[data.char_enum.BigMonster])
	then
		local sorted_monsters = character.get_sorted_chars(data.char_enum.BigMonster)
		if not sorted_monsters then
			return
		end

		for i, monster in ipairs(sorted_monsters) do
			---@cast monster BigEnemy
			local in_draw_distance = monster.distance < config.current.draw.distance
			if imgui.tree_node(string.format("%s##%s", monster.name, monster.id)) then
				imgui.spacing()

				util.set_pos(5)
				imgui.begin_rect()
				imgui.text("In Draw Distance: ")
				imgui.same_line()
				imgui.text_colored(
					in_draw_distance and "Yes" or "No",
					in_draw_distance and data.colors.good or data.colors.bad
				)
				imgui.text("Distance: ")
				imgui.same_line()
				imgui.text_colored(string.format("%.3f", monster.distance), data.colors.info)
				imgui.end_rect(5, 10)
				imgui.spacing()

				if imgui.begin_table(table_data.name .. i, table_data.col_count, table_data.flags --[[@as ImGuiTableFlags]]) then
					draw_table(monster)
					imgui.end_table()
				end
				imgui.tree_pop()
			end
		end
	end
end

return this
