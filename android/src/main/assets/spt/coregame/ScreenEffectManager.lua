local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Camera = UnityEngine.Camera
local GameHub = clr.GameHub
local DepthTextureMode = UnityEngine.DepthTextureMode

local WeatherConstParams = require("coregame.WeatherConstParams")

local ScreenEffectManager = class(unity.base)

-- 在某些天气背景下，摄像机特效被禁用
ScreenEffectManager.bloomForbidden = false
ScreenEffectManager.blurForbidden = false
ScreenEffectManager.fxProForbidden = false

function ScreenEffectManager:ctor()
    self.radialBlur = self.___ex.radialBlur
    self.fxPro = self.___ex.fxPro
    self.fastBloom = self.___ex.fastBloom
    self.playerManager = self.___ex.playerManager
    self.effectParams = {}
end

function ScreenEffectManager:start()
    local threshhold = WeatherConstParams[WeatherConstParams.currentWeather].BloomThreshhold
    local intensity = WeatherConstParams[WeatherConstParams.currentWeather].BloomIntensity
    local blurSize = WeatherConstParams[WeatherConstParams.currentWeather].BloomBlurSize
    self:SetBloomParams(threshhold, intensity, blurSize)
    self.fxPro.enabled = false
    self.fastBloom.enabled = false
    self.radialBlur.enabled = false
end

function ScreenEffectManager:SetBloomParams(threshhold, intensity, blurSize)
    self.fastBloom.threshhold = threshhold
    self.fastBloom.intensity = intensity
    self.fastBloom.blurSize = blurSize
    self.fastBloom.enabled = true
end

local ScreenEffectConfig = {
    Default = { -- 正常情况
        Bloom = {
            low = false,
            middle = false,
            high = true,
        },
        DepthOfField = {
            low = false,
            middle = false,
            high = false,
        },
        RadialBlur = {
            low = false,
            middle = false,
            high = false,
        }
    },
    Shoot = { -- 射门
        Bloom = {
            low = false,
            middle = false,
            high = true,
        },
        DepthOfField = {
            low = false,
            middle = false,
            high = false,
        },
        RadialBlur = {
            low = false,
            middle = false,
            high = true,
        }
    },
    DeadBall = { -- 死球后的特写
        Bloom = {
            low = false,
            middle = false,
            high = true,
        },
        DepthOfField = {
            low = false,
            middle = false,
            high = true,
        },
        RadialBlur = {
            low = false,
            middle = false,
            high = false,
        }
    },
}

function ScreenEffectManager:AppendEffect(situation, athleteIds)
    local param = {
        situation = situation,
        athleteIds = athleteIds,
    }
    table.insert(self.effectParams, param)
end

function ScreenEffectManager:ClearEffect()
    self.effectParams = {}
end

function ScreenEffectManager:RenderNextEffect()
    local param = table.remove(self.effectParams, 1)
    if not param then
        return
    end
    self:ApplyEffect(param.situation, param.athleteIds)
end

function ScreenEffectManager:ApplyEffect(situation, athleteIds)
    local nowConfig = ScreenEffectConfig[situation]
    if not device or not nowConfig then
        return
    end
    local bloomEnabled = nowConfig.Bloom[device.level]
    local dofEnabled = nowConfig.DepthOfField[device.level]
    local radialBlurEnabled = nowConfig.RadialBlur[device.level]

    if not dofEnabled then
        self.fxPro.enabled = false
        self.fxPro:GetComponent(Camera).depthTextureMode = DepthTextureMode.None
    else
        if athleteIds then
            local firstAthleteId = athleteIds[1]
            local playerName = GameHub.GetPlayerNameById(firstAthleteId)
            local targetObj = self.playerManager.___ex[string.lower(playerName)]
            if targetObj then
                self.fxPro.DOFParams.Target = targetObj.transform
            end
        end
        if self.fxPro.enabled then
            if self.fxPro.DOFEnabled ~= dofEnabled then
                self.fxPro.DOFEnabled = dofEnabled
                self.fxPro:InitDOF()
            end
        else
            self.fxPro.DOFEnabled = dofEnabled
            self.fxPro.enabled = true and (not ScreenEffectManager.fxProForbidden)
        end
    end
    self.fastBloom.enabled = bloomEnabled and (not ScreenEffectManager.bloomForbidden)
    self.radialBlur.enabled = radialBlurEnabled and (not ScreenEffectManager.blurForbidden)
end

return ScreenEffectManager
