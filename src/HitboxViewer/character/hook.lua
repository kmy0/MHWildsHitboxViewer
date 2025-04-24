local data = require("HitboxViewer.data")
local load_queue = require("HitboxViewer.character.load_queue")

local rt = data.runtime

local this = {}

function this.get_base_pre(args)
    local storage = thread.get_hook_storage()
    storage["charbase"] = sdk.to_managed_object(args[2])
end

function this.get_base_post(retval)
    local char_base = thread.get_hook_storage()["charbase"] --[[@as app.CharacterBase?]]
    if not char_base then
        return
    end

    load_queue:enqueue({ tick = rt.state.tick_count, char_base = char_base })
    return retval
end

return this
