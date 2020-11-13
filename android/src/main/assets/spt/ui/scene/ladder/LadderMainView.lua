local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Object = UnityEngine.Object
local EventSystem = require("EventSystem")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ReqEventModel = require("ui.models.event.ReqEventModel")

local LadderMainView = class(unity.base)

function LadderMainView:ctor()
    -- 赛季排行按钮
    self.btnRank = self.___ex.btnRank
    -- 赛季奖励按钮
    self.btnReward = self.___ex.btnReward
    -- 对战记录按钮
    self.btnRecord = self.___ex.btnRecord
    -- 领取奖励按钮
    self.btnReceive = self.___ex.btnReceive
    -- 天梯商店按钮
    self.btnShop = self.___ex.btnShop
    -- 设置主场按钮
    self.btnSetHome = self.___ex.btnSetHome
    -- 换一批按钮
    self.btnChangeOpponents = self.___ex.btnChangeOpponents
    -- 帮助按钮
    self.btnHelp = self.___ex.btnHelp
    -- 每日奖励按钮
    self.btnDailyRewardDetail = self.___ex.btnDailyRewardDetail
    -- 我的排名
    self.txtRank = self.___ex.txtRank
    -- 当前排名可累计奖励
    self.txtRewardWithCurRank = self.___ex.txtRewardWithCurRank
    -- 累计可领取奖励
    self.txtTotalReceiveReward = self.___ex.txtTotalReceiveReward
    -- 今日挑战剩余次数
    self.txtRemainChallengeTimes = self.___ex.txtRemainChallengeTimes
    -- 冷却时间
    self.txtCoolTime = self.___ex.txtCoolTime
    self.coolTimeGo = self.___ex.coolTimeGo
    -- 奖励提示信息
    self.txtRewardHintInfo = self.___ex.txtRewardHintInfo
    -- 挑战对手区域
    self.challengeOpponentsContent = self.___ex.challengeOpponentsContent
    -- 玩家的荣誉点数
    self.txtMyHonorPoint = self.___ex.txtMyHonorPoint
    self.infoBarDynParent = self.___ex.infoBar
    self.menuBarDynParent = self.___ex.menuBarDynParent
    self.animator = self.___ex.animator
    self.honorEffect1 = self.___ex.honorEffect1
    self.honorEffect2 = self.___ex.honorEffect2
    self.honorEffect3 = self.___ex.honorEffect3
    -- 新纪录红点
    self.ladderRedPoint = self.___ex.ladderRedPoint
end

function LadderMainView:start()
    self:BindButtonHandler()
end

function LadderMainView:InitView(ladderModel)
    self.ladderModel = ladderModel
    self.txtRank.text = tostring(ladderModel:GetRank())
    self.txtRewardWithCurRank.text = tostring(ladderModel:GetRewardWithCurRank() * 12)
    self.txtTotalReceiveReward.text = tostring(ladderModel:GetTotalReceiveReward())
    self.txtRemainChallengeTimes.text = lang.trans("ladder_remainChallengeTimesValue", ladderModel:GetRemainChallengeTimes())
    if ladderModel:GetRank() == 1 then
        self.txtRewardHintInfo.text = lang.trans("ladder_rewardHintInfoForFirstRank")
    else
        self.txtRewardHintInfo.text = lang.trans("ladder_rewardHintInfo", ladderModel:GetRaiseRankForHigherReward())
    end
    self:RefreshMyCurHonorPoint()
    self:UpdateChallengeCd(ladderModel:GetCd())
    self:UpdateChallengeOpponents()
    self:IsShowLadderRedPoint()
end

function LadderMainView:BindButtonHandler()
    self.btnRank:regOnButtonClick(function()
        if self.onRank then
            self.onRank()
        end
    end)
    self.btnReward:regOnButtonClick(function()
        if self.onReward then
            self.onReward()
        end
    end)
    self.btnRecord:regOnButtonClick(function()
        if self.onRecord then
            self.onRecord()
        end
    end)
    self.btnReceive:regOnButtonClick(function()
        if self.onReceive then
            self.onReceive()
        end
    end)
    self.btnShop:regOnButtonClick(function()
        if self.onShop then
            self.onShop()
        end
    end)
    self.btnSetHome:regOnButtonClick(function()
        if self.onSetHome then
            self.onSetHome()
        end
    end)
    self.btnChangeOpponents:regOnButtonClick(function()
        if self.onChangeOpponents then
            self.onChangeOpponents()
        end
    end)
    self.btnDailyRewardDetail:regOnButtonClick(function()
        if self.onDailyRewardDetail then
            self.onDailyRewardDetail()
        end
    end)
    self.btnHelp:regOnButtonClick(function()
        if self.onRuleHelp then
            self.onRuleHelp()
        end
    end)
