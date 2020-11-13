local SettingsLanguageModel = require("ui.models.settings.SettingsLanguageModel")
local DialogManager = require("ui.control.manager.DialogManager")
local SettingsLanguageCtrl = class()

function SettingsLanguageCtrl:ctor(contentView, data)
    self.data = data
    self.view = contentView
    self:InitView()
end

function SettingsLanguageCtrl:InitView()
    self.settingsLanguageModel = SettingsLanguageModel.new(self.data)
    self.view:InitView(self.settingsLanguageModel)
end

function SettingsLanguageCtrl:SetLangFlag()
    local mLangId = self.view:GetLanguageStatue()
    local isNormal = self.settingsLanguageModel:LangIsNormal(mLangId)
    if isNormal then
        DialogManager.ShowToastByLang("settings_modifySuccess")
        return
    end
    self.settingsLanguageModel:ChangeLanguage(mLangId)
    clr.coroutine(function()
        local response = req.setLang(self.settingsLanguageModel:GetLang2Server(mLangId))
        if api.success(response) then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("settings_language_tip"), function ()
                unity.restart()
            end)
        end
    end)
end

return SettingsLanguageCtrl
