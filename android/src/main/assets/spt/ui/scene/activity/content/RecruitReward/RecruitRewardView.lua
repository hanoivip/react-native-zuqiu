local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardIndexModel = require("ui.models.cardIndex.CardIndexModel")
local RecruitRewardView = class(ActivityParentView)

function RecruitRewardView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.specialCardView = self.___ex.specialCardView
    self.progressRewardSpt = self.___ex.progressRewardSpt
    self.progressRewardLSpt = self.___ex.progressRewardLSpt
    self.btnReward = self.___ex.btnReward
    self.btnRanking = self.___ex.btnRanking
    self.buttonReward = self.___ex.buttonReward
    self.buttonRanking = self.___ex.buttonRanking
    self.btnRefresh = self.___ex.btnRefresh
    self.rankingListScrollView = self.___ex.rankingListScrollView
    self.rankingScroll = self.___ex.rankingScroll
    self.rewardScroll = self.___ex.rewardScroll
    self.rewardListScrollView = self.___ex.rewardListScrollView
    self.btnRule = self.___ex.btnRule
    self.btnGoToStore = self.___ex.btnGoToStore
    self.btnRefreshObj = self.___ex.btnRefreshObj
    self.myRank = self.___ex.myRank
    self.myScore = self.___ex.myScore
    self.afterActEndTextObj = self.___ex.afterActEndTextObj
    self.actTimeText = self.___ex.actTimeText
    self.recruitTimeText = self.___ex.recruitTimeText
    self.recruitTimeTextL = self.___ex.recruitTimeTextL
    self.progressItemArea = self.___ex.progressItemArea
    self.progressItemAreaL = self.___ex.progressItemAreaL

    self.residualTimer = nil
end

function RecruitRewardView:start()
    self.btnRefresh:regOnButtonClick(function()
        if self.clickRefresh then
            self.clickRefresh()
        end
    end)
    self.buttonReward:regOnButtonClick(function()
        if self.clickReward then
            self.clickReward()
        end
    end)
    self.buttonRanking:regOnButtonClick(function()
        if self.clickRanking then
            self.clickRanking()
        end
    end)
    self.btnRule:regOnButtonClick(function()
        if self.clickRule then
            self.clickRule()
        end
    end)
    self.btnGoToStore:regOnButtonClick(function()
        if self.clickGoToStore then
            self.clickGoToStore()
        end
    end)
end

function RecruitRewardView:InitView(activityModel, specialCardCidList)
    self.recruitRewardModel = activityModel
    self.recruitTimeText.text = tostring(self.recruitRewardModel:GetRecruitTime())
    self.recruitTimeTextL.text = tostring(self.recruitRewardModel:GetRecruitTime())

    if not self.cardIndexModel then
        self.cardIndexModel = CardIndexModel.new()
    end
    
    self.specialCardView:RefreshItemWithScrollPos(specialCardCidList, 0, self.cardIndexModel)  --special cardlist
end

function RecruitRewardView:SwitchRankingAndReward(isShowRanking)
    GameObjectHelper.FastSetActive(self.rankingScroll, isShowRanking)
    GameObjectHelper.FastSetActive(self.btnRefreshObj, isShowRanking)
    GameObjectHelper.FastSetActive(self.rewardScroll, not isShowRanking)
end

function RecruitRewardView:RefreshContent()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    self.residualTimer = Timer.new(self.activityModel:GetRemainTime(), function(time)
        dump("Timer loops...")
        self.residualTime.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
    end)

    self.activityDes.text = self.cumulativeConsumeModel:GetActivityDesc()
end

function RecruitRewardView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return RecruitRewardView