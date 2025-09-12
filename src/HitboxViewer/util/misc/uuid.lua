local this = {}

math.randomseed(os.time())

---@param imgui_id boolean?
---@return string
function this.generate(imgui_id)
    local chars = {}
    local uuid_template = {
        8,
        4,
        4,
        4,
        12,
    }
    local hex_chars = "0123456789abcdef"

    for i = 1, #uuid_template do
        if i > 1 then
            table.insert(chars, "-")
        end

        for j = 1, uuid_template[i] do
            if i == 3 and j == 1 then
                table.insert(chars, "4")
            elseif i == 4 and j == 1 then
                local variant_chars = "89ab"
                local idx = math.random(1, #variant_chars)
                table.insert(chars, variant_chars:sub(idx, idx))
            else
                local idx = math.random(1, #hex_chars)
                table.insert(chars, hex_chars:sub(idx, idx))
            end
        end
    end

    local ret = table.concat(chars)
    if imgui_id then
        ret = "##" .. ret
    end

    return ret
end

return this
