local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local load_queue = require("HitboxViewer.character.load_queue")
local util_ref = require("HitboxViewer.util.ref.init")

local this = {}

function this.get_base_post(_)
    local char_base = util_ref.get_this() --[[@as app.CharacterBase?]]
    if not char_base then
        return
    end

    load_queue:push_back({ tick = frame_counter.frame, char_base = char_base })
end

return this
