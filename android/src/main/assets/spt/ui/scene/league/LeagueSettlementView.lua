local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local QuestPageViewModel = require("ui.models.quest.QuestPageViewModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MatchInfoModel = require("ui.models.MatchInfoModel")

local LeagueSettlementView = class(unity.base)

function LeagueSettlementView:ctor()
    -- 比赛结果视图
    self.matchResultView = self.___ex.matchResultView
    -- 比赛结果数据视图
    self.matchDataView = self.___ex.matchDataView
    -- 比赛关卡是否有特殊通关条件
    self.matchStageIsSpecial = false
    -- 比赛结果，1:胜利，0:平局，-1:失败
    self.resultStatus = nil
    self.matchInfoModel = nil
end

function LeagueSettlementView:InitView(matchInfoModel)
    self.matchInfoModel = matchInfoModel
end

function LeagueSettlementView:start()
    if not self.matchInfoModel then
        self.matchInfoModel = MatchInfoModel.GetInstance()
    end
    self:JudgeMatchResult()
    self:RegisterEvent()
    self:ShowMatchResultView()
end

function LeagueSettlementView:ShowMatchResultView()
    self.matchResultView:InitView(self.resultStatus, self.matchStageIsSpecial)
    GameObjectHelper.FastSetActive(self.matchResultView.gameObject, true)
end

function LeagueSettlementView:ShowMatchDataView()
    self.matchDataView:InitView(self.resultStatus, self.matchStageIsSpecial)
    GameObjectHelper.FastSetActive(self.matchDataView.gameObject, true)
end

function LeagueSettlementView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

--- 注册事件
function LeagueSettlementView:RegisterEvent()
    EventSystem.AddEvent("SettlementPageView.ShowMatchDataView", self, self.ShowMatchDataView)
    EventSystem.AddEvent("SettlementPageView.ExitScene", self, self.Close)
end

--- 移除事件
function LeagueSettlementView:RemoveEvent()
    EventSystem.RemoveEvent("SettlementPageView.ShowMatchDataView", self, self.ShowMatchDataView)
    EventSystem.RemoveEvent("SettlementPageView.ExitScene", self, self.Close)
end

--- 判断比赛结果
function LeagueSettlementView:JudgeMatchResult()
    self.resultStatus = self.matchInfoModel:GetMatchResult()
    local matchResultData = cache.getMatchResult()
    if matchResultData.matchType == MatchConstants.MatchType.QUEST then
        local questPageViewModel = QuestPageViewModel.new()
        local matchStageId, matchStageIsCleared, matchStageIsSpecial = questPageViewModel:GetMatchStageId()
        self.matchStageIsSpecial = matchStageIsSpecial
    end
end

function LeagueSettlementView:GetMatchScoreText()
    return self.matchDataView:GetMatchScoreText()
end

function LeagueSettlementView:SetTeamName(teamNameText, teamName)
    self.matchDataView:SetTeamName(teamNameText, teamName)
end

function LeagueSettlementView:onDestroy()
    self:RemoveEvent()
end

return LeagueSettlementView