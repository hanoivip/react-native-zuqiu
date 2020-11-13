
local tonumber_ = tonumber
--[[--

Convert to number.

@param mixed v
@return number

]]
function tonumber(v, base)
    return tonumber_(v, base) or 0
end

--[[--

Convert to integer.

@param mixed v
@return number(integer)

]]
function toint(v)
    return math.round(tonumber(v))
end

--[[--

Convert to boolean.

@param mixed v
@return boolean

]]
function tobool(v)
    return (v ~= nil and v ~= false)
end

--[[--

Convert to table.

@param mixed v
@return table

]]
function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

--[[--

Returns a formatted version of its variable number of arguments following the description given in its first argument (which must be a string). string.format() alias.

@param string format
@param mixed ...
@return string

]]
function format(...)
    return string.format(...)
end

--[[--

Creating a copy of an table with fully replicated properties.

**Usage:**

    -- Creating a reference of an table:
    local t1 = {a = 1, b = 2}
    local t2 = t1
    t2.b = 3    -- t1 = {a = 1, b = 3} <-- t1.b changed

    -- Createing a copy of an table:
    local t1 = {a = 1, b = 2}
    local t2 = clone(t1)
    t2.b = 3    -- t1 = {a = 1, b = 2} <-- t1.b no change


@param mixed object
@return mixed

]]
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function shallowClone(object)
    if type(object) ~= "table" then
        return object
    end
    local new_table = {}
    for key, value in pairs(object) do
        new_table[key] = value
    end
    return setmetatable(new_table, getmetatable(object))
end

--[[--

Create an class.

**Usage:**

    local Shape = class("Shape")

    -- base class
    function Shape:ctor(shapeName)
        self.shapeName = shapeName
        printf("Shape:ctor(%s)", self.shapeName)
    end

    function Shape:draw()
        printf("draw %s", self.shapeName)
    end

    --

    local Circle = class("Circle", Shape)

    function Circle:ctor()
        Circle.super.ctor(self, "circle")   -- call super-class method
        self.radius = 100
    end

    function Circle:setRadius(radius)
        self.radius = radius
    end

    function Circle:draw()                  -- overrideing super-class method
        printf("draw %s, raidus = %0.2f", self.shapeName, self.raidus)
    end

    --

    local Rectangle = class("Rectangle", Shape)

    function Rectangle:ctor()
        Rectangle.super.ctor(self, "rectangle")
    end

    --

    local circle = Circle.new()             -- output: Shape:ctor(circle)
    circle:setRaidus(200)
    circle:draw()                           -- output: draw circle, radius = 200.00

    local rectangle = Rectangle.new()       -- output: Shape:ctor(rectangle)
    rectangle:draw()                        -- output: draw rectangle


@param string classname
@param table|function super-class
@return table

]]
function class(super, classname)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
            if super.__index == super then
                cls.__index = nil
            end
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        if not cls.__index then
            cls.__index = cls
        end

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    function cls.attach(instance, ...)
        for k,v in pairs(cls) do instance[k] = v end
        instance.class = cls
        instance:ctor(...)
        return instance
    end

    return cls
end

--[[--

hecks if the given key or index exists in the table.

@param table arr
@param mixed key
@return boolean

]]
function isset(arr, key)
    return type(arr) == "table" and arr[key] ~= nil
end

--[[--

Rounds a float.

@param number num
@return number(integer)

]]
function math.round(num)
    return math.floor(num + 0.5)
end

--[[--

Count all elements in an table.

@param table t
@return number(integer)

]]
function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

--[[--

Return all the keys or a subset of the keys of an table.

**Usage:**

    local t = {a = 1, b = 2, c = 3}
    local keys = table.keys(t)
    -- keys = {"a", "b", "c"}


@param table t
@return table

]]
function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

