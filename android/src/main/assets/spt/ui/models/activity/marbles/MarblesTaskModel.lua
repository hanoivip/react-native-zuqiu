local Model = require("ui.models.Model")
local MarblesTaskModel = class(Model)

function MarblesTaskModel:ctor(taskData)
    self.taskData = taskData
end

function MarblesTaskModel:InitWithProtocol(taskData)
    self.taskData = taskData.taskList
    self:InitTaskList()
end

function MarblesTaskModel:InitTaskList()
    self.taskLit = {}
    for i, v in pairs(self.taskData) do
        v.taskId = i
        table.insert(self.taskLit, v)
    end
    table.sort(self.taskLit, function(a, b) return a.taskId < b.taskId end)
end

function MarblesTaskModel:GetTaskList()
    return self.taskLit
end

function MarblesTaskModel:SetMarblesModel(marblesModel)
    self.marblesModel = marblesModel
end

function MarblesTaskModel:GetMarblesModel()
    return self.marblesModel
end

function MarblesTaskModel:GetPeriodId()
    return self.marblesModel:GetPeriodId()
end

function MarblesTaskModel:GetTaskRedPointState()
    return self.taskRedPoint
end

function MarblesTaskModel:RefreshTaskData(taskData)
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

function MarblesTaskModel:GetTaskDataByTaskId(taskId)
    for i,v in ipairs(self.taskLit) do
        local tempTaskId = v.taskId
        if tempTaskId == taskId then
            return v
        end
    end
end

return MarblesTaskModel
