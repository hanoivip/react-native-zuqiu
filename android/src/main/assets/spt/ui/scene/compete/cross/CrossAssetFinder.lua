local CrossContentOrder = require("ui.scene.compete.cross.CrossContentOrder")
local CrossAssetFinder = {}

local ModelRes = 
{
	[CrossContentOrder.TeamScore] = "ui.models.compete.cross.CompeteScoreModel",
	[CrossContentOrder.Universe_Additional] = "ui.models.compete.cross.CompeteAdditionalModel",
	[CrossContentOrder.Universe_Team] = "ui.models.compete.cross.CompeteTeamModel",
	[CrossContentOrder.Universe_Knockout] = "ui.models.compete.cross.CompeteKnockoutModel",
	[CrossContentOrder.Galaxy_Knockout] = "ui.models.compete.cross.CompeteKnockoutModel",
	[CrossContentOrder.Galaxy_Team] = "ui.models.compete.cross.CompeteTeamModel",
	[CrossContentOrder.Galaxy_Additional] = "ui.models.compete.cross.CompeteAdditionalModel",
}
-- 获取跨服赛版块model
function CrossAssetFinder.GetCrossModel(crossName)
	assert(crossName)
	return ModelRes[tostring(crossName)] 
end

local PrefabRes = 
{
	[CrossContentOrder.Universe_Additional] = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/Additional.prefab",
	[CrossContentOrder.Universe_Team] = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteTeam.prefab",
	[CrossContentOrder.Universe_Knockout] = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteOutPage.prefab",
	[CrossContentOrder.Galaxy_Additional] = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/Additional.prefab",
	[CrossContentOrder.Galaxy_Team] = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteTeam.prefab",
	[CrossContentOrder.Galaxy_Knockout] = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteOutPage.prefab",
	[CrossContentOrder.TeamScore] = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteScore.prefab",
}
-- 获取跨服赛版块Prefab
function CrossAssetFinder.GetCrossPrefab(crossName)
	assert(crossName)
	return PrefabRes[tostring(crossName)] 
end

return CrossAssetFinder
