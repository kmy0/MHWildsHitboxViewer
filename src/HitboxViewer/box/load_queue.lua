---@class ColQueue : Queue
---@field push_back fun(self: ColQueue, value: ColLoadData)
---@field iter fun(self: ColQueue, n: integer): fun(): ColLoadData

---@class (exact) ColLoadData
---@field char Character
---@field rsc via.physics.RequestSetCollider

---@class (exact) BoxLoadData : ColLoadData
---@field col via.physics.Collidable
---@field resource_idx integer
---@field set_idx integer
---@field collidable_idx integer
---@field userdata via.physics.UserData

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local hurtbox = require("HitboxViewer.box.hurt.init")
local pressbox = require("HitboxViewer.box.press.init")
local queue = require("HitboxViewer.util.misc.queue")

local mod = data.mod

---@class ColQueue
local this = queue:new()

---@param rsc via.physics.RequestSetCollider
---@return fun(): integer, integer, integer
local function get_collidable(rsc)
    ---@type [integer, integer, integer][]
    local ret = {}
    local index = 1
    for i = 0, rsc:get_NumRequestSets() - 1 do
        for j = 0, rsc:getNumRequestSetsFromIndex(i) - 1 do
            for k = 0, rsc:getNumCollidablesFromIndex(i, j) - 1 do
                table.insert(ret, { i, j, k })
            end
        end
    end

    return function()
        if index <= #ret then
            local item = ret[index]
            index = index + 1
            return item[1], item[2], item[3]
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

function this.get()
    for load_data in this:iter(config.max_char_loads) do
        for resource_idx, set_idx, collidable_idx in get_collidable(load_data.rsc) do
            local col = load_data.rsc:getCollidableFromIndex(resource_idx, set_idx, collidable_idx)

            if not col then
                goto continue
            end

            local userdata = col:get_UserData()
            ---@cast userdata via.physics.RequestSetColliderUserData
            local p_data = userdata:get_ParentUserData()

            if not p_data then
                goto continue
            end

            local data_type = p_data:get_type_definition() --[[@as RETypeDefinition]]

            if
                data_type:is_a("app.col_user_data.DamageParam")
                or (
                    (
                        load_data.char.type == mod.enum.char.Player
                        or load_data.char.type == mod.enum.char.MasterPlayer
                    )
                    and resource_idx == 0
                    and collidable_idx == 0
                    and (set_idx == 1 or set_idx == 2)
                )
            then
                ---@cast p_data app.col_user_data.DamageParam
                hurtbox.queue:push_back({
                    col = col,
                    char = load_data.char,
                    rsc = load_data.rsc,
                    resource_idx = resource_idx,
                    set_idx = set_idx,
                    collidable_idx = collidable_idx,
                    userdata = p_data,
                })
            elseif data_type:is_a("app.col_user_data.PressParam") then
                ---@cast p_data app.col_user_data.PressParam
                pressbox.queue:push_back({
                    col = col,
                    char = load_data.char,
                    rsc = load_data.rsc,
                    resource_idx = resource_idx,
                    set_idx = set_idx,
                    collidable_idx = collidable_idx,
                    userdata = p_data,
                })
            end

            ::continue::
        end
    end
end

return this