--[[--

Return all the values of an table.

**Usage:**

    local t = {a = "1", b = "2", c = "3"}
    local values = table.values(t)
    -- values = {1, 2, 3}


@param table t
@return table

]]
function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

--[[--

Merge tables.

**Usage:**

    local dest = {a = 1, b = 2}
    local src  = {c = 3, d = 4}
    table.merge(dest, src)
    -- dest = {a = 1, b = 2, c = 3, d = 4}


@param table dest
@param table src

]]
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[--

Merge arraies.

**Usage:**

    local dest = {1, 2}
    local src  = {3, 4}
    table.imerge(dest, src)
    -- dest = {1, 2, 3, 4}


@param table dest
@param table src

]]
function table.imerge(dest, src)
    for i, v in ipairs(src) do
        table.insert(dest, v)
    end
end

-- 获得最大的key(key需为数字)
function table.maxKey(t)
    local max = math.min_int32
    assert(type(t) == "table", "must be table type!")
    for k, v in pairs(t) do
        if tonumber(k) > max then
            max = tonumber(k)
        end
    end
    return max
end

--[[--

Convert special characters to HTML entities.

The translations performed are:

-   '&' (ampersand) becomes '&amp;'
-   '"' (double quote) becomes '&quot;'
-   "'" (single quote) becomes '&#039;'
-   '<' (less than) becomes '&lt;'
-   '>' (greater than) becomes '&gt;'

@param string input
@return string

]]
function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

--[[--

Inserts HTML line breaks before all newlines in a string.

Returns string with '<br />' inserted before all newlines (\n).

@param string input
@return string

]]
function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

--[[--

Returns a HTML entities formatted version of string.

@param string input
@return string

]]
function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

--[[--

Split a string by string.

@param string str
@param string delimiter
@return table

]]
function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

--[[--

Strip whitespace (or other characters) from the beginning of a string.

@param string str
@return string

]]
function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

--[[--

Strip whitespace (or other characters) from the end of a string.

@param string str
@return string

]]
function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

--[[--

Strip whitespace (or other characters) from the beginning and end of a string.

@param string str
@return string

]]
function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

--[[--

Make a string's first character uppercase.

@param string str
@return string

]]
function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--[[--

@param string str
@return string

]]
function string.urlencodeChar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

--[[--

URL-encodes string.

@param string str
@return string

]]
function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", string.urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

--[[--

Get UTF8 string length.

@param string str
@return int

]]
function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--[[--

Return formatted string with a comma (",") between every group of thousands.

**Usage:**

    local value = math.comma("232423.234") -- value = "232,423.234"


@param number num
@return string

]]
function string.formatNumberThousands(num)
    local formatted = tostring(tonumber(num))
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')  --Lua assist checked flag
        if k == 0 then break end
    end
    return formatted
end

function string.capital(s)
    if type(s) == 'string' and string.len(s) > 0 then
        return string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2)
    else
        return s
    end
end


-- 球员映射关系
local noToQuality = 
{
    ["1"] = "D",
    ["2"] = "C",
    ["3"] = "B",
    ["4"] = "A",
    ["5"] = "S",
    ["5+"] = "S+",
    ["6"] = "SS",
    ["6+"] = "SS+",
    ["7"] = "SSS",
}

-- 将数字转换为字母
function string.convertNoToQuality(no)
    assert(noToQuality[tostring(no)])
    return noToQuality[tostring(no)]
end

local medalNoToQuality = {
    ["1"] = "C",
    ["2"] = "B",
    ["3"] = "A",
    ["4"] = "S",
    ["5"] = "SS"
}

-- 将勋章的品质映射出来
function string.convertMedalNoToQuality(no)
    assert(medalNoToQuality[tostring(no)])
    return medalNoToQuality[tostring(no)]
end

math.nan = 0/0
math.max_int32 = 0x7FFFFFFF
math.min_int32 = -math.max_int32 - 1
math.eps = 1e-6

function math.isNan(num)
    return num ~= num
end

