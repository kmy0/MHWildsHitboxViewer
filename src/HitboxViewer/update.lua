local box = require("HitboxViewer.box")
local char = require("HitboxViewer.character")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local hb_draw = require("HitboxViewer.hb_draw")

local rt = data.runtime

local this = {}

function this.characters()
    if
        (not config.current.enabled_hurtboxes and not config.current.enabled_hitboxes)
        or not char.get_master_player()
        or rt.in_transition()
    then
        return
    end

    local tick = rt.state.tick_count
    local update_order = rt.map.update_order
    local updated = 0
    local force_updated = 0
    local master_player_pos = char.get_master_player():get_pos()
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

                out_of_range = not character:update_distance(master_player_pos)
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
                hb_draw.enqueue(character:update_hitboxes())
            end
            if config.current.enabled_hurtboxes then
                hb_draw.enqueue(character:update_hurtboxes())
            end
            ::continue::
        end

        ::next_type::
    end
end

function this.queues()
    rt.state.tick_count = rt.state.tick_count + 1
    char.get()
    box.hurtbox.get()
    box.hitbox.get()
    box.dummy.get()
end

function this.clear()
    rt.state.tick_count = 0
    box.hurtbox.clear()
    box.hitbox.clear()
    box.dummy.clear()
    char.clear()
    hb_draw.clear()
end

return this
