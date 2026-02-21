local s = require("HitboxViewer.util.ref.singletons")

local this = {}

---@return ace.cMouseKeyboardInfo
function this.get_kb()
    return s.get("ace.MouseKeyboardManager"):get_MainMouseKeyboard()
end

---@return ace.cPadInfo
function this.get_pad()
    return s.get("ace.PadManager"):get_MainPad()
end

return this
