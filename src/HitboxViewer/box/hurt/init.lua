local data = require("HitboxViewer.data")
local enemy = {
    big_enemy = require("HitboxViewer.box.hurt.big_enemy"),
    small_enemy = require("HitboxViewer.box.hurt.enemy"),
}
local friend = {
    player = require("HitboxViewer.box.hurt.player"),
    npc = require("HitboxViewer.box.hurt.hurtbox_base"),
    pet = require("HitboxViewer.box.hurt.hurtbox_base"),
}
local rt = data.runtime

local this = {
    conditions = require("HitboxViewer.box.hurt.conditions"),
    queue = require("HitboxViewer.box.hurt.load_queue"),
}

function this.get()
    for load_data in this.queue:get() do
        ---@type HurtBoxBase?
        local box
        local char = load_data.char

        local userdata = load_data.userdata
        local data_type = load_data.userdata:get_type_definition() --[[@as RETypeDefinition]]

        -- stylua: ignore start
        if
            char.type == rt.enum.char.Npc
            and (
                data_type:is_a("app.col_user_data.DamageParamNpc")
                ---@cast userdata app.col_user_data.DamageParamNpc
                and userdata._IsAttackDetector
            )
        -- stylua: ignore end
        then
            ---@cast char Npc
            box = friend.npc:new(load_data.col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.Player or char.type == rt.enum.char.MasterPlayer then
            ---@cast char Player
            box = friend.player:new(load_data.col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.Pet and data_type:is_a("app.col_user_data.DamageParamOt") then
            ---@cast char Pet
            box = friend.pet:new(load_data.col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx)
        elseif char.type == rt.enum.char.BigMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
            ---@cast char BigEnemy
            box = enemy.big_enemy:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                userdata --[[@as app.col_user_data.DamageParamEm]]
            )
        elseif char.type == rt.enum.char.SmallMonster and data_type:is_a("app.col_user_data.DamageParamEm") then
            ---@cast char SmallEnemy
            box = enemy.small_enemy:new(load_data.col, char, load_data.resource_idx, load_data.set_idx, load_data.collidable_idx, userdata --[[@as app.col_user_data.DamageParamEm]])
        end

        if box then
            char:add_hurtbox(box)
        end
    end
end

return this
