local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")

local TimeLimitGoldBallRewardItemView = class(unity.base, "TimeLimitGoldBallRewardItemView")

function TimeLimitGoldBallRewardItemView:ctor()
    -- 基础奖励控制脚本
    self.sptCommonReward = self.___ex.sptCommonReward
    -- 进阶奖励控制脚本
    self.sptAdvanceReward = self.___ex.sptAdvanceReward
    -- 显示领取金球数目按钮
    self.btnReceive = self.___ex.btnReceive
    -- 可领取按钮
    self.btnCanReceive = self.___ex.btnCanReceive
    -- 所需金球数量
    self.txtGoldBallNum = self.___ex.txtGoldBallNum
end

function TimeLimitGoldBallRewardItemView:InitView(itemData)
    self.data = itemData
    self.txtGoldBallNum.text = "X" .. string.formatNumWithUnit(self.data.goldBallNum)
    self.sptCommonReward:InitView(self.data.pos, self.data.commonReward) -- 普通奖励
    self.sptAdvanceReward:InitView(self.data.pos, self.data.advanceReward, true) -- 进阶奖励
end

function TimeLimitGoldBallRewardItemView:start()
end

return TimeLimitGoldBallRewardItemView
