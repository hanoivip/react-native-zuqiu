local AssetFinder = require("ui.common.AssetFinder")
local FeatureItemFrameView = class(unity.base)

function FeatureItemFrameView:ctor()
    FeatureItemFrameView.super.ctor(self)
    self.featureName = self.___ex.featureName
	self.desc = self.___ex.desc
    self.decorate = self.___ex.decorate
    self.imgIcon = self.___ex.imgIcon
    self.quality = self.___ex.quality
	self.sign = self.___ex.sign
end

function FeatureItemFrameView:InitView(featureModel)
	self.decorate.overrideSprite = AssetFinder.GetCoachFeatureDecorateIcon(featureModel:GetDecoratePicIcon())
	self.imgIcon.overrideSprite = AssetFinder.GetCoachFeatureSkillIcon(featureModel:GetPicIcon())
	self.quality.overrideSprite = AssetFinder.GetItemQualityBoard(featureModel:GetQuality())
	self.sign.overrideSprite = AssetFinder.GetCoachFeatureSign(featureModel:GetQualitySign())

	self.featureName.text = featureModel:GetName()
	self.desc.text = featureModel:GetDesc()
end

return FeatureItemFrameView