local BeginnerCarnivalBase = require("data.BeginnerCarnivalBase")
local BeginnerCarnival = require("data.BeginnerCarnival")
local BeginnerCarnivalTotalReward = require("data.BeginnerCarnivalTotalReward")
local Model = require("ui.models.Model")
local CarnivalModel = class(Model, "CarnivalModel")
local Duration = 7
function CarnivalModel:ctor()
    self.todayIndex = 0
    self.progressNumber = 0
    self.cacheData = {}
    self.taskList = {}
    self.labelList = {}
    self.tabList = {}
    self.rewardList = {}
   CarnivalModel.super.ctor(self)
end

function CarnivalModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:InitData(data)
end

function CarnivalModel:InitData(data)
    assert(type(data) == "table")
    self.todayIndex = data.beginDate
    self.remainTime = data.remainTime
    self.activityType = data.type
    self.cacheData = {}
    for i, v in ipairs(data.list) do
        table.insert(self.cacheData, v)
    end
    self:SetLabels()
    self:SetTabs()
    self:SetTaskList(self.cacheData)
    self:SetRewardData(data.option)
    EventSystem.SendEvent("CarnivalReward_UpdateRedPointState")
end

function CarnivalModel:SetTaskList(dataList)
    self.taskList = {}
    self.progressNumber = 0
    local curDayIndex = 1
    for i = 1, #dataList do
        local detail = {}
        local taskId = dataList[i].value.ID
        detail.taskId = taskId
        detail.taskValue = dataList[i].value
        local detailData = BeginnerCarnival[taskId]
        detail.dayIndex = detailData.type % 2 == 0 and detailData.type / 2 or (detailData.type + 1) / 2
        detail.tagIndex = detailData.type % 2 == 0 and 2 or 1
        -- task state
        if detail.dayIndex >= self:GetTodayIndex() + 2 then
            -- 后日解锁
            detail.taskState = - 3
        elseif detail.dayIndex >= self:GetTodayIndex() + 1 then
            -- 明日解锁
            detail.taskState = - 2
        else
            detail.taskState = dataList[i].status
        end
        -- 计算成就点
        if self:GetTodayIndex() >= detail.dayIndex and detail.taskState >= 0 then
            self.progressNumber = self.progressNumber + 1
            if detail.taskState == 0 then
                self.labelList[detail.dayIndex].redPointCounter = self.labelList[detail.dayIndex].redPointCounter + 1
                self.tabList[detailData.type].redPointCounter = self.tabList[detailData.type].redPointCounter + 1
            end
        end
        -- 构建任务列表
        detail.rewardId = dataList[i].subID
        detail.contents = dataList[i].contents
        detail.type = BeginnerCarnival[taskId].type
        detail.desc = BeginnerCarnival[taskId].desc
        detail.target = BeginnerCarnival[taskId].condition
        local taskDay = tostring(detail.dayIndex)
        if not self.taskList[taskDay] then
            self.taskList[taskDay] = {}
        end
        local taskTag = tostring(detail.tagIndex)
        if not self.taskList[taskDay][taskTag] then
            self.taskList[taskDay][taskTag] = {}
        end
        table.insert(self.taskList[taskDay][taskTag], detail)
    end
end

function CarnivalModel:SetLabels()
    self.labelList = {}
    for i = 1, Duration do
        local label = {}
        label.dayIndex = i
        label.isSelect = false
        label.isUnlock = i <= self:GetUnlockIndex()
        label.redPointCounter = 0
        table.insert(self.labelList, label)
    end
end

function CarnivalModel:SetSelectLabel(dayIndex)
    if dayIndex ~= 0 then
        self.labelList[dayIndex].isSelect = true
    end
end

function CarnivalModel:SetTabs()
    self.tabList = {}
    for i = 1, Duration * 2 do
        local data = {}
        data.name = BeginnerCarnivalBase[tostring(i)].tagName
        data.redPointCounter = 0
        table.insert(self.tabList, data)
    end
end

function CarnivalModel:SetRewardData(rewardList)
    self.rewardList = {}
    local rewardIndex = 1
    for k, v in pairs(rewardList) do
        if not v.status then
            v.status = self:GetCurrentProgressNumber() >= v.condition and 0 or -1
        end
        v.index = rewardIndex
        table.insert(self.rewardList, v)
        rewardIndex = rewardIndex + 1
    end
    table.sort(self.rewardList, function(a, b) return a.condition < b.condition end)
end

function CarnivalModel:GetActivityType()
    return self.activityType
end

function CarnivalModel:GetTodayIndex()
    return self.todayIndex
end

function CarnivalModel:GetRemainTime()
    return self.remainTime
end

function CarnivalModel:GetUnlockIndex()
    return (self:GetTodayIndex() + 2) > Duration and Duration or (self:GetTodayIndex() + 2)
end

function CarnivalModel:GetCurrentTabs(dayIndex)
    return self.tabList[dayIndex * 2 - 1], self.tabList[dayIndex * 2]
end

function CarnivalModel:GetLabelsLockState()
    return self.labelList
end

function CarnivalModel:GetCurrentDetailData(dayIndex, tabIndex)
    table.sort(self.taskList[tostring(dayIndex)][tostring(tabIndex)], function(a, b)
        local rewardCondition = math.abs(a.taskState) < math.abs(b.taskState)
        local unfinishConditon = (math.abs(a.taskState) == math.abs(b.taskState)) and (a.taskState < b.taskState)
        local idCondition = (a.taskState == b.taskState) and (a.taskId < b.taskId)
        return rewardCondition or unfinishConditon or idCondition
    end)
    return self.taskList[tostring(dayIndex)][tostring(tabIndex)]
end

function CarnivalModel:GetProgressList()
    return self.rewardList
end

function CarnivalModel:GetTotalProgressNumber()
    return self.rewardList[#self.rewardList].condition
end

function CarnivalModel:GetCurrentProgressNumber()
    return self.progressNumber
end

return CarnivalModel