local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LightmapData = UnityEngine.LightmapData
local LightmapSettings = UnityEngine.LightmapSettings
local Color = UnityEngine.Color
local WaitForSeconds = UnityEngine.WaitForSeconds
local Camera = UnityEngine.Camera
local Vector3 = UnityEngine.Vector3
local Vector4 = UnityEngine.Vector4
local GameObject = UnityEngine.GameObject
local SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
local RenderSettings = UnityEngine.RenderSettings
local Material = UnityEngine.Material

local MatchInfoModel = require("ui.models.MatchInfoModel")
local ClothUtils = require("cloth.ClothUtils")
local ScreenEffectManager = require("coregame.ScreenEffectManager")
local WeatherConstParams = require("coregame.WeatherConstParams")

local HomeShirt = require("data.HomeShirt")
local AwayShirt = require("data.AwayShirt")
local GKShirt = require("data.GKShirt")
local QualitySetting = require("coregame.QualitySetting")

local SpectatorsState = {
    INVALID = 0,
    CALM = 1,
    CHEER = 2,
}

local skyTexturePath = {
    Sunny = {
        "Assets/CapstonesRes/Game/Models/Sky/Textures/SkyDay.psd",
        "Assets/CapstonesRes/Game/Models/Sky/Textures/SkyDayMraky.psd"
    },
    Night = {
        "Assets/CapstonesRes/Game/Models/Sky/Textures/SkyNight.psd",
        "Assets/CapstonesRes/Game/Models/Sky/Textures/SkyNightMraky.psd"
    },
    Cloudy = {
        "Assets/CapstonesRes/Game/Models/Sky/Textures/SkyCloudy.psd",
        "Assets/CapstonesRes/Game/Models/Sky/Textures/SkyCloudyMraky.psd"
    }
}

local weatherSkyMap = {
    SummerSunny = "Sunny",
    WinterSunny = "Sunny",
    SummerNight = "Night",
    WinterNight = "Night",
    Rain = "Cloudy",
    Snow = "Cloudy",
    SunShine = "Sunny",
    Wind = "Cloudy",
    Fog = "Cloudy",
    Sand = "Cloudy",
    Heat = "Cloudy",
}

math.randomseed(os.time())

local StadiumManager = class(unity.base)

function StadiumManager:ctor()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    self.opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    self.baseInfo = self.matchInfoModel:GetBaseInfo()

    self:initWeather()
    self:initPitchPattern()
    self:initSpectators()
    self:initGoalNet()
end

function StadiumManager:start()
    self:setWeather(WeatherConstParams.currentWeather)
    self:setPitchPattern()
    self:setSpectators()

    if ___CONFIG__DEBUG_MATCH_SCENE and self.___ex.debugTools then
        self.___ex.debugTools:SetActive(true)
    end

    local homeLogo = self.baseInfo.home == 1 and self.playerTeamData.logo or self.opponentTeamData.logo
    local awayLogo = self.baseInfo.home == 1 and self.opponentTeamData.logo or self.playerTeamData.logo
    self.___ex.spectatorsBannerManager:Init(homeLogo, awayLogo, self.baseInfo.spectatorsType == 2)
end

local function loadWeatherLightmapData(prefix, id)
    local lightmapData = LightmapData()
    lightmapData.lightmapLight = res.LoadRes("Assets/CapstonesRes/Game/MatchScenes/Lightmaps/" .. prefix .. "/LightmapFar-" .. id .. ".exr")
    return lightmapData
end

function StadiumManager:setLightAndLightmap(weather)
    self:coroutine(function()
        coroutine.yield()
        unity.waitForNextEndOfFrame()

        local prefix = WeatherConstParams[weather].Lightmap
        local lightmaps = clr.array({loadWeatherLightmapData(prefix, 0)}, LightmapData)
        LightmapSettings.lightmaps = lightmaps
        local weatherParams = WeatherConstParams[weather]
        self:SetMainLight(weatherParams.LightIntensity, weatherParams.LightColor, weatherParams.AmbientLight)
    end)
end

