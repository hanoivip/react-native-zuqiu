local ActivityModel = require("ui.models.activity.ActivityModel")
local DailyLoginSelfItemModel = require("ui.models.activity.DailyLoginSelfItemModel")
local DailyLoginSelfModel = class(ActivityModel)

function DailyLoginSelfModel:ctor(data)
    self.itemModels = nil
    DailyLoginSelfModel.super.ctor(self, data)
end

function DailyLoginSelfModel:InitWithProtocol()
    self.itemModels = {}
    local singleData = self:GetActivitySingleData()
    for i, itemData in ipairs(singleData.list) do
        local itemModel = DailyLoginSelfItemModel.new(itemData)
        table.insert(self.itemModels, itemModel)
    end
end

--- 获取单元箱model的列表
function DailyLoginSelfModel:GetItemModels()
    return self.itemModels
end

--- 获取活动说明
function DailyLoginSelfModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

--- 获取活动开始时间
function DailyLoginSelfModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function DailyLoginSelfModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

--- 获取最先可以领取的奖励索引
function DailyLoginSelfModel:GetFirstPrizeIndex()
    for i, itemModel in ipairs(self.itemModels) do
        if itemModel:IsCanReceive() then
            return i
        end
    end

    return 0
end

--- 更新通信数据
function DailyLoginSelfModel:UpdateProtocolData(updateData)
    for i, itemModel in ipairs(self.itemModels) do
        if itemModel:GetActivityID() == updateData.subID then
            itemModel:SetStatus(updateData.status)
        end
    end
end

return DailyLoginSelfModel
