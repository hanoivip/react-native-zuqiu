local UnityEngine = clr.UnityEngine
local Screen = UnityEngine.Screen
local Tweening = clr.DG.Tweening
local Vector2 = UnityEngine.Vector2
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local TweenExtensions = Tweening.TweenExtensions
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CardTrainingMainModel = require("ui.models.cardTraining.CardTrainingMainModel")
local CardTrainingLevelUpCtrl = require("ui.controllers.cardTraining.CardTrainingLevelUpCtrl")
local CardTrainingConditionCtrl = require("ui.controllers.cardTraining.CardTrainingConditionCtrl")
local CardTrainingFinishOneCtrl = require("ui.controllers.cardTraining.CardTrainingFinishOneCtrl")
local CardTrainingFinishTwoCtrl = require("ui.controllers.cardTraining.CardTrainingFinishTwoCtrl")
local CardTrainingFinishThreeCtrl = require("ui.controllers.cardTraining.CardTrainingFinishThreeCtrl")
local CardTrainingItemCtrl = require("ui.controllers.cardTraining.CardTrainingItemCtrl")
local CardTrainingItemWithCardCtrl = require("ui.controllers.cardTraining.CardTrainingItemWithCardCtrl")

local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")

local CardTrainingMainCtrl = class(BaseCtrl, "CardTrainingMainCtrl")

CardTrainingMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/CardTrainingCanvas.prefab"

function CardTrainingMainCtrl:AheadRequest(cardDetailModel, cardTrainingMainModel)
    self.cardDetailModel = cardDetailModel
    if cardTrainingMainModel then
        self.cardTrainingMainModel = cardTrainingMainModel
        return
    end
    local response = req.cardTrainingInfo(cardDetailModel:GetCardModel():GetPcid())
    if api.success(response) then
        local data = response.val
        self.cardTrainingMainModel = CardTrainingMainModel.new(cardDetailModel)
        self.cardTrainingMainModel:InitWithProtocol(data)
    end
end

function CardTrainingMainCtrl:Init(cardDetailModel, cardTrainingMainModel)
    self.LetterContentCtrl = {}
    self.view:InitView(self.cardTrainingMainModel)
    if not cardTrainingMainModel then
        self.view:GotoCellImmediate()
    end
    self.view.onClickMenu = function (tag) self:OnClickMenu(tag) end
    self.view.questionBtnClick = function () self:OnQuestionBtnClick() end
end

function CardTrainingMainCtrl:Refresh()
    CardTrainingMainCtrl.super.Refresh(self)
    -- 默认点击第一个标签
    self.view.levelMenuGroup:selectMenuItem(tostring(self.cardTrainingMainModel:GetCurrLevelSelected()))
    self:ChangeLetterContent(self.cardTrainingMainModel:GetCurrLevelSelected())
end

function CardTrainingMainCtrl:OnQuestionBtnClick()
    res.PushDialog("ui.controllers.cardTraining.CardTrainingBaseRuleCtrl", self.cardTrainingMainModel:GetCid())
end

function CardTrainingMainCtrl:OnClickMenu(tag)
    self.cardTrainingMainModel:SetCurrLevelSelected(tag)
    self:ChangeLetterContent(tag)
    self.view.levelStateView:InitView(self.cardTrainingMainModel)
    self.view.resultView:InitView(self.cardTrainingMainModel)
    self.view.notOpenView:InitView(self.cardTrainingMainModel)
    self.view.finishView:InitView(self.cardTrainingMainModel)
end