function math.clamp(num, min, max)
    if num < min then num = min end
    if num > max then num = max end
    return num
end

function math.cmpf(a, b)
    if a < b - math.eps then
        return -1
    elseif a > b + math.eps then
        return 1
    else
        return 0
    end
end

function math.sign(num)
    if num > math.eps then
        return 1
    elseif num < -math.eps then
        return -1
    end
    return 0
end

--[Comment]
--return a < b ? { min = a, max = b } : { min = b, max = a }
function math.range(a, b)
    return a < b and { min = a, max = b } or { min = b, max = a }
end

--[Comment]
--return x >= min and x <= max
function math.isInRange(x, min, max)
    return x >= min and x <= max
end

--[Comment]
--return a random real number in range [min, max)
function math.randomInRange(min, max)
    return min + math.random() * (max - min)
end

--[Comment]
--ceil the number to precision: math.ceilEx(7.44, 0.1) = 7.5
--return math.ceil(number / precision) * precision
function math.ceilEx(number, precision)
    return math.ceil(number / precision) * precision
end

function math.lerp(a, b, bweight)
    bweight = math.clamp(bweight, 0, 1)
    return a * (1 - bweight) + b * bweight
end

function math.isInt(num)
    return type(num) == "number" and num == math.floor(num)
end

function table.isEmpty(table)
    if table == nil then return true end
    if type(table) ~= 'table' then return false end
    local empty = true
    for k,v in pairs(table) do
        empty = false
        break
    end
    return empty
end

function table.compare(data1, data2)
    if type(data1) == 'table' and type(data2) == 'table' then
        local allKeys = {}
        for k,v in pairs(data1) do
            allKeys[k] = v
        end
        for k,v in pairs(data2) do
            allKeys[k] = v
        end
        local part2 = 0
        for k,v in pairs(allKeys) do
            local v1 = data1[k]
            local v2 = data2[k]
            local part = table.compare(v1, v2)
            if math.isNan(part) then
                return part
            elseif part ~= 0 then
                if (part2 > 0 and part < 0) or (part2 < 0 and part > 0) then
                    return math.nan
                end
                part2 = part
            end
        end
        return part2
    elseif data1 == nil and data2 == nil then
        return 0
    elseif data1 == nil then
        return -1
    elseif data2 == nil then
        return 1
    elseif type(data1) ~= type(data2) then
        return math.nan
    elseif type(data1) == 'number' then
        return data1 - data2
    elseif type(data1) == 'string' then
        if data1 < data2 then
            return -1
        elseif data1 > data2 then
            return 1
        else
            return 0
        end
    elseif data1 == data2 then
        return 0
    else
        return math.nan
    end
end

function table.compareArray(data1, data2)
    if type(data1) == 'table' and type(data2) == 'table' then
        for i,v1 in ipairs(data1) do
            local v2 = data2[i]
            local part = table.compareArray(v1, v2)
            if part ~= 0 then
                return part
            end
        end
        if #data2 > #data1 then
            return -1
        else
            return 0
        end
    elseif data1 == nil and data2 == nil then
        return 0
    elseif data1 == nil then
        return -1
    elseif data2 == nil then
        return 1
    elseif type(data1) ~= type(data2) then
        return math.nan
    elseif type(data1) == 'number' then
        return data1 - data2
    elseif type(data1) == 'string' then
        if data1 < data2 then
            return -1
        elseif data1 > data2 then
            return 1
        else
            return 0
        end
    elseif data1 == data2 then
        return 0
    else
        return math.nan
    end
end

function table.shuffleArray(t)
    for i = #t, 1, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

function string.formatIntWithComma(amount)
    if type(amount) ~= 'number' then
        return tostring(amount)
    end
    amount = math.floor(amount)
    local formatted = tostring(amount)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')  --Lua assist checked flag
        if k == 0 then
            break
        end
    end
    return formatted
end

