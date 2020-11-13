local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamHallView = class(unity.base)

function DreamHallView:ctor()
    self.boardTitle = self.___ex.boardTitle
    self.myScore = self.___ex.myScore
    self.yesterdayScore = self.___ex.yesterdayScore
    self.yesterdayTitle = self.___ex.yesterdayTitle
    self.boardMatchScroll = self.___ex.boardMatchScroll
    self.yesterdayMatchScroll = self.___ex.yesterdayMatchScroll
    self.foramtionBtn = self.___ex.foramtionBtn
    self.formationButton = self.___ex.formationButton
    self.myLeagueBtn = self.___ex.myLeagueBtn
    self.rewardBtn = self.___ex.rewardBtn
    self.formationEnable = self.___ex.formationEnable
    self.formationDisable = self.___ex.formationDisable
end

function DreamHallView:InitView(dreamHallModel)
    self.dreamHallModel = dreamHallModel
    self.foramtionBtn:regOnButtonClick(function ()
        if self.onForamtionClick then
            self.onForamtionClick()
        end
    end)
    self.myLeagueBtn:regOnButtonClick(function ()
        if self.onMyLeagueClick then
            self.onMyLeagueClick()
        end
    end)
    self.rewardBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.dreamLeague.dreamDailyReward.DreamDailyRewardCtrl")
    end)
    local boardTitleText = self.dreamHallModel:GetBoardTitleText()
    local myScoreText = self.dreamHallModel:GetMyScoreText()
    local yesterdayScoreText = self.dreamHallModel:GetYesterdayScoreText()
    self.boardTitle.text = boardTitleText
    self.myScore.text = myScoreText
    self.yesterdayScore.text = yesterdayScoreText
    self.yesterdayMatchScroll:RegOnItemButtonClick("more", function(data)
        if self.onYesterdayDetailClick then
            self.onYesterdayDetailClick(data)
        end
    end)

    local notEnding = self.dreamHallModel:IsCanSetFormation()
    GameObjectHelper.FastSetActive(self.formationEnable, notEnding)
    GameObjectHelper.FastSetActive(self.formationDisable, not notEnding)

    self:InitBoardMatchScrollView()
    self:InitYesterdayMatchScrollView()
end

function DreamHallView:InitBoardMatchScrollView()
    local boardMatchData = self.dreamHallModel:GetBoardMatchScrollData()
    self.boardMatchScroll:InitView(boardMatchData)
end

function DreamHallView:InitYesterdayMatchScrollView()
    local yesterdayMatchData = self.dreamHallModel:GetYesterdayMatchScrollData()
    self.yesterdayMatchScroll:InitView(yesterdayMatchData)
end

return DreamHallView
