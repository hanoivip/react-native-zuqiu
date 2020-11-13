local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LightmapData = UnityEngine.LightmapData
local LightmapSettings = UnityEngine.LightmapSettings
local Color = UnityEngine.Color
local WaitForSeconds = UnityEngine.WaitForSeconds
local Camera = UnityEngine.Camera
local Vector4 = UnityEngine.Vector4
local GameObject = UnityEngine.GameObject
local SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
local Time = UnityEngine.Time
local RenderSettings = UnityEngine.RenderSettings
local Toggle = UnityEngine.UI.Toggle
local Transform=UnityEngine.Transform

local WeatherConstParams = require("coregame.WeatherConstParams")
local ScreenEffectManager = require("coregame.ScreenEffectManager")
local HomeShirt = require("data.HomeShirt")
local AwayShirt = require("data.AwayShirt")
local GKShirt = require("data.GKShirt")
local ShirtMask = require("data.ShirtMask")
local InitTeam = require("data.InitTeam")
local InitShirt = require("data.InitShirt")
local TeamLogoColor = require("data.TeamLogoColor")
local ClothUtils = require("cloth.ClothUtils")
local QualitySetting=require("coregame.QualitySetting")

local shirtIDList = {}
local initShirtCount = 0
local function GetShirtList()
    for k, v in pairs(InitShirt) do
        table.insert(shirtIDList, k)
        initShirtCount = initShirtCount + 1
    end
    for k, v in pairs(HomeShirt) do
        table.insert(shirtIDList, k)
    end
    for k, v in pairs(TeamLogoColor) do
        v.mask = "Mask_02"
        table.insert(shirtIDList, k)
    end
end
GetShirtList()

local MatchMainDebugTools = class(unity.base)

local WeatherType = {
    "SummerSunny",
    "SummerNight",
    "WinterSunny",
    "WinterNight",
    "Rain",
    "Snow",
}

function MatchMainDebugTools:ctor()
    self.mainLight = self.___ex.mainLight
    self.playerManager = self.___ex.playerManager
    self.stadiumManager = self.___ex.stadiumManager
    self.screenEffectManager = self.___ex.screenEffectManager
    self.shadowManager = self.___ex.shadowManager
    self.bloom = self.___ex.bloom
    self.fxPro = self.___ex.fxPro

    -- UI
    self.btnTools = self.___ex.btnTools
    self.buttonsPanel = self.___ex.buttonsPanel

    self.showWeatherText = self.___ex.showWeatherText
    self.btnSwitchWeather = self.___ex.btnSwitchWeather
    self.lightPanel = self.___ex.lightPanel
    self.btnLight = self.___ex.btnLight

    self.colorPick = self.___ex.colorPick

    self.lightColorImage = self.___ex.lightColorImage
    self.btnLightColor = self.___ex.btnLightColor
    self.ambientImage = self.___ex.ambientImage
    self.btnAmbient = self.___ex.btnAmbient

    self.lightSlider = self.___ex.lightSlider
    self.lightSliderValue = self.___ex.lightSliderValue
    self.tuneSlider = self.___ex.tuneSlider
    self.tuneSliderValue = self.___ex.tuneSliderValue
    self.shadowSlider = self.___ex.shadowSlider
    self.shadowSliderValue = self.___ex.shadowSliderValue

    self.btnFxPro = self.___ex.btnFxPro
    self.fxProText = self.___ex.fxProText
    self.btnBloom = self.___ex.btnBloom
    self.bloomPanel = self.___ex.bloomPanel
    self.btnBloomSwitch = self.___ex.btnBloomSwitch
    self.bloomText = self.___ex.bloomText
    self.bloomThreshholdSlider = self.___ex.bloomThreshholdSlider
    self.bloomThreshholdSliderValue = self.___ex.bloomThreshholdSliderValue
    self.bloomIntensitySlider = self.___ex.bloomIntensitySlider
    self.bloomIntensitySliderValue = self.___ex.bloomIntensitySliderValue
    self.bloomBlurSizeSlider = self.___ex.bloomBlurSizeSlider
    self.bloomBlurSizeSliderValue = self.___ex.bloomBlurSizeSliderValue

    self.btnChangeCloth = self.___ex.btnChangeCloth
    self.textCloth = self.___ex.textCloth

    self.btnPause = self.___ex.btnPause

    self.btnSwitchBodyMesh = self.___ex.btnSwitchBodyMesh
    self.bodyMeshText = self.___ex.bodyMeshText

    self.btnGoal = self.___ex.btnGoal
    self.btnGoalText = self.___ex.btnGoalText

    self.btnQuality=self.___ex.btnQuality
    self.qualityPanel=self.___ex.qualityPanel
    self.switchShadow=self.___ex.switchShadow
    self.switchPlayer=self.___ex.switchPlayer
    self.switch=self.___ex.switch

    self.btnFog = self.___ex.btnFog
