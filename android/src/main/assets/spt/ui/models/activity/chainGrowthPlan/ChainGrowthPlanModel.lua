local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ActivityModel = require("ui.models.activity.ActivityModel")
local ChainGrowthPlanState = require("ui.scene.activity.ChainGrowthPlan.ChainGrowthPlanState")
local ChainGrowthPlanModel = class(ActivityModel)

function ChainGrowthPlanModel:ctor(data)
    assert(type(data) == "table" and next(data), "data error!!!")
    ChainGrowthPlanModel.super.ctor(self, data)
end

local defaultTableIndex = 1
local HOUR_SECONDS = 3600
function ChainGrowthPlanModel:InitWithProtocol(newDataList)
    self.dataListMap = self:GetActivitySingleData().chainGrowthPlan or {}
    self.dataList = {}
    local tempData = {}
    local chainList = {}
    local endId = 0
    for k,v in pairs(self.dataListMap) do
        v.previousID = v.list[1].previousID
        tempData[v.id] = v
    end
    self.dataList = self:SortChain(tempData)
    local maxOpenIndex = self:GetMaxOpenIndex()

    local activityFirstRead = -2
    local activity = ReqEventModel.GetInfo("activity")
    local activityType = self:GetActivityType()
    local activityData = activity[activityType]
    for i,v in ipairs(self.dataList) do
        v.uniqueID = i
        if i < maxOpenIndex then
            v.clientBuyState = ChainGrowthPlanState.Sell
        elseif i == maxOpenIndex then
            v.clientBuyState = ChainGrowthPlanState.Buy
        else
            v.clientBuyState = ChainGrowthPlanState.Disable
        end
        if activityData then
            if type(activityData) == "table" then
                v.isFirstRead = tonumber(activityData[tostring(v.id)]) == activityFirstRead
            else
                v.isFirstRead = tonumber(activityData) == activityFirstRead
            end
        else
            v.isFirstRead = false
        end
    end
    if not self.tabTag and self.dataList[defaultTableIndex] then
        self.defaultTabTag = self.dataList[defaultTableIndex].uniqueID
        self.tabTag = self.defaultTabTag
        self.isSelectedActActive = true
    end
    self.lastRealTime = Time.realtimeSinceStartup
end

function ChainGrowthPlanModel:IsActFirstRead()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].isFirstRead
end

function ChainGrowthPlanModel:SetActFirstRead(isFirstRead)
    local tabTag = self:GetSelectedTabTag()
    self.dataListMap[tabTag].isFirstRead = isFirstRead
end

function ChainGrowthPlanModel:GetTabDataList()
    return self.dataList or {}
end

function ChainGrowthPlanModel:RefreshActivityData(data)
    local tabTag = self:GetSelectedTabTag()
    self.dataListMap[tabTag] = data
    self:InitWithProtocol(self.dataListMap)
end

function ChainGrowthPlanModel:HasRewardCollectable(tabTag)
    local dataList = self.dataListMap[tabTag].list
    local collectableStatus = 0
    for k, v in pairs(dataList) do
        if v.status == collectableStatus then
            return true
        end
    end

    return false
end

function ChainGrowthPlanModel:SetActState(isActive)
    self.isSelectedActActive = isActive
end

function ChainGrowthPlanModel:GetActState()
    return self.isSelectedActActive
end

function ChainGrowthPlanModel:GetActivityID()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].id
end

function ChainGrowthPlanModel:GetRewardDataList()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].list or {}
end

function ChainGrowthPlanModel:GetVipLow()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local vipLow = finalTable.vipLow
    return vipLow
end

function ChainGrowthPlanModel:GetVipHigh()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local vipHigh = finalTable.vipHigh
    return vipHigh
end

function ChainGrowthPlanModel:GetLvlLow()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local lvLow = finalTable.lvLow
    return lvLow
end

function ChainGrowthPlanModel:GeLvlHigh()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local lvHigh = finalTable.lvHigh
    return lvHigh
end

function ChainGrowthPlanModel:GetConditionDescByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local conditionDesc = finalTable.conditionDesc
    return conditionDesc or ""
end

function ChainGrowthPlanModel:GetActDesc()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].desc or {}
end

function ChainGrowthPlanModel:GetRewardProgressByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local progressValue = finalTable.value
    return progressValue
end

function ChainGrowthPlanModel:GetRewardStatusByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local status = finalTable.status
    return status
end

function ChainGrowthPlanModel:GetRewardSubIdByIndex(index)
    local finalTable = self:CheckTableExistByIndex(index)
    local subID = finalTable.subID
    return subID
end

function ChainGrowthPlanModel:SetRewardStatusByIndex(index, status)
    local finalTable = self:CheckTableExistByIndex(index)
    finalTable.status = status
end

