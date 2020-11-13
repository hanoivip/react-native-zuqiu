local DialogManager = require("ui.control.manager.DialogManager")
local CoachHelper = require("ui.scene.coach.common.CoachHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local AssetFinder = require("ui.common.AssetFinder")

local CoachGuideView = class(unity.base)

function CoachGuideView:ctor()
    -- 顶部信息条框
    self.infoBarBox = self.___ex.infoBarBox
    -- 可接受任务列表scroll
    self.guideListScroll = self.___ex.guideListScroll

    self.bagBtn = self.___ex.bagBtn
    self.helpBtn = self.___ex.helpBtn
	self.manualBtn = self.___ex.manualBtn
    self.tipsTxt = self.___ex.tipsTxt
end

function CoachGuideView:start()
    self.bagBtn:regOnButtonClick(function() self:OnBagClick() end)
    self.helpBtn:regOnButtonClick(function() self:OnHelpClick() end)
	self.manualBtn:regOnButtonClick(function() self:OnManualClick() end)
    self.normalizedPosition = 1
end

function CoachGuideView:InitView(coachGuideModel)
    self.coachGuideModel = coachGuideModel
    self.guideListScroll:RegOnItemButtonClick("switchBtn", self.onSwitchClick)
    self.guideListScroll:RegOnItemButtonClick("addBtn", self.onAddClick)
    self.guideListScroll:RegOnItemButtonClick("buyBtn", self.onBuyClick)
    self.guideListScroll:RegOnItemButtonClick("notOpenBtn", self.onNotOpenClick)
    self.guideListScroll:RegOnItemButtonClick("cardDetailBtn", self.onCardDetailClick)

    local guideDesc = self.coachGuideModel:GetMaxCoachGuideDesc()
    self.tipsTxt.text = guideDesc
    
    self:RefreshSlotArea()
end

function CoachGuideView:RegOnDynamicLoad(func)
    self.infoBarBox:RegOnDynamicLoad(func)
end

function CoachGuideView:RefreshSlotArea()
    local coachGuideSlotsList = self.coachGuideModel:GetCoachGuideSlotsList()
    local position = self.normalizedPosition or self.guideListScroll:GetScrollNormalizedPosition()
    self.guideListScroll:InitView(coachGuideSlotsList, self.coachGuideModel)
    self.guideListScroll:SetScrollNormalizedPosition(position)
    self.normalizedPosition = nil
end

function CoachGuideView:OnBagClick()
    if self.onBagClick then
        self.onBagClick()
    end
end

function CoachGuideView:OnHelpClick()
    local config = CoachHelper.Explain.CoachGuide
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(config.id, config.descID)
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function CoachGuideView:OnManualClick()
	res.PushScene("ui.controllers.cardDetail.feature.FeatureManualPageCtrl")
end

return CoachGuideView
