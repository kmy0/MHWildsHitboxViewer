local box = require("HitboxViewer.box")
local char = require("HitboxViewer.character")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local draw_queue = require("HitboxViewer.draw_queue")

local rt = data.runtime

local this = {}

function this.characters()
    draw_queue:clear()

    if
        (
            not config.current.enabled_hurtboxes
            and not config.current.enabled_hitboxes
            and not config.current.enabled_pressboxes
        )
        or not char.get_master_player()
        or rt.in_transition()
    then
        return
    end

    local tick = rt.state.tick_count
    local update_order = rt.map.update_order
    local updated = 0
    local force_updated = 0

    rt.update_camera()
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

                out_of_range = not character:update_distance(rt.camera.origin)
                if not force_update then
                    updated = updated + 1
                else
                    force_updated = force_updated + 1
                end
            end

            if character:is_disabled() or out_of_range then
                goto continue
            end

            if config.current.enabled_hitboxes then
                draw_queue:enqueue(character:update_hitboxes())
            end

            if config.current.enabled_hurtboxes then
                draw_queue:enqueue(character:update_hurtboxes())
            end

            if config.current.enabled_pressboxes then
                draw_queue:enqueue(character:update_pressboxes())
            end

            ::continue::
        end

        ::next_type::
    end
end

function this.queues()
    rt.state.tick_count = rt.state.tick_count + 1
    char.get()
    box.get()
end

function this.clear()
    rt.state.tick_count = 0
    box.clear()
    char.clear()
    draw_queue.clear()
end

return this
