local char_cache = require("HitboxViewer.character.char_cache")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local load_queue = require("HitboxViewer.box.hit.load_queue")
local utilities = require("HitboxViewer.util")

local rt = data.runtime
local rl = data.util.reverse_lookup

local this = {}

function this.get_shell_pre(args)
    if not config.current.enabled_hitboxes then
        return
    end

    local storage = thread.get_hook_storage()
    storage["shellcolhit"] = sdk.to_managed_object(args[2])
end

function this.get_shell_post(retval)
    if not config.current.enabled_hitboxes then
        return
    end

    local storage = thread.get_hook_storage()
    if not storage or not storage["shellcolhit"] then
        return
    end

    local shellcolhit = storage["shellcolhit"] --[[@as app.mcShellColHit]]
    --FIXME: surely there must be better way to get actual owner of the shell???
    local shellcol_owner = shellcolhit:get_Owner()
    local shell_base = utilities.get_component(shellcol_owner, "ace.ShellBase")
    ---@cast shell_base ace.ShellBase
    local shell_owner = shell_base:get_ShellOwner()
    local shell_transform = shell_owner:get_Transform()

    while 1 do
        local parent = shell_transform:get_Parent()
        if parent then
            shell_transform = parent
        else
            break
        end
    end

    local actual_owner = shell_transform:get_GameObject()
    local char = char_cache.get_char(actual_owner)

    if
        not char
        or char.distance > config.current.draw.distance
        or config.current.hitboxes.disable[rl(rt.enum.char, char.type)]
    then
        return
    end

    local first_colider = shellcolhit._FirstCollider
    local sub_colliders = shellcolhit._SubColliders

    if not first_colider and sub_colliders:get_Count() == 0 then
        load_queue:enqueue({
            type = rt.enum.hitbox_load_data.shell_rsc,
            char = char,
            rsc = shellcolhit._ReqSetCol,
            res_idx = shellcolhit._CollisionResourceIndex,
            shellcolhit = shellcolhit,
        })
    else
    load_queue:enqueue({
        type = rt.enum.hitbox_load_data.shell,
        char = char,
        first_colider = shellcolhit._FirstCollider,
        sub_colliders = shellcolhit._SubColliders,
        shellcolhit = shellcolhit,
    })
    end

    return retval
end

function this.get_attack_pre(args)
    if not config.current.enabled_hitboxes or sdk.to_int64(args[3]) & 1 == 0 then
        return
    end

    local collider_switcher = sdk.to_managed_object(args[2])
    ---@cast collider_switcher app.ColliderSwitcher
    local game_object = collider_switcher._HitController:get_Owner()
    local char = char_cache.get_char(game_object)

    if
        not char
        or char.distance > config.current.draw.distance
        or config.current.hitboxes.disable[rl(rt.enum.char, char.type)]
    then
        return
    end

    load_queue:enqueue({
        type = rt.enum.hitbox_load_data.rsc,
        char = char,
        rsc = collider_switcher._RequestSetCollider,
        res_idx = sdk.to_int64(args[4]) & 0xFFFFFFFF,
        req_idx = sdk.to_int64(args[5]) & 0xFFFFFFFF,
    })
end

return this
