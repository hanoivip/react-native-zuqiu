local CourtBuildType = require("ui.scene.court.CourtBuildType")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local TechnologyInfoCtrl = class(BaseCtrl)

TechnologyInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/TechnologyInfo.prefab"

function TechnologyInfoCtrl:Init()
    self.view.clickEvent = function() self:ClickEvent() end
    self.view.refreshBuild = function(courtBuildType, courtBuildModel) self:RefreshBuild(courtBuildType, courtBuildModel) end
    self.view.clickLevelUp = function(courtBuildType) self:ClickLevelUp(courtBuildType) end
    self.view.clickComplete = function(courtBuildType, cost) self:ClickComplete(courtBuildType, cost) end
end

function TechnologyInfoCtrl:ClickEvent()
    EventSystem.SendEvent("ShowTechnologyHall")
end

function TechnologyInfoCtrl:Refresh(courtBuildModel, courtBuildType)

    self.view:InitView(courtBuildModel, courtBuildType)
end

function TechnologyInfoCtrl:ClickComplete(courtBuildType,cost)
    CostDiamondHelper.CostDiamond(cost, nil, function()
		local confirmCallback = function()
			self.view:Close()
			EventSystem.SendEvent("CourtComplete", courtBuildType)
		end
		DialogMultipleConfirmation.MultipleConfirmation(lang.trans("tips"), lang.trans("complete_desc"), confirmCallback)
    end)
end

function TechnologyInfoCtrl:ClickLevelUp(courtBuildType)
    EventSystem.SendEvent("CourtLevelUp", courtBuildType)
end

-- 倒计时为0时重新刷新数据
function TechnologyInfoCtrl:RefreshBuild(courtBuildType, courtBuildModel)
    self.view:InitView(courtBuildModel, courtBuildType)
end

return TechnologyInfoCtrl