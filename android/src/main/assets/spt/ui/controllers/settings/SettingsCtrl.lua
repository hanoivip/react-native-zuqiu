local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local AudioManager = require("unity.audio")

local SettingsCtrl = class()

function SettingsCtrl:ctor(data)
    self.data = data
    local settings, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Settings/Settings.prefab", "camera", true, true)
    self.settingsView = dialogcomp.contentcomp
    self.playerInfoModel = PlayerInfoModel.new()
    self.changeTeamNameCost = data.changeName

    self:InitView()
end

function SettingsCtrl:InitView()
    self.settingsView.onSetTeamName = function(teamName) self:OnSetTeamName(teamName) end
    self.settingsView.onSetTeamLogo = function() self:OnSetTeamLogo() end
    self.settingsView.onSetTeamHomeShirt = function() self:OnSetHomeTeamUniform() end
    self.settingsView.onSetTeamAwayShirt = function() self:OnSetAwayTeamUniform() end
    self.settingsView.onInitTeamLogo = function() self:OnInitTeamLogo(self.playerInfoModel:GetTeamLogo()) end
    self.settingsView.onRegisterListener = function() self:OnRegisterListener() end
    self.settingsView.onUnregisterListener = function() self:OnUnregisterListener() end
    self.settingsView.specialTeam = function(suitId) self:OnClickSpecialTeam(suitId) end
    self.settingsView:InitView(self.data)
end

function SettingsCtrl:OnSetTeamName(teamName)
    local currName = self.playerInfoModel:GetName()
    if teamName == currName then
        DialogManager.ShowToastByLang("settings_noChange")
        return
    end
    
    if self.changeTeamNameCost == 0 then
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("settings_changeNameFirst"), function ()
            clr.coroutine(function()
                local response = req.changeTeamName(teamName)
                if api.success(response) then
                    self.playerInfoModel:SetName(teamName)
                    clr.coroutine(function ()
                    local response = req.setting()
                        if api.success(response) then
                            local data = response.val
                            self.changeTeamNameCost = data.changeName
                        end
                    end)
                end
            end)
        end)
    else
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("settings_changeNameNoFirst", self.changeTeamNameCost), function ()
            clr.coroutine(function()
                local response = req.changeTeamName(teamName)
                if api.success(response) then
                    self.playerInfoModel:SetName(teamName)
                    self.playerInfoModel:SetDiamond(response.val.cost.curr_num)
                end
            end)
        end)
    end
end

function SettingsCtrl:OnSetTeamLogo()
    if self:IsSpecialSuit() then
        DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("set_spcialSuit_notice"))
        return
    end
    res.PushScene("ui.controllers.teamCreate.TeamLogoModifyCtrl")
end

function SettingsCtrl:OnSetTeamUniform(isHomeShirt)
    res.PushScene("ui.controllers.teamCreate.TeamUniformModifyCtrl", isHomeShirt)
end

function SettingsCtrl:OnSetHomeTeamUniform()
    if self:IsSpecialSuit() then
        DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("set_spcialSuit_notice"))
        return
    end
    self:OnSetTeamUniform(true)
end

function SettingsCtrl:OnSetAwayTeamUniform()
    if self:IsSpecialSuit() then
        DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("set_spcialSuit_notice"))
        return
    end
    self:OnSetTeamUniform(false)
end

function SettingsCtrl:OnInitTeamLogo(logoData)
    TeamLogoCtrl.BuildTeamLogo(self.settingsView:GetTeamLogoGameObject(), logoData)
end

function SettingsCtrl:OnInitHomeTeamUniform()
    self.view:InitTeamShirt(true)
end

function SettingsCtrl:OnInitAwayTeamUniform()
    self.view:InitTeamShirt(false)
end

function SettingsCtrl:OnTeamLogoChanged()
    self:OnInitTeamLogo(self.playerInfoModel:GetTeamLogo())    
end

function SettingsCtrl:OnHomeTeamUniformChanged()
    self.settingsView:InitTeamShirt(true)
end

function SettingsCtrl:OnAwayTeamUniformChanged()
    self.settingsView:InitTeamShirt(false)
end

function SettingsCtrl:OnRegisterListener()
    EventSystem.AddEvent("PlayerInfo", self, self.OnTeamLogoChanged)
    EventSystem.AddEvent("PlayerInfo", self, self.OnHomeTeamUniformChanged)
    EventSystem.AddEvent("PlayerInfo", self, self.OnAwayTeamUniformChanged)
    EventSystem.AddEvent("OnSetSpcialTeam", self, self.OnSetSpcialTeamEvent)
    cache.registerListener("keySettingsMusicOpen", function(key ,value)
        if value then
            AudioManager.SetAudioOnOff("music", value)
        end
    end, "keySettingsMusicOpen")
    cache.registerListener("keySettingsSoundEffectOpen", function(key, value)
        if value then
            AudioManager.SetAudioOnOff("", value)
        end
    end, "keySettingsSoundEffectOpen")
    cache.registerListener("keySettingsMusicVolume", function(key ,value)
        if value then
            AudioManager.SetAudioVolume("music", value)
        end
    end, "keySettingsMusicVolume")
    cache.registerListener("keySettingsSoundEffectVolume", function(key, value)
        if value then
            AudioManager.SetAudioVolume("", value)
        end
    end, "keySettingsSoundEffectVolume")
end

function SettingsCtrl:OnUnregisterListener()
    EventSystem.RemoveEvent("PlayerInfo", self, self.OnTeamLogoChanged)
    EventSystem.RemoveEvent("PlayerInfo", self, self.OnHomeTeamUniformChanged)
    EventSystem.RemoveEvent("PlayerInfo", self, self.OnAwayTeamUniformChanged)
    EventSystem.RemoveEvent("OnSetSpcialTeam", self, self.OnSetSpcialTeamEvent)
    cache.registerListener("keySettingsMusicOpen", nil, "keySettingsMusicOpen")
    cache.registerListener("keySettingsSoundEffectOpen", nil, "keySettingsSoundEffectOpen")
    cache.registerListener("keySettingsMusicVolume", nil, "keySettingsMusicVolume")
    cache.registerListener("keySettingsSoundEffectVolume", nil, "keySettingsSoundEffectVolume")
end

-- 恢复UI时，传入的参数
function SettingsCtrl:GetStatusData()
    return self.data
end

-- 点击设置套装
function SettingsCtrl:OnClickSpecialTeam(suitId)
    res.curSceneInfo.blur = nil
    res.PushScene("ui.controllers.settings.SpecialTeamCtrl", self.data, suitId)
end

-- 是否使用套装
function SettingsCtrl:IsSpecialSuit()
    return self.playerInfoModel:IsUseSpecificTeam()
end

-- 设置特殊套装
function SettingsCtrl:OnSetSpcialTeamEvent(value)
    self.data.logoShirt.useSpecific = value.useSpecific
    self.data.logoShirt.specificTeam = value.specificTeam
end

return SettingsCtrl
