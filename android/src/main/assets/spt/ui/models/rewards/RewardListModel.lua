local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")
local SystemReward = require("data.SystemReward")
local TASK_TYPE = require("ui.controllers.rewards.TASK_TYPE")
local RewardItemModel = require("ui.models.rewards.RewardItemModel")

local TASK_CLASS_MAP = {
    [TASK_TYPE.NEW] = "New",
    [TASK_TYPE.MAIN] = "Main",
    [TASK_TYPE.DAILY] = "Daily",
}

-- 相同type奖励类型排序算法
local function SameTypeSort(aModel, bModel)
    if aModel:GetState() == bModel:GetState() then
        return aModel:GetItemOrder() < bModel:GetItemOrder()
    else
        return aModel:GetState() > bModel:GetState()
    end
end

-- 相同class奖励排序算法
local function SameClassSort(aModel, bModel)
    if aModel:GetTypeOrder() == bModel:GetTypeOrder() then
        return aModel:GetItemOrder() < bModel:GetItemOrder()
    else
        return aModel:GetTypeOrder() < bModel:GetTypeOrder()
    end
end

-- 可以领取奖励的排序(实现一种稳定排序 -- 封装一个index字段)
local function PriorGetRewardSort(a, b)
    if a.model:GetState() == b.model:GetState() then
        return a.index < b.index
    else
        return a.model:GetState() > b.model:GetState()
    end
end

local RewardListModel = class(Model, "RewardListModel")

function RewardListModel:ctor()
end

function RewardListModel:InitWithProtocol(data)
    self.data = data
end

function RewardListModel:GetRewardListData()
    return self.data
end

function RewardListModel:IsShowNewTaskType()
    local isShow = false
    local taskData = self.data.list[TASK_CLASS_MAP[TASK_TYPE.NEW]]
    if not taskData then return isShow end
    for i, v in ipairs(taskData) do
        for j, rewardState in ipairs(v.list) do
            local state = rewardState.state
            if state and state ~= 1 then
                isShow = true
                break
            end
        end
    end
    return isShow
end

-- 返回某一类型是否还有可以领取的奖励
function RewardListModel:IsCanGetReward(taskType)
    if not self.data.list[TASK_CLASS_MAP[taskType]] then return false end
    for i, v in ipairs(self.data.list[TASK_CLASS_MAP[taskType]]) do
        for j, rewardState in ipairs(v.list) do
            if rewardState.state == 0 then
                return true
            end
        end
    end
    return false
end

function RewardListModel:GetRewardItemModel(rewardID)
    return self.rewardItemModelMap[rewardID]
end

-- 高V玩家未领取的体力将会缓存
function RewardListModel:GetRewardCacheSp()
    return self.data.autoReceiveSp or 0
end

function RewardListModel:HasRewardCacheSp()
    return tobool(self:GetRewardCacheSp() > 0)
end

function RewardListModel:SetRewardCacheSp(sp)
    self.data.autoReceiveSp = sp
end

-- 返回此类型将要被显示到界面上的RewardItemModel列表
function RewardListModel:GetToBeShownRewardModelList(taskType)
    assert(taskType)
    local retRewardModelList = {}
    self.rewardItemModelMap = {}

    for i, v in ipairs(self.data.list[TASK_CLASS_MAP[taskType]]) do
        local sameTypeList = {}
        for j, rewardState in ipairs(v.list) do
            local rewardItemModel = RewardItemModel.new(rewardState.rewardID, rewardState.state, rewardState.value, rewardState.remainDays, rewardState.condition)
            if rewardItemModel:GetState() ~= 1 then
                table.insert(sameTypeList, rewardItemModel)
            end
            self.rewardItemModelMap[rewardState.rewardID] = rewardItemModel
        end
        
        if next(sameTypeList) then
            if sameTypeList[1]:GetArrangement() == 1 then
                table.sort(sameTypeList, SameTypeSort)
                table.insert(retRewardModelList, sameTypeList[1])
            elseif sameTypeList[1]:GetArrangement() == 2 then
                for k, tempModel in ipairs(sameTypeList) do
                    table.insert(retRewardModelList, tempModel)
                end
            end
        end
    end

    table.sort(retRewardModelList, SameClassSort)

    local list = {}
    for i, v in ipairs(retRewardModelList) do
        local t = {
            model = v,
            index = i
        }
        table.insert(list, t)
    end

    -- 可以领取的奖励优先排在前面
    table.sort(list, PriorGetRewardSort)

    retRewardModelList = {}
    for i, v in ipairs(list) do
        table.insert(retRewardModelList, v.model)
    end

    return retRewardModelList
end

-- 奖励收取
function RewardListModel:SetRewardReceiced(rewardID)
    assert(rewardID)
    for k, sameClassGroup in pairs(self.data.list) do
        for i, sameTypeList in ipairs(sameClassGroup) do
            for j, rewardState in ipairs(sameTypeList.list) do
                if rewardState.rewardID == rewardID then
                    rewardState.state = 1
                    EventSystem.SendEvent("RewardListModel_SetRewardReceiced", rewardID)
                end
            end
        end
    end
end

return RewardListModel
