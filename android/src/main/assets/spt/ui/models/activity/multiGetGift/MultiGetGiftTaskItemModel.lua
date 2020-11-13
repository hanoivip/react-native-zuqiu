local Model = require("ui.models.Model")
local RewardTaskType = require("ui.scene.rewards.RewardTaskType")

local MultiGetGiftTaskItemModel = class(Model, "MarblesTaskItemModel")

function MultiGetGiftTaskItemModel:ctor(taskData, multiGetGiftModel)
    self.taskData = taskData
    self.taskId = taskData.taskID
    self.state = taskData.state
    self.progress = taskData.progress
    self.showIndex = taskData.showIndex
    self.multiGetGiftModel = multiGetGiftModel
end

function MultiGetGiftTaskItemModel:GetTaskData()
    return self.taskData
end

function MultiGetGiftTaskItemModel:GetTaskId()
    return self.taskId
end

-- 奖励状态（-1：未达成；0：达成未领取；1；已领取）
function MultiGetGiftTaskItemModel:GetState()
    return self.state
end

-- 活跃度类型的奖励，当前值
function MultiGetGiftTaskItemModel:GetProgress()
    return self.progress
end

function MultiGetGiftTaskItemModel:GetType()
    return self.taskData.taskType
end

function MultiGetGiftTaskItemModel:GetTaskParam()
    return self.taskData.taskParam
end

function MultiGetGiftTaskItemModel:GetDesc()
    local descStr = self.taskData.desc
    local value = self:GetProgress()
    local param = self:GetTaskParam()
    local paramStr = string.formatNumWithUnit(param)
    local valueStr = string.formatNumWithUnit(value)
    local str = string.format(descStr, valueStr, paramStr)
    return str
end

function MultiGetGiftTaskItemModel:GetKeyCount()
    return self.taskData.scoreReward
end

-- index
function MultiGetGiftTaskItemModel:GetShowIndexs()
    return self.showIndex
end

-- 跳转至指定界面
function MultiGetGiftTaskItemModel:IsJumpToAppointTask()
    local isJump = self:GetType() == RewardTaskType.Clearance
    return isJump
end

-- 按钮的状态(-2：跳转 -1：不能领取 0：可领取 1：已领取)
function MultiGetGiftTaskItemModel:GetButtonState()
    local taskType = self:GetType()
    if taskType == 4 then -- 充值跳转
        local state = self:GetState()
        if state == -1 then
            return -2
        end
    end
    return self:GetState()
end

function MultiGetGiftTaskItemModel:GetMultiGetGiftModel()
    return self.multiGetGiftModel
end

function MultiGetGiftTaskItemModel:RefreshData(data)
    self.state = data.taskInfo.state
    self.progress = data.taskInfo.progress
end

return MultiGetGiftTaskItemModel
