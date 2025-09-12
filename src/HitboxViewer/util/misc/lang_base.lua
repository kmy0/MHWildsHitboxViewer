---@class LangBase
---@field files table<string, LangFile>
---@field sorted string[]
---@field font integer?
---@field default_file_name string
---@field default LangFile
---@field current LangFile
---@field path string
---@field default_font_size integer
---@field default_font_file string?

---@class LangFile
---@field _font {name: string?, size: integer}?

local util_misc = require("HitboxViewer.util.misc.util")
local util_table = require("HitboxViewer.util.misc.table")

---@class LangBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param default_lang LangFile
---@param path string
---@param default_lang_file_name string
---@param default_font_size integer?
---@param default_font_file string?
---@return LangBase
function this:new(default_lang, path, default_lang_file_name, default_font_size, default_font_file)
    local o = {
        files = {},
        sorted = {},
        default = default_lang,
        default_file_name = default_lang_file_name,
        path = path,
        current = default_lang,
        default_font_size = default_font_size or 16,
        default_font_file = default_font_file,
    }

    setmetatable(o, self)
    ---@cast o LangBase

    return o
end

function this:load()
    json.dump_file(util_misc.join_paths(self.path, self.default_file_name), self.default)

    local files = fs.glob(util_misc.join_paths_b(self.path, ".*json"))
    for i = 1, #files do
        local file = files[i]
        local name = util_misc.get_file_name(file, false)
        self.files[name] = json.load_file(file)
        table.insert(self.sorted, name)
    end

    table.sort(self.sorted)
    self:change(self.default)
end

function this:get_font_size()
    if self.current._font and self.current._font.size then
        return self.current._font.size
    end

    return self.default_font_size
end

---@param lang_file LangFile
function this:change(lang_file)
    local font = lang_file._font or {}
    self.font = imgui.load_font(
        font.name or self.default_font_file,
        font.size or self.default_font_size,
        { 0x1, 0xFFFF, 0 }
    )
    self.current = lang_file
end

---@param key string
---@return string
function this:tr(key)
    local ret = util_table.get_by_key(self.current, key)
    if ret then
        return ret
    end

    return string.format("Bad key: %s", key)
end

return this
