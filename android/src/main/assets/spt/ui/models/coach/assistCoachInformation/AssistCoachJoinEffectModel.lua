local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local Model = require("ui.models.Model")

local AssistCoachJoinEffectModel = class(Model, "AssistCoachJoinEffectModel")


function AssistCoachJoinEffectModel:ctor()
    self.data = nil
    self.acModel = nil
    self.itemModels = {}

    self.coachItemMapModel = CoachItemMapModel.new()
end

function AssistCoachJoinEffectModel:InitWithProtocol(data)
    self.data = data
    self.acModel = AssistantCoachModel.new()
    self.acModel:InitWithProtocol(self.data.ac_info)
    for k, itemModel in ipairs(self.itemModels) do
        itemModel.isSuccess = self.data.items[tostring(itemModel:GetId())] == 1
    end
end

-- 设置消耗的物品id数组
function AssistCoachJoinEffectModel:SetCostItemIds(ids)
    self.itemModels = {}
    for i, id in ipairs(ids) do
        table.insert(self.itemModels, self.coachItemMapModel:GetCoachItemModelById(id))
    end
end

-- 获得消耗的物品aciModel
function AssistCoachJoinEffectModel:GetCostItemModels()
    return self.itemModels
end

-- 获得成功使用的aciModel
function AssistCoachJoinEffectModel:GetSuccessItemModels()
    local result = {}
    for k, itemModel in ipairs(self.itemModels) do
        if itemModel.isSuccess then
            table.insert(result, itemModel)
        end
    end
    return result
end

-- 根据位置，获得使用的aciModel
function AssistCoachJoinEffectModel:GetSuccessItemModel(idx)
    return self.itemModels[idx]
end

-- 获得本次合成消耗的物品实际数目
function AssistCoachJoinEffectModel:GetCostItemNum()
    return #self.itemModels
end

-- 获得预期星级
function AssistCoachJoinEffectModel:GetPreStar()
    return tonumber(self.acModel:GetQuality())
end

-- 获得合成的助理教练Model
function AssistCoachJoinEffectModel:GetNewAssistantCoachModel()
    return self.acModel
end

return AssistCoachJoinEffectModel
