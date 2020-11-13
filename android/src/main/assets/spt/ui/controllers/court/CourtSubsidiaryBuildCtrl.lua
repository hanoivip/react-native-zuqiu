local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CourtSubsidiaryBuildCtrl = class(BaseCtrl)
local CostDiamondHelper = require("ui.common.CostDiamondHelper")

CourtSubsidiaryBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SubsidiaryBuildLevelUp.prefab"

function CourtSubsidiaryBuildCtrl:Init()
    self.view.clickEvent = function() self:ClickEvent() end
    self.view.refreshBuild = function(buildType, courtBuildModel) self:RefreshBuild(buildType, courtBuildModel) end
    self.view.clickLevelUp = function(courtBuildType) self:ClickLevelUp(courtBuildType) end
    self.view.clickComplete = function(courtBuildType, cost) self:ClickComplete(courtBuildType, cost) end
end

function CourtSubsidiaryBuildCtrl:ClickEvent()
    EventSystem.SendEvent("ShowBuild")
    GuideManager.Show(self)
end

function CourtSubsidiaryBuildCtrl:ClickComplete(courtBuildType, cost)
    CostDiamondHelper.CostDiamond(cost, nil, function()
        if GuideManager.GuideIsOnGoing("court") then
            EventSystem.SendEvent("CourtComplete", courtBuildType)
            GuideManager.Show(self)
        else
    		local confirmCallback = function()
    			EventSystem.SendEvent("CourtComplete", courtBuildType)
    			GuideManager.Show(self)
    		end
    		DialogMultipleConfirmation.MultipleConfirmation(lang.trans("tips"), lang.trans("complete_desc"), confirmCallback)
        end
    end)
end

function CourtSubsidiaryBuildCtrl:ClickLevelUp(courtBuildType)
    EventSystem.SendEvent("CourtLevelUp", courtBuildType)
    GuideManager.Show(self)
end

function CourtSubsidiaryBuildCtrl:Refresh(courtBuildModel, buildType)
    self.view:InitView(courtBuildModel, buildType)
end

function CourtSubsidiaryBuildCtrl:RefreshBuild(buildType, courtBuildModel)
    self.view:InitView(courtBuildModel, buildType)
end

return CourtSubsidiaryBuildCtrl