function StadiumManager:SetMainLight(intensity, lightColor, ambientLight)
    self.___ex.light.intensity = intensity
    self.___ex.light.color = Color(lightColor[1], lightColor[2], lightColor[3], lightColor[4])
    RenderSettings.ambientLight = Color(ambientLight[1], ambientLight[2], ambientLight[3], ambientLight[4])
end

function StadiumManager:SetSkyTexture(weather)
    local texturePaths = skyTexturePath[weatherSkyMap[weather]]
    self.___ex.skyMeshRenderer.material:SetTexture("_MainTex", res.LoadRes(texturePaths[1]))
    self.___ex.skyMeshRenderer.material:SetTexture("_DetailTex", res.LoadRes(texturePaths[2]))
end

function StadiumManager:initWeather()
    self.weatherSetting = {}
    self.weatherSetting.Rain =
    {
        cameraEffect = "Assets/CapstonesRes/Game/Models/EffectWeather/Rain/Rain.prefab",
        mainTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Rain/RainGrassNew.jpg",
        overlayPatternTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Rain/RainOverlayPattenNew.png",
        overlayPatternDetailTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Rain/RainDetailOverlayNew.jpg",
        overlayTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Rain/RainOverlayNew.jpg",
        weatherType = "Rain",
    }
    self.weatherSetting.Snow =
    {
        cameraEffect = "Assets/CapstonesRes/Game/Models/EffectWeather/Snow/Snow.prefab",
        overlayPatternTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Snow/SnowOverlayPattenNew.png",
        overlayPatternDetailTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Snow/SnowDetailOverlayNew.jpg",
        overlayTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Snow/SnowOverlayNew.jpg",
        mainTex = "Assets/CapstonesRes/Game/Models/EffectWeather/Snow/SnowGrassNew.bmp",
        weatherType = "Snow",
    }
    self.weatherSetting.Wind = {
        cameraEffect = "Assets/CapstonesRes/Game/Models/EffectWeather/Wind/Wind.prefab",
    }
    self.weatherSetting.Fog = {
        cameraEffect = "Assets/CapstonesRes/Game/Models/EffectWeather/Fog/Fog.prefab",
    }
    self.weatherSetting.Sand = {
        cameraEffect = "Assets/CapstonesRes/Game/Models/EffectWeather/SandStorm/SandStorm.prefab",
    }
    self.weatherSetting.Heat = {
        cameraEffect = "Assets/CapstonesRes/Game/Models/EffectWeather/Hot/Hot.prefab",
    }
    self.weatherSetting.default = {
        mainTex = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Pitch/Grass.bmp",
    }
end

local particleObj

function StadiumManager:ClearOtherWeatherEffect()
    if particleObj then
        Object.Destroy(particleObj)
    end
    self.pitchMaterial:EnableKeyword("_DEFULAT")
    self.pitchMaterial:DisableKeyword("_SNOW")
    self.pitchMaterial:DisableKeyword("_RAIN")

    self.pitchMaterial:SetTexture("_OverlayPatternTex", clr.null)
    self.pitchMaterial:SetTexture("_OverlayPatternDetailTex", clr.null)
    self.pitchMaterial:SetTexture("_OverlayTex", clr.null)
    self.pitchMaterial:SetTexture("_MainTex", res.LoadRes(self.weatherSetting.default.mainTex))
end