end

function MatchMainDebugTools:start()
    self:RegButton()
    self.weatherIndex = 5
    self.allPlayerList = self.playerManager.players
    self.allOpponentList = self.playerManager.opponents

    self.lightPanel:SetActive(false)
    self.buttonsPanel:SetActive(false)
    self.bloomPanel:SetActive(false)
    self.qualityPanel:SetActive(false)

    self.lightSlider.value = self.mainLight.intensity
    -- self.tuneSlider.value = 0.15

    self.bloomThreshholdSlider.value = self.bloom.threshhold
    self.bloomIntensitySlider.value = self.bloom.intensity
    self.bloomBlurSizeSlider.value = self.bloom.blurSize

    -- self:SetLight(0.8)
    -- self:SetTune(0.3)
    self.bloomOpen = self.bloom.enabled
end

function MatchMainDebugTools:RegButton()
    self.btnTools:regOnButtonClick(function()
        if self.toolsOpen then
            self.toolsOpen = false
            self.buttonsPanel:SetActive(false)
        else
            self.toolsOpen = true
            self.buttonsPanel:SetActive(true)
        end
    end)

    self.btnSwitchWeather:regOnButtonClick(function()
        self:OnBtnSwitchWeather()
    end)
    self.btnLight:regOnButtonClick(function()
        if self.lightPanelOpen then
            self.lightPanelOpen = false
            self.lightPanel:SetActive(false)
        else
            self.lightPanelOpen = true
            self.lightPanel:SetActive(true)
            self.lightColorImage.color = self.mainLight.color
            self.ambientImage.color = RenderSettings.ambientLight
        end
    end)

    self.btnLightColor:regOnButtonClick(function()
        self.colorPick.gameObject:SetActive(true)
        self.colorPick.Title.text = "LightColor"
        self.colorPick.InitColor(self.mainLight.color,
        function(color)
            self.mainLight.color = color
            self.lightColorImage.color = color
        end)
    end)
    self.btnAmbient:regOnButtonClick(function()
        self.colorPick.gameObject:SetActive(true)
        self.colorPick.Title.text = "AmbientLight"
        self.colorPick.InitColor(RenderSettings.ambientLight,
        function(color)
            RenderSettings.ambientLight = color
            self.ambientImage.color = color
        end)
    end)

    self.lightSlider.onValueChanged:AddListener(function(value)
        value = math.floor(value * 1000) / 1000
        self.lightSliderValue.text = tostring(value)
        self:SetLight(value)
    end)
    self.tuneSlider.onValueChanged:AddListener(function(value)
        value = math.floor(value * 1000) / 1000
        self.tuneSliderValue.text = tostring(value)
        self:SetTune(value)
    end)
    self.shadowSlider.onValueChanged:AddListener(function(value)
        value = math.floor(value * 1000) / 1000
        self.shadowSliderValue.text = tostring(value)
        self:SetShadow(value)        
    end)

    self.btnBloom:regOnButtonClick(function()
        if self.bloomPanelOpen then
            self.bloomPanelOpen = false
            self.bloomPanel:SetActive(false)
        else
            self.bloomPanelOpen = true
            self.bloomPanel:SetActive(true)
            self.bloomThreshholdSliderValue.text = tostring(math.floor(self.bloom.threshhold * 1000) / 1000)
            self.bloomIntensitySliderValue.text = tostring(math.floor(self.bloom.intensity * 1000) / 1000)
            self.bloomBlurSizeSliderValue.text = tostring(math.floor(self.bloom.blurSize * 1000) / 1000)
        end
    end)

    self.btnBloomSwitch:regOnButtonClick(function()
        if self.bloomOpen then
            self.bloomOpen = false
            self:SetBloom(false)
        else
            self.bloomOpen = true
            self:SetBloom(true)
        end
    end)
    self.bloomThreshholdSlider.onValueChanged:AddListener(function(value)
        if not self.bloomOpen then return end
        self.bloomThreshholdSliderValue.text = tostring(math.floor(value * 1000) / 1000)
        self.bloom.threshhold = value
    end)
    self.bloomIntensitySlider.onValueChanged:AddListener(function(value)
        if not self.bloomOpen then return end
        self.bloomIntensitySliderValue.text = tostring(math.floor(value * 1000) / 1000)
        self.bloom.intensity = value
    end)
    self.bloomBlurSizeSlider.onValueChanged:AddListener(function(value)
        if not self.bloomOpen then return end
        self.bloomBlurSizeSliderValue.text = tostring(math.floor(value * 1000) / 1000)
        self.bloom.blurSize = value
    end)

    self.btnFxPro:regOnButtonClick(function()
        if self.fxProOpen then
            self.fxProOpen = false
            self:SetFxPro(false)
        else
            self.fxProOpen = true
            self:SetFxPro(true)
        end
    end)

    self.btnChangeCloth:regOnButtonClick(function()
        self:OnBtnSwitchCloth()
    end)

    self.btnPause:regOnButtonClick(function()
        self.timeScale = Time.timeScale
        if self.timeScale == 0 then
            Time.timeScale = 1
        else
            Time.timeScale = 0
        end
    end)

    self.btnSwitchBodyMesh:regOnButtonClick(function()
        if self.bodyMeshHighQualilty then
            self.bodyMeshHighQualilty = false
            self:OnBtnSwitchBodyMesh(false)
        else
            self.bodyMeshHighQualilty = true
            self:OnBtnSwitchBodyMesh(true)
        end
    end)

    self.btnGoal:regOnButtonClick(function()
        ___matchUI:startMatchHighlightsPlayback()
    end)

    self.btnQuality:regOnButtonClick(function()
        if self.qualityPanelOpen then
            self.qualityPanelOpen = false
            self.qualityPanel:SetActive(false)
        else
            self.qualityPanelOpen = true
            self.qualityPanel:SetActive(true)
        end
    end)

    local switch = self.switch:GetComponent(Transform)
    if(switch) then
        for i=1,3 do
            local go = switch:GetChild(i-1).gameObject
            local toggle = go:GetComponent(Toggle)     
            toggle.onValueChanged:AddListener(function(isOn)
                self:OnValueChangedSwitch(isOn, go)
            end)
        end
    end

    local switchPlayer = self.switchPlayer:GetComponent(Transform)
    if(switchPlayer) then
        for i=1,3 do
            local go = switchPlayer:GetChild(i-1).gameObject
            local toggle = go:GetComponent(Toggle)     
            toggle.onValueChanged:AddListener(function(isOn)
                self:OnValueChangedSwitchPlayer(isOn, go)
            end)
        end
    end

    local switchShadow = self.switchShadow:GetComponent(Transform)
    if(switchShadow) then
        for i=1,3 do
            local go = switchShadow:GetChild(i-1).gameObject
            local toggle = go:GetComponent(Toggle)     
            toggle.onValueChanged:AddListener(function(isOn)
                self:OnValueChangedSwitchShadow(isOn, go)
            end)
        end
    end
    
    self.btnFog:regOnButtonClick(function()
        RenderSettings.fog = not RenderSettings.fog
    end)
