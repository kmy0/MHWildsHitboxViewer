local this = {
    queue = require("HitboxViewer.box.press.load_queue"),
}

function this.get()
    this.queue.get()
end

return this
