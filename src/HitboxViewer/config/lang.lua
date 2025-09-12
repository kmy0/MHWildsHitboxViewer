---@class Language : LangBase
---@field ref MainConfig

local lang_base = require("HitboxViewer.util.misc.lang_base")
local util_table = require("HitboxViewer.util.misc.table")

---@class Language
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = lang_base })

---@param default_lang LangFile
---@param path string
---@param default_lang_file_name string
---@param ref MainConfig
---@return Language
function this:new(default_lang, path, default_lang_file_name, ref)
    local o = lang_base.new(self, default_lang, path, default_lang_file_name)
    setmetatable(o, self)
    ---@cast o Language
    o.ref = ref
    return o
end

function this:load()
    lang_base.load(self)
    self:change()
end

---@param lang_file LangFile?
function this:change(lang_file)
    if not lang_file then
        local config_lang = self.ref.current.mod.lang
        lang_file = self.files[config_lang.file]
        if not lang_file then
            config_lang.file = self.default_file_name
            lang_file = self.files[config_lang.file]
        end
    end

    lang_base.change(self, lang_file)
end

---@param key string
---@return string
function this:tr(key)
    local ret = util_table.get_by_key(self.current, key)

    if not ret and self.ref.current.mod.lang.fallback then
        ret = util_table.get_by_key(self.default, key)
    end

    if not ret then
        ret = string.format("Bad key: %s", key)
    end

    return ret
end

return this