end

-- 切换天气
function MatchMainDebugTools:OnBtnSwitchWeather()
    self.weatherIndex = math.fmod(self.weatherIndex + 1, #WeatherType)
    local weather = WeatherType[self.weatherIndex + 1]
    dump(weather)
    WeatherConstParams.currentWeather = weather
    self:SwitchWeather(weather)
end

function MatchMainDebugTools:SwitchWeather(weather)
    self.showWeatherText.text = weather
    self.stadiumManager:ClearOtherWeatherEffect()
    self.stadiumManager:setWeather(weather)
    local weatherParams = WeatherConstParams[weather]
    self.screenEffectManager:SetBloomParams(weatherParams.BloomThreshhold, weatherParams.BloomIntensity, weatherParams.BloomBlurSize)
    self.shadowManager:SetShadowIntensity(weatherParams.ShodowIntensity)
end

-- 修改阴影的强度
function MatchMainDebugTools:SetShadow(intensity)
    self.shadowManager:SetShadowIntensity(intensity)
end

-- 改变衣服材质的Tune值（明暗对比，主要是背光面的亮度）
function MatchMainDebugTools:SetTune(tune)
end

-- 改变光照强度
function MatchMainDebugTools:SetLight(intensity)
    intensity = tonumber(intensity)
    self.mainLight.intensity = intensity
end

-- bloom
function MatchMainDebugTools:SetBloom(isOpen)
    self.bloom.enabled = isOpen
    ScreenEffectManager.bloomForbidden = not isOpen
    self.bloomText.text = "Bloom " .. tostring(isOpen)
end

-- fxPro
function MatchMainDebugTools:SetFxPro(isOpen)
    if not isOpen then
        self.fxPro.enabled = false
    end
    ScreenEffectManager.fxProForbidden = not isOpen
    self.fxProText.text = "FxPro " .. tostring(isOpen)
end

-- 判断mask遮罩是否为大辅色
local function IsMaskBigAssistColor(mask)
    assert(type(mask) == "string")
    local maskTable = ShirtMask[mask]
    return maskTable and (tonumber(maskTable.assistColour) == 1) or false
end

local function IsCloseShirtColor(aShirt, aIsBigAssistColor, bShirt, bIsBigAssistColor)
    if aIsBigAssistColor and bIsBigAssistColor then
        -- 均为大辅色球衣
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskRedChannel), ClothUtils.parseColorString(bShirt.maskRedChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskRedChannel), ClothUtils.parseColorString(bShirt.maskGreenChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskGreenChannel), ClothUtils.parseColorString(bShirt.maskRedChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskGreenChannel), ClothUtils.parseColorString(bShirt.maskGreenChannel)) then
            return true
        end

        return false
    elseif aIsBigAssistColor or bIsBigAssistColor then
        -- 只有一方为大辅色，另一方为小辅色
        local tmpBigAssistShirt
        local tmpAnotherShirt
        if aIsBigAssistColor then
            tmpBigAssistShirt = aShirt
            tmpAnotherShirt = bShirt
        else
            tmpBigAssistShirt = bShirt
            tmpAnotherShirt = aShirt
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(tmpBigAssistShirt.maskRedChannel), ClothUtils.parseColorString(tmpAnotherShirt.maskRedChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(tmpBigAssistShirt.maskGreenChannel), ClothUtils.parseColorString(tmpAnotherShirt.maskRedChannel)) then
            return true
        end

        return false
    elseif not aIsBigAssistColor and not bIsBigAssistColor then
        -- 均为小辅色
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskRedChannel), ClothUtils.parseColorString(bShirt.maskRedChannel)) then
            return true
        end

        return false
    end
