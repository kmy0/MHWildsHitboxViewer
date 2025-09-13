local data = require("HitboxViewer.data.init")
local enemy = {
    big_enemy = require("HitboxViewer.box.press.pressbox_base"),
    small_enemy = require("HitboxViewer.box.press.pressbox_base"),
}
local friend = {
    player = require("HitboxViewer.box.press.pressbox_base"),
    npc = require("HitboxViewer.box.press.pressbox_base"),
    pet = require("HitboxViewer.box.press.pressbox_base"),
}

local mod = data.mod

local this = {
    queue = require("HitboxViewer.box.press.load_queue"),
}

function this.get()
    for load_data in this.queue:get() do
        ---@type PressBoxBase?
        local box
        local char = load_data.char

        if char.type == mod.enum.char.Npc then
            ---@cast char Npc
            box = friend.npc:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                load_data.userdata
            )
        elseif char.type == mod.enum.char.Player or char.type == mod.enum.char.MasterPlayer then
            ---@cast char Player
            box = friend.player:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                load_data.userdata
            )
        elseif char.type == mod.enum.char.Pet then
            ---@cast char Pet
            box = friend.pet:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                load_data.userdata
            )
        elseif char.type == mod.enum.char.BigMonster then
            ---@cast char BigEnemy
            box = enemy.big_enemy:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                load_data.userdata
            )
        elseif char.type == mod.enum.char.SmallMonster then
            ---@cast char SmallEnemy
            box = enemy.small_enemy:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx,
                load_data.userdata
            )
        end

        if box then
            char:add_pressbox(box)
        end
    end
end

return this