function StadiumManager:setWeatherObj(weather)
    for k, setting in pairs(self.weatherSetting) do
        if k == weather then
            -- 雨和雪的粒子特效创建(挂靠在摄像机下面)
            if setting.cameraEffect and setting.cameraEffect ~= "" then
                particleObj = res.Instantiate(setting.cameraEffect)
                local cameraTrans = self.___ex.cameraTrans
                if cameraTrans == nil then
                    cameraTrans = GameObject.Find("/CameraContainer/MainCamera").transform
                end
                particleObj.transform:SetParent(cameraTrans, false)
            end
            -- 雨和雪的草地材质设置
            if setting.overlayPatternTex and setting.overlayPatternTex ~= "" then
                self.pitchMaterial:SetTexture("_OverlayPatternTex", res.LoadRes(setting.overlayPatternTex))
            end
            if setting.overlayPatternDetailTex and setting.overlayPatternDetailTex ~= "" then
                self.pitchMaterial:SetTexture("_OverlayPatternDetailTex", res.LoadRes(setting.overlayPatternDetailTex)) 
            end
            if setting.overlayTex and setting.overlayTex ~= "" then
                self.pitchMaterial:SetTexture("_OverlayTex", res.LoadRes(setting.overlayTex))
            end
            if setting.weatherType and setting.weatherType == "Rain" then
                self.pitchMaterial:SetTexture("_MainTex", res.LoadRes(setting.mainTex))   
                self.pitchMaterial:DisableKeyword("_DEFULAT")
                self.pitchMaterial:DisableKeyword("_SNOW")
                self.pitchMaterial:EnableKeyword("_RAIN")
            end
            if setting.weatherType and setting.weatherType == "Snow" then
                self.pitchMaterial:SetTexture("_MainTex", res.LoadRes(setting.mainTex))   
                self.pitchMaterial:DisableKeyword("_DEFULAT")
                self.pitchMaterial:EnableKeyword("_SNOW")
                self.pitchMaterial:DisableKeyword("_RAIN")
            end
        end
    end
end

function StadiumManager:SetPitchColor(pitchColor)
    self.pitchMaterial:SetVector("_Color", Vector4(pitchColor[1], pitchColor[2], pitchColor[3], pitchColor[4]))
end

function StadiumManager:SetPitchLineLightness(lightness)
    self.pitchLineMaterial:SetFloat("_ColorFactor", lightness)
end

function StadiumManager:setWeather(weather)
    print("weather: " .. tostring(weather))

    if weather then
        -- 不同季节不同天气下的草地材质的光照参数
        local pitchColor = WeatherConstParams[weather].PitchColor
        self:SetPitchColor(pitchColor)
        self:SetPitchLineLightness(WeatherConstParams[weather].PitchLineLightness)

        self:setWeatherObj(weather)
        self:setLightAndLightmap(weather)
        self:SetSkyTexture(weather)
        if weather == "Snow" then
            -- 雪天关闭bloom特效
            -- ScreenEffectManager.bloomForbidden = true
            -- 使用粉色的足球
            -- 改为了一个橙色足球
            local ball = GameObject.Find("/PlayerManager/Ball")
            local ballMaterial = ball.transform:FindChild("ball"):GetComponent(SkinnedMeshRenderer).material
            ballMaterial:SetTexture("_MainTex", res.LoadRes("Assets/CapstonesRes/Game/Models/Ball/Textures/soccer_orange.jpg"))
            ballMaterial:SetTexture("_BumpMap", res.LoadRes("Assets/CapstonesRes/Game/Models/Ball/Textures/soccer_on.jpg"))
        else
            ScreenEffectManager.bloomForbidden = false
        end
    end
end

function StadiumManager:initPitchPattern()
    self.___ex.pitchCollier.enabled = true
    self.___ex.pitchRenderer.sharedMaterial = Object.Instantiate(self.___ex.pitchRenderer.sharedMaterial)
    self.pitchMaterial = self.___ex.pitchRenderer.sharedMaterial

    self.___ex.pitchLineRenderer.sharedMaterial = Object.Instantiate(self.___ex.pitchLineRenderer.sharedMaterial)
    self.pitchLineMaterial = self.___ex.pitchLineRenderer.sharedMaterial
end

