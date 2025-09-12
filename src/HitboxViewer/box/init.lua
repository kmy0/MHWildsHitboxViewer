local this = {
    hitbox = require("HitboxViewer.box.hit.init"),
    hurtbox = require("HitboxViewer.box.hurt.init"),
    pressbox = require("HitboxViewer.box.press.init"),
    dummy = require("HitboxViewer.box.dummy"),
    queue = require("HitboxViewer.box.load_queue"),
}

function this.get()
    this.queue.get()
    this.hurtbox.get()
    this.pressbox.get()
    this.hitbox.get()
    this.dummy.get()
end

return this