function string.formatIntWithTenThousands(amount)
    if type(amount) ~= "number" then
        return tostring(amount)
    end
    local strResult = ""
    if amount >= 100000000 then
        local part = math.floor(amount / 100000000)
        strResult = lang.transstr("logogramMoneyHundredMillon", part)
        amount = amount % 100000000
        amount = math.floor(amount / 10000)
        if amount > 0 then
            strResult = lang.transstr("logogramMoneyTenThousand", strResult .. amount)
        end
    elseif amount >= 10000 then
        amount = math.floor(amount / 100) / 100
        strResult = lang.transstr("logogramMoneyTenThousand", amount)
    else
        strResult = tostring(amount)
    end
    return strResult
end

--- 换算数字，超过1万数字形式为xx万，超过1亿数字形式为xx亿
-- @param num 数字，类型number
-- @param n 保留小数位数（默认两位）
-- @return 数字转换后的字符串形式，类型string
function string.formatNumWithUnit(num, n)
    num = tonumber(num)
    if not n then
        n = 2
    else
        n = tonumber(n)
    end

    if num < 10000 then
        return tostring(num)
    elseif num < 100000000 then
        num = math.floor(num / math.pow(10, 4 - n)) / math.pow(10, n)
        return lang.transstr("logogramMoneyTenThousand", num)
    else
        num = math.floor(num / math.pow(10, 8 - n)) / math.pow(10, n)
        return lang.transstr("logogramMoneyHundredMillon", num)
    end
end

function string.formatIntWithTenThousandsWithoutUnit(amount)
    if type(amount) ~= 'number' then
        return tostring(amount)
    end
    local strResult = ''
    if amount >= 10000 then
        amount = math.floor(amount / 100) / 100
        strResult = amount
    else
        strResult = tostring(amount)
    end
    return strResult
end

