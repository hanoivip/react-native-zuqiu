local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CourtStadiumBuildCtrl = class(BaseCtrl)

CourtStadiumBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/StadiumLevelUp.prefab"

function CourtStadiumBuildCtrl:Init()
    self.view.clickAudience = function(courtBuildModel) self:ClickAudience(courtBuildModel) end
    self.view.clickLighting = function(courtBuildModel) self:ClickLighting(courtBuildModel) end
    self.view.clickScore = function(courtBuildModel) self:ClickScore(courtBuildModel) end
    self.view.clickStore = function(courtBuildModel) self:ClickStore(courtBuildModel) end
    self.view.clickLevelUp = function() self:ClickLevelUp() end
    self.view.clickComplete = function(cost) self:ClickComplete(cost) end
    self.view.refreshBuild = function() self:RefreshBuild() end
end

function CourtStadiumBuildCtrl:ClickComplete(cost)
    CostDiamondHelper.CostDiamond(cost, nil, function()
        self.view:Close()
        EventSystem.SendEvent("CourtComplete", CourtBuildType.StadiumBuild)
    end)
end

function CourtStadiumBuildCtrl:ClickLevelUp()
    EventSystem.SendEvent("CourtLevelUp", CourtBuildType.StadiumBuild)
end

function CourtStadiumBuildCtrl:ClickAudience(courtBuildModel)
    res.PushDialog("ui.controllers.court.CourtAudienceBuildCtrl", courtBuildModel)
    self.view:DisableBuild()
end

function CourtStadiumBuildCtrl:ClickLighting(courtBuildModel)
    res.PushDialog("ui.controllers.court.CourtLightingBuildCtrl", courtBuildModel)
    self.view:DisableBuild()
end

function CourtStadiumBuildCtrl:ClickScore(courtBuildModel)
    res.PushDialog("ui.controllers.court.CourtScoreBoardBuildCtrl", courtBuildModel)
    self.view:DisableBuild()
end

function CourtStadiumBuildCtrl:ClickStore(courtBuildModel)
    res.PushDialog("ui.controllers.court.CourtStoreBuildCtrl", courtBuildModel)
    GuideManager.Show(self)
    self.view:DisableBuild()
end

function CourtStadiumBuildCtrl:Refresh()
    self.view:InitView()
end

function CourtStadiumBuildCtrl:RefreshBuild()
    self.view:InitView()
end

return CourtStadiumBuildCtrl