local Model = require("ui.models.Model")
local DailyLoginSelfItemModel = class(Model)

function DailyLoginSelfItemModel:ctor(data)
    DailyLoginSelfItemModel.super.ctor(self)
    self.data = data
end

--- 获取描述
function DailyLoginSelfItemModel:GetDesc()
    return self.data.conditionDesc
end

--- 获取奖励数据
function DailyLoginSelfItemModel:GetRewardsData()
    return self.data.contents
end

--- 获取子活动ID
function DailyLoginSelfItemModel:GetActivityID()
    return self.data.subID
end

--- 设置奖励状态
function DailyLoginSelfItemModel:SetStatus(status)
    self.data.status = status
end

--- 获取奖励状态
function DailyLoginSelfItemModel:GetStatus()
    return self.data.status
end

--- 获取该任务的天数索引
function DailyLoginSelfItemModel:GetDayIndex()
    return self.data.condition
end

--- 获取玩家当前登录天数
function DailyLoginSelfItemModel:GetNowDayIndex()
    return self.data.value
end

--- 是否可以领奖
function DailyLoginSelfItemModel:IsCanReceive()
    return self:GetStatus() == 0
end

return DailyLoginSelfItemModel
