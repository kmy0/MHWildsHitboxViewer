---@class (exact) PartGroup
---@field show boolean
---@field highlight boolean
---@field name string
---@field part_data PartData
---@field condition ConditionState
---@field condition_color integer
---@field scars_open boolean
---@field hurtboxes EnemyHurtbox[]
---@field update fun(self: PartGroup)

---@class (exact) Scar
---@field show boolean
---@field highlight boolean
---@field state string
---@field hitzone table<string, integer>
---@field box Scarbox
---@field box_state BoxState
---@field enabled boolean
---@field condition ConditionState
---@field condition_color integer
---@field _scar app.EnemyScar
---@field _scar_part app.cEmModuleScar.cScarParts

---@class (exact) PartData
---@field hitzone table<string, integer>
---@field enabled boolean
---@field can_break boolean
---@field is_broken boolean
---@field is_weak boolean
---@field is_lost boolean
---@field scars Scar[]?
---@field guid string
---@field extract string
---@field _hitzones table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>?
---@field _dmg_part app.cEmModuleParts.cDamageParts
---@field _break_parts app.cEmModuleParts.cBreakParts?

local conditions = require("HitboxViewer.conditions")
local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local scarbox = require("HitboxViewer.box.scar")
local utilities = require("HitboxViewer.utilities")

local this = {}

---@param self PartGroup
local function update(self)
    if not self.part_data.is_weak and self.part_data._hitzones then
        self.part_data.hitzone = self.part_data._hitzones[self.part_data._dmg_part:get_MeatSlot()]
    end

    if self.part_data.can_break and not self.part_data.is_broken then
        self.part_data.is_broken = self.part_data._break_parts:get_IsBreakAll()
    end

    if self.part_data.scars then
        for _, scar in pairs(self.part_data.scars) do
            scar.state = data.ace_scar_enum[scar._scar_part:get_State()]
            scar.enabled = not scar._scar_part:get_IsForceDisableCollision()
            scar.box_state = scar.box:update()
            scar.condition, scar.condition_color = conditions.check_scar(scar.state)
        end
    end

    --FIXME: app.cEmModuleParts.cDamageParts:get_IsEnable seems to return wrong values? or does it refer to something else?
    self.part_data.enabled = false
    for _, box in pairs(self.hurtboxes) do
        if box.enabled then
            self.part_data.enabled = true
            break
        end
    end

    self.condition, self.condition_color = conditions.check(self.part_data)
end

---@param meat_guid System.Guid
---@param param_parts app.user_data.EmParamParts
---@return table<string, integer>
local function get_hitzone(meat_guid, param_parts)
    local meat_index = param_parts:getMeatIndex(meat_guid)
    local meat_list = param_parts:get_MeatList()

    ---@type table<string, integer>
    local meat_data = {}
    for _, field in ipairs(data.cMeatFields) do
        meat_data[field:get_name():sub(2)] = field:get_data(meat_list[meat_index._Value])
    end
    return meat_data
end

---@param part_index System.Int32
---@param mc_holder app.EnemyCharacter.MINI_COMPONENT_HOLDER
---@param param_parts app.user_data.EmParamParts
---@return Scar[]?
local function get_scar_parts(part_index, mc_holder, param_parts)
    ---@type Scar[]
    local ret = {}
    local mc_scarman = mc_holder._ScarManager
    local scar_holder_list = mc_scarman._ScarList
    local scar_holder_list_size = scar_holder_list:get_Count()

    --FIXME: i dont like this
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
                local o = {
                    state = data.ace_scar_enum[scar_part:get_State()],
                    show = false,
                    highlight = false,
                    hitzone = get_hitzone(scar_part._MeatGuid_1, param_parts),
                    box_state = data.box_state.None,
                    condition = data.condition_state.None,
                    enabled = true,
                    condition_color = 0,
                    _scar = scar,
                    _scar_part = scar_part,
                }
                o.box = scarbox.ctor(o, scar._ColSizeRadius)
                table.insert(ret, o)
            end
        end
    end

    if next(ret) ~= nil then
        return ret
    end
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

