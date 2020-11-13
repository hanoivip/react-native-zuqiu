local Vector3 = clr.UnityEngine.Vector3
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PasterSupporterCtrl = require("ui.controllers.cardDetail.supporter.PasterSupporterCtrl")
local TrainingSupporterCtrl = require("ui.controllers.cardDetail.supporter.TrainingSupporterCtrl")
local LegendRoadSupporterCtrl = require("ui.controllers.cardDetail.supporter.LegendRoadSupporterCtrl")
local SupporterType = require("ui.models.cardDetail.supporter.SupporterType")

local SupporterView = class(unity.base, "SupporterView")

local Tag = {}
Tag.Paster = "paster"
Tag.Training = "training"
Tag.LegendRoad = "legendRoad"
local DefaultTag = Tag.Paster

function SupporterView:ctor()
--------Start_Auto_Generate--------
    self.questionBtn = self.___ex.questionBtn
    self.closeBtn = self.___ex.closeBtn
    self.cardEmptyGo = self.___ex.cardEmptyGo
    self.switchCardBtn = self.___ex.switchCardBtn
    self.cardSupporterTrans = self.___ex.cardSupporterTrans
    self.supportIconGo = self.___ex.supportIconGo
    self.switchBtn = self.___ex.switchBtn
    self.supporterNameTxt = self.___ex.supporterNameTxt
    self.cardSelfTrans = self.___ex.cardSelfTrans
    self.supportedIconGo = self.___ex.supportedIconGo
    self.selfNameTxt = self.___ex.selfNameTxt
    self.supportInfoGo = self.___ex.supportInfoGo
    self.supportInfoTxt = self.___ex.supportInfoTxt
    self.supportArrowGo = self.___ex.supportArrowGo
    self.supportArrowTxt = self.___ex.supportArrowTxt
    self.activeBtn = self.___ex.activeBtn
    self.activeTxt = self.___ex.activeTxt
    self.effectGetRewardBtnGo = self.___ex.effectGetRewardBtnGo
    self.tabGroupSpt = self.___ex.tabGroupSpt
    self.supporterTypeTrans = self.___ex.supporterTypeTrans
    self.tipTxt = self.___ex.tipTxt
--------End_Auto_Generate----------
    self.subCtrl = {}
    self.canvasGroup = self.___ex.canvasGroup
end

function SupporterView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeBtn:regOnButtonClick(function ()
        if self.onClose and type(self.onClose) == "function" then
            self.onClose()
        end
    end)
    self.switchCardBtn:regOnButtonClick(function ()
        if self.onBtnSwitchCard and type(self.onBtnSwitchCard) == "function" then
            self.onBtnSwitchCard()
        end
    end)
    self.activeBtn:regOnButtonClick(function ()
        if self.onBtnActive and type(self.onBtnActive) == "function" then
            self.onBtnActive()
        end
    end)
    self.switchBtn:regOnButtonClick(function ()
        if self.onBtnSwitchCard and type(self.onBtnSwitchCard) == "function" then
            self.onBtnSwitchCard()
        end
    end)
    self.questionBtn:regOnButtonClick(function ()
        if self.onBtnQuestion and type(self.onBtnQuestion) == "function" then
            self.onBtnQuestion()
        end
    end)

    self:InitTab()
end

function SupporterView:InitView(supporterModel)
    self.model = supporterModel
    self:OnTabClick(DefaultTag)
    self.tabGroupSpt:selectMenuItem(DefaultTag)
    if not self.cardView then
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        cardObject.transform:SetParent(self.cardSelfTrans, false)
        cardObject.transform.localScale = Vector3(0.6, 0.6, 1)
        self.cardView = cardSpt
    end
    self.cardModel = supporterModel:GetCardModel()
    self.cardView:InitView(self.cardModel)
    self.cardView:IsShowName(false)
    self.selfNameTxt.text = self.cardModel:GetName()
    self:RefreshView()
end

function SupporterView:InitTab()
    for i, v in pairs(self.tabGroupSpt.menu) do
        self.tabGroupSpt:BindMenuItem(i, function()
            self:OnTabClick(i)
        end)
    end
end

function SupporterView:OnTabClick(tag)
    if tag == Tag.Paster then
        if not self.subCtrl[tag] then
            local pasterSupporterModel = self.model:GetPasterSupporterModel()
            self.subCtrl[tag] = PasterSupporterCtrl.new(pasterSupporterModel, self.supporterTypeTrans)
        end
    elseif tag == Tag.Training then
        if not self.subCtrl[tag] then
            local trainingSupporterModel = self.model:GetTrainingSupporterModel()
            self.subCtrl[tag] = TrainingSupporterCtrl.new(trainingSupporterModel, self.supporterTypeTrans)
        end
    elseif tag == Tag.LegendRoad then
        if not self.subCtrl[tag] then
            local legendRoadSupporterModel = self.model:GetLegendRoadSupporterModel()
            self.subCtrl[tag] = LegendRoadSupporterCtrl.new(legendRoadSupporterModel, self.supporterTypeTrans)
        end
    end
    self:SetSubViewState(tag)
    self.subCtrl[tag]:Refresh()
    self.subTag = tag
    self:SetTipText(tag)
end

