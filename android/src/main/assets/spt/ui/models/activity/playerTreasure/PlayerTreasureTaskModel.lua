local Model = require("ui.models.Model")
local PlayerTreasureTaskModel = class(Model)

function PlayerTreasureTaskModel:ctor(taskData)
    self.taskData = taskData
end

function PlayerTreasureTaskModel:GetTaskList()
    local cfgTask = self.taskData.cfgTask
    local redeemedTask = self.taskData.redeemedTask
    local taskTriggers = self.taskData.taskTriggers
    self.taskLit = {}
    self.taskRedPoint = false
    for k,v in pairs(cfgTask) do
        local tempTask = v
        local taskType = tostring(tempTask.taskType)
        local taskValue = taskTriggers[taskType]
        local taskState = -1
        if taskValue then
            local taskParam1 = v.taskParam1
            if tonumber(taskParam1) <= tonumber(taskValue) then
                taskState = 0
                if not redeemedTask[k] then
                    self.taskRedPoint = true
                end
            end
        end
        if redeemedTask[k] then
            taskState = 1
        end
        v.taskValue = taskValue or 0
        v.taskState = taskState
        v.taskId = k
        table.insert(self.taskLit, tempTask)
    end
    table.sort(self.taskLit, function(a, b)
        return a.taskId < b.taskId
    end)
    return self.taskLit
end

function PlayerTreasureTaskModel:GetPeriod()
    return self.taskData.period
end

function PlayerTreasureTaskModel:GetTaskRedPointState()
    return self.taskRedPoint
end

function PlayerTreasureTaskModel:SetRedeemedTaskData(redeemedTaskData)
    if type(redeemedTaskData) == "table" then
        self.taskData.redeemedTask = redeemedTaskData
    end
end

function PlayerTreasureTaskModel:GetTaskDataByTaskId(taskId)
    for i,v in ipairs(self.taskLit) do
        local tempTaskId = v.taskId
        if tempTaskId == taskId then
            return v
        end
    end
end

return PlayerTreasureTaskModel
