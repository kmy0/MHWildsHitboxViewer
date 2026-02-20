local box = require("HitboxViewer.box.init")
local call_queue = require("HitboxViewer.util.misc.call_queue")
local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local draw_queue = require("HitboxViewer.draw_queue")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local queue = require("HitboxViewer.util.misc.queue")
local util_game = require("HitboxViewer.util.game.init")

local mod = data.mod

local this = {}

function this.characters()
    local config_mod = config.current.mod
    draw_queue:clear()

    local master_player = char.get_master_player()
    if
        (
            not config_mod.enabled_hurtboxes
            and not config_mod.enabled_hitboxes
            and not config_mod.enabled_pressboxes
            and not config_mod.enabled_collisionboxes
            and master_player
            and master_player:is_dummybox_disabled()
        ) or not master_player
    then
        return
    end

    local tick = frame_counter.frame
    local update_order = mod.map.update_order
    local updated = 0
    local force_updated = 0

    for i = 1, #update_order do
        local char_type = update_order[i]
        local characters = char.cache.by_type_by_gameobject[char_type]

        if not characters then
            goto next_type
        end

        for _, character in pairs(characters) do
            local out_of_range = character:is_out_of_range()
            local do_update = tick - character.last_update_tick >= config.min_char_interval
            local force_update = tick - character.last_update_tick >= config.max_char_interval

            if
                (do_update and updated < config.max_char_updates)
                or force_update and force_updated < config.max_char_updates
                or character.last_update_tick == 0
            then
                character.last_update_tick = tick
                if character:is_dead() then
                    char.cache.remove(character)
                    goto continue
                end

                out_of_range = not character:update_distance(util_game.get_camera_origin())
                if not force_update then
                    updated = updated + 1
                else
                    force_updated = force_updated + 1
                end
            end

            if character:is_disabled() or out_of_range then
                goto continue
            end

            if config_mod.enabled_hitboxes then
                draw_queue:extend(character:update_hitboxes())
            end

            if config_mod.enabled_hurtboxes then
                draw_queue:extend(character:update_hurtboxes())
            end

            if config_mod.enabled_pressboxes then
                draw_queue:extend(character:update_pressboxes())
            end

            if config_mod.enabled_collisionboxes then
                draw_queue:extend(character:update_collisionboxes())
            end

            draw_queue:extend(character:update_dummyboxes())

            ::continue::
        end

        ::next_type::
    end
end

function this.queues()
    if mod.in_transition() then
        return
    end

    char.get()
    box.get()
    call_queue:execute()
end

function this.clear()
    queue.clear_all()
end

return this