function SupporterView:SetTipText(tag)
    if not self.model:GetSupportCardModel() then
        self.tipTxt.text = lang.transstr("support_tip_1")
        return
    end
    if not self.cardModel then return end
    local hasTrained = tobool(self.cardModel:GetTrainingBase() > 0)
    local hasLegendRoad = self.cardModel:IsOpenLegendRoad()
    local quality = self.cardModel:GetCardQuality()
    local QualitySpecial = self.cardModel:GetCardQualitySpecial()
    local fixQuality = CardHelper.GetQualityFixed(quality, QualitySpecial)
    local qualitySign = CardHelper.GetQualitySign(fixQuality)
    local name = self.cardModel:GetName()
    local tagName = ""
    if tag == Tag.Training and not hasTrained then
        tagName = lang.transstr("training_base")
        self.tipTxt.text = lang.transstr("support_tip_9", qualitySign, name, tagName)
    elseif tag == Tag.LegendRoad and not hasLegendRoad then
        tagName = lang.transstr("legend_road")
        self.tipTxt.text = lang.transstr("support_tip_9", qualitySign, name, tagName)
    else
        self.tipTxt.text = ""
    end
end

function SupporterView:SetSubViewState(tag)
    for i, v in pairs(self.subCtrl) do
        v:SetViewState(tag == i)
    end
end

function SupporterView:Refresh()
    self:RefreshView()
    if self.subCtrl and self.subCtrl[self.subTag] then
        self.subCtrl[self.subTag]:Refresh()
    end
end

function SupporterView:RefreshView()
    local supporterCardModel = self.model:GetSupportCardModel()
    GameObjectHelper.FastSetActive(self.cardEmptyGo, not tobool(supporterCardModel))
    GameObjectHelper.FastSetActive(self.activeBtn.gameObject, tobool(supporterCardModel))
    if supporterCardModel then
        if not self.supporterCardView then
            local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
            cardObject.transform:SetParent(self.cardSupporterTrans, false)
            cardObject.transform.localScale = Vector3(0.6, 0.6, 1)
            self.supporterCardObject = cardObject
            self.supporterCardView = cardSpt
        end
        self.supporterCardView:InitView(supporterCardModel)
        self.supporterCardView:IsShowName(false)
        self.supporterNameTxt.text = supporterCardModel:GetName()
        self.activeTxt.text = lang.transstr("support_confirm")
        self.switchBtn.transform.SetSiblingIndex(10)
        self:SetTipText(self.subTag)
        self.supportArrowTxt.text = lang.transstr("support_supporter_preview")
        GameObjectHelper.FastSetActive(self.effectGetRewardBtnGo, true)
    else
        self.supportInfoTxt.text = ""
        self.tipTxt.text = lang.transstr("support_tip_1")
        self.supportArrowTxt.text = lang.transstr("support_supporter")
    end
    local hasSupportCard = self.cardModel:IsHasSupportCard()
    if hasSupportCard then
        self.activeTxt.text = lang.transstr("support_cancel")
        self.supportedIconGo.transform.SetSiblingIndex(10)
        self.supportIconGo.transform.SetSiblingIndex(10)
        self:RefreshSupporterDetail(true)
        GameObjectHelper.FastSetActive(self.effectGetRewardBtnGo, false)
    end
    if self.supporterCardObject then
        GameObjectHelper.FastSetActive(self.supporterCardObject, tobool(supporterCardModel))
    end
    GameObjectHelper.FastSetActive(self.supportInfoGo.gameObject, tobool(hasSupportCard))
    GameObjectHelper.FastSetActive(self.supportArrowGo.gameObject, not tobool(hasSupportCard))
    GameObjectHelper.FastSetActive(self.supportedIconGo, tobool(hasSupportCard))
    GameObjectHelper.FastSetActive(self.supportIconGo, tobool(hasSupportCard))
    GameObjectHelper.FastSetActive(self.supporterNameTxt.gameObject, tobool(hasSupportCard) or tobool(supporterCardModel))
    GameObjectHelper.FastSetActive(self.switchCardBtn.gameObject, tobool(not supporterCardModel))
    GameObjectHelper.FastSetActive(self.switchBtn.gameObject, tobool(not hasSupportCard and supporterCardModel))
end

function SupporterView:RefreshSupporterDetail(doNotRequest)
    if not self.cardModel:IsHasSupportCard() then return end
    local hasTrainingSupport = self.model:GetSelectTrainingType() == SupporterType.StType.SupportCard
    local hasLegendRoadSupport = self.model:GetSelectLegendRoadType() == SupporterType.SlrType.SupportCard
    local info = lang.transstr("support_paster") .. lang.transstr("untranslated_2384") .. "\n"
    if hasTrainingSupport then
        info = info .. lang.transstr("support_training") .. lang.transstr("untranslated_2384") .. "\n"
    end
    if hasLegendRoadSupport then
        info = info .. lang.transstr("support_legend_road") .. lang.transstr("untranslated_2384")
    end
    self.supportInfoTxt.text = info
    if doNotRequest then return end
    if self.onSwitchState then
        self.onSwitchState()
    end
end

function SupporterView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
            self.closeDialog()
        end)
    end
end

function SupporterView:EnterScene()
    EventSystem.AddEvent("Supporter_Select", self, self.Refresh)
    EventSystem.AddEvent("Supporter_Select_type", self, self.RefreshSupporterDetail)
end

function SupporterView:ExitScene()
    EventSystem.RemoveEvent("Supporter_Select", self, self.Refresh)
    EventSystem.RemoveEvent("Supporter_Select_type", self, self.RefreshSupporterDetail)
    for i, v in pairs(self.subCtrl) do
        v:OnExitScene()
    end
end

return SupporterView
