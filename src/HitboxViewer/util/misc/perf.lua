---@diagnostic disable: undefined-global

---@class (exact) PerfStats
---@field it integer
---@field total number
---@field min number
---@field max number
---@field mean number
---@field trimmed_mean number
---@field median number
---@field p95 number
---@field p99 number
---@field stddev number

local this = {}

---@return integer
local function get_time()
    ---@diagnostic disable-next-line: no-unknown
    if hudcontroller_util then
        ---@diagnostic disable-next-line: no-unknown
        return hudcontroller_util.now_us()
    end

    return os.clock() * 1000000
end

---@param measurements integer[]
---@param trim_percent number?
---@return PerfStats
function this.calc_stats(measurements, trim_percent)
    table.sort(measurements)

    local sum = 0
    for i = 1, #measurements do
        sum = sum + measurements[i]
    end

    local mean = sum / #measurements
    local min = measurements[1]
    local max = measurements[#measurements]

    local function percentile(p)
        local index = math.ceil(p * #measurements / 100)
        return measurements[math.max(1, math.min(index, #measurements))]
    end

    local trim_count = math.floor(#measurements * trim_percent / 100)
    local trimmed_sum = 0
    local trimmed_count = 0

    for i = trim_count + 1, #measurements - trim_count do
        trimmed_sum = trimmed_sum + measurements[i]
        trimmed_count = trimmed_count + 1
    end

    local trimmed_mean = trimmed_count > 0 and (trimmed_sum / trimmed_count) or mean

    local variance_sum = 0
    for i = 1, #measurements do
        local diff = measurements[i] - mean
        variance_sum = variance_sum + (diff * diff)
    end

    ---@type PerfStats
    return {
        it = #measurements,
        total = sum,
        min = min,
        max = max,
        mean = mean,
        trimmed_mean = trimmed_mean,
        median = percentile(50),
        p95 = percentile(95),
        p99 = percentile(99),
        stddev = math.sqrt(variance_sum / (#measurements - 1)),
    }
end

---@param microseconds number
---@return string
local function format_time(microseconds)
    if microseconds < 1000 then
        return string.format("%.2f μs", microseconds)
    elseif microseconds < 1000000 then
        return string.format("%.2f ms", microseconds / 1000)
    else
        return string.format("%.2f s", microseconds / 1000000)
    end
end

---@param name string
---@param stats PerfStats
---@return string
function this.format_stats(name, stats)
    local ret = string.format("--Performance: %s\nit: %s", name, stats["it"])
    local keys = { "total", "min", "max", "mean", "trimmed_mean", "median", "p95", "p99", "stddev" }
    for i = 1, #keys do
        local key = keys[i]
        ret = string.format("%s\n%s: %s", ret, key, format_time(stats[key]))
    end

    return ret
end

---@param fn fun(...): any
---@param it integer? by default, 100
---@param name string?
---@param trim_percent number?, by_default, 10
---@param output_file string?
---@param predicate (fun(stats: PerfStats): boolean)?
---@param callback (fun(name: string, stats: PerfStats, measurements: number[]))?
---@return fun(...): any
function this.perf(fn, it, name, trim_percent, output_file, predicate, callback)
    it = it or 100
    name = name or ""
    trim_percent = trim_percent or 10
    local measurements = {}
    local count = 0

    return function(...)
        if count == it then
            local ret = fn(...)
            return ret
        end

        local s = get_time()
        local ret = fn(...)
        local e = get_time()
        local t = e - s

        count = count + 1
        table.insert(measurements, t)

        if count == it then
            local stats = this.calc_stats(measurements, trim_percent)

            if predicate and not predicate(stats) then
                return
            end

            local str = this.format_stats(name, stats)

            log.debug(str)

            if output_file then
                local file = io.open(output_file, "a")
                if file then
                    file:write(str .. "\n")
                    file:close()
                end
            end

            if callback then
                callback(name, stats, measurements)
            end
        end

        return ret
    end
end

return this
