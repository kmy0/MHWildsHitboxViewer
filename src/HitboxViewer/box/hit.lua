---@class HitLoadData
---@field type HitLoadDataType
---@field char_obj CharObj

---@class HitLoadDataRsc : HitLoadData
---@field rsc via.physics.RequestSetCollider
---@field res_idx integer
---@field req_idx integer

---@class HitLoadDataShell : HitLoadData
---@field first_colider via.physics.Collidable
---@field sub_colliders System.Array<via.physics.Collidable>
---@field shellcolhit app.mcShellColHit

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local box = require("HitboxViewer.box.init")
local attack_log = require("HitboxViewer.attack_log.init")
local attack_misc_type = require("HitboxViewer.attack_log.misc_type")

local this = {}
---@type HitLoadData[]
this.load_queue = {}
---@enum HitLoadDataType
this.load_data_enum = {
	["rsc"] = 1,
	["shell"] = 2,
}

---@param self Hitbox
---@return BoxState
local function update(self)
	if config.current.hitboxes.use_one_color then
		self.color = config.current.hitboxes.color.one_color
	elseif config.current.hitboxes.misc_type.disable[self.log_entry.misc_type] then
		self.color = config.current.hitboxes.misc_type.color[self.log_entry.misc_type]
	elseif config.current.hitboxes.guard_type.color_enable[self.log_entry.guard_type] then
		self.color = config.current.hitboxes.guard_type.color[self.log_entry.guard_type]
	elseif config.current.hitboxes.damage_angle.color_enable[self.log_entry.damage_angle] then
		self.color = config.current.hitboxes.damage_angle.color[self.log_entry.damage_angle]
	elseif config.current.hitboxes.damage_type.color_enable[self.log_entry.damage_type] then
		self.color = config.current.hitboxes.damage_type.color[self.log_entry.damage_type]
	else
		self.color = config.current.hitboxes.color[data.reverse_lookup(data.char_enum, self.parent.type)]
	end

	return data.box_state.Draw
end

---@param collider via.physics.Collidable
---@param char_obj CharObj
---@param shellcolhit app.mcShellColHit?
local function box_insert(collider, char_obj, shellcolhit)
	if not collider or char_obj.hitboxes[collider] then
		return
	end

	local userdata = collider:get_UserData()
	---@cast userdata via.physics.RequestSetColliderUserData
	local log_entry = attack_log.get_log_entry(char_obj, userdata)
	if not log_entry then
		return
	end

	if
		config.current.hitboxes.misc_type.disable[attack_misc_type.check(log_entry)]
		or config.current.hitboxes.guard_type.disable[log_entry.guard_type]
		or config.current.hitboxes.damage_angle.disable[log_entry.damage_angle]
		or config.current.hitboxes.damage_type.disable[log_entry.damage_type]
	then
		return
	end

	attack_log.log(log_entry)
	local hitbox = box.hitbox_ctor(collider, char_obj, update, log_entry, shellcolhit)
	if hitbox then
		char_obj.hitboxes[collider] = hitbox
	end
end

function this.get()
	if config.current.enabled_hitboxes and not data.in_transition() then
		for idx, load_data in pairs(this.load_queue) do
			if load_data.type == this.load_data_enum.rsc then
				---@cast load_data HitLoadDataRsc
				for i = 0, load_data.rsc:getNumCollidables(load_data.res_idx, load_data.req_idx) - 1 do
					local col = load_data.rsc:getCollidable(load_data.res_idx, load_data.req_idx, i)
					box_insert(col, load_data.char_obj)
				end
			else
				---@cast load_data HitLoadDataShell
				box_insert(load_data.first_colider, load_data.char_obj, load_data.shellcolhit)
				local size = load_data.sub_colliders:get_Count()
				for i = 0, size - 1 do
					box_insert(load_data.sub_colliders:get_Item(i), load_data.char_obj, load_data.shellcolhit)
				end
			end

			this.load_queue[idx] = nil
		end
	end
end

return this