function ChainGrowthPlanModel:CheckTableExistByIndex(index)
    local tabTag = self:GetSelectedTabTag()
    local dataList = self.dataListMap[tabTag]
    assert(dataList.list and dataList.list[index], "server data error!!!")
    return dataList.list[index]
end

function ChainGrowthPlanModel:GetTabData()
    local tabTag = self:GetSelectedTabTag()
    assert(self.dataListMap[tabTag], "server data error!!!")
    return self.dataListMap[tabTag] or {}
end

function ChainGrowthPlanModel:IsBought()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].isBuy
end

function ChainGrowthPlanModel:GetPayType()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local currencyType = finalTable.currencyType
    return currencyType
end

function ChainGrowthPlanModel:GetBuyCount()
    local finalTable = self:CheckTableExistOfDefaultIndex()
    local needCount = finalTable.diamond
    return needCount
end

function ChainGrowthPlanModel:CheckTableExistOfDefaultIndex()
    local tabTag = self:GetSelectedTabTag()
    local dataList = self.dataListMap[tabTag]
    assert(dataList and dataList.list and dataList.list[defaultTableIndex], "server data error!!!")
    return dataList.list[defaultTableIndex]
end

function ChainGrowthPlanModel:SetSelectedTabTag(tabTag)
    self.tabTag = tabTag or self.defaultTabTag
end

function ChainGrowthPlanModel:GetSelectedTabTag()
    return self.tabTag
end

function ChainGrowthPlanModel:GetRemainTime()
    local tabTag = self:GetSelectedTabTag()
    local isBuy = self:IsBought()
    local nowRealTime = Time.realtimeSinceStartup
    -- 从服务器收到消息的时间到现在进入页面或者刷新页面的时间差值
    local deltaTime = nowRealTime - self.lastRealTime
    local remainTime = 0
    if not isBuy then
        remainTime = self.dataListMap[tabTag].remainTime - deltaTime
    else
        remainTime = self.dataListMap[tabTag].showRemainTime - deltaTime
    end
    if remainTime > 1 then
        return remainTime
    end
    return 0
    -- 暂时用服务器发送的时间 等buyTime时间修复 后用以下时间 2019.3.1
    -- local tabTag = self:GetSelectedTabTag()
    -- local isBuy = self:IsBought()
    -- local nowRealTime = Time.realtimeSinceStartup
    -- -- 从服务器收到消息的时间到现在进入页面或者刷新页面的时间差值
    -- local deltaTime = nowRealTime - self.lastRealTime
    -- local remainTime = 0
    -- local tagData = self.dataListMap[tabTag]
    -- if not isBuy then
    --     remainTime = tagData.remainTime - deltaTime
    -- else
    --     -- 购买后的活动结束时间  从购买当天的五点开始+duration2 时间结束后活动结束
    --     local buyTime = tagData.buyTime
    --     local serverTime = tagData.serverTime
    --     local duration2 = tagData.duration2 * HOUR_SECONDS
    --     remainTime = buyTime + duration2 - serverTime - deltaTime
    -- end
    -- if remainTime > 1 then
    --     return remainTime
    -- end
    -- return 0
end

function ChainGrowthPlanModel:GetDefaultTabTag()
    return self.defaultTabTag
end

function ChainGrowthPlanModel:GetActID()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].id
end

-- 当前开启的礼盒编号
function ChainGrowthPlanModel:GetMaxOpenIndex()
    local maxOpenIndex = 0
    for i,v in ipairs(self.dataList) do
        if v.isBuy then
           maxOpenIndex = i
        end
    end
    if maxOpenIndex + 1 > #self.dataList then
        return maxOpenIndex
    else
        return maxOpenIndex + 1
    end
end

-- 最大的礼盒索引
function ChainGrowthPlanModel:GetMaxIndex()
    return #self.dataList
end

function ChainGrowthPlanModel:GetActTitle()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].title or {}
end

function ChainGrowthPlanModel:GetClientBuyState()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].clientBuyState or false
end

-- 根据previousID对列表进行筛选和排序
function ChainGrowthPlanModel:SortChain(tempData)
    local endId = 0
    for k,v in pairs(tempData) do
        local hasExist = false
        for id, data in pairs(tempData) do
            if k == data.previousID then
                hasExist = true
            end
        end

        if not hasExist then
            endId = k
            break
        end
    end

    chain = {}
    local isLoop = true
    local nextId = endId
    while isLoop do
        local nextData = tempData[nextId]
        if not nextData then
            break
        end
        if nextData.previousID == 0 then
            isLoop = false
        end
        table.insert(chain, nextData)
        nextId = nextData.previousID
    end

    reverseChain = {}
    for i=#chain, 1, -1 do
        table.insert(reverseChain, chain[i])
    end
    return reverseChain
end

return ChainGrowthPlanModel