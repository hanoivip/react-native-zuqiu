local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CompeteGuessReverseRewardItemView = class(unity.base, "CompeteGuessReverseRewardItemView")

function  CompeteGuessReverseRewardItemView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 奖励显示区
    self.rctRewardLayout = self.___ex.rctRewardLayout
end

function CompeteGuessReverseRewardItemView:start()
end

function CompeteGuessReverseRewardItemView:InitView(data)
    self.data = data
    if data.nextComebackTimes > 0 then
        self.txtTitle.text = lang.trans("compete_guess_reward_3", data.idx, data.comebackTimes / 100, data.nextComebackTimes / 100, data.comebackTimes / 100)
    else
        self.txtTitle.text = lang.trans("compete_guess_reward_5", data.idx, data.comebackTimes / 100, data.comebackTimes / 100)
    end

    assert(self.data.contents, "data.contents is nil")

    res.ClearChildren(self.rctRewardLayout)
    local rewardParams = {
        parentObj = self.rctRewardLayout,
        rewardData = self.data.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

return CompeteGuessReverseRewardItemView
