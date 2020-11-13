local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")


local SettingsLanguageView = class(unity.base)

function SettingsLanguageView:ctor()
    self.langToggle = self.___ex.langToggle
end

function SettingsLanguageView:InitView(settingsLanguageModel)
    self.settingsLanguageModel = settingsLanguageModel
    self.langToggle[settingsLanguageModel:GetDeviceLanguage()].isOn = true
    self:SetLangStates(settingsLanguageModel)
end

function SettingsLanguageView:SetLangStates(settingsLanguageModel)
    for k,v in pairs(self.langToggle) do
        GameObjectHelper.FastSetActive(v.gameObject, settingsLanguageModel.LangIsShow[k])
    end
end

function SettingsLanguageView:GetLanguageStatue()
    for k,v in pairs(self.langToggle) do
        if v.isOn then
            return k
        end
    end
end


return SettingsLanguageView