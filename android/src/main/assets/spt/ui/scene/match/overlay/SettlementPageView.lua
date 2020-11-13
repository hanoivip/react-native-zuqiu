local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local MatchInfoModel = require("ui.models.MatchInfoModel")
local QuestPageViewModel = require("ui.models.quest.QuestPageViewModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local SettlementPageView = class(unity.base)

function SettlementPageView:ctor()
    -- 比赛结果视图
    self.matchResultView = self.___ex.matchResultView
    -- 比赛结果数据视图
    self.matchDataView = self.___ex.matchDataView
    -- 精彩回放
    self.matchHighlightsView = self.___ex.matchHighlightsView
    -- 比赛关卡是否有特殊通关条件
    self.matchStageIsSpecial = false
    -- 比赛结果，1:胜利，0:平局，-1:失败
    self.resultStatus = nil
    self.matchInfoModel = nil
end

function SettlementPageView:start()
    EventSystem.SendEvent("FightMenuManager.CloseViewsOnCertainTime")
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self:JudgeMatchResult()
    self:RegisterEvent()
    self:ShowMatchResultView()
end

function SettlementPageView:ShowMatchResultView()
    self.matchResultView:InitView(self.resultStatus, self.matchStageIsSpecial)
    GameObjectHelper.FastSetActive(self.matchResultView.gameObject, true)
end

function SettlementPageView:ShowMatchDataView()
    self.matchDataView:InitView(self.resultStatus, self.matchStageIsSpecial)
    GameObjectHelper.FastSetActive(self.matchDataView.gameObject, true)
end

function SettlementPageView:ShowMatchHighlightsView()
    self.matchHighlightsView:InitView(self.matchInfoModel:GetPlayerTeamData(), self.matchInfoModel:GetOpponentTeamData(), self)
    GameObjectHelper.FastSetActive(self.matchResultView.gameObject, false)
    GameObjectHelper.FastSetActive(self.matchDataView.gameObject, false)
    GameObjectHelper.FastSetActive(self.matchHighlightsView.gameObject, true)
end

function SettlementPageView:ExitScene()
    EventSystem.SendEvent("FightMenuManager.ExitScene")
end

--- 注册事件
function SettlementPageView:RegisterEvent()
    EventSystem.AddEvent("SettlementPageView.ShowMatchDataView", self, self.ShowMatchDataView)
    EventSystem.AddEvent("SettlementPageView.ExitScene", self, self.ExitScene)
    EventSystem.AddEvent("SettlementPageView.ShowHighlightsView", self, self.ShowMatchHighlightsView)
end

--- 移除事件
function SettlementPageView:RemoveEvent()
    EventSystem.RemoveEvent("SettlementPageView.ShowMatchDataView", self, self.ShowMatchDataView)
    EventSystem.RemoveEvent("SettlementPageView.ExitScene", self, self.ExitScene)
    EventSystem.RemoveEvent("SettlementPageView.ShowHighlightsView", self, self.ShowMatchHighlightsView)
end

--- 判断比赛结果
function SettlementPageView:JudgeMatchResult()
    self.resultStatus = self.matchInfoModel:GetMatchResult()
    local matchResultData = cache.getMatchResult()
    if matchResultData.matchType == MatchConstants.MatchType.QUEST then
        local questPageViewModel = QuestPageViewModel.new()
        local matchStageId, matchStageIsCleared, matchStageIsSpecial = questPageViewModel:GetMatchStageId()
        self.matchStageIsSpecial = matchStageIsSpecial
    end
end

function SettlementPageView:GetMatchScoreText()
    return self.matchDataView:GetMatchScoreText()
end

function SettlementPageView:SetTeamName(teamNameText, teamName)
    self.matchDataView:SetTeamName(teamNameText, teamName)
end

function SettlementPageView:onDestroy()
    self:RemoveEvent()
end

return SettlementPageView