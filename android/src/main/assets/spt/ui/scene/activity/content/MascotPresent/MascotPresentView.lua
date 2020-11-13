local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.models.activity.mascotPresent.CommonConstants")
local MascotPresentView = class(ActivityParentView)

function MascotPresentView:ctor()
    self.residualTime = self.___ex.residualTime
    self.activityDes = self.___ex.activityDes
    self.progressRewardLSpt = self.___ex.progressRewardLSpt
    self.progressItemArea = self.___ex.progressItemArea
    self.progressItemAreaL = self.___ex.progressItemAreaL
    self.progressRewardSpt = self.___ex.progressRewardSpt
    self.btnRule = self.___ex.btnRule
    self.btnMemberReward = self.___ex.btnMemberReward
    self.memberRewardScroller = self.___ex.memberRewardScroller
    self.memberRewardScrollView = self.___ex.memberRewardScrollView
    self.guildRewardScrollView = self.___ex.guildRewardScrollView
    self.guildRewardScroller = self.___ex.guildRewardScroller
    self.btnGuildReward = self.___ex.btnGuildReward
    self.btnRankingReward = self.___ex.btnRankingReward
    self.btnContribute = self.___ex.btnContribute
    self.actDescText = self.___ex.actDescText
    self.refreshTimeTip = self.___ex.refreshTimeTip
    self.btnGuildTaskSpt = self.___ex.btnGuildTaskSpt
    self.btnMemberTaskSpt = self.___ex.btnMemberTaskSpt
    self.myGuildName = self.___ex.myGuildName
    self.myGuildRank = self.___ex.myGuildRank
    self.myGuildPoint = self.___ex.myGuildPoint
    self.redPoint1 = self.___ex.guildTaskRedPoint
    self.redPoint2 = self.___ex.memberTaskRedPoint
    self.progressItemAreaS = self.___ex.progressItemAreaS
    self.progressRewardSSpt = self.___ex.progressRewardSSpt
end

function MascotPresentView:start()
    EventSystem.AddEvent("MascotPresent_RefreshGorMRewardRP", self, self.RefreshRedPoint)
    EventSystem.AddEvent("MascotPresent_RefreshGuildPointAndProgressGiftArea", self, self.RefreshGuildPointAndProgressGiftArea)
    EventSystem.AddEvent("MascotPresent_RefreshTaskRewardArea", self, self.RefreshTaskRewardArea)

    self.btnGuildReward:regOnButtonClick(function()
        if self.clickGuildReward then
            self.clickGuildReward()
        end
    end)
    self.btnMemberReward:regOnButtonClick(function()
        if self.clickMemberReward then
            self.clickMemberReward()
        end
    end)

    self.btnRankingReward:regOnButtonClick(function()
        if self.clickRankingReward then
            self.clickRankingReward()
        end
    end)
    self.btnContribute:regOnButtonClick(function()
        if self.clickContribute then
            self.clickContribute()
        end
    end)

    self.btnRule:regOnButtonClick(function()
        if self.clickRule then
            self.clickRule()
        end
    end)
end

function MascotPresentView:InitView(mascotPresentModel)
    self.activityModel = mascotPresentModel

    self:RefreshRedPoint()
    self:InitStaticTextArea()
    self:InitRewardScrollArea()
end

function MascotPresentView:RefreshRedPoint()
    local isGuildRedPointShow = self.activityModel:IsShowTaskRewardRedPoint(CommonConstants.GUILD_REWARD_INDEX)
    local isMemberRedPointShow = self.activityModel:IsShowTaskRewardRedPoint(CommonConstants.MEMBER_REWARD_INDEX)
    GameObjectHelper.FastSetActive(self.redPoint1, isGuildRedPointShow)
    GameObjectHelper.FastSetActive(self.redPoint2, isMemberRedPointShow)
end

function MascotPresentView:InitStaticTextArea()
    self.myGuildName.text = lang.transstr("mascotPresent_desc10") .. tostring(self.activityModel:GetMyGuildName())
    self:RefreshMyGuildRankText()
    self:RefreshMyGuildPointValue()
    self.actDescText.text = self.activityModel:GetActDescWithComma()
    self.refreshTimeTip.text = self.activityModel:GetRefreshTimeTipWithComma()
end

function MascotPresentView:RefreshTaskRewardArea()
    if type(self.refreshTaskRewardArea) == "function" then
        self.refreshTaskRewardArea()
    end
end

function MascotPresentView:RefreshMyGuildRankText()
    self.myGuildRank.text = tostring(self.activityModel:GetMyGuildRank())
end

function MascotPresentView:RefreshGuildPointAndProgressGiftArea()
    if type(self.refreshProgressRewardArea) == "function" then
        self.refreshProgressRewardArea()
    end
    self:RefreshMyGuildPointValue()
end

function MascotPresentView:RefreshMyGuildPointValue()
    self.myGuildPoint.text = tostring(self.activityModel:GetMyGuildPointValue())
end

function MascotPresentView:InitRewardScrollArea()
    self:ShowGuildRewardArea(true)

    self:InitGuildRewardScroller()
end

function MascotPresentView:InitGuildRewardScroller()
    self.guildRewardScrollView:InitView(self.activityModel, CommonConstants.GUILD_REWARD_INDEX)
end

function MascotPresentView:InitMemberRewardScroller()
    self.memberRewardScrollView:InitView(self.activityModel, CommonConstants.MEMBER_REWARD_INDEX)
end

function MascotPresentView:ShowGuildRewardArea(isShowGuildReward)
    GameObjectHelper.FastSetActive(self.guildRewardScroller, isShowGuildReward)
    GameObjectHelper.FastSetActive(self.memberRewardScroller, not isShowGuildReward)
    GameObjectHelper.FastSetActive(self.refreshTimeTip.gameObject, not isShowGuildReward)
    self.btnGuildTaskSpt:InitView(isShowGuildReward)
    self.btnMemberTaskSpt:InitView(not isShowGuildReward)
end

function MascotPresentView:onDestroy()
    EventSystem.RemoveEvent("MascotPresent_RefreshGorMRewardRP", self, self.RefreshRedPoint)
    EventSystem.RemoveEvent("MascotPresent_RefreshGuildPointAndProgressGiftArea", self, self.RefreshGuildPointAndProgressGiftArea)
    EventSystem.RemoveEvent("MascotPresent_RefreshTaskRewardArea", self, self.RefreshTaskRewardArea)
end

return MascotPresentView