---@param cpart app.user_data.EmParamParts.cParts
---@param param_parts app.user_data.EmParamParts
---@return table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>
local function get_hitzones(cpart, param_parts)
    local meat_list = param_parts:get_MeatList()

    ---@type table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>
    local ret = {}
    for i, name in pairs(data.ace_meat_slot_enum) do
        local field_name = data.meat_type_to_field_name[name]
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
        for _, field in ipairs(data.cMeatFields) do
            meat_data[field:get_name():sub(2)] = field:get_data(meat_list[meat_index._Value])
        end
        ret[i] = meat_data
        ::continue::
    end
    return ret
end

---@param fixed_part_type System.Int32
---@return string?
local function get_part_name(fixed_part_type)
    local part_type_enum = utilities.get_part_type(fixed_part_type)
    local guid = utilities.EmPartsName(nil, part_type_enum)
    local ret = utilities.get_message_local(guid, utilities.get_language(), true)
    if string.len(ret) > 0 then
        return ret
    end
end

---@param parent BigEnemy
---@param enemy_hurtbox EnemyHurtbox
function this.add_part_group(parent, enemy_hurtbox)
    local userdata_cpart = enemy_hurtbox.meat_data:get_Parts()
    local cruntime = enemy_hurtbox.meat_data:get_RuntimeData()
    local part_guid = userdata_cpart:get_PartsGuid()
    local part_index = cruntime._PartsIndex
    local is_weak = data.ace_em_part_index_enum[userdata_cpart:get_Category()] == "WEAK_POINT"

    local formated_guid = utilities.format_guid(part_guid)
    local part_group = parent.parts[formated_guid]
    if not part_group then
        local param_parts = enemy_hurtbox.parent.ctx.Parts._ParamParts
        ---@type app.cEmModuleParts.cBreakParts?
        local break_part
        ---@type Scar[]?
        local scars
        ---@type app.user_data.EmParamParts.cParts
        local cpart
        ---@type app.cEmModuleParts.cDamageParts
        local dmg_part
        ---@type string
        local name
        ---@type table<app.user_data.EmParamParts.MEAT_SLOT, table<string, integer>>?
        local hitzones
        ---@type table<string, integer>?
        local weak_hitzone
        ---@type boolean?
        local is_lost

        if is_weak then
            dmg_part = enemy_hurtbox.parent.ctx.Parts:get_WeakPointParts()[part_index]
            weak_hitzone = get_hitzone(param_parts:get_WeakPointList()[part_index]._MeatGuid, param_parts)
            ---FIXME: does it even have a name?
            name = data.name_missing
        else
            dmg_part = enemy_hurtbox.parent.ctx.Parts:get_DmgParts()[part_index]
            break_part, is_lost = get_break_parts(part_index, enemy_hurtbox.parent.ctx, enemy_hurtbox.parent.ctx.Parts)
            scars = get_scar_parts(part_index, enemy_hurtbox.parent.mc_holder, param_parts)
            cpart = param_parts:get_PartsList()[part_index]
            name = get_part_name(cpart._PartsType:get_Value()) or data.name_missing
            hitzones = get_hitzones(cpart, param_parts)
        end

        ---@type PartGroup
        parent.parts[formated_guid] = {
            show = config.current.hurtboxes.default_state == data.default_hurtbox_enum.Draw,
            highlight = false,
            name = name,
            scars_open = false,
            hurtboxes = {},
            part_data = {
                guid = formated_guid,
                enabled = false,
                extract = data.ace_rod_enum[cruntime._RodExtract],
                can_break = break_part ~= nil,
                is_weak = is_weak,
                is_broken = false,
                is_lost = is_lost ~= nil and is_lost,
                scars = scars,
                ---@diagnostic disable-next-line: need-check-nil
                hitzone = weak_hitzone or hitzones[dmg_part:get_MeatSlot()],
                _hitzones = hitzones,
                _dmg_part = dmg_part,
                _meat_slot = dmg_part:get_MeatSlot(),
                _break_parts = break_part,
            },
            condition = data.condition_state.None,
            condition_color = 0,
            update = update,
        }
    end
    enemy_hurtbox.part_group = parent.parts[formated_guid]
    table.insert(enemy_hurtbox.part_group.hurtboxes, enemy_hurtbox)
end

return this
