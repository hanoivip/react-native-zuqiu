local Model = require("ui.models.Model")
local ActivityListModel = class(Model)

function ActivityListModel:ctor(activityRes)
    ActivityListModel.super.ctor(self)
    self.activityRes = activityRes
    self.singleModelMap = cache.getActivityData()
    self.activityViewData = cache.getActivityViewData() or {}
    if self.singleModelMap == nil then
        self.singleModelMap = {}
    end
end

-- 为每个活动分发一个ActivityModel
function ActivityListModel:InitWithProtocol(data)
    assert(data)
    for i, activityData in ipairs(data) do
        local activityType = tostring(activityData.type)
        local activityId = tonumber(activityData.id)
        if not self.singleModelMap[activityType] then 
            self.singleModelMap[activityType] = {}
        end
        local modelPath = self.activityRes:GetActivityModelPath(activityType, activityId)
        if not modelPath then 
            modelPath = "ui.models.activity.ActivityModel"
        end
        local singleModel = require(modelPath).new(activityData)
        self.singleModelMap[activityType][activityId] = singleModel
        cache.setActivityData(self.singleModelMap)
    end
    self.data = data
    table.sort(self.data, function(a, b) return (a.sort or -1) < (b.sort or -1) end)
end

function ActivityListModel:GetActivityDataMap()
    return self.singleModelMap
end

function ActivityListModel:GetSingleModel(activityType, activityId)
    return self.singleModelMap[activityType][activityId]
end

function ActivityListModel:GetActivityModelsByActivityType(activityType)
    return self.singleModelMap[activityType]
end

function ActivityListModel:GetActivityList()
    return self.data
end

function ActivityListModel:GetActivityTypeAndId(index)
    local activityData = self.data[index]
    return activityData["type"], activityData["id"]
end

function ActivityListModel:GetActivityType(index)
    local activityData = self.data[index]
    return activityData["type"]
end

function ActivityListModel:SetSelectActivityType(activityType)
    self.activityViewData.activityType = activityType
    cache.setActivityViewData(self.activityViewData)
end

function ActivityListModel:GetSelectActivityType()
    return self.activityViewData.activityType
end

function ActivityListModel:RefreshData(data)
    for i, activityData in pairs(data) do
        local activityType = tostring(activityData.type)
        local activityId = tonumber(activityData.id)
        local typeList = self.singleModelMap[activityType] and self.singleModelMap[activityType][activityId]
        if typeList then
            typeList:RefreshData(activityData)
        end
    end
    self.data = data
end

-- 需要先判断上一次选择活动是否因为时效变动导致不存在
function ActivityListModel:GetActivityIndex(activityType)
    local isExist = false
    local DefaultSelectLabel = 1
    for i, v in ipairs(self.data) do
        local dataType = v["type"]
        local id = v["id"]
        if activityType == dataType then
            DefaultSelectLabel = i
            isExist = true
            break
        end
    end
    return DefaultSelectLabel, isExist
end

return ActivityListModel
