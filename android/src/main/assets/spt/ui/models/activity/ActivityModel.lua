local Model = require("ui.models.Model")
local ActivityModel = class(Model)
-- 每个单独活动的model基类
function ActivityModel:ctor(data)
    ActivityModel.super.ctor(self)
    self.singleData = data
    self:InitWithProtocol()
end

function ActivityModel:InitWithProtocol()
end

function ActivityModel:GetActivityType()
    return self.singleData.type
end

function ActivityModel:GetActivitySingleData()
    return self.singleData
end

function ActivityModel:GetActivityId()
    return tonumber(self.singleData.id)
end

-- 刷新活动数据
function ActivityModel:RefreshData(data)
    self.singleData = data
    self:InitWithProtocol()
end

-- 活动view
function ActivityModel:SetActivityView(viewSpt)
    self.viewSpt = viewSpt
end

-- 活动view
function ActivityModel:GetActivityView()
    return self.viewSpt
end

return ActivityModel
