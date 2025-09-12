local this = {
    conditions = require("HitboxViewer.box.hurt.conditions.init"),
    queue = require("HitboxViewer.box.hurt.load_queue"),
}

function this.get()
    this.queue.get()
end

return this
