local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require ("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerDollRewardSelectItemView = class(unity.base)

function PlayerDollRewardSelectItemView:ctor()
    PlayerDollRewardSelectItemView.super.ctor(self)
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
    self.selectBtn = self.___ex.selectBtn
    self.selectGo = self.___ex.selectGo
--------End_Auto_Generate----------
end

function PlayerDollRewardSelectItemView:start()
    self.selectBtn:regOnButtonClick(function()
        self:OnBtnSelect()
    end)
end

function PlayerDollRewardSelectItemView:InitView(itemData, playerDollModel, canSelect)
    res.ClearChildren(self.contentTrans)
    self.playerDollModel = playerDollModel
    self.rewardId = itemData.id
    local rewardDetail = itemData.reward.contents
    local isRewardWanted = self.playerDollModel:IsRewardWanted(self.rewardId)
    GameObjectHelper.FastSetActive(self.selectBtn.gameObject, canSelect)
    GameObjectHelper.FastSetActive(self.selectGo, isRewardWanted)
    local rewardParams = {
        parentObj = self.contentTrans,
        rewardData = rewardDetail,
        isShowName = true,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function PlayerDollRewardSelectItemView:OnBtnSelect()
    local isRewardWanted = self.playerDollModel:IsRewardWanted(self.rewardId)
    local isRewardsFullFilledById = self.playerDollModel:IsRewardsFullFilledById(self.rewardId)
    if not isRewardWanted and isRewardsFullFilledById then
        DialogManager.ShowToast(lang.trans("timeLimit_player_doll_cantNotSelect"))
    else
        self.playerDollModel:SetWantedReward(self.rewardId, not isRewardWanted)
        GameObjectHelper.FastSetActive(self.selectGo, not isRewardWanted)
        EventSystem.SendEvent("PlayerDoll_RewardSelect")
    end
end

return PlayerDollRewardSelectItemView
