local FeatureAdditionDetailModel = require("ui.models.cardDetail.feature.FeatureAdditionDetailModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MySceneModel = require("ui.models.myscene.MySceneModel")
local FeatureInfoCtrl = class(BaseCtrl)
FeatureInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureAdditionInfo.prefab"
FeatureInfoCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function FeatureInfoCtrl:Init(cardModel, bShowScene)
	local featureAdditionDetailModel = FeatureAdditionDetailModel.new()
	if bShowScene then
		local sceneModel = MySceneModel.new()
		featureAdditionDetailModel:SetGrassCategory(sceneModel:GetGrass())
		featureAdditionDetailModel:SetWeatherCategory(sceneModel:GetWeather())
		featureAdditionDetailModel:SetTeamCategory(sceneModel:GetHome())
	end
	self.view:InitView(cardModel, featureAdditionDetailModel)
end

function FeatureInfoCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function FeatureInfoCtrl:OnExitScene()
    self.view:OnExitScene()
end

return FeatureInfoCtrl