---@class (exact) PartGroup
---@field is_show boolean
---@field is_highlight boolean
---@field name string
---@field part_data PartData
---@field condition ConditionResult
---@field condition_color integer
---@field hurtboxes BigEnemyHurtBox[]
---@field guid string

---@class (exact) PartData
---@field hitzone table<string, integer>
---@field is_enabled boolean
---@field can_break boolean
---@field is_broken boolean
---@field is_weak boolean
---@field is_lost boolean
---@field scar_boxes ScarBox[]?
---@field is_scar_gui_open boolean
---@field extract string
---@field _hitzones table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>?
---@field _dmg_part app.cEmModuleParts.cDamageParts
---@field _break_parts app.cEmModuleParts.cBreakParts?

local conditions = require("HitboxViewer.box.hurt.conditions")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local scar_box = require("HitboxViewer.box.hurt.scar")
local table_util = require("HitboxViewer.table_util")
local util = require("HitboxViewer.util")

local gui = data.gui
local ace = data.ace
local rt = data.runtime

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
    ---@type app.cEmModuleParts.cBreakParts
    local ret = enemy_ctx.Parts:get_BreakPartsByPartsIdx()[part_index]
    if ret:get_MaxBreakCount() > 0 then
        return ret, false
    end

    local lost_part_count = module_parts:getLostPartsCount()
    for i = 0, lost_part_count - 1 do
        local lost_part_index = module_parts:getLostPartsIndex(i)
        if lost_part_index == part_index then
            return ret, true
        end
    end
end

---@param fixed_part_type System.Int32
---@return string?
local function get_part_name(fixed_part_type)
    local part_type_enum = util.get_part_type(fixed_part_type)
    local guid = util.EmPartsName(nil, part_type_enum) --[[@as System.Guid]]
    local ret = util.get_message_local(guid, util.get_language(), true)
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
    local scar_holder_list = mc_scarman._ScarList
    local scar_holder_list_size = scar_holder_list:get_Count()

    for i = 0, scar_holder_list_size - 1 do
        local scar_holder = scar_holder_list:get_Item(i)
        ---@cast scar_holder app.EnemyScarHolder
        local scar_part = scar_holder._Parts
        if scar_part:get_PartsIndex_1() == part_index then
            local scar_list = scar_holder._ScarCompList
            local scar_list_size = scar_list:get_Count()
            for j = 0, scar_list_size - 1 do
                local scar = scar_list:get_Item(j)
                ---@cast scar app.EnemyScar
                scar_part = scar:get_Parts()
                local hitzone = get_hitzone(scar_part._MeatGuid_1, param_parts)
                table.insert(ret, scar_box:new(hitzone, scar, scar_part))
            end
        end
    end

    if not table_util.empty(ret) then
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
    local break_part, scars, dmg_part, name, hitzones, weak_hitzone, is_lost

    if is_weak then
        local weakpoint = param_parts:get_WeakPointList()[part_index] --[[@as app.user_data.EmParamParts.cWeakPoint]]
        dmg_part = enemy_ctx.Parts:get_WeakPointParts()[part_index] --[[@as app.cEmModuleParts.cDamageParts]]
        weak_hitzone = get_hitzone(weakpoint._MeatGuid, param_parts)
        name = gui.name_missing
    else
        local em_cparts = param_parts:get_PartsList()[part_index] --[[@as app.user_data.EmParamParts.cParts]]
        dmg_part = enemy_ctx.Parts:get_DmgParts()[part_index] --[[@as app.cEmModuleParts.cDamageParts]]
        break_part, is_lost = get_break_parts(part_index, enemy_ctx, enemy_ctx.Parts)
        name = get_part_name(em_cparts._PartsType:get_Value()) or gui.name_missing
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
        is_lost = is_lost ~= nil and is_lost,
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
    local formated_guid = util.format_guid(guid)

    ---@type PartGroup
    local o
    if not cache[formated_guid] then
        local name, part_data = get_part_data(enemy_ctx, enemy_mc_holder, meat_data)
        o = {
            is_show = config.current.hurtboxes.default_state == rt.enum.default_hurtbox_state.Draw,
            is_highlight = false,
            hurtboxes = {},
            condition = rt.enum.condition_result.None,
            condition_color = 0,
            part_data = part_data,
            name = name,
            guid = formated_guid,
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
            local box_state, boxes = scar:update()
            if box_state == rt.enum.box_state.Draw and boxes then
                table.move(boxes, 1, #boxes, #ret + 1, ret)
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

    self.condition, self.condition_color = conditions:check_part_group(self)
    if not table_util.empty(ret) then
        return ret
    end
end

---@param elem_name string
function this:get_hitzone(elem_name)
    return self.part_data.hitzone[elem_name]
end

return this
