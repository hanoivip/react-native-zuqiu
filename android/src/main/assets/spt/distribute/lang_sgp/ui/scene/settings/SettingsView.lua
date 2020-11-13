local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Regex = clr.System.Text.RegularExpressions.Regex
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local TeamUniformModel  = require("ui.models.common.TeamUniformModel")
local ClothUtils = require("cloth.ClothUtils")
local UISoundManager = require("ui.control.manager.UISoundManager")
local MatchUseShirtType = require("coregame.MatchUseShirtType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local QualitySetting = require("coregame.QualitySetting")

local SettingsView = class(unity.base)

local SWITCHTYPE = {
    CLOSE = 0,
    OPEN = 1
}

function SettingsView:ctor()
    self.btnClose = self.___ex.btnClose
    self.btnSetTeamName = self.___ex.btnSetTeamName
    self.btnSetTeamLogo = self.___ex.btnSetTeamLogo
    self.btnSetTeamHomeShirt = self.___ex.btnSetTeamHomeShirt
    self.btnSetTeamAwayShirt = self.___ex.btnSetTeamAwayShirt
    -- 队徽
    self.teamLogo = self.___ex.teamLogo
    -- 队名
    self.teamName = self.___ex.teamName
    -- 背景音滑动条
    self.musicSlider = self.___ex.musicSlider
    self.musicSliderListener = self.___ex.musicSliderListener
    -- 音效音滑动条
    self.soundEffectSlider = self.___ex.soundEffectSlider
    self.soundEffectSliderListener = self.___ex.soundEffectSliderListener
    -- 声音保存按钮
    self.btnSoundSave = self.___ex.btnSoundSave
    -- 背景音音量文本
    self.musicProgressText = self.___ex.musicProgressText
    -- 音效音音量文本
    self.soundEffectProgressText = self.___ex.soundEffectProgressText
    -- 背景音开关按钮
    self.btnMusicSwitch = self.___ex.btnMusicSwitch
    -- 音效开关按钮
    self.btnSoundEffectSwitch = self.___ex.btnSoundEffectSwitch
    -- 背景音开图标
    self.musicOpenImage = self.___ex.musicOpenImage
    -- 背景音关图标
    self.musicCloseImage = self.___ex.musicCloseImage
    -- 音效音开图标
    self.soundEffectOpenImage = self.___ex.soundEffectOpenImage
    -- 音效音关图标
    self.soundEffectCloseImage = self.___ex.soundEffectCloseImage
    -- 主场队服
    self.teamHomeShirt = self.___ex.teamHomeShirt
    -- 客场队服
    self.teamAwayShirt = self.___ex.teamAwayShirt
    -- 背景音开关状态
    self.musicState = SWITCHTYPE.OPEN
    -- 音效音开关状态
    self.soundEffectState = SWITCHTYPE.OPEN
    self.canvasGroup = self.___ex.canvasGroup
    self.shareToggle = self.___ex.shareToggle
    self.isOpenTxt = self.___ex.isOpenTxt
    self.shareHanle = self.___ex.shareHanle
    self.qualitySlider = self.___ex.qualitySlider
    self.maxVolume = 1
    self.UIClothBase = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/UISmallCloth/UIClothBase.mat")
    self.playerInfoModel = nil

    -- 特殊套装
    self.specialSuitBtn = self.___ex.specialSuitBtn
    self.specialBtn = self.___ex.specialBtn
    self.scrollRect = self.___ex.scrollRect
    self.leftPageBtn = self.___ex.leftPageBtn
    self.rightPageBtn = self.___ex.rightPageBtn
    self.speBtnTxt = self.___ex.speBtnTxt
    self.realMadridBtn = self.___ex.realMadridBtn
    self.languageSettingView = self.___ex.languageSettingView

    GameObjectHelper.FastSetActive(self.leftPageBtn.gameObject, false)
end

function SettingsView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    -- 保存声音
    self.btnSoundSave:regOnButtonClick(function()
        UISoundManager.play("Player/encourageSound", 1)
        self:OnSoundSave()
        if self.onSetLangFlag then
            self.onSetLangFlag()
        end
    end)
    -- 设置队名
    self.btnSetTeamName:regOnButtonClick(function()
        if self.onSetTeamName then
            local name = Regex.Replace(self.teamName.text, "\\p{Cs}", "")
            self.onSetTeamName(name)
        end
    end)
    -- 设置队徽
    self.btnSetTeamLogo:regOnButtonClick(function()
        if self.onSetTeamLogo then
            self.onSetTeamLogo()
        end
    end)
    -- 设置主场队服
    self.btnSetTeamHomeShirt:regOnButtonClick(function()
        if self.onSetTeamHomeShirt then
            self.onSetTeamHomeShirt()
        end
    end)
    -- 设置客场队服
    self.btnSetTeamAwayShirt:regOnButtonClick(function()
        if self.onSetTeamAwayShirt then
            self.onSetTeamAwayShirt()
        end
    end)
    -- 开关背景音
    self.btnMusicSwitch:regOnButtonClick(function()
        self:OnMusicSwitch()
    end)
    -- 开关音效
    self.btnSoundEffectSwitch:regOnButtonClick(function()
        self:OnSoundEffectSwitch()
    end)

    self.musicSliderListener:regOnEndDrag(function ()
        UISoundManager.play("Match/tacticsSlider", 1)
    end)
    self.soundEffectSliderListener:regOnEndDrag(function ()
        UISoundManager.play("Match/tacticsSlider", 1)
    end)

    -- 翻页
    self.leftPageBtn:regOnButtonClick(function()
        self:SwitchPage(0)
    end)
    self.rightPageBtn:regOnButtonClick(function()
        self:SwitchPage(1)
    end)
    -- 拜仁
    self.specialBtn:regOnButtonClick(function()
        if type(self.specialTeam) == "function" then
            self.specialTeam("Bayern")
        end
    end)
    -- 皇马
    self.realMadridBtn:regOnButtonClick(function ()
        if type(self.specialTeam) == "function" then
            self.specialTeam("RealMadrid")
        end
    end)

    self.shareToggle.onValueChanged:AddListener(function (isOn)
        if isOn then
            self.shareHanle.localPosition = Vector3(22.5, 0, 0)
            self.isOpenTxt.text = lang.trans("settings_hasopen")
        else
            self.shareHanle.localPosition = Vector3(-18.02, 0, 0)
            self.isOpenTxt.text = lang.trans("settings_nopen")
        end
        self.isOpenRealTimeVideo = isOn
    end)

    if self.onRegisterListener then
        self.onRegisterListener()
    end
    self.musicSlider.onValueChanged:AddListener(function(value) self:OnMusicSliderValueChanged(value) end)
    self.soundEffectSlider.onValueChanged:AddListener(function(value) self:OnSoundEffectSliderValueChanged(value) end)
    self.qualitySlider.onValueChanged:AddListener(function (value)
        if value == 0 then
            self.qualityLevel = "low"
        elseif value == 1 then
            self.qualityLevel = "middle"
        elseif value == 2 then
            self.qualityLevel = "high"
        end
    end)
    self:PlayInAnimator()
end

function SettingsView:InitView(data)
    self.data = data
    self.playerInfoModel = PlayerInfoModel.new()
    self.teamName.text = self.playerInfoModel:GetName()
    self:InitTeamLogo()
    self:InitTeamShirt(true)
    self:InitTeamShirt(false)
    self:InitSoundSettings()
    self:InitSpecificTeam(self.data)
    local quality = QualitySetting.GetLevel()
    if quality == "low" then
        self.qualitySlider.value = 0
    elseif quality == "middle" then
        self.qualitySlider.value = 1
    elseif quality == "high" then
        self.qualitySlider.value = 2
    end
    local isOpenRealTimeVideo = cache.getIsOpenRealTimeVideo()
    self.shareToggle.isOn = isOpenRealTimeVideo or false
    if not self.shareToggle.isOn then
        self.shareHanle.localPosition = Vector3(-18.02, 0, 0)
        self.isOpenTxt.text = lang.trans("settings_nopen")
    end
end

-- 初始化声音设置
function SettingsView:InitSoundSettings()
    self.musicState = cache.getLocalData("keySettingsMusicOpen") or SWITCHTYPE.OPEN
    self.soundEffectState = cache.getLocalData("keySettingsSoundEffectOpen") or SWITCHTYPE.OPEN
    self.qualityLevel = QualitySetting.GetLevel()
    self.isOpenRealTimeVideo = cache.getIsOpenRealTimeVideo or false
    self:InitMusicSwitchImage()
    self:InitSoundEffectSwitchImage()
    self:InitMusicSlider()
    self:InitSoundEffectSlider()
end

-- 初始化背景音开关图标
function SettingsView:InitMusicSwitchImage()
    -- local musicState = cache.getLocalData("keySettingsMusicOpen") or SWITCHTYPE.OPEN
    if self.musicState == SWITCHTYPE.OPEN then
        self.musicOpenImage:SetActive(true)
        self.musicCloseImage:SetActive(false)
    else
        self.musicCloseImage:SetActive(true)
        self.musicOpenImage:SetActive(false)
    end
end

-- 初始化音效音开关图标
function SettingsView:InitSoundEffectSwitchImage()
    -- local soundEffectState = cache.getLocalData("keySettingsSoundEffectOpen") or SWITCHTYPE.OPEN
    if self.soundEffectState == SWITCHTYPE.OPEN then
        self.soundEffectOpenImage:SetActive(true)
        self.soundEffectCloseImage:SetActive(false)
    else
        self.soundEffectCloseImage:SetActive(true)
        self.soundEffectOpenImage:SetActive(false)
    end
end

-- 初始化背景音滑动条
function SettingsView:InitMusicSlider()
    local musicVolume = cache.getLocalData("keySettingsMusicVolume") or self.maxVolume
    self.musicSlider.value = musicVolume
    self:OnMusicSliderValueChanged(self.musicSlider.value)
    self:InitMusicSliderState()
end

-- 初始化音效音滑动条
function SettingsView:InitSoundEffectSlider()
    local soundEffectVolume = cache.getLocalData("keySettingsSoundEffectVolume") or self.maxVolume
    self.soundEffectSlider.value = soundEffectVolume
    self:OnSoundEffectSliderValueChanged(self.soundEffectSlider.value)
    self:InitSoundEffectSliderState()
end

-- 初始化背景音滑动条状态
function SettingsView:InitMusicSliderState()
    -- self.musicState = cache.getLocalData("keySettingsMusicOpen") or SWITCHTYPE.OPEN
    if self.musicState == SWITCHTYPE.OPEN then
        self.musicSlider.interactable = true
    else
        self.musicSlider.interactable = false
    end
end

-- 初始化音效音滑动条状态
function SettingsView:InitSoundEffectSliderState()
    -- self.soundEffectState = cache.getLocalData("keySettingsSoundEffectOpen") or SWITCHTYPE.OPEN
    if self.soundEffectState == SWITCHTYPE.OPEN then
        self.soundEffectSlider.interactable = true
    else
        self.soundEffectSlider.interactable = false
    end
end

-- 背景音开关按钮
function SettingsView:OnMusicSwitch()
    -- local musicState = cache.getLocalData("keySettingsMusicOpen") or SWITCHTYPE.OPEN
    if self.musicState == SWITCHTYPE.OPEN then
        self.musicState = SWITCHTYPE.CLOSE
        -- cache.setLocalData("keySettingsMusicOpen", SWITCHTYPE.CLOSE, true)
    else
        self.musicState = SWITCHTYPE.OPEN
        -- cache.setLocalData("keySettingsMusicOpen", SWITCHTYPE.OPEN, true)
    end
    self:InitMusicSwitchImage()
    self:InitMusicSliderState()
end

-- 音效音开关按钮
function SettingsView:OnSoundEffectSwitch()
    -- local soundEffectState = cache.getLocalData("keySettingsSoundEffectOpen") or SWITCHTYPE.OPEN
    if self.soundEffectState == SWITCHTYPE.OPEN then
        self.soundEffectState = SWITCHTYPE.CLOSE
        -- cache.setLocalData("keySettingsSoundEffectOpen", SWITCHTYPE.CLOSE, true)
    else
        self.soundEffectState = SWITCHTYPE.OPEN
        -- cache.setLocalData("keySettingsSoundEffectOpen", SWITCHTYPE.OPEN, true)
    end
    self:InitSoundEffectSwitchImage()
    self:InitSoundEffectSliderState()
end

-- 背景音滑动条值改变监听函数
function SettingsView:OnMusicSliderValueChanged(value)
    -- cache.setLocalData("keySettingsMusicVolume", value, true)
    self.musicProgressText.text = tostring(math.floor(value * 100)) .. "%"
end

-- 音效音音滑动条值改变监听函数
function SettingsView:OnSoundEffectSliderValueChanged(value)
    -- cache.setLocalData("keySettingsSoundEffectVolume", value, true)
    self.soundEffectProgressText.text = tostring(math.floor(value * 100)) .. "%"
end

-- 初始化队徽
function SettingsView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

-- 初始化队服
function SettingsView:InitTeamShirt(isHomeShirt)
    if self.playerInfoModel:IsUseSpecificTeam() then
        local specificTeam = self.playerInfoModel:GetSpecificTeam()
        local SpecificTeamData = require("cloth.SpecificTeamData")
        if isHomeShirt then
            self.teamHomeShirt.material = clr.null
            self.teamHomeShirt.overrideSprite = res.LoadRes(SpecificTeamData[specificTeam].resMap[MatchUseShirtType.HOME].smallCloth)
        else
            self.teamAwayShirt.material = clr.null
            self.teamAwayShirt.overrideSprite = res.LoadRes(SpecificTeamData[specificTeam].resMap[MatchUseShirtType.AWAY].smallCloth)
        end
    else
        local mat = Object.Instantiate(self.UIClothBase)
        local shirt = nil
        if isHomeShirt then
            shirt = self.playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Home)
        else
            shirt = self.playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Away)
        end
        local maskName = "Small" .. shirt.mask
        local maskPath = "Assets/CapstonesRes/Game/UI/Common/UISmallCloth/Mask/" .. maskName .. "/" .. maskName .. ".png"
        mat:SetTexture("_Mask", res.LoadRes(maskPath))
        mat:SetColor("_MaskRedChannel", ClothUtils.parseColorString(shirt.maskRedChannel))
        mat:SetColor("_MaskGreenChannel", ClothUtils.parseColorString(shirt.maskGreenChannel))
        mat:SetColor("_MaskBlueChannel", ClothUtils.parseColorString(shirt.maskBlueChannel))

        if isHomeShirt then
            self.teamHomeShirt.material = mat
            self.teamHomeShirt.sprite = clr.null
        else
            self.teamAwayShirt.material = mat
            self.teamAwayShirt.sprite = clr.null
        end
    end
