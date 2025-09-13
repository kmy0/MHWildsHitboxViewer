local char_cls = require("HitboxViewer.character.char_base")
local data = require("HitboxViewer.data.init")
local load_queue = require("HitboxViewer.character.load_queue")
local util_game = require("HitboxViewer.util.game.init")

local mod = data.mod

local this = {
    hook = require("HitboxViewer.character.hook"),
    cache = require("HitboxViewer.character.char_cache"),
}

function this.create_all_chars()
    local chars = util_game.get_all_components("app.CharacterBase")
    util_game.do_something(chars, function(system_array, index, value)
        load_queue:enqueue({
            tick = mod.state.tick_count,
            game_object = value:get_GameObject(),
            char_base = value,
        })
    end)
end

--FIXME: when chars are created trough app.CharacterBase.doStart hook, some elements are not created yet
-- and things throw exceptions, couldnt find anything better to hook
function this.get()
    for load_data in load_queue:get() do
        if load_data.char_base and not char_cls:is_valid(load_data.char_base) then
            goto continue
        end

        if not load_data.game_object then
            load_data.game_object = load_data.char_base:get_GameObject()
        end

        this.cache.get_char(load_data.game_object, load_data.char_base)
        ::continue::
    end
end

---@param char_enum CharType
---@return Character[]?
function this.get_sorted_chars(char_enum)
    local ret = {}
    if not this.cache.by_type_by_gameobject[char_enum] then
        return
    end

    for _, char_obj in pairs(this.cache.by_type_by_gameobject[char_enum]) do
        table.insert(ret, char_obj)
    end

    ---@param x Character
    ---@param y Character
    ---@return boolean
    table.sort(ret, function(x, y)
        if x.order < y.order then
            return true
        end
        return false
    end)
    return ret
end

function this.get_master_player()
    return this.cache:get_master_player()
end

function this.clear()
    this.cache:clear()
end

return this
