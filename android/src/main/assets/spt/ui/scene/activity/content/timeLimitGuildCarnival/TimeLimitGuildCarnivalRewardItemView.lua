local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local TimeLimitGuildCarnivalRewardItemView = class(unity.base, "TimeLimitGuildCarnivalRewardItemView")

function TimeLimitGuildCarnivalRewardItemView:ctor()
    -- 积分水平提示
    self.txtLabel = self.___ex.txtLabel
    -- 奖励容器
    self.rewardLayout = self.___ex.rewardLayout
    -- 发奖励时间
    self.txtRewardTime = self.___ex.txtRewardTime
end

function TimeLimitGuildCarnivalRewardItemView:InitView(data)
    self.data = data
    -- 左上角积分标签
    self.txtLabel.text = tostring(data.count)
    -- 物品图标
    self:InitItemArea()
    -- 达成文本
    if not data.isDismissed then
        if data.currGuildPoint >= tonumber(data.count) then
            GameObjectHelper.FastSetActive(self.txtRewardTime.gameObject, true)
            local date = string.convertSecondToYearAndMonthAndDay(data.rewardTime)
            local time = date.month .. lang.transstr("month") .. date.day .. lang.transstr("day_1")
            time = string.convertSecondToMonth(data.rewardTime)
            self.txtRewardTime.text = lang.trans("time_limit_guild_carnival_guild_reward", time)
        else
            GameObjectHelper.FastSetActive(self.txtRewardTime.gameObject, false)
            self.txtRewardTime.text = lang.trans("time_limit_growthPlan_desc4")
        end
    else
        GameObjectHelper.FastSetActive(self.txtRewardTime.gameObject, false)
    end
end

-- 初始化物品图标
function TimeLimitGuildCarnivalRewardItemView:InitItemArea()
    assert(self.data.contents, "data.contents is nil")

    res.ClearChildren(self.rewardLayout)
    local rewardParams = {
        parentObj = self.rewardLayout,
        rewardData = self.data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

return TimeLimitGuildCarnivalRewardItemView