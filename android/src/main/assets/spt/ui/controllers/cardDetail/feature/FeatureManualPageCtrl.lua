local PlayerTalentSkill = require("data.PlayerTalentSkill")
local CoachPlayerTalentSkillModel = require("ui.models.coach.common.CoachPlayerTalentSkillModel")
local FeatureChooseModel = require("ui.models.cardDetail.feature.FeatureChooseModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FeatureManualPageCtrl = class(BaseCtrl)

FeatureManualPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureManualPage.prefab"

function FeatureManualPageCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:PlayLeaveAnimation()
            res.PopScene()
        end)
    end)
end

function FeatureManualPageCtrl:Refresh(scrollNormalizedPos, featureChooseModel)
    FeatureManualPageCtrl.super.Refresh(self)
    self.cacheScrollPos = scrollNormalizedPos or 1
	self.featureChooseModel = featureChooseModel or FeatureChooseModel.new()
    self:InitView(self.featureChooseModel)
end

function FeatureManualPageCtrl:GetStatusData()
	return self.cacheScrollPos, self.featureChooseModel
end

function FeatureManualPageCtrl:InitView(featureChooseModel)
	local featureManualModelsMap = {}
	for id, v in pairs(PlayerTalentSkill) do
		local coachPlayerTalentSkillModel = CoachPlayerTalentSkillModel.new()
		coachPlayerTalentSkillModel:InitWithId(id)
		table.insert(featureManualModelsMap, coachPlayerTalentSkillModel)
	end

    self.view:InitView(featureManualModelsMap, featureChooseModel)
end

function FeatureManualPageCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function FeatureManualPageCtrl:OnExitScene()
    self.view:OnExitScene()
end

return FeatureManualPageCtrl
