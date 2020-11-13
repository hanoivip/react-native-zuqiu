local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerDollModel = require("ui.models.activity.playerDoll.PlayerDollModel")
local RewardState = PlayerDollModel.RewardState
local PlayerDollTimesRewardItemView = class(unity.base)

function PlayerDollTimesRewardItemView:ctor()
    PlayerDollTimesRewardItemView.super.ctor(self)
--------Start_Auto_Generate--------
    self.imgGiftAnim = self.___ex.imgGiftAnim
    self.effectGo = self.___ex.effectGo
    self.maskGo = self.___ex.maskGo
    self.imgDarkIconGo = self.___ex.imgDarkIconGo
    self.imgStateLockGo = self.___ex.imgStateLockGo
    self.imgStateClaimedGo = self.___ex.imgStateClaimedGo
    self.timesTxt = self.___ex.timesTxt
--------End_Auto_Generate----------
end

function PlayerDollTimesRewardItemView:InitView(rewardData, playerDollModel)
    local itemId = rewardData.id
    local state = playerDollModel:GetCountRewardState(tostring(itemId))
    self.timesTxt.text = lang.trans("timeLimit_player_doll_timesForReward", rewardData.reward.count)
    local isCanNotReceive = state == RewardState.CanNotReceive
    local isCanReceive = state == RewardState.CanReceive
    local isReceived = state == RewardState.Received
    GameObjectHelper.FastSetActive(self.imgDarkIconGo, isReceived)
    GameObjectHelper.FastSetActive(self.imgStateLockGo, isCanNotReceive)
    GameObjectHelper.FastSetActive(self.imgStateClaimedGo, isReceived)
    GameObjectHelper.FastSetActive(self.effectGo, isCanReceive)
    GameObjectHelper.FastSetActive(self.maskGo, isCanReceive)
    self.imgGiftAnim.enabled = isCanReceive
end

return PlayerDollTimesRewardItemView
