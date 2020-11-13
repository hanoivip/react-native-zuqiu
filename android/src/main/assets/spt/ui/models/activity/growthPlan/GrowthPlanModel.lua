local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ActivityModel = require("ui.models.activity.ActivityModel")
local GrowthPlanModel = class(ActivityModel)

function GrowthPlanModel:ctor(data)
    assert(type(data) == "table" and next(data), "data error!!!")
    GrowthPlanModel.super.ctor(self, data)
end

local defaultTableIndex = 1
local HOUR_SECONDS = 3600
function GrowthPlanModel:InitWithProtocol(newDataList)
    if newDataList then
        self.dataListMap = newDataList
    else
        self.dataListMap = self:GetActivitySingleData().growthPlan or {}
    end
    local activityFirstRead = -2
    local activity = ReqEventModel.GetInfo("activity")
    local activityType = self:GetActivityType()
    local activityData = activity[activityType]
    self.dataList = {}
    for k, v in pairs(self.dataListMap) do
        v.uniqueID = k
        if activityData then
            if type(activityData) == "table" then
                v.isFirstRead = tonumber(activityData[tostring(v.id)]) == activityFirstRead
            else
                v.isFirstRead = tonumber(activityData) == activityFirstRead
            end
        else
            v.isFirstRead = false
        end
        table.insert(self.dataList, v)
    end
    if not self.tabTag and self.dataList[defaultTableIndex] then
        self.defaultTabTag = self.dataList[defaultTableIndex].uniqueID
        self.tabTag = self.defaultTabTag
        self.isSelectedActActive = true
    end
    self.requestTime = Time.realtimeSinceStartup
end

function GrowthPlanModel:IsActFirstRead()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].isFirstRead
end

function GrowthPlanModel:SetActFirstRead(isFirstRead)
    local tabTag = self:GetSelectedTabTag()
    self.dataListMap[tabTag].isFirstRead = isFirstRead
end

function GrowthPlanModel:GetTabDataList()
    return self.dataList or {}
end

function GrowthPlanModel:RefreshActivityData(data)
    local tabTag = self:GetSelectedTabTag()
    self.dataListMap[tabTag] = data
    self:InitWithProtocol(self.dataListMap)
end

function GrowthPlanModel:HasRewardCollectable(tabTag)
    local dataList = self.dataListMap[tabTag].list
    local collectableStatus = 0
    for k, v in pairs(dataList) do
        if v.status == collectableStatus then
            return true
        end
    end

    return false
end

function GrowthPlanModel:SetActState(isActive)
    self.isSelectedActActive = isActive
end

function GrowthPlanModel:GetActState()
    return self.isSelectedActActive
end

function GrowthPlanModel:GetActivityID()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].id
end

function GrowthPlanModel:GetRewardDataList()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].list or {}
end

function GrowthPlanModel:GetVipLow()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local vipLow = finalTable.vipLow
    return vipLow
end

function GrowthPlanModel:GetVipHigh()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local vipHigh = finalTable.vipHigh
    return vipHigh
end

function GrowthPlanModel:GetConditionDescByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local conditionDesc = finalTable.conditionDesc
    return conditionDesc or ""
end

function GrowthPlanModel:GetActDesc()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].desc or {}
end

function GrowthPlanModel:GetRewardProgressByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local progressValue = finalTable.value
    return progressValue
end

function GrowthPlanModel:GetRewardStatusByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local status = finalTable.status
    return status
end

function GrowthPlanModel:GetRewardSubIdByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local subID = finalTable.subID
    return subID
end

function GrowthPlanModel:SetRewardStatusByIndex(index, status)
    local finalTable = self:CheckTableExistByIndex(index)
    finalTable.status = status
end

function GrowthPlanModel:CheckTableExistByIndex(index)
    local tabTag = self:GetSelectedTabTag()
    local dataList = self.dataListMap[tabTag]
    assert(dataList.list and dataList.list[index], "server data error!!!")
    return dataList.list[index]
end

function GrowthPlanModel:GetTabData()
    local tabTag = self:GetSelectedTabTag()
    assert(self.dataListMap[tabTag], "server data error!!!")
    return self.dataListMap[tabTag] or {}
end

function GrowthPlanModel:IsBought()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].isBuy
end

function GrowthPlanModel:GetPayType()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local currencyType = finalTable.currencyType
    return currencyType
end

function GrowthPlanModel:GetBuyCount()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local needCount = finalTable.diamond
    return needCount
end

function GrowthPlanModel:CheckTableExistOfDefaultIndex()
    local tabTag = self:GetSelectedTabTag()
    local dataList = self.dataListMap[tabTag]
    assert(dataList and dataList.list and dataList.list[defaultTableIndex], "server data error!!!")
    return dataList.list[defaultTableIndex]
end

function GrowthPlanModel:SetSelectedTabTag(tabTag)
    self.tabTag = tabTag or self.defaultTabTag
end

function GrowthPlanModel:GetSelectedTabTag()
    return self.tabTag
end

function GrowthPlanModel:GetRemainTime()
    local endTime = self:GetEndTime()
    local tabTag = self:GetSelectedTabTag()
    local serverTime = self.dataListMap[tabTag].serverTime
    local serverTimeNow = serverTime + Time.realtimeSinceStartup - self.requestTime
    local remainTime = endTime - serverTimeNow

    return remainTime
end

--获取活动结束的时间，可能是购买结束的时间或购买后的活动持续的结束时间
function GrowthPlanModel:GetEndTime()
    local tabTag = self:GetSelectedTabTag()
    local isBought = self:IsBought()
    local endTime = self.dataListMap[tabTag].endTime
    if isBought then
        endTime = self.dataListMap[tabTag].beginTime + self.dataListMap[tabTag].duration2 * HOUR_SECONDS
    end
    
    return endTime
end

function GrowthPlanModel:GetDefaultTabTag()
    return self.defaultTabTag
end

function GrowthPlanModel:GetActID()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].id
end

return GrowthPlanModel