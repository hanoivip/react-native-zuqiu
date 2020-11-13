local Model = require("ui.models.Model")
local RewardTaskType = require("ui.scene.rewards.RewardTaskType")

local MarblesTaskItemModel = class(Model, "MarblesTaskItemModel")

function MarblesTaskItemModel:ctor(taskData)
    self.taskData = taskData
    self.taskId = taskData.taskId
    self.state = taskData.state
    self.progress = taskData.progress
end

function MarblesTaskItemModel:GetTaskId()
    return self.taskId
end

-- 奖励状态（-1：未达成；0：达成未领取；1；已领取）
function MarblesTaskItemModel:GetState()
    return self.state
end

-- 活跃度类型的奖励，当前值
function MarblesTaskItemModel:GetProgress()
    return self.progress
end

function MarblesTaskItemModel:GetType()
    return self.taskData.taskType
end

function MarblesTaskItemModel:GetTaskParam()
    return self.taskData.taskParam
end

function MarblesTaskItemModel:GetDesc()
    local descStr = self.taskData.desc
    local value = self:GetProgress()
    local param = self:GetTaskParam()
    local paramStr = string.formatNumWithUnit(param)
    local valueStr = string.formatNumWithUnit(value)
    local str = string.format(descStr, valueStr, paramStr)
    return str
end

function MarblesTaskItemModel:GetKeyCount()
    return self.taskData.taskReward
end

-- 跳转至指定界面
function MarblesTaskItemModel:IsJumpToAppointTask()
    local isJump = self:GetType() == RewardTaskType.Clearance
    return isJump
end

-- 按钮的状态(-2：跳转 -1：不能领取 0：可领取 1：已领取)
function MarblesTaskItemModel:GetButtonState()
    local taskType = self:GetType()
    if taskType == 4 then -- 充值跳转
        local state = self:GetState()
        if state == -1 then
            return -2
        end
    end
    return self:GetState()
end

return MarblesTaskItemModel
