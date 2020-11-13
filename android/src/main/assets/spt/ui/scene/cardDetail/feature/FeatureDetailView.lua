local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local FeatureDetailView = class(unity.base)

function FeatureDetailView:ctor()
    self.featureName = self.___ex.featureName
    self.canvasGroup = self.___ex.canvasGroup
    self.btnClose = self.___ex.btnClose
    self.quality = self.___ex.quality
    self.decorate = self.___ex.decorate
    self.imgIcon = self.___ex.imgIcon
    self.titleText = self.___ex.titleText
    self.titleTag = self.___ex.titleTag
	self.level = self.___ex.level
	self.contentText = self.___ex.contentText
end

function FeatureDetailView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
 
    self:PlayInAnimator()
end

function FeatureDetailView:OnBtnFeature(slot)
    if self.clickFeature then 
        self.clickFeature(slot)
    end
end

function FeatureDetailView:InitView(featureModel)
	self.featureModel = featureModel
	self.decorate.overrideSprite = AssetFinder.GetCoachFeatureDecorateIcon(featureModel:GetDecoratePicIcon())
	self.imgIcon.overrideSprite = AssetFinder.GetCoachFeatureSkillIcon(featureModel:GetPicIcon())
	self.quality.overrideSprite = AssetFinder.GetItemQualityBoard(featureModel:GetQuality())

	self.contentText.text = featureModel:GetDesc()
	self.featureName.text = featureModel:GetName()
	local tag = featureModel:GetTagText()
	local qualityName = featureModel:GetSkillQuality()
	self.titleText.text = tag
	self.level.text = qualityName
	GameObjectHelper.FastSetActive(self.titleTag.gameObject, tobool(tag and tag ~= ""))
end

function FeatureDetailView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FeatureDetailView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FeatureDetailView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FeatureDetailView:Close()
    self:PlayOutAnimator()
end

return FeatureDetailView