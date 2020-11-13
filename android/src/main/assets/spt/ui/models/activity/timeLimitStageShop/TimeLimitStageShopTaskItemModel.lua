local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")
local SystemReward = require("data.SystemReward")
local RewardTaskType = require("ui.scene.rewards.RewardTaskType")
local TASK_TYPE = require("ui.controllers.rewards.TASK_TYPE")

local TimeLimitStageShopTaskItemModel = class(Model, "TimeLimitStageShopTaskItemModel")

function TimeLimitStageShopTaskItemModel:ctor(taskData)
    self.taskData = taskData
    self.taskId = taskData.taskId
    self.state = taskData.state
    self.progress = taskData.progress
end

function TimeLimitStageShopTaskItemModel:GetTaskId()
    return self.taskId
end

-- 奖励状态（-1：未达成；0：达成未领取；1；已领取）
function TimeLimitStageShopTaskItemModel:GetState()
    return self.state
end

-- 活跃度类型的奖励，当前值
function TimeLimitStageShopTaskItemModel:GetProgress()
    return self.progress
end

function TimeLimitStageShopTaskItemModel:GetType()
    return self.taskData.taskType
end

function TimeLimitStageShopTaskItemModel:GetTaskParam()
    return self.taskData.taskParam
end

function TimeLimitStageShopTaskItemModel:GetDesc()
    local descStr = self.taskData.desc
    local value = self:GetProgress()
    local param = self:GetTaskParam()
    local paramStr = string.formatNumWithUnit(param)
    local valueStr = string.formatNumWithUnit(value)
    local str = string.format(descStr, valueStr, paramStr)
    return str
end

function TimeLimitStageShopTaskItemModel:GetKeyCount()
    return self.taskData.taskReward
end

-- 跳转至指定界面
function TimeLimitStageShopTaskItemModel:IsJumpToAppointTask()
    local isJump = self:GetType() == RewardTaskType.Clearance
    return isJump
end

-- 按钮的状态(-2：跳转 -1：不能领取 0：可领取 1：已领取)
function TimeLimitStageShopTaskItemModel:GetButtonState()
    local taskType = self:GetType()
    if taskType == 4 then -- 充值跳转
        local state = self:GetState()
        if state == -1 then
            return -2
        end
    end
    return self:GetState()
end

return TimeLimitStageShopTaskItemModel
