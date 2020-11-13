local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local WeatherPageCtrl = class(nil, "WeatherPageCtrl")

function WeatherPageCtrl:ctor(view, content)
    self:Init(content)
end

function WeatherPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/WeatherCenter.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.pageView.refreshBuild = function() self:RefreshBuild() end
end

function WeatherPageCtrl:EnterScene()
end

function WeatherPageCtrl:ExitScene()
end

function WeatherPageCtrl:ClickBuild(courtBuildType)
    res.PushDialog("ui.controllers.court.technologyHall.TechnologyInfoCtrl", self.courtBuildModel, courtBuildType)
    EventSystem.SendEvent("DisableTechnologyHall")
end

function WeatherPageCtrl:InitView(courtBuildModel)
    self.courtBuildModel = courtBuildModel
    self.pageView:InitView(courtBuildModel)
end

function WeatherPageCtrl:RefreshBuild()
    self:InitView(CourtBuildModel.new())
end

function WeatherPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return WeatherPageCtrl
