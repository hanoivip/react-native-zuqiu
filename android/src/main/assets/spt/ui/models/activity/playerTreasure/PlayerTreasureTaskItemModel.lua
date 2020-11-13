local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")
local SystemReward = require("data.SystemReward")
local RewardTaskType = require("ui.scene.rewards.RewardTaskType")
local TASK_TYPE = require("ui.controllers.rewards.TASK_TYPE")

local PlayerTreasureTaskItemModel = class(Model, "PlayerTreasureTaskItemModel")

function PlayerTreasureTaskItemModel:ctor(taskData)
    self.taskData = taskData
    self.taskId = taskData.taskId
    self.taskState = taskData.taskState
    self.taskValue = taskData.taskValue
end

function PlayerTreasureTaskItemModel:GetTaskId()
    return self.taskId
end

-- 奖励状态（-1：未达成；0：达成未领取；1；已领取）
function PlayerTreasureTaskItemModel:GetState()
    return self.taskState
end

-- 活跃度类型的奖励，当前值
function PlayerTreasureTaskItemModel:GetValue()
    return self.taskValue
end

function PlayerTreasureTaskItemModel:GetType()
    return self.taskData.taskType
end

function PlayerTreasureTaskItemModel:GetTaskParam()
    return self.taskData.taskParam1
end

function PlayerTreasureTaskItemModel:GetDesc()
    local descStr = self.taskData.taskDesc
    local value = self:GetValue()
    local param = self:GetTaskParam()
    local str = string.format(descStr, value, param)
    return str
end

function PlayerTreasureTaskItemModel:GetKeyCount()
    return self.taskData.keysCount
end

-- 跳转至指定界面
function PlayerTreasureTaskItemModel:IsJumpToAppointTask()
    local isJump = self:GetType() == RewardTaskType.Clearance
    return isJump
end

-- 按钮的状态(-2：跳转 -1：不能领取 0：可领取 1：已领取)
function PlayerTreasureTaskItemModel:GetButtonState()
    local taskType = self:GetType()
    if taskType == 4 then -- 充值跳转
        local state = self:GetState()
        if state == -1 then
            return -2
        end
    end
    return self:GetState()
end

return PlayerTreasureTaskItemModel