end

function SettingsView:GetTeamLogoGameObject()
    return self.teamLogo
end

function SettingsView:OnSoundSave()
    cache.setLocalData("keySettingsMusicOpen", self.musicState, true)
    cache.setLocalData("keySettingsSoundEffectOpen", self.soundEffectState, true)
    cache.setLocalData("keySettingsMusicVolume", self.musicSlider.value, true)
    cache.setLocalData("keySettingsSoundEffectVolume", self.soundEffectSlider.value, true)
    QualitySetting.SwitchQuality(self.qualityLevel)
    cache.setIsOpenRealTimeVideo(self.isOpenRealTimeVideo)
    -- DialogManager.ShowToastByLang("settings_modifySuccess")
end

function SettingsView:onDestroy()
    if self.onUnregisterListener then
        self.onUnregisterListener()
    end
end

function SettingsView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function SettingsView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function SettingsView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function SettingsView:Close()
    self:PlayOutAnimator()
end

-- 翻页 
-- @param index 0:向左 1:向右
function SettingsView:SwitchPage(index)
    local isLeftSwitchClick = index == 0
    GameObjectHelper.FastSetActive(self.leftPageBtn.gameObject, not isLeftSwitchClick)
    GameObjectHelper.FastSetActive(self.rightPageBtn.gameObject, isLeftSwitchClick)
    if index == 0 then
        self.scrollRect.anchoredPosition = Vector2(0, self.scrollRect.anchoredPosition.y)
    else
        self.scrollRect.anchoredPosition = Vector2(-353.4, self.scrollRect.anchoredPosition.y)
    end
end

-- 初始化 套装
function SettingsView:InitSpecificTeam(data)
    if next(data.logoShirt.specificTeam) then
        for k, v in pairs(data.logoShirt.specificTeam) do
            if k == "Bayern" then
                GameObjectHelper.FastSetActive(self.specialSuitBtn, true)
            elseif k == "RealMadrid" then
                GameObjectHelper.FastSetActive(self.realMadridBtn.gameObject, true)
            end
        end
    else
        GameObjectHelper.FastSetActive(self.leftPageBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.rightPageBtn.gameObject, false)
    end
    -- local suitSize = table.nums(data.logoShirt.specificTeam)
    -- if suitSize == 0 then
    --     GameObjectHelper.FastSetActive(self.specialSuitBtn, false)
    --     GameObjectHelper.FastSetActive(self.leftPageBtn.gameObject, false)
    --     GameObjectHelper.FastSetActive(self.rightPageBtn.gameObject, false)
    -- else
    --     self.speBtnTxt.text = lang.trans("set_spcialTeam")
    -- end
end

return SettingsView
