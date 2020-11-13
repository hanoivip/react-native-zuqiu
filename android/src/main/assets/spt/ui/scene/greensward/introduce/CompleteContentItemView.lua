local AdventureFloor = require("data.AdventureFloor")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local AdventureRewardBase = require("data.AdventureRewardBase")
local CompleteContentItemView = class(unity.base)

function CompleteContentItemView:ctor()
--------Start_Auto_Generate--------
    self.levelTxt = self.___ex.levelTxt
    self.scoreTxt = self.___ex.scoreTxt
    self.moraleTxt = self.___ex.moraleTxt
    self.rewardTrans = self.___ex.rewardTrans
--------End_Auto_Generate----------
end

function CompleteContentItemView:InitView(level, rewardData)
    local levelData = rewardData.stageReward
    local levelStr = tostring(level)
    local stagePoint = AdventureFloor[levelStr].stagePoint
    self.levelTxt.text = levelStr
    self.scoreTxt.text = tostring(stagePoint)
    self.moraleTxt.text = tostring(rewardData.moraleReward)
    res.ClearChildren(self.rewardTrans)

    -- 士气奖励也添加进去
    local moraleParams = {
        parentObj = self.rewardTrans,
        rewardData = {morale = rewardData.moraleReward},
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowSymbol = false,
    }
    RewardDataCtrl.new(moraleParams)

    if type(levelData) ~= "table" then
        return
    end
    for i, v in pairs(levelData) do
        local contents = AdventureRewardBase[v].contents
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

return CompleteContentItemView