end

function LadderMainView:UpdateChallengeOpponents()
    if self.updateChallengeOpponents then
        self.updateChallengeOpponents()
    end
end

function LadderMainView:ClearChallengeOpponents()
    local count = self.challengeOpponentsContent.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.challengeOpponentsContent:GetChild(i).gameObject)
    end
end

function LadderMainView:AddChallengeOpponent(challengeTeamBar)
    challengeTeamBar.transform:SetParent(self.challengeOpponentsContent, false)
end

function LadderMainView:UpdateChallengeCd(leftSeconds)
    if leftSeconds <= 0 then
        GameObjectHelper.FastSetActive(self.coolTimeGo, false)
    else
        GameObjectHelper.FastSetActive(self.coolTimeGo, true)
        self:StartTimeCoroutine(leftSeconds)
    end
end

function LadderMainView:StartTimeCoroutine(leftSeconds)
    self:coroutine(function()
        self:SetCoolTimeText(leftSeconds)
        while true do
            coroutine.yield(WaitForSeconds(1))
            leftSeconds = math.max(leftSeconds - 1, 0)
            if leftSeconds <= 0 then
                self.ladderModel:SetCd(0)
                break
            end
            self:SetCoolTimeText(leftSeconds)
        end
    end)
end

function LadderMainView:SetCoolTimeText(leftSeconds)
    self.txtCoolTime.text = lang.trans("ladder_coolTime", string.formatTimeClock(leftSeconds, 60, ":"))
end

function LadderMainView:RefreshMyCurHonorPoint()
    self.txtMyHonorPoint.text = tostring(self.ladderModel:GetMyCurrentHonorPoint())
end

function LadderMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function LadderMainView:RegOnMenuBarDynamicLoad(func)
    self.menuBarDynParent:RegOnDynamicLoad(func)
end

function LadderMainView:IsShowLadderRedPoint()
    local ladderRecord = ReqEventModel.GetInfo("ladderRecord")
    GameObjectHelper.FastSetActive(self.ladderRedPoint, tonumber(ladderRecord) > 0)
end

function LadderMainView:RegisterEvent()
    EventSystem.AddEvent("Ladder_UpdateTotalReceiveReward", self, self.EventUpdateTotalReceiveReward)
    EventSystem.AddEvent("Ladder_UpdateChallengeOpponents", self, self.EventUpdateChallengeOpponents)
    EventSystem.AddEvent("Ladder_UpdateChallengeCd", self, self.EventUpdateChallengeCd)
    EventSystem.AddEvent("ReqEventModel_ladderRecord", self, self.IsShowLadderRedPoint)
end

function LadderMainView:UnRegisterEvent()
    EventSystem.RemoveEvent("Ladder_UpdateTotalReceiveReward", self, self.EventUpdateTotalReceiveReward)
    EventSystem.RemoveEvent("Ladder_UpdateChallengeOpponents", self, self.EventUpdateChallengeOpponents)
    EventSystem.RemoveEvent("Ladder_UpdateChallengeCd", self, self.EventUpdateChallengeCd)
    EventSystem.RemoveEvent("ReqEventModel_ladderRecord", self, self.IsShowLadderRedPoint)
end

function LadderMainView:EventUpdateTotalReceiveReward()
    self.txtTotalReceiveReward.text = tostring(self.ladderModel:GetTotalReceiveReward())
end

function LadderMainView:EventUpdateChallengeOpponents()
    self:UpdateChallengeOpponents()
end

function LadderMainView:EventUpdateChallengeCd()
    if self.ladderModel:IsCdDoing() then
        GameObjectHelper.FastSetActive(self.coolTimeGo, true)
    else
        GameObjectHelper.FastSetActive(self.coolTimeGo, false)
    end
end

function LadderMainView:OnLeave()
    if type(self.onLeaveCallBack) == "function" then
        self.onLeaveCallBack()
    end
end

function LadderMainView:PlayAccessAnimation()
    self.animator:Play("LadderAccess")
end

function LadderMainView:PlayLeaveAnimation()
    self.animator:Play("LadderLeave")
end

function LadderMainView:StopHonorEffect()
    GameObjectHelper.FastSetActive(self.honorEffect1, false)
    GameObjectHelper.FastSetActive(self.honorEffect2, false)
    GameObjectHelper.FastSetActive(self.honorEffect3, false)
end

function LadderMainView:PlayerHonorEffect()
    self:StopHonorEffect()
    GameObjectHelper.FastSetActive(self.honorEffect1, true)
    GameObjectHelper.FastSetActive(self.honorEffect2, true)
    GameObjectHelper.FastSetActive(self.honorEffect3, true)
end

return LadderMainView