end

function MatchMainDebugTools:OnBtnSwitchCloth()
    if not self.clothIndex then
        self.clothIndex = 0
    else
        self.clothIndex = math.fmod(self.clothIndex + 1, #shirtIDList)
    end
    local shirtID = shirtIDList[self.clothIndex + 1]
    self:SetOpponentCloth(shirtID)
end

-- 更换对手的球衣
function MatchMainDebugTools:SetOpponentCloth(shirtID)
    self.textCloth.text = shirtID .. "=>" .. tostring(self.clothIndex + 1)
    self.playerManager.opponentTeamData.currentUseShirt = (InitShirt[shirtID] or HomeShirt[shirtID]) or TeamLogoColor[shirtID]

    local playerShirt = self.playerManager.playerTeamData.currentUseShirt
    local opponentShirt = self.playerManager.opponentTeamData.currentUseShirt
    local isPlayerShirtBigAssistColor = IsMaskBigAssistColor(playerShirt.mask)
    local isOpponentBigAssistColor = IsMaskBigAssistColor(opponentShirt.mask)
    local isCloseColorCloth = IsCloseShirtColor(playerShirt, isPlayerShirtBigAssistColor, opponentShirt, isOpponentBigAssistColor)
    dump(tostring(isPlayerShirtBigAssistColor) .. "--" .. tostring(isOpponentBigAssistColor))
    dump(playerShirt)
    dump(opponentShirt)
    dump("Is Close Shirt : " .. tostring(isCloseColorCloth))

    self.playerManager:initKit()
end

function MatchMainDebugTools:OnBtnSwitchBodyMesh(isHigh)
    self.bodyMeshText.text = "Mesh " .. (isHigh and "High" or "Low")
    self:SwitchBodyMesh(isHigh)
end

-- 切换高低模
function MatchMainDebugTools:SwitchBodyMesh(isHigh)
    self.playerManager:ChangeBodyMesh(isHigh and self.___ex.bodyLOD1Mesh or self.___ex.bodyLOD2Mesh)
end

function MatchMainDebugTools:onDestroy()
    -- 释放引用的资源
    self.___ex.bodyLOD1Mesh = nil
    self.___ex.bodyLOD2Mesh = nil
end

--切换画质
function MatchMainDebugTools:OnValueChangedSwitch(isOn, sender)  
    if sender.name == "High" and isOn then
        self:SwitchQuality("high")
    elseif sender.name == "Middle" and isOn then
        self:SwitchQuality("middle")
    elseif sender.name == "Low" and isOn  then
        self:SwitchQuality("low")
    end
end

--切换球员材质
function MatchMainDebugTools:OnValueChangedSwitchPlayer(isOn, sender)  
    if sender.name == "High" and isOn then
        self:SwitchPlayerMatQuality("high")
    elseif sender.name == "Middle" and isOn then
        self:SwitchPlayerMatQuality("middle")
    elseif sender.name == "Low" and isOn then
        self:SwitchPlayerMatQuality("low")
    end
end

--切换影子质量
function MatchMainDebugTools:OnValueChangedSwitchShadow(isOn, sender)  
    if sender.name == "High" and isOn then
        self:SwitchShadowQuality("high")
    elseif sender.name == "Middle" and isOn then
        self:SwitchShadowQuality("middle")
    elseif sender.name == "Low" and isOn then
        self:SwitchShadowQuality("low")
    end
end

function  MatchMainDebugTools:SwitchQuality(level)
    self.playerManager:SwitchMaterialLevel(level)
    self.shadowManager:SwitchShadowQuality(level)
end

function  MatchMainDebugTools:SwitchPlayerMatQuality(level)
    self.playerManager:SwitchMaterialLevel(level)
end

function  MatchMainDebugTools:SwitchShadowQuality(level)
    self.shadowManager:SwitchShadowQuality(level)
end


return MatchMainDebugTools
