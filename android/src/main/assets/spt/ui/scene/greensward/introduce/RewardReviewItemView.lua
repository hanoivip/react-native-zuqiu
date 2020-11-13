local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local Item = require("data.Item")
local ItemContent = require("data.ItemContent")
local RewardReviewItemView = class(unity.base)

function RewardReviewItemView:ctor()
--------Start_Auto_Generate--------
    self.bgImg = self.___ex.bgImg
    self.itemNameTxt = self.___ex.itemNameTxt
    self.rewardTrans = self.___ex.rewardTrans
    self.rewardContentTrans = self.___ex.rewardContentTrans
--------End_Auto_Generate----------

    self.scrollAtOnce = self.___ex.scrollAtOnce
    self.imgPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/DialogImage/Reward_Preview_%s.png"
end

function RewardReviewItemView:InitView(regionData, scrollRect)
    local regionRewardId = tostring(regionData.regionReward)
    local ground = regionData.ground
    self.bgImg.overrideSprite = res.LoadRes(string.format(self.imgPath, ground))
    local reward = {}
    reward.item = {}
    local itemReward = {}
    itemReward.id = regionRewardId
    itemReward.num = 1
    table.insert(reward.item, itemReward)
    self.scrollAtOnce.scrollRectInParent = scrollRect
    res.ClearChildren(self.rewardTrans)
    if reward then
        local rewardParams = {
            parentObj = self.rewardTrans,
            rewardData = reward,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            isShowSymbol = false,
            hideCount = true,
        }
        RewardDataCtrl.new(rewardParams)
    end

    res.ClearChildren(self.rewardContentTranRewardReviewIntroduceViews)
    local itemData = Item[regionRewardId]
    local itemContentIds = itemData.itemContent
    self.itemNameTxt.text = itemData.name
    for i, v in pairs(itemContentIds) do
        local tContent = ItemContent[v]
        if tContent and tContent.contents then
            local rewardParams = {
                parentObj = self.rewardContentTrans,
                rewardData = tContent.contents,
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

function RewardReviewItemView:IsSingleRank(rankHigh, rankLow)
    if rankHigh == rankLow and rankHigh > 0 and rankLow > 0 then
        return rankHigh
    end
    return false
end

return RewardReviewItemView