--- 格式化时间戳为年月日
function string.formatTimestampBetweenYearAndDay(timestamp)
    local year = os.date("%Y", timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    return year .. lang.transstr("year") .. month .. lang.transstr("month") .. day .. lang.transstr("day")
end

-- 格式化时间戳为xx月xx日xx:xx
function string.formatTimestampNoYear(timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    local hour = os.date("%H", timestamp)
    local minute = os.date("%M", timestamp)
    return month .. lang.transstr("month") .. day .. lang.transstr("day_1") .. hour .. ":" .. minute
end

-- 格式化时间戳为xxxx年xx月xx日 xx:xx
function string.formatTimestampAllWithWord(timestamp)
    local year = os.date("%Y", timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    local hour = os.date("%H", timestamp)
    local minute = os.date("%M", timestamp)
    return year .. lang.transstr("year") .. month .. lang.transstr("month") .. day .. lang.transstr("day_1") .. hour .. ":" .. minute
end

-- 格式化时间戳为xxxx.xx.xx xx:xx
function string.formatTimestampAllWithDot(timestamp)
    local year = os.date("%Y", timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    local hour = os.date("%H", timestamp)
    local minute = os.date("%M", timestamp)
    return year .. "." .. month .. "." .. day .. " " .. hour .. ":" .. minute
end

--- 转换时间为秒数
-- @param day 天数，类型number
-- @param hour 小时数，类型number
-- @param minute 分钟数，类型number
-- @param second 秒数，类型number
function string.convertTimeToSecond(day, hour, minute, second)
    
    local totalSecond = 0

    if day ~= nil then
        day = tonumber(day)
        totalSecond = day * 86400
    end

    if hour ~= nil then
        hour = tonumber(hour)
        totalSecond = totalSecond + hour * 3600
    end

    if minute ~= nil then
        minute = tonumber(minute)
        totalSecond = totalSecond + minute * 60
    end

    if second ~= nil then
        second = tonumber(second)
        totalSecond = totalSecond + second
    end

    return totalSecond
end

--- 转换时间为月，日，时间等
--- 例：3月3日4:00
function string.convertSecondToMonth(num)
    local timeTable = os.date("*t", num)
    local month = timeTable.month .. lang.transstr("month")
    local day = timeTable.day .. lang.transstr("day_1")
    local hour = timeTable.hour
    local minute = timeTable.min
    if minute == 0 then 
        minute = minute .. "0" 
    elseif minute <= 9 then 
        minute = "0" .. minute 
    end
    return month .. day .. hour .. ":" .. minute
end

-- 转换为日期范围
-- 例：4月4日~4月8日
function string.convertSecondToMonthAndDayRange(startTime, endTime)
    local daySecond = 24 * 60 * 60
    local range  = {}
    for time = startTime, endTime, daySecond do
        local timeTable = os.date("*t", time)
        local dayTable = {}
        dayTable.month = timeTable.month
        dayTable.day = timeTable.day
        table.insert(range, dayTable)
    end
    return range
end

function string.convertSecondToMonthAndDay(num)
    local date = {}
    date.month = os.date("*t", num).month
    date.day = os.date("*t", num).day
    return date
end

function string.convertSecondToHourAndMinute(num)
    local date = {}
    date.hour = os.date("*t", num).hour
    date.minute = os.date("*t", num).min
    if string.len(date.minute) < 2 then
        date.minute = "0" .. date.minute
    end
    return date
end

-- 年，月，日
function string.convertSecondToYearAndMonthAndDay(num)
    local date = {}
    date.year = os.date("*t", num).year
    date.month = os.date("*t", num).month
    date.day = os.date("*t", num).day
    return date
end

function string.convertSecondToTimeAll(num)
    local date = {}
    date.year = os.date("*t", num).year
    date.month = os.date("*t", num).month
    date.day = os.date("*t", num).day
    date.hour = os.date("*t", num).hour
    date.minute = os.date("*t", num).min
    date.second = os.date("*t", num).sec
    local content = date.year .. "-" .. date.month .. "-" .. date.day .. "   " .. 
        string.format("%02d", date.hour) .. ":" .. string.format("%02d", date.minute) .. ":" .. string.format("%02d", date.second)
        
    return content, date
end

--- 转换秒数为时间字符串
-- @param secondNum 秒数，类型number
-- @return string
function string.convertSecondToTime(secondNum)
    local function formateNum(num)
        if string.len(num) < 2 then
            return '0' .. num
        else
            return tostring(num)
        end
    end

    local timeTable = string.convertSecondToTimeTable(secondNum)
    local timeStr = nil

    if timeTable.day > 0 then
        timeStr = timeTable.day .. lang.transstr('day') .. ' ' .. formateNum(timeTable.hour) .. ':' .. formateNum(timeTable.minute) .. ':' .. formateNum(timeTable.second)
    else

        if timeTable.hour > 0 then
            timeStr = formateNum(timeTable.hour) .. ':' .. formateNum(timeTable.minute) .. ':' .. formateNum(timeTable.second)
        else
            timeStr = formateNum(timeTable.minute) .. ':' .. formateNum(timeTable.second)
        end
    end

    return timeStr
end

--- 转换秒数为时间字符串 天数独立显示
-- @param secondNum 秒数，类型number
-- @return string
function string.convertSecondToTimeHighlightDay(secondNum)
    local function formatNumber(num)
        if string.len(num) < 2 then
            return "0" .. num
        else
            return tostring(num)
        end
    end

    local timeTable = string.convertSecondToTimeTable(secondNum)

    local timeString = nil
    local timeStrDay = nil

    if timeTable.day > 0 then
        timeStrDay = timeTable.day .. lang.transstr("day")
    end
    if timeTable.hour > 0 then
        timeString = formatNumber(timeTable.hour) .. ":" .. formatNumber(timeTable.minute) .. ":" .. formatNumber(timeTable.second)
    else
        timeString = formatNumber(timeTable.minute) .. ":" .. formatNumber(timeTable.second)
    end

    return timeString, timeStrDay
end

function string.convertSecondToTimeTrans(secondNum)
    local timeTable = string.convertSecondToTimeTable(secondNum)
    local trans = ""
    if timeTable.day > 0 then 
        trans = trans .. timeTable.day .. lang.transstr("day")
    end
    if timeTable.hour > 0 then 
        trans = trans .. timeTable.hour .. lang.transstr("hour")
    end
    if timeTable.minute > 0 then 
        trans = trans .. timeTable.minute .. lang.transstr("minute")
    end
    if timeTable.second > 0 then 
        trans = trans .. timeTable.second .. lang.transstr("second")
    end

    return trans
end

--- 转换秒数为时间table
-- @param secondNum 秒数，类型number
-- @return table
function string.convertSecondToTimeTable(secondNum)
    secondNum = math.round(secondNum)
    local day = math.floor(secondNum / 86400)
    secondNum = secondNum % 86400
    local hour = math.floor(secondNum / 3600)
    secondNum = secondNum % 3600
    local minute = math.floor(secondNum / 60)
    secondNum = secondNum % 60
    local second = secondNum

    local timeTable = {}
    timeTable.day = day
    timeTable.hour = hour
    timeTable.minute = minute
    timeTable.second = second

    return timeTable
end

function string.formatTimeClock(time, precision, symbol)
    local finalTime = ''
    local _hour = ''
    local _minute = ''
    local _second = ''
    local symbol = symbol or ':'
    local hour = math.floor(time / 3600)
    if precision == 3600 then
        _hour = string.format("%02d", 0) .. symbol
        _minute = string.format("%02d", 0) .. symbol
    elseif precision == 60 then
        _minute = string.format("%02d", 0) .. symbol
    end

    if hour > 0 then
        time = time % 3600
        _hour = string.format("%02d", hour) .. symbol 
        _minute = string.format("%02d", 0) .. symbol
    end
    finalTime = _hour

    local minute = math.floor(time / 60)
    if minute > 0 then
        time = time % 60
        _minute = string.format("%02d", minute) .. symbol
    end
    finalTime = finalTime .. _minute

    local second = math.floor(time)
    _second = string.format("%02d", second)
    finalTime = finalTime .. _second
    return finalTime
end

-- 把字符串中汉字和数字分开
function string.splitWordAndNumber(str) 
    local i = 1
    while i <= #str do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1
            break
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        i = i + byteCount
    end
    local word = string.sub(str, 1, i - 1)
    local number = string.sub(str, i)
    return word, number
end

-- 拆分字符串(在unity编辑器上得需要在PlayerSetting 中 定义LUA_USE_UTF8_ON_EDITOR_WIN)
function string.splitCharacter(text, symbol) 
    local textTab = {}
    for uchar in string.gfind(text, "[%z\1-\127\194-\244][\128-\191]*") do 
        textTab[#textTab+1] = uchar 
    end
    text = table.concat(textTab, symbol)
    return text, textTab 
end

function math.concatCompareFunc(...)
    local funcs = {}
    local reverse = {}
    for i = 1, select('#', ...) do
        local arg = select(i, ...)
        if type(arg) == 'function' then
            funcs[#funcs + 1] = arg
        elseif type(arg) == 'table' and type(arg[1]) == 'function' then
            funcs[#funcs + 1] = arg[1]
            reverse[#funcs] = arg[2]
        end
    end
    local function concatedCompare(a, b)
        for i,v in ipairs(funcs) do
            local pv = v(a, b)
            if type(pv) == 'number' then
                if pv ~= 0 then
                    if reverse[i] then
                        return -pv
                    else
                        return pv
                    end
                end
            end
        end
        return 0
    end
    return concatedCompare
end

function setIndexHierarchical(table, indexmeta)
    local meta = getmetatable(table)
    if not meta then
        return setmetatable(table, { __index = indexmeta })
    else
        if not meta.__index then
            meta.__index = indexmeta
            return table
        else
            if type(meta.__index) == 'function' then
                local oldmeta = meta.__index
                meta.__index = function(table, key)
                    local rv = oldmeta(table, key)
                    if rv ~= nil then
                        return rv
                    else
                        if type(indexmeta) == 'function' then
                            return indexmeta(table, key)
                        elseif type(indexmeta) == 'table' or type(indexmeta) == 'userdata' then
                            return indexmeta[key]
                        end
                    end
                end
                return table
            elseif type(meta.__index) == 'table' or type(meta.__index) == 'userdata' then
                setIndexHierarchical(meta.__index, indexmeta)
                return table
            else
                meta.__index = indexmeta
                return table
            end
        end
    end
    return table
end

function setNewIndexHierarchical(table, indexmeta)
    local meta = getmetatable(table)
    if not meta then
        return setmetatable(table, { __newindex = indexmeta })
    else
        if not meta.__newindex then
            meta.__newindex = indexmeta
            return table
        else
            if type(meta.__newindex) == 'function' then
                -- ??
                meta.__newindex = indexmeta
                return table
            elseif type(meta.__newindex) == 'table' or type(meta.__newindex) == 'userdata' then
                setIndexHierarchical(meta.__newindex, indexmeta)
                return table
            else
                meta.__newindex = indexmeta
                return table
            end
        end
    end
    return table
end

function string.utf8char(dig)
    if dig < 128 then
        return string.char(dig)
    elseif dig < 2048 then
        return string.char(math.floor(dig / 64) + 192, dig % 64 + 128)
    elseif dig < 65536 then
        return string.char(math.floor(dig / 4096) + 224, math.floor((dig % 4096) / 64) + 128, dig % 64 + 128)
    else
        -- TODO: this is out of ucs2 range
        return ""
    end
end

-- 按指定的顺序遍历table
function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do a[#a + 1] = n end
    table.sort(a, f)
    local i = 0
    return function ()
        i = i + 1
        return a[i], t[a[i]]
    end
end

-- 将一个number转换为二进制表示的table
-- 如10转换为二进制是1010
-- 传入参数mask=10
-- 返回{false, true, false, true}
-- 低位在table的前面，高位在table的后面
function math.getMaskTable(mask)
    mask = tonumber(mask)
    local tab = {}
    while mask > 0 do
        table.insert(tab, mask % 2 == 1 and true or false)
        mask = math.floor(mask / 2)
    end
    return tab
end

function string.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

--- 将秒数保留至小数点后两位并转换为xx'yy''格式
-- @param second 秒数，类型number/string (10.22)
-- @return string (10'22'')
function string.convertSecondToTimeString(second)
    local result = string.format("%.2f", tostring(second))
    result = string.gsub(result, "%.", "\'")
    result = result .. "\'\'"
    return result
end

function ToStringEx(value)
    if type(value) == 'table' then
       return TableToStr(value)
    elseif type(value) == 'string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end

-- 将lua table转换成string
function TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key, value in pairs(t) do
        local signal = ","
        if i == 1 then
          signal = ""
        end

        if key == i then
            retstr = retstr .. signal .. ToStringEx(value)
        else
            if type(key) == 'number' or type(key) == 'string' then
                retstr = retstr .. signal .. '['..ToStringEx(key).."]=" ..ToStringEx(value)
            else
                if type(key) == 'userdata' then
                    retstr = retstr .. signal .. "*s" .. TableToStr(getmetatable(key)) .. "*e" .. "=" .. ToStringEx(value)
                else
                    retstr = retstr .. signal .. key .. "=" .. ToStringEx(value)
                end
            end
        end

        i = i+1
    end

     retstr = retstr .. "}"
     return retstr
end

function GetServerTimeNow()
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    return serverTimeNow
end