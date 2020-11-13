local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local TweenExtensions = Tweening.TweenExtensions
local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.HeroHallInfoBarCtrl")
local HeroHallStatueModel = require("ui.models.heroHall.statue.HeroHallStatueModel")
local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")

local HeroHallStatueCtrl = class(BaseCtrl, "HeroHallStatueCtrl")

HeroHallStatueCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/HeroHall/Statue/Prefabs/HeroHallStatue.prefab"

function HeroHallStatueCtrl:ctor()
    HeroHallStatueCtrl.super.ctor(self)
end

function HeroHallStatueCtrl:Init(hallData, heroHallDataModel, heroHallStatueModel)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child)
    end)

    self.view.onClickBtnLeft = function() self:OnClickBtnLeft() end
    self.view.onClickBtnRight = function() self:OnClickBtnRight() end
    self.view.onClickBtnUpgrade = function() self:OnClickBtnUpgrade() end
    self.view.onClickBtnIntro = function() self:OnClickBtnIntro() end
    self.view.onClickEfxMask = function() self:OnClickEfxMask() end
end

function HeroHallStatueCtrl:Refresh(hallData, heroHallDataModel, heroHallStatueModel)
    HeroHallStatueCtrl.super.Refresh(self)
    if heroHallStatueModel then
        self.model = heroHallStatueModel
    else
        self.model = HeroHallStatueModel.new(hallData, heroHallDataModel)
    end
    self.view:InitView(self.model)
end

function HeroHallStatueCtrl:GetStatusData()
    return self.model:GetHallData(), self.model:GetHeroHallDataModel(), self.model
end

-- 升级雕像后更新
function HeroHallStatueCtrl:UpdateAfterUpgrade(newStatueData)
    self.model:UpdateAfterUpgrade(newStatueData)
    self.view:InitUpgradeEffect()
end

function HeroHallStatueCtrl:OnClickBtnLeft()
    self.model:PreviousStatue()
    self.view:UpdateStatueView()
    self:MoveEffect(true)
end

function HeroHallStatueCtrl:OnClickBtnRight()
    self.model:NextStatue()
    self.view:UpdateStatueView()
    self:MoveEffect(false)
end

function HeroHallStatueCtrl:OnClickEfxMask()
    self.view:FinishUpgradeEffect()
end

local MoveDistance = 1334
local FadeMinAlpha = 0.2
local PlayTime = 0.16
function HeroHallStatueCtrl:MoveEffect(isLeft)
    if self.moveOut then
        TweenExtensions.Pause[Tweener](self.moveOut)
        TweenExtensions.Pause[Tweener](self.fadeOut)
    end
    if self.moveIn then
        TweenExtensions.Pause[Tweener](self.moveIn)
        TweenExtensions.Pause[Tweener](self.fadeIn)
    end
    self.view.showAreaCanvasGroup.alpha = 1
    local ratio = isLeft and 1 or -1
    self.moveOut = ShortcutExtensions.DOAnchorPosX(self.view.showArea.transform, MoveDistance * ratio, PlayTime)
    self.fadeOut = ShortcutExtensions.DOFade(self.view.showAreaCanvasGroup, FadeMinAlpha, PlayTime)
    TweenSettingsExtensions.SetEase(self.moveOut, Ease.OutQuart)
    TweenSettingsExtensions.OnComplete(self.moveOut, function()
        self.view.showArea.transform.anchoredPosition = Vector2(MoveDistance * -ratio, -22)
        self.view.showAreaCanvasGroup.alpha = FadeMinAlpha
        self.moveIn = ShortcutExtensions.DOAnchorPosX(self.view.showArea.transform, 0, PlayTime * 2)
        TweenSettingsExtensions.SetEase(self.moveIn, Ease.OutQuart)
        self.fadeIn = ShortcutExtensions.DOFade(self.view.showAreaCanvasGroup, 1, PlayTime * 2)
    end)
end

function HeroHallStatueCtrl:OnClickBtnUpgrade()
    if self.model:IsCurrStatueMaxLevel() then return end

    local statueData = self.model:GetCurrStatue()
    if statueData.activate ~= 1 then
        DialogManager.ShowToastByLang("hero_hall_statue_upgrade_none")
        return
    end

    res.PushDialog("ui.controllers.heroHall.upgrade.HeroHallUpgradeCtrl", statueData, self.model:GetCurrCardModel(), self.model:GetHeroHallDataModel())
end

function HeroHallStatueCtrl:OnClickBtnIntro()
    local statueData = self.model:GetCurrStatue()
    res.PushDialog("ui.controllers.heroHall.improve.HeroHallImproveCtrl", statueData.list)
end

function HeroHallStatueCtrl:OnEnterScene()
    EventSystem.AddEvent("herohall.aftergrade", self, self.UpdateAfterUpgrade)
end

function HeroHallStatueCtrl:OnExitScene()
    EventSystem.RemoveEvent("herohall.aftergrade", self, self.UpdateAfterUpgrade)
end

return HeroHallStatueCtrl