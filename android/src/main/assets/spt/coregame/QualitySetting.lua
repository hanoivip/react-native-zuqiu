local UnityEngine  =  clr.UnityEngine
local device  =  require("core.device")

local QualitySetting  =  {}

local currLevel = nil

function  QualitySetting.SwitchQuality(strLevel)
    strLevel  =  strLevel or "low"

    if(strLevel == currLevel) then
        return false
    end

    currLevel = strLevel
    cache.setQualityLevel(currLevel)
    return true
end

function QualitySetting.GetLevel()
    --1,判断用户是否以前保存过，如果本地有，则直接读取
    local cacheLevel = cache.getQualityLevel() or "none"
    if(cacheLevel ~= "none") then
        currLevel = cacheLevel or "low"
        return currLevel
    end
     --2,如果本地没有，而且是第一次获取，则去访问当前设备质量，以此作为画质质量
    if(currLevel == nil) then
       local deviceLevel = device and device.level or "low"
       currLevel = deviceLevel
       cache.setQualityLevel(currLevel)
       return currLevel
    end
    --3,其他情况下直接返回当前的画质质量
    return currLevel
end

--画面质量显示的时候，只能显示最高画质以下的等级
function  QualitySetting.GetHighestLevel()
    local deviceLevel = device and device.level or "low"
    return deviceLevel
end

return QualitySetting