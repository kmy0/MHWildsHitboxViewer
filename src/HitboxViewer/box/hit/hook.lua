local char_cache = require("HitboxViewer.character.char_cache")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local game_data = require("HitboxViewer.util.game.data")
local load_queue = require("HitboxViewer.box.hit.load_queue")
local util_game = require("HitboxViewer.util.game.init")
local util_ref = require("HitboxViewer.util.ref.init")

local mod = data.mod
local rl = game_data.reverse_lookup

local this = {}

function this.get_shell_post(retval)
    local config_mod = config.current.mod
    if not config_mod.enabled_hitboxes then
        return
    end

    local shellcolhit = util_ref.get_this() --[[@as app.mcShellColHit?]]
    if not shellcolhit then
        return
    end

    --FIXME: surely there must be better way to get actual owner of the shell???
    local shellcol_owner = shellcolhit:get_Owner()
    local shell_base = util_game.get_component(shellcol_owner, "ace.ShellBase")
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
        or char.distance > config_mod.draw.distance
        or config_mod.hitboxes.disable[rl(mod.enum.char, char.type)]
    then
        return
    end

    local first_colider = shellcolhit._FirstCollider
    local cols = util_game.system_array_to_lua(shellcolhit._SubColliders)
    if first_colider then
        table.insert(cols, first_colider)
    end

    load_queue:push_back({
        type = mod.enum.hitbox_load_data.shell,
        char = char,
        colliders = cols,
        rsc = shellcolhit._ReqSetCol,
        res_idx = shellcolhit._CollisionResourceIndex,
        shellcolhit = shellcolhit,
    })
end

function this.get_attack_pre(args)
    local config_mod = config.current.mod

    if not config_mod.enabled_hitboxes or not util_ref.to_bool(args[3]) then
        return
    end

    local collider_switcher = sdk.to_managed_object(args[2])
    ---@cast collider_switcher app.ColliderSwitcher
    local game_object = collider_switcher._HitController:get_Owner()
    local char = char_cache.get_char(game_object)

    if
        not char
        or char.distance > config_mod.draw.distance
        or config_mod.hitboxes.disable[rl(mod.enum.char, char.type)]
    then
        return
    end

    load_queue:push_back({
        type = mod.enum.hitbox_load_data.rsc,
        char = char,
        rsc = collider_switcher._RequestSetCollider,
        res_idx = util_ref.to_int(args[4]),
        req_idx = util_ref.to_int(args[5]),
    })
end

function this.get_kinsect_attack_post(retval)
    local config_mod = config.current.mod

    if not config_mod.enabled_hitboxes then
        return
    end

    local insect = util_ref.get_this()--[[@as app.Wp10Insect?]]
    if not insect then
        return
    end

    local owner = insect:get_Hunter()
    local game_object = owner:get_GameObject()
    local char = char_cache.get_char(game_object, owner)

    if
        not char
        or char.distance > config_mod.draw.distance
        or config_mod.hitboxes.disable[rl(mod.enum.char, char.type)]
    then
        return
    end

    local components = insect._Components

    load_queue:push_back({
        type = mod.enum.hitbox_load_data.base,
        char = char,
        rsc = components._RequestSetCol,
    })
end

return this
