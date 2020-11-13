local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local GrassPageCtrl = class(nil, "GrassPageCtrl")

function GrassPageCtrl:ctor(view, content)
    self:Init(content)
end

function GrassPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/GrassCenter.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.pageView.refreshBuild = function() self:RefreshBuild() end
end

function GrassPageCtrl:EnterScene()
end

function GrassPageCtrl:ExitScene()
end

function GrassPageCtrl:ClickBuild(courtBuildType)
    res.PushDialog("ui.controllers.court.technologyHall.TechnologyInfoCtrl", self.courtBuildModel, courtBuildType)
    EventSystem.SendEvent("DisableTechnologyHall")
end

function GrassPageCtrl:InitView(courtBuildModel)
    self.courtBuildModel = courtBuildModel
    self.pageView:InitView(courtBuildModel)
end

function GrassPageCtrl:RefreshBuild()
    self:InitView(CourtBuildModel.new())
end

function GrassPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return GrassPageCtrl
