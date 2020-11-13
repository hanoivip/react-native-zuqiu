local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local CourtPageCtrl = class(nil, "CourtPageCtrl")

function CourtPageCtrl:ctor(view, content, technologySettingConfig)
    self:Init(content, technologySettingConfig)
end

function CourtPageCtrl:Init(content, technologySettingConfig)
    self.technologySettingConfig = technologySettingConfig
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/CourtCenter.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickGrass = function(settingType) self:OnClickGrass(settingType) end
    self.pageView.clickWeather = function(settingType) self:OnClickWeather(settingType) end
end

function CourtPageCtrl:EnterScene()
end

function CourtPageCtrl:ExitScene()
end

function CourtPageCtrl:InitView(courtBuildModel)
    self.pageView:InitView(courtBuildModel, self.technologySettingConfig)
end

function CourtPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

function CourtPageCtrl:OnClickGrass(settingType)
    res.PushDialog("ui.controllers.court.technologyHall.SettingDisplayCtrl", settingType, TechnologyDevelopType.GrassType)
    EventSystem.SendEvent("DisableTechnologyHall")
end

function CourtPageCtrl:OnClickWeather(settingType)
    res.PushDialog("ui.controllers.court.technologyHall.SettingDisplayCtrl", settingType, TechnologyDevelopType.WeatherType)
    EventSystem.SendEvent("DisableTechnologyHall")
end

return CourtPageCtrl