function CardTrainingMainCtrl:ChangeLetterContent(tag)

    for k, v in pairs(self.LetterContentCtrl) do
        v:HideGameObject()
    end
    local isLock = self.cardTrainingMainModel:GetIsLockByLevel(tag)
    local IsTrainingUseSelf = self.cardTrainingMainModel:IsTrainingUseSelf()

    if not IsTrainingUseSelf then
        local plate = self.cardTrainingMainModel:GetLetterContentTypeByLevel(tag)
        if isLock then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.Empty] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Empty] = CardTrainingFinishThreeCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Empty]:ShowGameObject()
            end
        elseif plate == CardTrainingConstant.LetterPart.FinishOnlyAttribute then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishOnlyAttribute] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishOnlyAttribute] = CardTrainingFinishTwoCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishOnlyAttribute]:ShowGameObject()
            end
        elseif plate == CardTrainingConstant.LetterPart.FinishWithSkill then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishWithSkill] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishWithSkill] = CardTrainingFinishOneCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishWithSkill]:ShowGameObject()
            end
        else
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.Empty] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Empty] = CardTrainingFinishThreeCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Empty]:ShowGameObject()
            end
        end
        return
    end

    if isLock then
        if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.Condition] then
            self.LetterContentCtrl[CardTrainingConstant.LetterPart.Condition] = CardTrainingConditionCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
        else
            self.LetterContentCtrl[CardTrainingConstant.LetterPart.Condition]:ShowGameObject()
        end
    else
        local plate = self.cardTrainingMainModel:GetLetterContentTypeByLevel(tag)
        if plate == CardTrainingConstant.LetterPart.Exp then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.Exp] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Exp] = CardTrainingLevelUpCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Exp]:ShowGameObject()
            end
        elseif plate == CardTrainingConstant.LetterPart.Item then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.Item] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Item] = CardTrainingItemCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.Item]:ShowGameObject()
            end
        elseif plate == CardTrainingConstant.LetterPart.ItemWithCard then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.ItemWithCard] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.ItemWithCard] = CardTrainingItemWithCardCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.ItemWithCard]:ShowGameObject()
            end
        elseif plate == CardTrainingConstant.LetterPart.FinishOnlyAttribute then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishOnlyAttribute] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishOnlyAttribute] = CardTrainingFinishTwoCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishOnlyAttribute]:ShowGameObject()
            end
        elseif plate == CardTrainingConstant.LetterPart.FinishWithSkill then
            if not self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishWithSkill] then
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishWithSkill] = CardTrainingFinishOneCtrl.new(self.cardTrainingMainModel, self.view.letterContentRect)
            else
                self.LetterContentCtrl[CardTrainingConstant.LetterPart.FinishWithSkill]:ShowGameObject()
            end
        end
    end
end

function CardTrainingMainCtrl:GetStatusData()
    return self.cardDetailModel, self.cardTrainingMainModel
end

function CardTrainingMainCtrl:RefreshMainView()
    clr.coroutine(function ()
        local response = req.cardTrainingInfo(self.cardDetailModel:GetCardModel():GetPcid())
        if api.success(response) then
            self.view:SaveScrollPos()
            local data = response.val
            local oldLvl = self.cardTrainingMainModel:GetCurrLevelSelected()
            local oldSubId = self.cardTrainingMainModel:GetSubIdByLevel(oldLvl)
            self.cardTrainingMainModel:InitWithProtocol(data)
            self.view:InitView(self.cardTrainingMainModel)
            self.view:GotoScrollPosImmediate()
            self.view.levelMenuGroup:selectMenuItem(tostring(self.cardTrainingMainModel:GetCurrLevelSelected()))
            self:ChangeLetterContent(self.cardTrainingMainModel:GetCurrLevelSelected())
            self:PlayLvlUpEffect(oldLvl, oldSubId)
        end
    end)
end

function CardTrainingMainCtrl:PlayLvlUpEffect(oldLvl, oldSubId)
    if self.cardTrainingMainModel:GetPlayFinishStatusFlag(oldLvl, oldSubId) then
        self.view.levelStateView:PlayLevelUpAnim()
    end
end

function CardTrainingMainCtrl:OnEnterScene()
    for k, v in pairs(self.LetterContentCtrl) do
        if v.OnEnterScene then
            v:OnEnterScene()
        end
    end
    self.view:EnterScene()
    EventSystem.AddEvent("CardTraining_RefreshMainView", self, self.RefreshMainView)
end

function CardTrainingMainCtrl:OnExitScene()
    for k, v in pairs(self.LetterContentCtrl) do
        if v.OnExitScene then
            v:OnExitScene()
        end
    end
    self.view:ExitScene()
    EventSystem.RemoveEvent("CardTraining_RefreshMainView", self, self.RefreshMainView)

    -- 英雄殿堂即时更新
    local heroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel").new()
    heroHallMapModel:UpdateTrainingBaseImproveByBaseID(self.cardDetailModel:GetCardModel():GetBaseID())
end

function CardTrainingMainCtrl:OnDestroy()

end

return CardTrainingMainCtrl
