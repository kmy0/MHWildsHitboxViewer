---@class CharQueue : Queue
---@field push_back fun(self: CharQueue, value: CharLoadData)
---@field iter fun(self: CharQueue, n: integer): fun(): CharLoadData

---@class (exact) CharLoadData
---@field game_object via.GameObject?
---@field char_base app.CharacterBase?
---@field tick integer

local char_cache = require("HitboxViewer.character.char_cache")
local char_cls = require("HitboxViewer.character.char_base")
local config = require("HitboxViewer.config.init")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local queue = require("HitboxViewer.util.misc.queue")

---@class CharQueue
local this = queue:new()
local min_frame = 60

--FIXME: when chars are created trough app.CharacterBase.doStart hook, some elements are not created yet
-- and things throw exceptions, couldnt find anything better to hook
function this.get()
    for load_data in this:iter(config.max_char_creates) do
        if frame_counter.frame - load_data.tick <= min_frame then
            this:push_back(load_data)
            goto continue
        end

        if load_data.char_base and not char_cls:is_valid(load_data.char_base) then
            goto continue
        end

        if not load_data.game_object then
            load_data.game_object = load_data.char_base:get_GameObject()
        end

        char_cache.get_char(load_data.game_object, load_data.char_base)
        ::continue::
    end
end

return this
