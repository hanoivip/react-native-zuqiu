local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local TweenExtensions = Tweening.TweenExtensions
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.HeroHallInfoBarCtrl")
local HeroHallMainModel = require("ui.models.heroHall.main.HeroHallMainModel")
local DialogManager = require("ui.control.manager.DialogManager")
local LevelLimit = require("data.LevelLimit")

local HeroHallMainCtrl = class(BaseCtrl, "HeroHallMainCtrl")

HeroHallMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/HeroHall/Main/Prefabs/HeroHallMain.prefab"

function HeroHallMainCtrl:AheadRequest()
    if self.view then
        self.view:ShowDisplayArea(false)
    end

    local response = req.heroHallMainInfo()
    if api.success(response) then
        local data = response.val
        self.model = HeroHallMainModel.new()
        self.model:InitWithProtocol(data)
        self.view:ShowDisplayArea(true)
    end
end

function HeroHallMainCtrl:ctor()
    HeroHallMainCtrl.super.ctor(self)
end

function HeroHallMainCtrl:Init()
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child)
    end)

    self.view.onClickBtnLeft = function() self:OnClickBtnLeft() end
    self.view.onClickBtnRight = function() self:OnClickBtnRight() end
    self.view.onItemClick = function(id) self:OnItemClick(id) end
    self.view.onIntroClick = function() self:OnIntroClick() end
    self.view.onRankClick = function() self:OnRankClick() end
end

function HeroHallMainCtrl:Refresh(currGroup)
    HeroHallMainCtrl.super.Refresh(self)
    if self.model then 
        if currGroup then
            self.model:SetCurrGroup(currGroup)
        end
        self.view:InitView(self.model)
    end
end

function HeroHallMainCtrl:GetStatusData()
    return self.model:GetCurrGroup()
end

function HeroHallMainCtrl:OnEnterScene()
    -- body
end

function HeroHallMainCtrl:OnExitScene()
    self.view:ExitScene()
end

function HeroHallMainCtrl:OnClickBtnLeft()
    if self.model:PreviousGroup() then
        self.view:RefreshHallsView()
        self:MoveEffect(true)
    end
end

function HeroHallMainCtrl:OnClickBtnRight()
    if self.model:NextGroup() then
        self.view:RefreshHallsView()
        self:MoveEffect(false)
    end
end

local MoveDistance = 1334
local FadeMinAlpha = 0.2
local PlayTime = 0.16
function HeroHallMainCtrl:MoveEffect(isLeft)
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
        self.view.showArea.transform.anchoredPosition = Vector2(MoveDistance * -ratio, 0)
        self.view.showAreaCanvasGroup.alpha = FadeMinAlpha
        self.moveIn = ShortcutExtensions.DOAnchorPosX(self.view.showArea.transform, 0, PlayTime * 2)
        TweenSettingsExtensions.SetEase(self.moveIn, Ease.OutQuart)
        self.fadeIn = ShortcutExtensions.DOFade(self.view.showAreaCanvasGroup, 1, PlayTime * 2)
    end)
end

function HeroHallMainCtrl:OnItemClick(id)
    local hallData = self.model:GetHallDataById(id)
    if hallData.activate == -1 then-- 未激活
        return
    elseif hallData.activate == 0 then-- 待激活
        self:ActivateHall(id)
    elseif hallData.activate == 1 then-- 已激活
        res.PushScene("ui.controllers.heroHall.statue.HeroHallStatueCtrl", hallData, self.model:GetHeroHallDataModel())
    else
        dump("wrong data activate, please check the server")
    end
end

function HeroHallMainCtrl:OnIntroClick()
    res.PushDialog("ui.controllers.heroHall.rule.HeroHallRuleCtrl")
end

function HeroHallMainCtrl:OnRankClick()
    local playerInfoModel = PlayerInfoModel.new()
    local playerLevel = playerInfoModel:GetLevel()
    if playerLevel >= LevelLimit.LeaderBoard.playerLevel then
        res.PushScene("ui.controllers.rank.RankMainCtrl")
    else
        DialogManager.ShowToastByLang("hero_hall_main_rank_limit", LevelLimit.LeaderBoard.playerLevel)
    end
end

function HeroHallMainCtrl:ActivateHall(id)
    clr.coroutine(function()
        local response = req.heroHallActivateHall(id)
        if api.success(response) then
            local data = response.val
            self.model:UpdateData(id, data)
            self.view:ActivateHallView(id)
            self.view:RefreshTotalScore()
        end
    end)
end

return HeroHallMainCtrl