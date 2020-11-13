local CoachMissionItem = require("data.CoachMissionItem")
local CoachMissionDetail = require("data.CoachMissionDetail")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local Model = require("ui.models.Model")

local CoachTaskDetailModel = class(Model, "CoachTaskDetailModel")

function CoachTaskDetailModel:ctor(coachTaskData, coachTaskModel)
    self.super.ctor(self)

    self.data = coachTaskData
    self.coachTaskModel = coachTaskModel
    self.taskCardInfo = coachTaskModel:GetTaskCardInfo()
    self.selectMap = {}
end

function CoachTaskDetailModel:GetCoachTaskQuality()
    return self.data.cq
end

function CoachTaskDetailModel:GetTaskData()
    return self.data
end

function CoachTaskDetailModel:GetTaskID()
    return self.data.id
end

-- return tips in lang  or false
function CoachTaskDetailModel:GetCanAcceptTips()
    if self:IsMaxExecutingCount() then
        return "coach_task_full"
    end

    if self:IsMaxAcceptCount() then
        return "coach_task_maxfull"
    end
    return false
end

function CoachTaskDetailModel:GetTaskDesc()
    local desc = {}
    for i,v in ipairs(self.data.cond) do
        local index = tostring(v)
        table.insert(desc, CoachMissionDetail[index].desc)
    end
    return desc
end

function CoachTaskDetailModel:GetTaskTotalTime()
    local totalTime = 0
    for i,v in ipairs(self.data.cond) do
        local index = tostring(v)
        totalTime = totalTime + CoachMissionDetail[index].missionTime
    end
    totalTime = totalTime * 60
    return lang.transstr("coach_task_remainTime") .. string.convertSecondToTime(totalTime)
end

function CoachTaskDetailModel:SetSelectPcidMap(selectPcid, clickIndex)
    self.selectMap[clickIndex] = selectPcid
end

function CoachTaskDetailModel:GetSelectPcidMap()
    return self.selectMap
end

function CoachTaskDetailModel:GetTaskCardInfo()
    return self.taskCardInfo
end

function CoachTaskDetailModel:GetTaskTitle(data)
    local nameTable = {}
    for key, v in pairs(self.data.cond) do
        local index = tostring(v)
        local detailData = CoachMissionDetail[index]
        local nameType = detailData.nameType
        local nameTxt = detailData.name
        nameTable[nameType] = nameTxt
    end
    local firstType = nameTable[CoachTaskHelper.NameType.FirstType] or ""
    local secondType = nameTable[CoachTaskHelper.NameType.SecondType] or ""
    return firstType .. secondType
end

-- 当日任务是否已经达到最大限制
function CoachTaskDetailModel:IsMaxAcceptCount()
    local currentMaxDailyMission = self.coachTaskModel:GetCurrentMaxDailyMission()
    local acceptCount = self.coachTaskModel:GetAcceptCount()
    return currentMaxDailyMission <= acceptCount
end

-- 当日执行中任务是否已经达到最大限制
function CoachTaskDetailModel:IsMaxExecutingCount()
    local executingAndRewardCount = self.coachTaskModel:GetExecutingAndRewardCount()
    local maxCoachMission = self.coachTaskModel:GetMaxCoachMission()
    return executingAndRewardCount >= maxCoachMission
end

function CoachTaskDetailModel:GetCommonReward()
    local data = self:GetTaskData()
    local commonReward = {}
    for i,v in ipairs(data.reward) do
        local missionItemData = CoachMissionItem[tostring(v)]
        -- CoachMissionItem order 标记不为0的为特殊物品分开显示
        if missionItemData.order == 0 then
            table.insert(commonReward, v)
        end
    end
    return commonReward
end

function CoachTaskDetailModel:GetSpecialReward()
    local data = self:GetTaskData()
    local specialReward = {}
    for i,v in ipairs(data.reward) do
        local missionItemData = CoachMissionItem[tostring(v)]
        -- CoachMissionItem order 标记不为0的为特殊物品分开显示
        if missionItemData.order > 0 then
            table.insert(specialReward, v)
        end
    end
    return specialReward
end

return CoachTaskDetailModel
