local this = {
    hook = require("HitboxViewer.box.hit.hook"),
    queue = require("HitboxViewer.box.hit.load_queue"),
}

function this.get()
    this.queue.get()
end

return this
