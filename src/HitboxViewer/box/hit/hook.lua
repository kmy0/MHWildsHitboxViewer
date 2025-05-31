local char_cache = require("HitboxViewer.character.char_cache")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local load_queue = require("HitboxViewer.box.hit.load_queue")
local util = require("HitboxViewer.util")

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
    local shell_base = util.get_component(shellcol_owner, "ace.ShellBase")
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
    local cols = util.system_array_to_lua(shellcolhit._SubColliders)
    if first_colider then
        table.insert(cols, first_colider)
    end

    load_queue:enqueue({
        type = rt.enum.hitbox_load_data.shell,
        char = char,
        colliders = cols,
        rsc = shellcolhit._ReqSetCol,
        res_idx = shellcolhit._CollisionResourceIndex,
        shellcolhit = shellcolhit,
    })

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

function this.get_kinsect_attack_pre(args)
    if not config.current.enabled_hitboxes then
        return
    end

    local storage = thread.get_hook_storage()
    storage["insect"] = sdk.to_managed_object(args[2])
end

function this.get_kinsect_attack_post(retval)
    if not config.current.enabled_hitboxes then
        return
    end

    local storage = thread.get_hook_storage()
    if not storage or not storage["insect"] then
        return
    end

    local insect = storage["insect"] --[[@as app.Wp10Insect]]
    local owner = insect:get_Hunter()
    local game_object = owner:get_GameObject()
    local char = char_cache.get_char(game_object, owner)

    if
        not char
        or char.distance > config.current.draw.distance
        or config.current.hitboxes.disable[rl(rt.enum.char, char.type)]
    then
        return
    end

    local components = insect._Components

    load_queue:enqueue({
        type = rt.enum.hitbox_load_data.base,
        char = char,
        rsc = components._RequestSetCol,
    })

    return retval
end

return this
