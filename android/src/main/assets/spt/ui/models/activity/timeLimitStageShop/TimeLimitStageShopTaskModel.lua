local Model = require("ui.models.Model")
local TimeLimitStageShopTaskModel = class(Model)

function TimeLimitStageShopTaskModel:ctor(taskData)
    self.taskData = taskData
end

function TimeLimitStageShopTaskModel:InitWithProtocol(taskData)
    self.taskData = taskData
    self:InitTaskList()
end

function TimeLimitStageShopTaskModel:InitTaskList()
    self.taskLit = {}
    for i, v in pairs(self.taskData) do
        v.taskId = i
        table.insert(self.taskLit, v)
    end
    table.sort(self.taskLit, function(a, b) return a.taskId < b.taskId end)
end

function TimeLimitStageShopTaskModel:GetTaskList()
    return self.taskLit
end

function TimeLimitStageShopTaskModel:GetPeriod()
    return self.taskData.period
end

function TimeLimitStageShopTaskModel:GetTaskRedPointState()
    return self.taskRedPoint
end

function TimeLimitStageShopTaskModel:RefreshTaskData(taskData)
    local taskId = tostring(taskData.taskId)
    local taskInfo = taskData.taskInfo
    if type(taskInfo) == "table" then
        for i,v in ipairs(self.taskLit) do
            local tempTaskId = v.taskId
            if tempTaskId == taskId then
                v.progress = taskInfo.progress
                v.state = taskInfo.state
                return
            end
        end
    end
end

function TimeLimitStageShopTaskModel:GetTaskDataByTaskId(taskId)
    for i,v in ipairs(self.taskLit) do
        local tempTaskId = v.taskId
        if tempTaskId == taskId then
            return v
        end
    end
end

return TimeLimitStageShopTaskModel
