local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local AdventureRewardBase = require("data.AdventureRewardBase")
local AllRewardContentItemView = class(unity.base)

function AllRewardContentItemView:ctor()
--------Start_Auto_Generate--------
    self.levelTxt = self.___ex.levelTxt
    self.rewardTrans = self.___ex.rewardTrans
--------End_Auto_Generate----------
end

function AllRewardContentItemView:InitView(level, levelData)
    self.levelTxt.text = tostring(level)
    res.ClearChildren(self.rewardTrans)
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

return AllRewardContentItemView
