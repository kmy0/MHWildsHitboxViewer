local e = require("HitboxViewer.util.game.enum")
local util_table = require("HitboxViewer.util.misc.table")

local this = {
    listener = require("HitboxViewer.util.game.bind.listener"),
    manager = require("HitboxViewer.util.game.bind.manager"),
    monitor = require("HitboxViewer.util.game.bind.monitor"),
}

---@return boolean
function this.init()
    if
        util_table.any({
            e.new("ace.ACE_PAD_KEY.BITS", function(key, _)
                return not util_table.contains({ "HOME", "DECIDE", "CANCEL" }, key)
            end),
            e.new("ace.ACE_MKB_KEY.INDEX"),
            e.new("ace.GUIDef.INPUT_DEVICE"),
        }, function(_, value)
            return not value.ok
        end)
    then
        return false
    end

    return true
end

return this
