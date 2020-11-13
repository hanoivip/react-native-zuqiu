local BannerAssetFinder = {}

-- 获取跨服赛版块Prefab
function BannerAssetFinder.GetCrossPrefab(isSelfArea, typeIndex, index)
	local path = ""
	if isSelfArea then 
		path = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/Banner"
	else
		path = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/RBanner"
	end
	local combinePath = path .. tostring(typeIndex) .. "T" .. tostring(index) .. ".prefab"
	return combinePath
end

return BannerAssetFinder
