local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local MatchInfoModel = require("ui.models.MatchInfoModel")

local MatchLoadingBase = class(unity.base)
local WeatherConstParams = require("coregame.WeatherConstParams")

WeatherConfig = {
    SummerSunny = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Sunny.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingSunny.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_SunShine.png",
        Time = "12:00",
    },
    SummerNight = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Night.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingNight.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Night.png",
        Time = "19:00",
    },
    WinterSunny = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Sunny.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingSunny.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_SunShine.png",
        Time = "12:00",
    },
    WinterNight = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Night.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingNight.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Night.png",
        Time = "19:00",
    },
    Rain = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Rain.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingRain.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Rain.png",
        Time = "15:00",
    },
    Snow = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Snow.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingSnow.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Snow.png",
        Time = "15:00",
    },
    SunShine = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Sunny.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingSunny.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_SunShine.png",
        Time = "12:00",
    },
    Wind = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Wind.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingWind.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Wind.png",
        Time = "15:00",
    },
    Fog = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Fog.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingFog.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Fog.png",
        Time = "15:00",
    },
    Sand = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Sand.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingSand.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Sand.png",
        Time = "15:00",
    },
    Heat = {
        Bg = "Assets/CapstonesRes/Game/UI/Match/Loading/Bg/Bg_Heat.jpg", 
        Effect = "Assets/CapstonesRes/Game/UI/Match/Loading/EffectLoadingHeat.prefab",
        Icon = "Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_Heat.png",
        Time = "12:00",
    },
}

function MatchLoadingBase:ctor(...)
    self.tip = self.___ex.tip
    self.bg = self.___ex.bg
    self.loadingCircle = self.___ex.loadingCircle
    self.isWriting = false
end

function MatchLoadingBase:start()
    if WeatherConstParams.currentWeather then
        self.bg.Path = WeatherConfig[WeatherConstParams.currentWeather].Bg
        self.bg:ApplySource()

        if WeatherConfig[WeatherConstParams.currentWeather].Effect then
            local obj = res.Instantiate(WeatherConfig[WeatherConstParams.currentWeather].Effect)
            obj.transform:SetParent(self.bg.transform, false)
            obj.transform.localPosition = UnityEngine.Vector3(0, 0, 0)
            obj.transform.localScale = UnityEngine.Vector3(1, 1, 1)
            self.effect = obj
        end
    end

    self.isDone = nil
    self:coroutine(function()
        local matchInfoModel = MatchInfoModel.GetInstance()
        local baseInfo = matchInfoModel:GetBaseInfo()
        if baseInfo and baseInfo.tips then
            self.tip.text = baseInfo.tips
        end

        while not self.isDone do
            if not self.isWriting then
                self.loadingCircle:SetActive(true)
            end
            coroutine.yield()
        end
    end)

    res.Instantiate('Assets/CapstonesRes/Game/UI/Common/Template/Functional/ScreenResolutionManager.prefab')
end

return MatchLoadingBase
