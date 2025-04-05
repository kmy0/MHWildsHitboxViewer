---@class HurtLoadData
---@field char_obj CharObj
---@field rsc via.physics.RequestSetCollider

local box = require("HitboxViewer.box.init")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local meat = require("HitboxViewer.meat")

local this = {}
---@type HurtLoadData[]
this.load_queue = {}

---@param self Hurtbox
---@return BoxState
local function update(self)
    local big_ok = self.parent.type == data.char_enum.BigMonster and self.part_group
    if big_ok and not self.part_group.show and self.part_group.condition ~= data.condition_state.Highlight then
        return data.box_state.None
    end

    if config.current.hurtboxes.use_one_color then
        self.color = config.current.hurtboxes.color.one_color
    elseif big_ok and self.part_group.highlight then
        self.color = config.current.hurtboxes.color.highlight
    elseif big_ok and self.part_group.condition == data.condition_state.Highlight then
        self.color = self.part_group.condition_color
    else
        self.color = config.current.hurtboxes.color[data.reverse_lookup(data.char_enum, self.parent.type)]
    end

    return data.box_state.Draw
end

---@param collidable via.physics.Collidable
---@param parent Friend
local function add_hurtbox(collidable, parent)
    local hurtbox = box.box_ctor(collidable, parent, update)
    if hurtbox then
        table.insert(parent.hurtboxes, hurtbox)
    end
end

---@param collidable via.physics.Collidable
---@param parent Enemy
---@param userdata app.col_user_data.DamageParamEm
local function add_enemy_hurtbox(collidable, parent, userdata)
    local hurtbox = box.enemy_hurtbox_ctor(collidable, parent, update, userdata)
    if hurtbox then
        if parent.type == data.char_enum.BigMonster then
            ---@cast parent BigEnemy
            meat.add_part_group(parent, hurtbox)
            if hurtbox.part_group then
                table.insert(parent.hurtboxes, hurtbox)
            end
        elseif parent.type == data.char_enum.SmallMonster then
            table.insert(parent.hurtboxes, hurtbox)
        end
    end
end

function this.get()
    if not data.in_transition() then
        local counter = 0

        for idx, load_data in pairs(this.load_queue) do
            local char_obj = load_data.char_obj
            if char_obj.type == data.char_enum.Player or char_obj.type == data.char_enum.MasterPlayer then
                --TODO: not sure which collidables are damage ones when riding, maybe Seikret has them?
                for j = 1, 2 do
                    ---@type via.physics.Collidable?
                    local col = load_data.rsc:getCollidableFromIndex(0, j, 0)
                    if col then
                        ---@cast char_obj Player
                        add_hurtbox(col, char_obj)
                    end
                end
            else
                for i = 0, load_data.rsc:get_NumRequestSets() - 1 do
                    for j = 0, load_data.rsc:getNumRequestSetsFromIndex(i) - 1 do
                        for k = 0, load_data.rsc:getNumCollidablesFromIndex(i, j) - 1 do
                            ---@type via.physics.Collidable?
                            local col = load_data.rsc:getCollidableFromIndex(i, j, k)

                            if not col then
                                goto next_col
                            end

                            local userdata = col:get_UserData()
                            ---@cast userdata via.physics.RequestSetColliderUserData
                            local p_data = userdata:get_ParentUserData()
                            local data_type = p_data:get_type_definition()

                            if not data_type then
                                goto next_col
                            end

							-- stylua: ignore start
                            if
                                (
                                    char_obj.type == data.char_enum.Pet
                                    and data_type:is_a("app.col_user_data.DamageParamOt")
                                )
                                or (
                                    char_obj.type == data.char_enum.Npc
                                    and (
                                        data_type:is_a("app.col_user_data.DamageParamNpc")
                                        ---@diagnostic disable-next-line: cast-type-mismatch
                                        ---@cast data_type app.col_user_data.DamageParamNpc
                                        and data_type._IsAttackDetector
                                    )
                                )
							-- stylua: ignore end
                            then
                                ---@cast char_obj Pet | Npc
                                add_hurtbox(col, char_obj)
                            elseif
                                (
                                    char_obj.type == data.char_enum.BigMonster
                                    or char_obj.type == data.char_enum.SmallMonster
                                ) and data_type:is_a("app.col_user_data.DamageParamEm")
                            then
                                ---@cast char_obj Enemy
                                ---@cast p_data app.col_user_data.DamageParamEm
                                add_enemy_hurtbox(col, char_obj, p_data)
                            end
                            ::next_col::
                        end
                    end
                end
            end

            counter = counter + 1
            this.load_queue[idx] = nil

            if counter == config.max_updates then
                return
            end
        end
    end
end

return this
