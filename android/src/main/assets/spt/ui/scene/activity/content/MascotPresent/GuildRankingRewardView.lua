local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuildRankingRewardView = class(unity.base)

function GuildRankingRewardView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.rankingScrollView = self.___ex.rankingScrollView
    self.rewardScrollView = self.___ex.rewardScrollView
    self.btnRanking = self.___ex.btnRanking
    self.btnReward = self.___ex.btnReward
    self.rankingObj = self.___ex.rankingObj
    self.rewardObj = self.___ex.rewardObj
    self.btnRankingSpt = self.___ex.btnRankingSpt
    self.btnRewardSpt = self.___ex.btnRewardSpt
    self.myGuildName = self.___ex.myGuildName
    self.myGuildRank = self.___ex.myGuildRank
    self.myGuildPointValue = self.___ex.myGuildPointValue
    self.rectTransform = self.___ex.transform

    DialogAnimation.Appear(self.rectTransform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function GuildRankingRewardView:start()
    self.btnRanking:regOnButtonClick(function()
        if self.clickRanking then
            self.clickRanking()
        end
    end)
    self.btnReward:regOnButtonClick(function()
        if self.clickReward then
            self.clickReward()
        end
    end)
end

function GuildRankingRewardView:InitView(mascotPresentModel)
    self.activityModel = mascotPresentModel
    self:InitMyGuildInfo()
    self:InitRankingRewardArea()
end

function GuildRankingRewardView:InitMyGuildInfo()
    self.myGuildName.text = tostring(self.activityModel:GetMyGuildName())
    self.myGuildRank.text = tostring(self.activityModel:GetMyGuildRank())
    local value = self.activityModel:GetMyGuildPointValue()
    value = value > 0 and value or "-"
    self.myGuildPointValue.text = tostring(value)
end

function GuildRankingRewardView:InitRankingRewardArea()
    self:ShowRankingScrollArea(true)

    self:InitRewardScroller()
    self:InitRankingScroller()
end

function GuildRankingRewardView:InitRankingScroller()
    self.rankingScrollView:InitView(self.activityModel)
end

function GuildRankingRewardView:InitRewardScroller()
    self.rewardScrollView:InitView(self.activityModel)
end

function GuildRankingRewardView:ShowRankingScrollArea(isShowRanking)
    GameObjectHelper.FastSetActive(self.rankingObj, isShowRanking)
    GameObjectHelper.FastSetActive(self.rewardObj, not isShowRanking)
    self.btnRankingSpt:InitView(isShowRanking)
    self.btnRewardSpt:InitView(not isShowRanking)
end

function GuildRankingRewardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.rectTransform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildRankingRewardView