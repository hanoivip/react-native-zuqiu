local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local CourtPageCtrl = require("ui.controllers.court.technologyHall.CourtPageCtrl")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CourtDisplayCtrl = class(BaseCtrl)

CourtDisplayCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/CourtDisplay.prefab"

function CourtDisplayCtrl:Init()
    self.view.clickGrass = function(settingType) self:OnClickGrass(settingType) end
    self.view.clickWeather = function(settingType) self:OnClickWeather(settingType) end
    self.view.showCourt = function() self:ShowCourt() end
end

function CourtDisplayCtrl:Refresh(courtBuildModel, technologySettingConfig)
    CourtDisplayCtrl.super.Refresh(self)
    self.technologySettingConfig = technologySettingConfig
    self.view:InitView(courtBuildModel)
end

function CourtDisplayCtrl:OnEnterScene()
    self.view:EnterScene()
end

function CourtDisplayCtrl:OnExitScene()
    self.view:ExitScene()
end

function CourtDisplayCtrl:ShowPageVisible(isVisible)
    self.view:ShowPageVisible(isVisible)
end

function CourtDisplayCtrl:OnClickGrass(settingType)
    res.PushDialog("ui.controllers.court.technologyHall.SettingDisplayCtrl", settingType, TechnologyDevelopType.GrassType)
    self:ShowPageVisible(false)
end

function CourtDisplayCtrl:OnClickWeather(settingType)
    res.PushDialog("ui.controllers.court.technologyHall.SettingDisplayCtrl", settingType, TechnologyDevelopType.WeatherType)
    self:ShowPageVisible(false)
end

function CourtDisplayCtrl:ShowCourt()
    if not self.courtPageCtrl then 
        self.courtPageCtrl = CourtPageCtrl.new(nil, self.view.pageArea, self.technologySettingConfig)
        self.courtPageCtrl:EnterScene()
    end
    self.courtPageCtrl:ShowPageVisible(true)
    self.courtBuildModel = CourtBuildModel.new()
    self.courtPageCtrl:InitView(self.courtBuildModel)
end

return CourtDisplayCtrl