function StadiumManager:setPitchPattern()
    local pitchPatternList = { "Pattern1", "Pattern2", "Pattern3", "Pattern4"}
    local pitchPattern = pitchPatternList[math.random(#pitchPatternList)]
    if type(self.baseInfo.pitchPattern) == "number" and self.baseInfo.pitchPattern >= 1 and self.baseInfo.pitchPattern <= 4 then
        pitchPattern = "Pattern" .. tostring(self.baseInfo.pitchPattern)
    end

    if self.___ex.pitchPattern then pitchPattern = self.___ex.pitchPattern end

    print("pitchPattern: " .. tostring(pitchPattern))

    if pitchPattern then
        local patternPath
        if (WeatherConstParams.currentWeather == "SummerNight" or WeatherConstParams.currentWeather == "WinterNight") then
            patternPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Pitch/NightPattern/" .. pitchPattern .. ".bmp"
        elseif WeatherConstParams.currentWeather == "SummerSunny" then
            patternPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Pitch/SunnyPattern/" .. pitchPattern .. ".bmp"
        else
            patternPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Pitch/Pattern/" .. pitchPattern .. ".bmp"
        end
        local pitchPatternTexture = res.LoadRes(patternPath)
        if pitchPatternTexture then
            self.pitchMaterial:SetTexture("_PatternTex", pitchPatternTexture)
        end
    end
end

function StadiumManager:initSpectators()
    local deviceLevel = QualitySetting.GetLevel() == "high" and "SpectatorsHighLevel" or "SpectatorsLowLevel"
    local matFormatPath = "Assets/CapstonesRes/Game/Models/Stadium/Materials/%s/%s.mat"
    local homeDensePath = string.format(matFormatPath, deviceLevel, "SpectatorsHomeDense")
    local homeSparsePath = string.format(matFormatPath, deviceLevel, "SpectatorsHomeSparse")
    local awayDensePath = string.format(matFormatPath, deviceLevel, "SpectatorsAwayDense")
    local awaySparsePath = string.format(matFormatPath, deviceLevel, "SpectatorsAwaySparse")
    self.spectatorsMaterial = {}
    self.spectatorsMaterial.homeDense = Object.Instantiate(res.LoadRes(homeDensePath, Material))
    self.spectatorsMaterial.homeSparse = Object.Instantiate(res.LoadRes(homeSparsePath, Material))
    self.spectatorsMaterial.awayDense = Object.Instantiate(res.LoadRes(awayDensePath, Material))
    self.spectatorsMaterial.awaySparse = Object.Instantiate(res.LoadRes(awaySparsePath, Material))

    local spectatorsMap
    if tonumber(self.baseInfo.spectatorsType) == 2 then
        -- 大客场
        spectatorsMap = {
            ["1_A1"] = "homeDense",
            ["1_A2"] = "awayDense",
            ["1_B"] = "awayDense",
            ["1_C1"] = "awayDense",
            ["1_C2"] = "homeDense",
            ["1_D"] = "homeDense",
            ["2_A1"] = "homeSparse",
            ["2_A2"] = "awaySparse",
            ["2_B"] = "awaySparse",
            ["2_C1"] = "awaySparse",
            ["2_C2"] = "homeSparse",
            ["2_D"] = "homeSparse",
            ["3_A1"] = "homeSparse",
            ["3_A2"] = "awaySparse",
            ["3_B"] = "awaySparse",
            ["3_C1"] = "awaySparse",
            ["3_C2"] = "homeSparse",
            ["3_D"] = "homeSparse",
        }
    else
        -- 小客场
        spectatorsMap = {
            ["1_A1"] = "homeDense",
            ["1_A2"] = "homeDense",
            ["1_B"] = "awayDense",
            ["1_C1"] = "homeDense",
            ["1_C2"] = "homeDense",
            ["1_D"] = "homeDense",
            ["2_A1"] = "homeSparse",
            ["2_A2"] = "homeSparse",
            ["2_B"] = "awaySparse",
            ["2_C1"] = "homeSparse",
            ["2_C2"] = "homeSparse",
            ["2_D"] = "homeSparse",
            ["3_A1"] = "homeSparse",
            ["3_A2"] = "homeSparse",
            ["3_B"] = "awaySparse",
            ["3_C1"] = "homeSparse",
            ["3_C2"] = "homeSparse",
            ["3_D"] = "homeSparse",
        }
    end

    for k, v in pairs(self.___ex.spectatorsRenderer) do
        if spectatorsMap[k] then
            v.sharedMaterial = self.spectatorsMaterial[spectatorsMap[k]]
        end
    end

    self.spectatorsState = {
        home = SpectatorsState.INVALID,
        away = SpectatorsState.INVALID,
    }

    self:cheerSpectators("home")
    self:cheerSpectators("away")
end

function StadiumManager:setSpectators()
    local playerColor = {}
    local playerParas = self.playerTeamData.spectators
    playerColor.Red = ClothUtils.parseColorString(playerParas.firstColor)
    playerColor.Green = ClothUtils.parseColorString(playerParas.secondColor)
    playerColor.MaskTex = playerParas.maskTex
    local opponentColor = {}
    local opponentParas = self.opponentTeamData.spectators
    opponentColor.Red = ClothUtils.parseColorString(opponentParas.firstColor)
    opponentColor.Green = ClothUtils.parseColorString(opponentParas.secondColor)
    opponentColor.MaskTex = opponentParas.maskTex

    local homeColor = nil
    local awayColor = nil
    -- 玩家是主场还是客场
    if self.baseInfo.home == 0 or self.baseInfo.home == 2 then
        homeColor = playerColor
        awayColor = opponentColor
    else
        homeColor = opponentColor
        awayColor = playerColor
    end

    local deviceLevel = QualitySetting.GetLevel() == "high" and "HighLevel" or "LowLevel"
    local denseFormatPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Spectators/%s/Dense/%s.png"
    local sparseFormatPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Spectators/%s/Sparse/%s.png"

    local denseSpectatorsPath = string.format(denseFormatPath, deviceLevel, playerColor.MaskTex)
    local sparseSpectatorsPath = string.format(sparseFormatPath, deviceLevel, playerColor.MaskTex)

    self.spectatorsMaterial.homeDense:SetColor("_FirstColor", playerColor.Red)
    self.spectatorsMaterial.homeDense:SetColor("_SecondColor", playerColor.Green)
    self.spectatorsMaterial.homeDense:SetColor("_ThirdColor", Color(0.075, 0.067, 0.259, 1))
    self.spectatorsMaterial.homeDense:SetTexture("_MaskTex", res.LoadRes(denseSpectatorsPath))

    self.spectatorsMaterial.homeSparse:SetColor("_FirstColor", playerColor.Red)
    self.spectatorsMaterial.homeSparse:SetColor("_SecondColor", playerColor.Green)
    self.spectatorsMaterial.homeSparse:SetColor("_ThirdColor", Color(0.439, 0.365, 0.051, 1))
    self.spectatorsMaterial.homeSparse:SetTexture("_MaskTex", res.LoadRes(sparseSpectatorsPath))

    self.spectatorsMaterial.awayDense:SetColor("_FirstColor", opponentColor.Red)
    self.spectatorsMaterial.awayDense:SetColor("_SecondColor", opponentColor.Green)
    self.spectatorsMaterial.awayDense:SetColor("_ThirdColor", Color(0.075, 0.067, 0.259, 1))
    self.spectatorsMaterial.awayDense:SetTexture("_MaskTex", res.LoadRes(denseSpectatorsPath))

    self.spectatorsMaterial.awaySparse:SetColor("_FirstColor", opponentColor.Red)
    self.spectatorsMaterial.awaySparse:SetColor("_SecondColor", opponentColor.Green)
    self.spectatorsMaterial.awaySparse:SetColor("_ThirdColor", Color(0.439, 0.365, 0.051, 1))
    self.spectatorsMaterial.awaySparse:SetTexture("_MaskTex", res.LoadRes(sparseSpectatorsPath))
end

function StadiumManager:onGoal(side)
    self:cheerSpectators(side)
    self:calmSpectators(self:getOtherSide(side))
end

function StadiumManager:onMatchEvent()
    self:calmSpectators("home")
    self:calmSpectators("away")
end

function StadiumManager:getOtherSide(side)
    return side == "home" and "away" or "home"
end

-- 每秒播放spectatorsSpeed帧的观众席动画
local spectatorsSpeed = 6
local levelFrameMap = {
    HighLevel = {
        step1 = {5, 5},
        step2 = {6, 6},
        step3 = {7, 16},
        calm = {1, 4},
    },
    LowLevel = {
        step1 = {4, 4},
        step2 = {5, 5},
        step3 = {5, 8},
        calm = {1, 3},
    },
}

function StadiumManager:cheerSpectators(side)
    local deviceLevel = QualitySetting.GetLevel() == "high" and "HighLevel" or "LowLevel"
    if self.spectatorsState[side] ~= SpectatorsState.CHEER then
        self.spectatorsState[side] = SpectatorsState.CHEER
        self:coroutine(function()
            coroutine.yield(WaitForSeconds(1 / spectatorsSpeed))
            self:setSpectatorsSpeed(side, 0)
            self:setSpectatorsFrames(side, levelFrameMap[deviceLevel].step1[1], levelFrameMap[deviceLevel].step1[2])
            coroutine.yield(WaitForSeconds(1 / spectatorsSpeed))
            self:setSpectatorsSpeed(side, 0)
            self:setSpectatorsFrames(side, levelFrameMap[deviceLevel].step2[1], levelFrameMap[deviceLevel].step2[2])
            coroutine.yield(WaitForSeconds(1 / spectatorsSpeed))
            self:setSpectatorsSpeed(side, spectatorsSpeed)
            self:setSpectatorsFrames(side, levelFrameMap[deviceLevel].step3[1], levelFrameMap[deviceLevel].step3[2])
        end)
    end
end

function StadiumManager:calmSpectators(side)
    local deviceLevel = QualitySetting.GetLevel() == "high" and "HighLevel" or "LowLevel"
    if self.spectatorsState[side] ~= SpectatorsState.CALM then
        self.spectatorsState[side] = SpectatorsState.CALM
        self:setSpectatorsSpeed(side, spectatorsSpeed)
        self:setSpectatorsFrames(side, levelFrameMap[deviceLevel].calm[1], levelFrameMap[deviceLevel].calm[2])
    end
end

function StadiumManager:setSpectatorsFrames(side, startFrame, endFrams)
    local denseMaterial = self.spectatorsMaterial[side .. "Dense"]
    local sparseMaterial = self.spectatorsMaterial[side .. "Sparse"]

    denseMaterial:SetInt("_StartFrame", startFrame)
    denseMaterial:SetInt("_EndFrame", endFrams)
    sparseMaterial:SetInt("_StartFrame", startFrame)
    sparseMaterial:SetInt("_EndFrame", endFrams)
end

function StadiumManager:setSpectatorsSpeed(side, speed)
    local denseMaterial = self.spectatorsMaterial[side .. "Dense"]
    local sparseMaterial = self.spectatorsMaterial[side .. "Sparse"]

    denseMaterial:SetFloat("_Speed", speed)
    sparseMaterial:SetFloat("_Speed", speed)
end

function StadiumManager:initGoalNet()
    self.___ex.goalNet1:SetEnabledFading(false, 0)
    self.___ex.goalNet2:SetEnabledFading(false, 0)
end

function StadiumManager:enableGoalNet()
    self.___ex.goalNet1:SetEnabledFading(true, 0)
    self.___ex.goalNet2:SetEnabledFading(true, 0)
    self.___ex.goalNet1.randomAcceleration = Vector3(50, 50, 50);
    self.___ex.goalNet2.randomAcceleration = Vector3(50, 50, 50);

    if ___cameraCtrlCore then
        ___cameraCtrlCore:checkGoalViewCameraShake()
    end

    self:coroutine(function()
        coroutine.yield(WaitForSeconds(2))
        self.___ex.goalNet1:SetEnabledFading(false, 0.5)
        self.___ex.goalNet2:SetEnabledFading(false, 0.5)
    end)
end

function StadiumManager:disableGoalNet()
    self.___ex.goalNet1:SetEnabledFading(false, 0)
    self.___ex.goalNet2:SetEnabledFading(false, 0)
end

function StadiumManager:onDestroy()
    -- 释放引用的资源
    self.pitchMaterial = nil
    self.pitchLineMaterial = nil
    self.spectatorsMaterial = nil
    self.___ex.spectatorsMaterial = nil
end

return StadiumManager
