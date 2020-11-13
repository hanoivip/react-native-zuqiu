local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local CommonConstants = require("ui.common.CommonConstants")
local PeakRuleSeasonRewardSplitView = class(unity.base)

function PeakRuleSeasonRewardSplitView:ctor()
--------Start_Auto_Generate--------
    self.itemTrans = self.___ex.itemTrans
    self.nameTxt = self.___ex.nameTxt
    self.numberTxt = self.___ex.numberTxt
--------End_Auto_Generate----------
end

function PeakRuleSeasonRewardSplitView:InitView(data)
    res.ClearChildren(self.itemTrans)
    local rewardParams = {
        parentObj = self.itemTrans,
        rewardData = data,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
    self.nameTxt.text = RewardNameHelper.GetSingleContentName(data)
    self.numberTxt.text = "x" .. self:GetItemCount(data)
end

function PeakRuleSeasonRewardSplitView:GetItemCount(reward)
    local firstRewardType = reward and next(reward)
    if firstRewardType then
        local fisrtData = reward[firstRewardType]
        if type(fisrtData) == "table" then
            return fisrtData[1].num
        else
            return fisrtData
        end
    end
end

return PeakRuleSeasonRewardSplitView
