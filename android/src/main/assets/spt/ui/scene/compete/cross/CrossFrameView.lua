local CrossAssetFinder = require("ui.scene.compete.cross.CrossAssetFinder")
local CrossFrameView = class(unity.base)

function CrossFrameView:ctor()
	self.content = self.___ex.content
end

function CrossFrameView:InitView(matchModel, index)
	if self.contentScript then 
		self.contentScript:InitView(matchModel, index)
	else
		local prefabPath = CrossAssetFinder.GetCrossPrefab(matchModel:GetCrossType())
		if prefabPath then 
			local obj, script = res.Instantiate(prefabPath)
			obj.transform:SetParent(self.content, false)
			self.contentScript = script
			self.contentScript:InitView(matchModel, index)
		end
	end
end

return CrossFrameView