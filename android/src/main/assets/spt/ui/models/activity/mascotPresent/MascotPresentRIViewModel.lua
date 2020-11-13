local RewardItemViewModel = require("ui.models.quest.RewardItemViewModel")
local MascotPresentRIViewModel = class(RewardItemViewModel, "MascotPresentRIViewModel")

function MascotPresentRIViewModel:ctor(data)
    assert(type(data) == "table" and type(data.static) == "table", "data error!!!")
    self.infoData = data
    MascotPresentRIViewModel.super.ctor(self, data)
    self.specialTaskTable = {
        ["1"] = "normal",
        ["2"] = "normal",
        ["3"] = "normal",
        ["4"] = "normal",
        ["5"] = "worldTourTaskID",
        ["6"] = "normal",
        ["7"] = "careerTaskID",
        ["8"] = "normal",
        ["9"] = "normal",
        ["10"] = "normal",
        ["11"] = "normal",
        ["12"] = "chargeTaskID",
    }
end

function MascotPresentRIViewModel:SpecifyTaskType(taskID)
    return self.specialTaskTable[tostring(taskID)] or "normal"
end

function MascotPresentRIViewModel:GetTaskType()
    return self.infoData.static.taskType or 1
end

function MascotPresentRIViewModel:GetTaskDesc()
    local taskDesc = self.infoData.static.taskDesc or ""
    return taskDesc
end

function MascotPresentRIViewModel:GetContents()
    return self.infoData.static.contents or {}
end

function MascotPresentRIViewModel:GetCurrentProgressValue()
    return self.infoData.data or "" 
end

function MascotPresentRIViewModel:GetTaskProgressValue()
    return self.infoData.static.taskParam1 or ""
end

function MascotPresentRIViewModel:GetRewardMascotPoint()
    local contents = self:GetContents()
    local mascotPoint = contents.jxw or 0
    return mascotPoint
end

function MascotPresentRIViewModel:IsTaskFinished()
    local progressValue = self:GetCurrentProgressValue()
    local taskValue = self:GetTaskProgressValue()
    return tonumber(progressValue) >= tonumber(taskValue)
end

function MascotPresentRIViewModel:GetTaskID()
    assert(self.infoData.keyValue, "data error!!!")
    return self.infoData.keyValue
end

function MascotPresentRIViewModel:GetGuildReward()
    local contents = {}
    contents.jxw = self.infoData.static.GuideJxw or 0
    return contents
end

--设置奖励状态已领取
function MascotPresentRIViewModel:SetRewardStateCollected()
    self.infoData.state = 1
end

--可领取未领取
function MascotPresentRIViewModel:IsRewardCollectable()
    return self.infoData.state == 0
end

--已领取
function MascotPresentRIViewModel:IsRewardAlreadyCollected()
    return self.infoData.state == 1
end

--未达成条件
function MascotPresentRIViewModel:IsRewardUnqualified()
    return self.infoData.state == -1
end

return MascotPresentRIViewModel