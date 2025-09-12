local this = {}

---@param rgba {r:integer, g:integer, b:integer, a:integer}
function this.rgba_to_int(rgba)
    return ((rgba.r & 0xFF) << 24)
        | ((rgba.g & 0xFF) << 16)
        | ((rgba.b & 0xFF) << 8)
        | (rgba.a & 0xFF)
end

---@param rgba_int integer
---@return {r:integer, g:integer, b:integer, a:integer}
function this.int_to_rgba(rgba_int)
    ---@type {r:integer, g:integer, b:integer, a:integer}
    return {
        r = (rgba_int >> 24) & 0xFF,
        g = (rgba_int >> 16) & 0xFF,
        b = (rgba_int >> 8) & 0xFF,
        a = rgba_int & 0xFF,
    }
end

---@param s string
---@param sep string?
---@return string[]
function this.split_string(s, sep)
    local ret = {}

    if not sep then
        for w in s:gmatch("%S+") do
            table.insert(ret, w)
        end

        return ret
    end

    local pos = 1
    while true do
        local found = s:find(sep, pos, true)
        if not found then
            table.insert(ret, s:sub(pos))
            break
        end

        table.insert(ret, s:sub(pos, found - 1))
        pos = found + #sep
    end

    return ret
end

---@param int integer
---@return integer
function this.unsigned_to_signed(int)
    local num32 = int & 0xFFFFFFFF --[[@as integer]]
    if num32 > 0x7FFFFFFF then
        return num32 - 0x100000000
    end
    return num32
end

---@param json_str  string
---@return string
function this.compress_json(json_str)
    local result = json_str
    result = result:gsub("%s*([{}%[%],:])%s*", "%1")
    result = result:gsub("[\n\r\t]", "")
    return result
end

---@return integer
function this.get_boot_time()
    return math.floor(os.time() - os.clock())
end

---@param try fun()
---@param catch fun(err: string)?
---@param finally fun(ok: boolean, err: string?)?
---@return boolean
function this.try(try, catch, finally)
    ---@diagnostic disable-next-line: no-unknown
    local ok, err = pcall(try)

    if not ok and catch then
        catch(err)
    end

    if finally then
        finally(ok, err)
    end

    return ok
end

---@param n number
---@param decimals integer
---@return unknown
function this.round(n, decimals)
    local mult = 10 ^ decimals
    return math.floor(n * mult + 0.5) / mult
end

---@param str string
---@param max_len integer?
---@return string
function this.trunc_string(str, max_len)
    max_len = max_len or 25

    if #str > max_len then
        return string.sub(str, 1, max_len - 3) .. "..."
    end

    return str
end

---@param path string
---@param ext boolean? by default, true
---@return string
function this.get_file_name(path, ext)
    ext = ext == nil and true or ext
    local ret = path:match("([^/\\]+)$")

    if not ext then
        ret = ret:match("(.+)%..+$") --[[@as string]]
    end

    return ret
end

---@param path string
---@return boolean
function this.file_exists(path)
    local handle = io.open(path, "r")
    if handle then
        handle:close()
        return true
    end
    return false
end

---@param ... string
---@return string
function this.join_paths(...)
    local res = table.concat({ ... }, "/"):gsub("\\", "/")
    res = res:gsub("/+", "/")
    return res
end

-- backslashes
---@param ... string
---@return string
function this.join_paths_b(...)
    local res = this.join_paths(...)
    res = res:gsub("/", "\\\\")
    return res
end

---@param bit integer
---@return integer[]
function this.extract_bits(bit)
    local ret = {}

    while bit ~= 0 do
        local lowest_bit = bit & -bit --[[@as integer]]
        table.insert(ret, lowest_bit)
        bit = bit & (bit - 1) --[[@as integer]]
    end

    return ret
end

---@param text string
---@param width integer
function this.wrap_text(text, width)
    local lines = {}
    local cur_line = ""

    for word in text:gmatch("%S+") do
        while #word > width do
            if #cur_line > 0 then
                table.insert(lines, cur_line)
                cur_line = ""
            end

            local part = word:sub(1, width)
            table.insert(lines, part)
            word = word:sub(width + 1)
        end

        if #word > 0 then
            if #cur_line == 0 then
                cur_line = word
            elseif #cur_line + 1 + #word <= width then
                cur_line = cur_line .. " " .. word
            else
                table.insert(lines, cur_line)
                cur_line = word
            end
        end
    end

    if #cur_line > 0 then
        table.insert(lines, cur_line)
    end

    return table.concat(lines, "\n")
end

---@param num integer
function this.integer_to_hex(num)
    return string.format("0x%x", num)
end

return this
