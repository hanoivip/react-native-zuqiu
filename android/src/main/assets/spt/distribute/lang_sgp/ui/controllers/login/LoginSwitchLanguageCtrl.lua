local SettingsLanguageModel = require("ui.models.settings.SettingsLanguageModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local LoginSwitchLanguageCtrl = class(BaseCtrl)

LoginSwitchLanguageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Login/LangSwitcher.prefab"

LoginSwitchLanguageCtrl.dialogStatus = {
    touchClose = false,
    withShadow = false,
    unblockRaycast = false,
}

function LoginSwitchLanguageCtrl:Init()
    self.settingsLanguageModel = SettingsLanguageModel.new()
    self.view:InitView(self.settingsLanguageModel)
    self.view.onSetLangFlag = function()
        self:SetLangFlag()
    end
end

function LoginSwitchLanguageCtrl:SwitchLanguage(title, mTip, mLangId)
    DialogManager.ShowConfirmPop(title, mTip, function ()
        self.view:coroutine(function()
            self.settingsLanguageModel:ChangeLanguage(mLangId)
            coroutine.yield(clr.UnityEngine.WaitForSeconds(1))
            unity.restart()
        end)
    end)
end

function LoginSwitchLanguageCtrl:SetLangFlag()
    local mLangId = self.view:GetLanguageStatue()
    local isNormal = self.settingsLanguageModel:LangIsNormal(mLangId)

    if isNormal then
        DialogManager.ShowToastByLang("settings_modifySuccess")
        self.view:Close()
        return
    end

    if self.settingsLanguageModel:IsFirstLogin() then
        local title = self.settingsLanguageModel:GetNormalText(lang.transstr("settings_language_tips_title"), mLangId)
        local mTip = lang.transstr("settings_language_first_tip", lang.transstr("settings_language_cn"), lang.transstr("settings_language_en"), lang.transstr("settings_language_th"))
        mTip = self.settingsLanguageModel:GetNormalText(mTip, mLangId)
        self:SwitchLanguage(title, mTip, mLangId)
        return
    end

    self.settingsLanguageModel:ChangeLanguage(mLangId)
    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("settings_language_tip"), function ()
        unity.restart()
    end)
end

return LoginSwitchLanguageCtrl
