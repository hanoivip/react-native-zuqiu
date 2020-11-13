device = {}

local function trySplit(str, sep)
    if type(str) == "string" and type(sep) == "string" then
        return string.split(str, sep)
    end
    return str
end

device.ratio = {}
device.ratio.width, device.ratio.height = luaevt.trig('GetRatio')
device.ratio.width = device.ratio.width or 0
device.ratio.height = device.ratio.height or 0
device.phoneType = luaevt.trig('GetPhoneType') or ''
device.cpuName = luaevt.trig('GetCpuName') or ''
device.cpuCoresNum = luaevt.trig('GetCpuCoresNum') or 0
device.cpuKernel = luaevt.trig('GetCpuKernel') or 0
device.memTotal = luaevt.trig('GetMemTotal') or 0
device.memAvail = luaevt.trig('GetMemAvail') or 0
device.maxCpuFreq = trySplit(luaevt.trig('GetMaxCpuFreq'), ":") or {}
device.minCpuFreq = trySplit(luaevt.trig('GetMinCpuFreq'), ":") or {}
device.curCpuFreq = trySplit(luaevt.trig('GetCurCpuFreq'), ":") or {}

--[[
iosDeviceInfo = {
    ["iphone 5,1"] = "iphone5(移动,联通)",
    ["iphone 5,2"] = "iphone5(移动,电信,联通)",
    ["iphone 4,1"] = "iphone4S",
    ["iphone 3,1"] = "iphone4(移动,联通)",
    ["iphone 3,2"] = "iphone4(联通)",
    ["iphone 3,3"] = "iphone4(电信)",
    ["iphone 2,1"] = "iphone3GS",
    ["iphone 1,2"] = "iphone3G",
    ["iphone 1,1"] = "iphone",
    ["ipad 1,1"] = "ipad 1",
    ["ipad 2,1"] = "ipad 2(Wifi)",
    ["ipad 2,2"] = "ipad 2(GSM)",
    ["ipad 2,3"] = "ipad 2(CDMA)",
    ["ipad 2,4"] = "ipad 2(32nm)",
    ["ipad 2,5"] = "ipad mini(Wifi)",
    ["ipad 2,6"] = "ipad mini(GSM)",
    ["ipad 2,7"] = "ipad mini(CDMA)",
    ["ipad 3,1"] = "ipad 3(Wifi)",
    ["ipad 3,2"] = "ipad 3(CDMA)",
    ["ipad 3,3"] = "ipad 3(4G)",
    ["ipad 3,4"] = "ipad 4(Wifi)",
    ["ipad 3,5"] = "ipad 4(4G)",
    ["ipad 3,6"] = "ipad 4(CDMA)",
    ["ipod 5,1"] = "ipod touch 5",
    ["ipod 4,1"] = "ipod touch 4",
    ["ipod 3,1"] = "ipod touch 3",
    ["ipod 2,1"] = "ipod touch 2",
    ["ipod 1,1"] = "ipod touch",
}
]]
local iosDeviceLevelConfig = {
    ["iphone 5,1"] = "high",
    ["iphone 5,2"] = "high",
    ["iphone 4,1"] = "middle",
    ["iphone 3,1"] = "middle",
    ["iphone 3,2"] = "middle",
    ["iphone 3,3"] = "middle",
    ["iphone 2,1"] = "low",
    ["iphone 1,2"] = "low",
    ["iphone 1,1"] = "low",
    ["ipad 1,1"] = "low",
    ["ipad 2,1"] = "low",
    ["ipad 2,2"] = "low",
    ["ipad 2,3"] = "low",
    ["ipad 2,4"] = "low",
    ["ipad 2,5"] = "low",
    ["ipad 2,6"] = "low",
    ["ipad 2,7"] = "low",
    ["ipad 3,1"] = "middle",
    ["ipad 3,2"] = "middle",
    ["ipad 3,3"] = "middle",
    ["ipad 3,4"] = "middle",
    ["ipad 3,5"] = "middle",
    ["ipad 3,6"] = "middle",
    ["ipod 5,1"] = "high",
    ["ipod 4,1"] = "middle",
    ["ipod 3,1"] = "middle",
    ["ipod 2,1"] = "low",
    ["ipod 1,1"] = "low",
    ["default"] = "high",
}

local function GetIOSDeviceLevel()
    local level = nil
    for key, value in pairs(iosDeviceLevelConfig) do
        if key == device.phoneType then
            level = value
            break
        end
    end
    if level then
        return level
    else
        return iosDeviceLevelConfig.default
    end
end

local androidDeviceLevelConfig = {
    low = {memTotal = 2, ratio = {ratioW = 960, ratioH = 640, }},
    middle = {memTotal = 3, ratio = {ratioW = 1280, ratioH = 720, }},
    high = {memTotal = 4, ratio = {ratioW = 1920, ratioH = 1080, }},
}

local specialAndroidDeviceLevelConfig = {
    ["SO-01H"] = "low",
    ["Nexus 7"] = "low",
} 

-- Android 系统不考虑高级显示效果
local function GetAndroidDeviceLevel()
    local level = nil
    for key, value in pairs(specialAndroidDeviceLevelConfig) do
        if key == device.phoneType then
            level = value
            break
        end
    end
    if level then
        return level
    else
        if (device.memTotal <= androidDeviceLevelConfig.low.memTotal or
            device.ratio.width <= androidDeviceLevelConfig.low.ratio.ratioW or
            device.ratio.height <= androidDeviceLevelConfig.low.ratio.ratioH) then
            return "low"
        -- elseif (device.memTotal >= androidDeviceLevelConfig.high.memTotal and
        --     device.ratio.width >= androidDeviceLevelConfig.high.ratio.ratioW and
        --     device.ratio.height >= androidDeviceLevelConfig.high.ratio.ratioH) then
        --     return "high"
        else
            return "middle"
        end
    end
end

local function GetDeviceLevel()
    if clr.plat == "Android" then
        return GetAndroidDeviceLevel()
    elseif clr.plat == "IPhonePlayer" then
        return GetIOSDeviceLevel()
    elseif clr.UnityEngine.Application.isEditor then
        return "high"
    end
    return "high"
end

device.level = GetDeviceLevel()

return device
