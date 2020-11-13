local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Mathf = UnityEngine.Mathf
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local Time = UnityEngine.Time
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local LeagueSeasonInfoPageCtrl = require("ui.controllers.league.LeagueSeasonInfoPageCtrl")
local LeagueRankPageCtrl = require("ui.controllers.league.LeagueRankPageCtrl")
local MatchLoader = require("coregame.MatchLoader")
local LeagueCtrl = require("ui.controllers.league.LeagueCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local Timer = require("ui.common.Timer")

local LeagueMainPageView = class(unity.base)
-- 联赛最高级别时隐藏晋级信息
local TopLevel = 10
function LeagueMainPageView:ctor()
    -- 顶部信息条框
    self.infoBarBox = self.___ex.infoBarBox
    -- 开始比赛按钮
    self.startBtn = self.___ex.startBtn
    -- 赛季信息按钮
    self.seasonInfoBtn = self.___ex.seasonInfoBtn
    -- 排行榜按钮
    self.rankBtn = self.___ex.rankBtn
    -- 左翻页按钮
    self.leftSwitchBtn = self.___ex.leftSwitchBtn
    -- 右翻页按钮
    self.rightSwitchBtn = self.___ex.rightSwitchBtn
    -- 标题
    self.title = self.___ex.title
    -- 标题-en
    self.title_En = self.___ex.title_En
    -- 晋级说明
    self.titleTips = self.___ex.titleTips
    -- 下一轮比赛节点
    self.nextMatchNode = self.___ex.nextMatchNode
    self.nextMatchCanvasGroup = self.___ex.nextMatchCanvasGroup
    -- 赛程节点
    self.scheduleNode = self.___ex.scheduleNode
    self.scheduleCanvasGroup = self.___ex.scheduleCanvasGroup
    -- 统计信息节点
    self.statisticsNode = self.___ex.statisticsNode
    self.statisticsCanvasGroup = self.___ex.statisticsCanvasGroup
    -- 剩余场数
    self.leftTimes = self.___ex.leftTimes
    -- Vip剩余场数
    self.vipLeftTimes = self.___ex.vipLeftTimes
    self.vipLeftTimesBox = self.___ex.vipLeftTimesBox
    -- 开始按钮文本
    self.startBtnText = self.___ex.startBtnText
    -- 动画管理器
    self.animator = self.___ex.animator
    self.menuBarDynParent = self.___ex.menuBarDynParent
    self.needTime = self.___ex.needTime
    -- 中间的比赛按钮
    self.centerBtn = self.___ex.centerBtn
    -- 自动比赛扫荡按钮
    self.autoStartBtn = self.___ex.autoStartBtn
    -- 底部按钮的动画控制器
    self.bottomAnimator = self.___ex.bottomAnimator
    -- 非月卡用户的 钻石提示
    self.tipsGo = self.___ex.tipsGo
    -- 月卡用户的免费提示
    self.freeGo = self.___ex.freeGo
    -- 扫荡价格
    self.sweepCostTxt = self.___ex.sweepCostTxt
    -- 中间比赛按钮的文字
    self.centerTxt = self.___ex.centerTxt

    -- model
    self.leagueInfoModel = nil
    -- 联赛等级
    self.leagueLevel = nil
    -- 联赛基础信息
    self.baseInfo = nil
    -- 中间界面的位置索引
    self.middlePagePosIndex = LeagueConstants.MainPageMiddleAnimPosIndex
    -- 动画位置列表
    self.animPosList = nil
    -- 是否正在播放动画
    self.isAnimPlaying = false
    -- 赛季是否已结束
    self.isEnded = false
    -- 是否构建界面
    self.isBuildPage = false
    self.matchTimesTimer = nil
    -- 底部动画的开合状态
    self.startBtnAnimState = false
end

function LeagueMainPageView:InitView(leagueInfoModel, isBuildPage, isNewSeason, onCreateNextMatchPage)
    self.leagueInfoModel = leagueInfoModel
    self.leagueLevel = self.leagueInfoModel:GetLeagueLevel()
    self.baseInfo = self.leagueInfoModel:GetBaseInfo()
    self.isEnded = self.leagueInfoModel:GetSeasonIsEnded()
    self.isMonthCard = self.leagueInfoModel:IsMonthCard()
    self.sweepCost = self.leagueInfoModel:GetSweepCost()

    self.isBuildPage = isBuildPage
    self.onCreateNextMatchPage = onCreateNextMatchPage
    if not self.animPosList then
        self.animPosList = clone(LeagueConstants.MainPageAnimPosList)
    end
    if isNewSeason then
        self.middlePagePosIndex = LeagueConstants.MainPageMiddleAnimPosIndex
    end
    if self.isEnded then
        if #self.animPosList == 3 then
            table.remove(self.animPosList)
        end
    else
        if #self.animPosList == 2 then
            self.animPosList = clone(LeagueConstants.MainPageAnimPosList)
        end
    end

    self:BuildPage()
    self:SetAnimState()
    local fee = self.leagueInfoModel:GetRewardSponsorshipFee()
    if fee <= 0 then
        GuideManager.Show()
    end
    GameObjectHelper.FastSetActive(self.tipsGo, not self.isMonthCard)
    GameObjectHelper.FastSetActive(self.freeGo, self.isMonthCard)
    self.sweepCostTxt.text = "x" .. self.sweepCost
end

function LeagueMainPageView:start()
    self:BindAll()
    self:RegisterEvent()
end

function LeagueMainPageView:RegisterEvent()
    EventSystem.AddEvent("League_RefreshChallengeTimes", self, self.BuildMatchTimes)
end

function LeagueMainPageView:RemoveEvent()
    EventSystem.RemoveEvent("League_RefreshChallengeTimes", self, self.BuildMatchTimes)
end

function LeagueMainPageView:BindAll()
    -- 赛季信息按钮
    self.seasonInfoBtn:regOnButtonClick(function ()
        LeagueSeasonInfoPageCtrl.new(self.leagueInfoModel)
    end)

    -- 联赛排行榜按钮
    self.rankBtn:regOnButtonClick(function ()
        LeagueRankPageCtrl.new(self.leagueInfoModel)
    end)

    -- 开始按钮
    self.startBtn:regOnButtonClick(function ()
        if not self.isEnded then
            if self.leagueInfoModel:GetRemainFreeTime() > 0 or self.leagueInfoModel:IsHasVIPTime() > 0 then
                local response = req.leagueStartMatch()
                if api.success(response) then
                    local playerTeamsModel = PlayerTeamsModel.new()
                    CustomEvent.LeagueMatchStart(self.leagueLevel, playerTeamsModel:GetTotalPower())
                    MatchLoader.startMatch(response.val)
                end
            elseif self.leagueInfoModel:GetTotalBuyTimes() > 0 and self.leagueInfoModel:GetLastBuyTimes() > 0 then
                res.PushDialog("ui.controllers.league.LeagueBuyChallengeTimesCtrl", self.leagueInfoModel)
            else
                local vipLevel = PlayerInfoModel.new():GetVipLevel()
                local dialogCallback = nil
                local dialogTip = nil
                
                if vipLevel < 7 then
                    dialogCallback = function ()
                        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl","vip", 7)
                    end
                    dialogTip = lang.trans("league_tip")
                elseif vipLevel >= 7 and vipLevel <= 10 then
                    dialogCallback = function ()
                        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl","vip", 11)
                    end
                    dialogTip = lang.trans("league_tip")
                else
                    dialogCallback = nil
                    dialogTip = lang.trans("match_time_is_zero")
                end
                if dialogCallback ~= nil then
                    DialogManager.ShowConfirmPop(lang.trans("tips"), dialogTip, dialogCallback)
                else
                    DialogManager.ShowToast(dialogTip)
                end
            end
        else
            local response = req.leagueNewSeason()
            if api.success(response) then
                LeagueCtrl.new()
            end
        end
    end)

    -- 右翻页按钮
    self.leftSwitchBtn:regOnButtonClick(function ()
        if self.isAnimPlaying then
            return
        end
        self.middlePagePosIndex = self.middlePagePosIndex + 1
        if self.middlePagePosIndex > #self.animPosList then
            self.middlePagePosIndex = 1
        end
        table.insert(self.animPosList, 1, table.remove(self.animPosList))
        self:PlaySwitchAnim()
    end)

    -- 左翻页按钮
    self.rightSwitchBtn:regOnButtonClick(function ()
        if self.isAnimPlaying then
            return
        end
        self.middlePagePosIndex = self.middlePagePosIndex - 1
        if self.middlePagePosIndex < 1 then
            self.middlePagePosIndex = #self.animPosList
        end
        table.insert(self.animPosList, table.remove(self.animPosList, 1))
        self:PlaySwitchAnim()
    end)

    -- 中间的比赛按钮
    self.centerBtn:regOnButtonClick(function()
        if self.isEnded then
            if self.onNewSeason then
                self.onNewSeason()
            end
        else
            local animName = "Close"
            if self.startBtnAnimState then
                animName = "Close"
            else
                animName = "Open"
            end
            local startBtnAnimState = self:GetStartBtnAnimState()
            self:SetStartBtnAnimState(not startBtnAnimState)
            self.bottomAnimator:Play(animName, 0)
        end
    end)

    -- 自动比赛扫荡按钮
    self.autoStartBtn:regOnButtonClick(function ()
        self:OnAutoStartBtnClick()
    end)
end

function LeagueMainPageView:RegOnDynamicLoad(func)
    self.infoBarBox:RegOnDynamicLoad(func)
end

function LeagueMainPageView:SetStartBtnAnimState(state)
    self.startBtnAnimState = state
end

function LeagueMainPageView:GetStartBtnAnimState()
    return self.startBtnAnimState or false
end

function LeagueMainPageView:ShowNeedTime()
    local needTime = self.baseInfo.r_t
    if needTime > 0 then
        if self.matchTimesTimer ~= nil then
            self.matchTimesTimer:Destroy()
            self.matchTimesTimer = nil
        end
        self.matchTimesTimer = Timer.new(needTime, function (secondTime)
            if secondTime > 0 then
                self.needTime.text = lang.trans("league_leftTimeShow", string.convertSecondToTime(secondTime))
            else
                self.baseInfo.free = self.baseInfo.free + 1
                self:BuildMatchTimes()
                if self.baseInfo.free < LeagueConstants.MaxMatchTimes then
                    self.baseInfo.r_t = 21600
                    self:ShowNeedTime()
                else
                    self.needTime.gameObject:SetActive(false)
                    self.matchTimesTimer:Destroy()
                end
            end
        end)
    end
    GameObjectHelper.FastSetActive(self.needTime.gameObject, needTime > 0)
end

function LeagueMainPageView:BuildPage()
    self.title.text = lang.trans("league_leagueLevel", self.leagueLevel)
    self.title_En.text = "LEAGUE Lv." .. tostring(self.leagueLevel)
    GameObjectHelper.FastSetActive(self.titleTips, self.leagueLevel ~= TopLevel)
    self:BuildMatchTimes()
    self:ShowNeedTime()
    if not self.isBuildPage then
        return
    end
    res.ClearChildren(self.nextMatchNode)
    res.ClearChildren(self.scheduleNode)
    res.ClearChildren(self.statisticsNode)

    if not self.isEnded then
        -- 下一轮比赛界面
        local nextMatchPage = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueNextMatch.prefab"))
        nextMatchPage.transform:SetParent(self.nextMatchNode, false)
        local nextMatchScripts = nextMatchPage:GetComponent(CapsUnityLuaBehav)
        nextMatchScripts:InitView(self.leagueInfoModel, self.onCreateNextMatchPage)
        self.centerTxt.text = lang.trans("match")
    else
        self.centerTxt.text = lang.trans("league_startNewSeason")
        self.bottomAnimator:Play("Close", 0)
    end

    -- 赛程界面
    local schedulePage = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueSchedule.prefab"))
    schedulePage.transform:SetParent(self.scheduleNode, false)
    local scheduleScripts = schedulePage:GetComponent(CapsUnityLuaBehav)
    scheduleScripts:InitView(self.leagueInfoModel)

    -- 统计信息界面
    local statisticsPage = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueStatistics.prefab"))
    statisticsPage.transform:SetParent(self.statisticsNode, false)
    local statisticsScripts = statisticsPage:GetComponent(CapsUnityLuaBehav)
    statisticsScripts:InitView(self.leagueInfoModel)
end

function LeagueMainPageView:BuildMatchTimes()
    self.leftTimes.text = lang.trans("league_leftTimes", "<color=#7BFD11>" .. self.baseInfo.free .. "</color>/" .. LeagueConstants.MaxMatchTimes)
    if tonumber(self.baseInfo.extraMaxCount) > 0 then
        self.vipLeftTimes.text = lang.trans("league_vipLeftTimes", "<color=#7BFD11>" .. (self.baseInfo.extraMaxCount - self.baseInfo.extraCnt) .. "</color>/" .. self.baseInfo.extraMaxCount)
        GameObjectHelper.FastSetActive(self.vipLeftTimesBox, true)
    else
        GameObjectHelper.FastSetActive(self.vipLeftTimesBox, false)
    end
end

--- 设置动画状态
function LeagueMainPageView:SetAnimState()
    if not self.isEnded then
        self:SetNodeState(LeagueConstants.MainPageMiddleAnimPosIndex - 1, self.scheduleNode, self.scheduleCanvasGroup)
        self:SetNodeState(LeagueConstants.MainPageMiddleAnimPosIndex, self.nextMatchNode, self.nextMatchCanvasGroup)
        self:SetNodeState(LeagueConstants.MainPageMiddleAnimPosIndex + 1, self.statisticsNode, self.statisticsCanvasGroup)
    else
        self:SetNodeState(LeagueConstants.MainPageMiddleAnimPosIndex - 1, self.scheduleNode, self.scheduleCanvasGroup)
        self:SetNodeState(LeagueConstants.MainPageMiddleAnimPosIndex, self.statisticsNode, self.statisticsCanvasGroup)
    end
end

--- 设置节点的状态
function LeagueMainPageView:SetNodeState(animPosIndex, node, nodeCanvasGroup)
    local animState = self.animPosList[animPosIndex]
    node.anchoredPosition3D = Vector3(animState.POS[1], animState.POS[2], animState.POS[3])
    nodeCanvasGroup.alpha = animState.ALPHA

    if animPosIndex == self.middlePagePosIndex then
        node:SetAsLastSibling()
    end
end

--- 播放切换动画
function LeagueMainPageView:PlaySwitchAnim()
    self.isAnimPlaying = true
    if not self.isEnded then
        self:PlayNodeAnim(LeagueConstants.MainPageMiddleAnimPosIndex - 1, self.scheduleNode, self.scheduleCanvasGroup)
        self:PlayNodeAnim(LeagueConstants.MainPageMiddleAnimPosIndex, self.nextMatchNode, self.nextMatchCanvasGroup)
        self:PlayNodeAnim(LeagueConstants.MainPageMiddleAnimPosIndex + 1, self.statisticsNode, self.statisticsCanvasGroup)
    else
        self:PlayNodeAnim(LeagueConstants.MainPageMiddleAnimPosIndex - 1, self.scheduleNode, self.scheduleCanvasGroup)
        self:PlayNodeAnim(LeagueConstants.MainPageMiddleAnimPosIndex, self.statisticsNode, self.statisticsCanvasGroup)
    end
end

--- 播放节点动画
function LeagueMainPageView:PlayNodeAnim(animPosIndex, node, nodeCanvasGroup)
    local animState = self.animPosList[animPosIndex]
    local moveTweener = ShortcutExtensions.DOAnchorPos3D(node, Vector3(animState.POS[1], animState.POS[2], animState.POS[3]), 0.3)
    local fadeTweener = ShortcutExtensions.DOFade(nodeCanvasGroup, animState.ALPHA, 0.3)
    if animPosIndex == self.middlePagePosIndex then
        node:SetAsLastSibling()
        TweenSettingsExtensions.OnComplete(moveTweener, function ()  --Lua assist checked flag
            self.isAnimPlaying = false
        end)
    end
end

function LeagueMainPageView:PlayMoveOutAnim()
    self.animator:Play("Base Layer.MoveOut", 0)
end

function LeagueMainPageView:RegOnMenuBarDynamicLoad(func)
    self.menuBarDynParent:RegOnDynamicLoad(func)
end

function LeagueMainPageView:OnAutoStartBtnClick()
    local isMonthCard = self.leagueInfoModel:IsMonthCard()
    if isMonthCard and self.onSweep then
        self.onSweep()
    else
        local title = lang.trans("tips")
        local contentStr = lang.trans("league_monthcard_buy", self.sweepCost)
        DialogManager.ShowConfirmPop(title, contentStr, function()
            CostDiamondHelper.CostDiamond(self.sweepCost, self, function()
                if self.onSweep then
                    self.onSweep()
                end
            end)
        end)
    end
end

function LeagueMainPageView:OnAnimEnd(animMoveType)
    if animMoveType == 1 then
        if type(self.onMoveOutAnimEnd) == "function" then
            self.onMoveOutAnimEnd()
        end
    end
end

function LeagueMainPageView:onDestroy()
    self:RemoveEvent()
    if self.matchTimesTimer ~= nil then
        self.matchTimesTimer:Destroy()
        self.matchTimesTimer = nil
    end
end

return LeagueMainPageView
