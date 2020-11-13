local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local AdventureRewardBase = require("data.AdventureRewardBase")
local DayContentItemView = class(unity.base)

function DayContentItemView:ctor()
--------Start_Auto_Generate--------
    self.firstRankGo = self.___ex.firstRankGo
    self.secondRankGo = self.___ex.secondRankGo
    self.thirdRankGo = self.___ex.thirdRankGo
    self.levelTxt = self.___ex.levelTxt
    self.rewardOtherTrans = self.___ex.rewardOtherTrans
    self.rewardOtherNoneTxt = self.___ex.rewardOtherNoneTxt
    self.rewardTrans = self.___ex.rewardTrans
    self.rewardNoneTxt = self.___ex.rewardNoneTxt
--------End_Auto_Generate----------
end

function DayContentItemView:InitView(rankHigh, rankLow, rewardData, dayRewardData)
    local isSingle = self:IsSingleRank(rankHigh, rankLow)
    GameObjectHelper.FastSetActive(self.firstRankGo, isSingle == 1)
    GameObjectHelper.FastSetActive(self.secondRankGo, isSingle == 2)
    GameObjectHelper.FastSetActive(self.thirdRankGo, isSingle == 3)
    GameObjectHelper.FastSetActive(self.levelTxt.gameObject, not isSingle)
    self.levelTxt.text = rankHigh .. "-" .. rankLow
    res.ClearChildren(self.rewardTrans)

    local reward = AdventureRewardBase[tostring(rewardData)]
    local contents = reward and reward.contents
    if contents then
        GameObjectHelper.FastSetActive(self.rewardNoneTxt.gameObject, false)
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
    else
        GameObjectHelper.FastSetActive(self.rewardNoneTxt.gameObject, true)
    end

    res.ClearChildren(self.rewardOtherTrans)
    local dayReward = AdventureRewardBase[tostring(dayRewardData)]
    local dayContents = dayReward and dayReward.contents
    if dayContents then
        GameObjectHelper.FastSetActive(self.rewardOtherNoneTxt.gameObject, false)
        local rewardParams = {
            parentObj = self.rewardOtherTrans,
            rewardData = dayContents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            isShowSymbol = false,
        }
        RewardDataCtrl.new(rewardParams)
    else
        GameObjectHelper.FastSetActive(self.rewardOtherNoneTxt.gameObject, true)
    end
end

function DayContentItemView:IsSingleRank(rankHigh, rankLow)
    if rankHigh == rankLow and rankHigh > 0 and rankLow > 0 then
        return rankHigh
    end
    return false
end

return DayContentItemView
