local this = {
    hitbox = require("HitboxViewer.box.hit.init"),
    hurtbox = require("HitboxViewer.box.hurt.init"),
    pressbox = require("HitboxViewer.box.press.init"),
    queue = require("HitboxViewer.box.load_queue"),
    collision = require("HitboxViewer.box.collision.init"),
    dummy = require("HitboxViewer.box.dummy"),
}

function this.get()
    this.queue.get()
    this.hurtbox.get()
    this.pressbox.get()
    this.hitbox.get()
    this.collision.get()
end

return this
