---@class (exact) PartGroup
---@field is_show boolean
---@field is_highlight boolean
---@field name string
---@field part_data PartData
---@field condition ConditionResult
---@field condition_color integer
---@field hurtboxes BigEnemyHurtBox[]
---@field guid string
---@field last_updated integer

---@class (exact) PartData
---@field hitzone table<string, integer>
---@field is_enabled boolean
---@field can_break boolean
---@field is_broken boolean
---@field is_weak boolean
---@field can_lost boolean
---@field scar_boxes ScarBox[]?
---@field is_scar_gui_open boolean
---@field extract string
---@field _hitzones table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>?
---@field _dmg_part app.cEmModuleParts.cDamageParts
---@field _break_parts app.cEmModuleParts.cBreakParts?

local conditions = require("HitboxViewer.box.hurt.conditions.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local game_data = require("HitboxViewer.util.game.data")
local game_lang = require("HitboxViewer.util.game.lang")
local m = require("HitboxViewer.util.ref.methods")
local scar_box = require("HitboxViewer.box.hurt.scar")
local util_game = require("HitboxViewer.util.game.init")
local util_table = require("HitboxViewer.util.misc.table")

local ace = data.ace
local mod = data.mod

---@class PartGroup
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param meat_guid System.Guid
---@param param_parts app.user_data.EmParamParts
---@return table<string, integer>
local function get_hitzone(meat_guid, param_parts)
    local meat_index = param_parts:getMeatIndex(meat_guid)
    local meat_list = param_parts:get_MeatList()

    ---@type table<string, integer>
    local meat_data = {}
    for _, field in ipairs(ace.map.cMeatFields) do
        meat_data[field:get_name():sub(2)] = field:get_data(meat_list[meat_index._Value])
    end
    return meat_data
end

---@param part_index System.Int32
---@param enemy_ctx app.cEnemyContext
---@param module_parts app.cEmModuleParts
---@return app.cEmModuleParts.cBreakParts?, boolean?
local function get_break_parts(part_index, enemy_ctx, module_parts)
    ---@type app.cEmModuleParts.cBreakParts?
    local ret

    local break_parts = enemy_ctx.Parts:get_BreakParts()
    local param_parts = enemy_ctx.Parts._ParamParts

    util_game.do_something(break_parts, function(_, index, break_part)
        local part_indexes = param_parts:getLinkPartsIndexByBreakPartsIndex(index)
        util_game.do_something(part_indexes, function(_, _, value)
            if value == part_index then
                ret = break_part
                return false
            end
        end)
    end)

    if ret then
        return ret, ret:get_IsLostParts()
    end

    return nil, nil
end

---@param fixed_part_type System.Int32
---@return string?
local function get_part_name(fixed_part_type)
    local part_type_enum = game_data.fixed_to_enum("app.EnemyDef.PARTS_TYPE", fixed_part_type)
    local guid = m.EmPartsName(part_type_enum)
    local ret = game_lang.get_message_local(guid, game_lang.get_language(), true)
    if string.len(ret) > 0 then
        return ret
    end
end

---@param cpart app.user_data.EmParamParts.cParts
---@param param_parts app.user_data.EmParamParts
---@return table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>
local function get_hitzones(cpart, param_parts)
    local meat_list = param_parts:get_MeatList()

    ---@type table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>
    local ret = {}
    for i, name in pairs(ace.enum.meat_slot) do
        local field_name = ace.map.meat_type_to_field_name[name]
        if not field_name then
            goto continue
        end

        local meat_guid = cpart:get_field(field_name)
        local meat_index = param_parts:getMeatIndex(meat_guid)

        if not meat_index._HasValue then
            goto continue
        end

        ---@type table<string, integer>
        local meat_data = {}
        for _, field in ipairs(ace.map.cMeatFields) do
            meat_data[field:get_name():sub(2)] = field:get_data(meat_list[meat_index._Value])
        end
        ret[i] = meat_data
        ::continue::
    end
    return ret
end

---@param part_index System.Int32
---@param mc_holder app.EnemyCharacter.MINI_COMPONENT_HOLDER
---@param param_parts app.user_data.EmParamParts
---@return ScarBox[]?
local function get_scar_parts(part_index, mc_holder, param_parts)
    ---@type ScarBox[]
    local ret = {}
    local mc_scarman = mc_holder._ScarManager

    util_game.do_something(mc_scarman._ScarList, function(_, _, scar_holder)
        local scar_part = scar_holder._Parts
        if scar_part:get_PartsIndex_1() == part_index then
            util_game.do_something(scar_holder._ScarCompList, function(_, _, scar)
                scar_part = scar:get_Parts()
                local hitzone = get_hitzone(scar_part._MeatGuid_1, param_parts)
                table.insert(ret, scar_box:new(hitzone, scar, scar_part))
            end)
        end
    end)

    if not util_table.empty(ret) then
        return ret
    end
end

---@param enemy_ctx app.cEnemyContext
---@param enemy_mc_holder app.EnemyCharacter.MINI_COMPONENT_HOLDER
---@param meat_data app.col_user_data.DamageParamEm
---@return string, PartData
local function get_part_data(enemy_ctx, enemy_mc_holder, meat_data)
    local dmg_cparts = meat_data:get_Parts()
    local runtime_data = meat_data:get_RuntimeData()
    local part_index = runtime_data._PartsIndex
    local param_parts = enemy_ctx.Parts._ParamParts
    local is_weak = ace.enum.em_part_index[dmg_cparts:get_Category()] == "WEAK_POINT"
    ---@diagnostic disable-next-line: no-unknown
    local break_part, scars, dmg_part, name, hitzones, weak_hitzone, can_lost

    if is_weak then
        local weakpoint = param_parts:get_WeakPointList()[part_index] --[[@as app.user_data.EmParamParts.cWeakPoint]]
        dmg_part = enemy_ctx.Parts:get_WeakPointParts()[part_index] --[[@as app.cEmModuleParts.cDamageParts]]
        weak_hitzone = get_hitzone(weakpoint._MeatGuid, param_parts)
        name = config.lang:tr("misc.text_name_missing")
    else
        local em_cparts = param_parts:get_PartsList()[part_index] --[[@as app.user_data.EmParamParts.cParts]]
        dmg_part = enemy_ctx.Parts:get_DmgParts()[part_index] --[[@as app.cEmModuleParts.cDamageParts]]
        break_part, can_lost = get_break_parts(part_index, enemy_ctx, enemy_ctx.Parts)
        name = get_part_name(em_cparts._PartsType:get_Value())
            or config.lang:tr("misc.text_name_missing")
        hitzones = get_hitzones(em_cparts, param_parts)
        scars = get_scar_parts(part_index, enemy_mc_holder, param_parts)
    end

    ---@type PartData
    local ret = {
        is_enabled = false,
        extract = ace.enum.rod[runtime_data._RodExtract],
        can_break = break_part ~= nil,
        is_weak = is_weak,
        is_broken = false,
        can_lost = can_lost ~= nil and can_lost,
        is_scar_gui_open = false,
        scar_boxes = scars,
        ---@diagnostic disable-next-line: need-check-nil
        hitzone = weak_hitzone or hitzones[dmg_part:get_MeatSlot()],
        _hitzones = hitzones,
        _dmg_part = dmg_part,
        _meat_slot = dmg_part:get_MeatSlot(),
        _break_parts = break_part,
    }
    return name, ret
end

---@param cache table<string, PartGroup>
---@param enemy_ctx app.cEnemyContext
---@param enemy_mc_holder app.EnemyCharacter.MINI_COMPONENT_HOLDER
---@param enemy_hurtbox BigEnemyHurtBox
---@param meat_data app.col_user_data.DamageParamEm
---@return PartGroup
function this:new(cache, enemy_ctx, enemy_mc_holder, enemy_hurtbox, meat_data)
    local dmg_cparts = meat_data:get_Parts()
    local guid = dmg_cparts:get_PartsGuid()
    local formated_guid = util_game.format_guid(guid)

    ---@type PartGroup
    local o
    if not cache[formated_guid] then
        local name, part_data = get_part_data(enemy_ctx, enemy_mc_holder, meat_data)
        o = {
            is_show = true,
            is_highlight = false,
            hurtboxes = {},
            condition = mod.enum.condition_result.None,
            condition_color = 0,
            part_data = part_data,
            name = name,
            guid = formated_guid,
            last_updated = 0,
        }
        setmetatable(o, self)
    else
        o = cache[formated_guid]
    end

    cache[formated_guid] = o
    table.insert(o.hurtboxes, enemy_hurtbox)
    return o
end

---@return BoxBase[]?
function this:update()
    ---@type BoxBase[]
    local ret = {}
    if not self.part_data.is_weak and self.part_data._hitzones then
        self.part_data.hitzone = self.part_data._hitzones[self.part_data._dmg_part:get_MeatSlot()]
    end

    if self.part_data.can_break and not self.part_data.is_broken then
        self.part_data.is_broken = self.part_data._break_parts:get_IsBreakAll()
    end

    if self.part_data.scar_boxes then
        for _, scar in pairs(self.part_data.scar_boxes) do
            local box_state = scar:update()
            if box_state == mod.enum.box_state.Draw then
                table.insert(ret, scar)
            end
        end
    end

    --FIXME: app.cEmModuleParts.cDamageParts:get_IsEnable seems to return wrong values? or does it refer to something else?
    self.part_data.is_enabled = false
    for _, box in pairs(self.hurtboxes) do
        if box.is_enabled then
            self.part_data.is_enabled = true
            break
        end
    end

    self.condition, self.condition_color = conditions.check_part_group(self)
    self.last_updated = frame_counter.frame
    if not util_table.empty(ret) then
        return ret
    end
end

---@return boolean
function this:is_updated()
    return frame_counter.frame - self.last_updated < 60 * 3
end

---@param elem_name string
function this:get_hitzone(elem_name)
    return self.part_data.hitzone[elem_name]
end

return this
