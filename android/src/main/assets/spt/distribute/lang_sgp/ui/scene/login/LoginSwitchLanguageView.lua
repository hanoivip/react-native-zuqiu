local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LoginSwitchLanguageView = class(unity.base)

function LoginSwitchLanguageView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.langToggle = self.___ex.langToggle
    self.saveBtn = self.___ex.saveBtn
    self.selectTip = self.___ex.selectTip
    self.mTitle = self.___ex.mTitle
    self.mSave = self.___ex.mSave
end

function LoginSwitchLanguageView:RegButtonClick()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.saveBtn:regOnButtonClick(function()
        if self.onSetLangFlag then
            self.onSetLangFlag()
        end
    end)
    for k,v in pairs(self.langToggle) do
        v.onValueChanged:AddListener(function (isOn)
            if isOn then
                if not self.settingsLanguageModel:IsFirstLogin() then return end
                self:ResetText(k)
            end
        end)
    end
end

function LoginSwitchLanguageView:SetLangStates()
    for k,v in pairs(self.langToggle) do
        GameObjectHelper.FastSetActive(v.gameObject, self.settingsLanguageModel.LangIsShow[k])
    end
end

function LoginSwitchLanguageView:InitView(settingsLanguageModel)
    self.settingsLanguageModel = settingsLanguageModel
    self.langToggle[settingsLanguageModel:GetDeviceLanguage()].isOn = true
    GameObjectHelper.FastSetActive(self.closeBtn.gameObject, not settingsLanguageModel:IsFirstLogin())
    self:ResetText(settingsLanguageModel:GetDeviceLanguage())
    self:SetLangStates()
    self:RegButtonClick()
end

function LoginSwitchLanguageView:ResetText(langId)
    langId = langId or "sgp"
    self.selectTip.text = self.settingsLanguageModel:GetNormalText(self.settingsLanguageModel:IsFirstLogin() and lang.transstr("settings_language_choose_tip1") or lang.transstr("settings_language_choose_tip2"), langId)
    self.mTitle.text = self.settingsLanguageModel:GetNormalText(lang.transstr("settings_language_choose_title"), langId)
    self.mSave.text = self.settingsLanguageModel:GetNormalText(lang.transstr("settings_language_choose"), langId)
end

function LoginSwitchLanguageView:GetLanguageStatue()
    for k,v in pairs(self.langToggle) do
        if v.isOn then
            return k
        end
    end
end

function LoginSwitchLanguageView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return LoginSwitchLanguageView

