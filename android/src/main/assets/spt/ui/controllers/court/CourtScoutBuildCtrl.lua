local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CourtScoutBuildCtrl = class(BaseCtrl)
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
CourtScoutBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ScoutLevelUp.prefab"

function CourtScoutBuildCtrl:Init()
    self.view.clickLevelUp = function() self:ClickLevelUp() end
    self.view.clickComplete = function(cost) self:ClickComplete(cost) end
    self.view.refreshBuild = function() self:RefreshBuild() end
    self.view.clickPlayer = function(courtBuildModel) self:ClickPlayer(courtBuildModel) end
end

function CourtScoutBuildCtrl:ClickComplete(cost)
    CostDiamondHelper.CostDiamond(cost, nil, function()
        self.view:Close()
        EventSystem.SendEvent("CourtComplete", CourtBuildType.ScoutBuild)
    end)

end

function CourtScoutBuildCtrl:ClickLevelUp()
    EventSystem.SendEvent("CourtLevelUp", CourtBuildType.ScoutBuild)
end

function CourtScoutBuildCtrl:ClickPlayer(courtBuildModel)
    self.view:DisableBuild()
    res.PushDialog("ui.controllers.court.courtScoutPlayer.CourtScoutPlayerInfoCtrl", courtBuildModel)
    GuideManager.Show(self)
end

function CourtScoutBuildCtrl:Refresh()
    self.view:InitView()
end

function CourtScoutBuildCtrl:RefreshBuild()
    self.view:InitView()
end

return CourtScoutBuildCtrl