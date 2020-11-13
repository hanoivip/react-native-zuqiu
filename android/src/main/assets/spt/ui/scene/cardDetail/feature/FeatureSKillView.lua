local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FeatureSKillState = require("ui.scene.cardDetail.feature.FeatureSKillState")
local LuaButton = require("ui.control.button.LuaButton")
local FeatureSKillView = class(LuaButton)

function FeatureSKillView:ctor()
    FeatureSKillView.super.ctor(self)
    self.bg = self.___ex.bg
    self.quality = self.___ex.quality
    self.border = self.___ex.border
    self.feature = self.___ex.feature
    self.level = self.___ex.level
    self.titleText = self.___ex.titleText
    self.titleTag = self.___ex.titleTag
    self.featureName = self.___ex.featureName
    self.lock = self.___ex.lock
    self.signSelect = self.___ex.signSelect
    self.available = self.___ex.available
	self.decorate = self.___ex.decorate
    self.imgIcon = self.___ex.imgIcon
	self.slotLockGo = self.___ex.slotLockGo
end

function FeatureSKillView:start()
    self:regOnButtonClick(function()
        self:OnBtnFeature(self.slot)
    end)
end

function FeatureSKillView:EnterScene()
	EventSystem.AddEvent("CardFeatureSkillRefreshHandle", self, self.EventFeatureSkillRefreshHandle)
end

function FeatureSKillView:ExitScene()
	EventSystem.RemoveEvent("CardFeatureSkillRefreshHandle", self, self.EventFeatureSkillRefreshHandle)
end

function FeatureSKillView:EventFeatureSkillRefreshHandle()
	if self.featureModel then 
		local featureStatu = self.featureModel:GetStatu()
		GameObjectHelper.FastSetActive(self.lock, tobool(featureStatu == CoachItemType.SkillFuncType.Lock))
		GameObjectHelper.FastSetActive(self.available, tobool(featureStatu == CoachItemType.SkillFuncType.Choose))
		GameObjectHelper.FastSetActive(self.signSelect, tobool(featureStatu == CoachItemType.SkillFuncType.Appoint))
	end
end

function FeatureSKillView:OnBtnFeature(slot)
    local featureSKillState = self.featureModel:GetFeatureSKillState()
    local canClick = featureSKillState == FeatureSKillState.Enable or featureSKillState == FeatureSKillState.Disable
    if self.clickFeature and canClick then 
        self.clickFeature(slot)
    end
end

function FeatureSKillView:InitView(featureModel, slot)
    self.slot = slot
    local featureSKillState = featureModel:GetFeatureSKillState()
    local qualityState = featureSKillState == FeatureSKillState.Enable or featureSKillState == FeatureSKillState.Disable
    local slotState = featureSKillState == FeatureSKillState.Lock or featureSKillState == FeatureSKillState.Disable

    self.featureModel = featureModel
    if qualityState then
        self.decorate.overrideSprite = AssetFinder.GetCoachFeatureDecorateIcon(featureModel:GetDecoratePicIcon())
        self.imgIcon.overrideSprite = AssetFinder.GetCoachFeatureSkillIcon(featureModel:GetPicIcon())
        self.quality.overrideSprite = AssetFinder.GetItemQualityBoard(featureModel:GetQuality())
        local isOpen = featureModel:IsOpen()
        local isShowIconColor = isOpen and 1 or 0
        self.decorate.color = Color(isShowIconColor, 1, 1)
        self.imgIcon.color = Color(isShowIconColor, 1, 1)
        self.quality.color = Color(isShowIconColor, 1, 1)
        self.featureName.text = featureModel:GetName()
        local tag = featureModel:GetTagText()
        local qualityName = featureModel:GetSkillQuality()
        self.titleText.text = tag
        self.level.text = qualityName
        GameObjectHelper.FastSetActive(self.titleTag.gameObject, tobool(tag and tag ~= ""))
        self:ResetStatus()
    end
    GameObjectHelper.FastSetActive(self.quality.gameObject, qualityState)
    GameObjectHelper.FastSetActive(self.slotLockGo.gameObject, slotState)
end

function FeatureSKillView:SetNameColor(color)
	self.featureName.color = color
end

function FeatureSKillView:ResetStatus()
	GameObjectHelper.FastSetActive(self.lock, false)
	GameObjectHelper.FastSetActive(self.available, false)
	GameObjectHelper.FastSetActive(self.signSelect, false)
end

return FeatureSKillView