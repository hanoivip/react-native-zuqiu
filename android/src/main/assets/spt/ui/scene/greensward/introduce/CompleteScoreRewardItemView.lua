local AdventureRewardBase = require("data.AdventureRewardBase")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CompleteScoreRewardItemView = class(unity.base, "CompleteRewardIntroduceItemView")

function CompleteScoreRewardItemView:ctor()
--------Start_Auto_Generate--------
    self.floorTxt = self.___ex.floorTxt
    self.scoreTxt = self.___ex.scoreTxt
    self.rewardTrans = self.___ex.rewardTrans
--------End_Auto_Generate----------
end

function CompleteScoreRewardItemView:InitView(floor, score, rewards)
    self.floorTxt.text = floor
    self.scoreTxt.text = score
    res.ClearChildren(self.rewardTrans)
    for i, v in ipairs(rewards) do
        local reward = AdventureRewardBase[v]
        local contents = reward and reward.contents
        if contents then
            local rewardParams = {
                parentObj = self.rewardTrans,
                rewardData = contents,
                isShowName = false,
                isReceive = false,
                isShowBaseReward = true,
                isShowCardReward = true,
                isShowDetail = true,
                isShowSymbol = false,
            }
            RewardDataCtrl.new(rewardParams)
        end
    end
end

return CompleteScoreRewardItemView
