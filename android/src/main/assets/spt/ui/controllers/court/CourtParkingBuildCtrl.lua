local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CourtParkingBuildCtrl = class(BaseCtrl)

CourtParkingBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ParkingLevelUp.prefab"

function CourtParkingBuildCtrl:Init()
    self.view.clickLevelUp = function() self:ClickLevelUp() end
    self.view.clickComplete = function(cost) self:ClickComplete(cost) end
    self.view.refreshBuild = function() self:RefreshBuild() end
end

function CourtParkingBuildCtrl:ClickComplete(cost)
    CostDiamondHelper.CostDiamond(cost, nil, function()
        self.view:Close()
        EventSystem.SendEvent("CourtComplete", CourtBuildType.ParkingBuild)
    end)
end

function CourtParkingBuildCtrl:ClickLevelUp()
    EventSystem.SendEvent("CourtLevelUp", CourtBuildType.ParkingBuild)
end

function CourtParkingBuildCtrl:Refresh()
    self.view:InitView()
end

function CourtParkingBuildCtrl:RefreshBuild()
    self.view:InitView()
end

return CourtParkingBuildCtrl