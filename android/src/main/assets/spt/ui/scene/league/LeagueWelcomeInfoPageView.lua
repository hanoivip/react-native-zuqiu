local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CommonConstants = require("ui.common.CommonConstants")

local LeagueWelcomeInfoPageView = class(unity.base)

function LeagueWelcomeInfoPageView:ctor()
    --奖励区域
    self.rewardArea = self.___ex.rewardArea
    -- 对手区域
    self.enemyArea = self.___ex.enemyArea
    -- 开始按钮
    self.startBtn = self.___ex.startBtn
    -- 点击继续提示
    self.continueTip = self.___ex.continueTip
    -- 动画管理器
    self.animator = self.___ex.animator
    -- model
    self.leagueInfoModel = nil
    -- 联赛等级
    self.leagueLevel = nil
    -- 联赛排名奖励
    self.rankReward = nil
    -- 动画序列
    self.mySequence = nil
    -- 动画是否已完成
    self.isAnimComplete = false
end

function LeagueWelcomeInfoPageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.leagueLevel = self.leagueInfoModel:GetLeagueLevel()
    self.rankReward = self.leagueInfoModel:GetRankReward()
    self:InitRewardArea()
    self:InitEnemyArea()
end

function LeagueWelcomeInfoPageView:start()
    self:BindAll()
    self:PlayAnim()
    GuideManager.Show()
end

function LeagueWelcomeInfoPageView:BindAll()
    -- 开始按钮
    self.startBtn:regOnButtonClick(function ()
        if not self.isAnimComplete then
            TweenExtensions.Complete(self.mySequence, true)
        else
            self:PlayMoveOutAnim()
        end
    end)
end

--- 初始化奖励区域
function LeagueWelcomeInfoPageView:InitRewardArea()
    for i = 1, LeagueConstants.TeamSum do
        local barScripts = self.rewardArea["bar" .. i]
        barScripts:InitView(i, self.rankReward[i])
    end
end

--- 初始化对手区域
function LeagueWelcomeInfoPageView:InitEnemyArea()
    local opponentList = self.leagueInfoModel:GetOpponentList()
    for i = 1, LeagueConstants.TeamSum - 1 do
        local barScripts = self.enemyArea["bar" .. i]
        local teamData = opponentList[i]
        barScripts:InitView(teamData)
    end
end

--- 播放动画
function LeagueWelcomeInfoPageView:PlayAnim()
    local continueBtnFadeInTweener = ShortcutExtensions.DOFade(self.continueTip, 1, 1)
    self.mySequence = DOTween.Sequence()
    TweenSettingsExtensions.Append(self.mySequence, continueBtnFadeInTweener)
    TweenSettingsExtensions.AppendCallback(self.mySequence, function ()
        self.isAnimComplete = true
        local continueBtnFadeInOutTweener = ShortcutExtensions.DOFade(self.continueTip, 0.3, 1)
        TweenSettingsExtensions.SetLoops(continueBtnFadeInOutTweener, -1, LoopType.Yoyo)
    end)
end

function LeagueWelcomeInfoPageView:OnClick()
    if not self.isAnimComplete then
        TweenExtensions.Complete(self.mySequence, true)
    else
        res.PushScene("ui.controllers.league.LeagueSponsorPageCtrl", self.leagueInfoModel)
    end
end

function LeagueWelcomeInfoPageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut")
end

function LeagueWelcomeInfoPageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:OnClick()
    end
end

return LeagueWelcomeInfoPageView
