local DataProvider = clr.ActionLayer.DataProvider
local EmulatorInput = clr.EmulatorInput
local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local InitializerFilter = require('emulator.InitializerFilter')
local MatchInfoModel = require("ui.models.MatchInfoModel")
local DemoMatchManager = require('coregame.DemoMatchManager')
local MusicManager = require("ui.control.manager.MusicManager")
local WeatherConstParams = require("coregame.WeatherConstParams")
local MatchConstants = require("ui.scene.match.MatchConstants")

local MatchLoader = {}

local WeatherType = {
    "SummerSunny",
    "SummerNight",
    "WinterSunny",
    "WinterNight",
    "Rain",
    "Snow",
}

function MatchLoader.startMatch(data, isDemoMatch)
    -- Reset
    DataProvider.Reset()
    MusicManager.stop()
    isDemoMatch = isDemoMatch or false
    local matchInfoModel = MatchInfoModel.GetInstance()
    if isDemoMatch then
        matchInfoModel:SetAsDemoMatch()
        if data == nil then
            data = require("coregame.DemoMatchInitializer")
        end
    else
        matchInfoModel:SetAsNormalMatch()
    end
    matchInfoModel:InitWithProtocol(data)
    if not isDemoMatch then
        local Initializer = InitializerFilter.getInitializer(matchInfoModel:GetData())
        if ___CONFIG__DEBUG_CORE_GAME_DUMP then
            dump(Initializer)
        end
        EmulatorInput.GetInstance():SetInitializerJson(json.encode(Initializer))
        EmulatorInput.GetInstance():SetFormationJson(json.encode(matchInfoModel:GetPlayerFormationInfo()))
    end

    clr.coroutine(function()
        unity.waitForEndOfFrame()

        res.CacheHandle()
        res.DestroyAll()
        res.UnloadAllBundleSoft()
        -- 点击特效
        -- local touchEffect = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/EffectClick/TouchEffect.prefab")
        if isDemoMatch then
            local obj, demoManager = res.Instantiate('Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/DemoMatchManager.prefab')
            res.DontDestroyOnLoad(obj)
        end
        if not MatchLoader.objectsSaved then
            MatchLoader.objectsSaved = true
            res.SaveCurObjects()
        end

        local baseInfo = matchInfoModel:GetBaseInfo()
        local weather = matchInfoModel:IsUseWeatherGrassTech() and tostring(baseInfo.weatherTech) or tostring(baseInfo.weather)
        if WeatherConstParams[weather] then
            WeatherConstParams.currentWeather = weather
        end

        res.LoadScene("Assets/CapstonesRes/Game/UI/Match/Loading/MatchLoading.unity")
    end)
end

function MatchLoader.startDemoMatchCN()
    -- Reset
    luaevt.trig("SDK_Report", "sample_match_start")
    DataProvider.Reset()
    MusicManager.stop()
    local matchInfoModel = MatchInfoModel.GetInstance()
    matchInfoModel:SetAsDemoMatch()
    data = require("coregame.DemoMatchInitializer")
    matchInfoModel:InitWithProtocol(data)

    clr.coroutine(function()
        res.DestroyAll()
        -- 点击特效
        -- local touchEffect = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/EffectClick/TouchEffect.prefab")
        local obj, demoManager = res.Instantiate('Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/DemoMatchManager.prefab')
        res.DontDestroyOnLoad(obj)

        if not MatchLoader.objectsSaved then
            MatchLoader.objectsSaved = true
            res.SaveCurObjects()
        end

        local baseInfo = matchInfoModel:GetBaseInfo()
        local weather = tostring(baseInfo.weather)
        if WeatherConstParams[weather] then
            WeatherConstParams.currentWeather = weather
        end

        res.Instantiate('Assets/CapstonesRes/Game/UI/Common/Template/Functional/ScreenResolutionManager.prefab')
        PrefabCache.load()

        coroutine.yield(clr.UnityEngine.WaitForSeconds(1))

        local loadinfo = res.ChangeSceneAsync("ui.controllers.match.MatchCtrl")
        if loadinfo then
            while not loadinfo.done do
                unity.waitForNextEndOfFrame()
            end
            demoManager:DisableLoadingBg()
        end

        res.CollectGarbageDeep()
    end)
end

function MatchLoader.startHeroMatch()
    clr.coroutine(function()
        res.DestroyAll()

        local matchInfoModel = MatchInfoModel.GetInstance()
        matchInfoModel:SetAsDemoMatch()
        data = require("coregame.heromatch.HeroMatchInitializer")
        matchInfoModel:InitWithProtocol(data)
        luaevt.trig("SendBIReport", "heroMatch_loading", "6")
        local obj = res.Instantiate('Assets/CapstonesRes/Game/UI/Match/Overlay/HeroMatchFightMenu.prefab')
        res.DontDestroyOnLoad(obj)
        MatchLoader.fightMenu = obj

        res.LoadScene("Assets/CapstonesRes/Game/MatchScenes/HeroMatch/hero_match.unity")
    end)
end

return MatchLoader
