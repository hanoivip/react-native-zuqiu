local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local WeatherConstParams = require("coregame.WeatherConstParams")
local QualitySetting = require("coregame.QualitySetting")

local ShadowManager = class(unity.base)

function ShadowManager:ctor()
    self.clrShadowManager = self.___ex.clrShadowManager
end

local ShadowConfig = {
    low = "low",
    middle = "low",
    high = "default",
}

function ShadowManager:start()
    local quality = QualitySetting and ShadowConfig[QualitySetting.GetLevel()] or "low"
    self:coroutine(function()
        coroutine.yield()
        self.clrShadowManager:Init(quality,self:IsNight())
        
        if(quality == "default") then
            self:SetShadowIntensity(WeatherConstParams[WeatherConstParams.currentWeather].ShodowIntensity)
        end
    end)

    EventSystem.AddEvent("ShadowManager.ReleaseCamera", self, self.ReleaseCamera)
end

function ShadowManager:IsNight()
    if(WeatherConstParams[WeatherConstParams.currentWeather] == WeatherConstParams.SummerNight or 
        WeatherConstParams[WeatherConstParams.currentWeather] == WeatherConstParams.WinterNight) then
        return true
    else
        return false
    end    
end


function ShadowManager:SetShadowIntensity(intensity)
    self.clrShadowManager:SetShadowIntensity(intensity)
end

function ShadowManager:ReleaseCamera()
    self.clrShadowManager.Camera.targetTexture = clr.null
    self.clrShadowManager.Camera.enabled = false
    self.clrShadowManager.enabled = false
end

function ShadowManager:onDestroy()
    EventSystem.RemoveEvent("ShadowManager.ReleaseCamera", self, self.ReleaseCamera)
end

function  ShadowManager:SwitchShadowQuality(qualityLevel)
    local level = ShadowConfig[qualityLevel] or "low"
    if(level == "default") then
        self:SetShadowIntensity(WeatherConstParams[WeatherConstParams.currentWeather].ShodowIntensity)
    end
    self.clrShadowManager:Init(level, self:IsNight())
end

return ShadowManager
