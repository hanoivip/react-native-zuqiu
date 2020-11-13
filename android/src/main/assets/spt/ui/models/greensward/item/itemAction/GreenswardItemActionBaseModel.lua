local AdventureItemAction = require("data.AdventureItemAction")
local Model = require("ui.models.Model")

local GreenswardItemActionBaseModel = class(Model, "GreenswardItemActionBaseModel")

-- 道具行为的model基类
-- @param id [string]: 行为的id
-- @param greenswardItemModel [GreenswardItemModel]: 与行为相关联的道具model
function GreenswardItemActionBaseModel:ctor(id, greenswardItemModel, greenswardBuildModel, args, argc)
    self.itemModel = nil -- 相关联的道具model
    self.actionId = nil -- 行为id
    self.staticData = nil -- 配置数据
    self.buildModel = nil

    self:Init(id, greenswardItemModel, greenswardBuildModel, unpack(args, 1, argc))
end

function GreenswardItemActionBaseModel:Init(id, greenswardItemModel, greenswardBuildModel)
    if greenswardItemModel ~= nil then
        self:SetItemModel(greenswardItemModel)
    end
    if greenswardBuildModel ~= nil then
        self:SetBuildModel(greenswardBuildModel)
    end
    if id ~= nil then -- 需要itemModel
        self:InitWithActionId(id)
    end
end

function GreenswardItemActionBaseModel:InitWithActionId(id)
    if id then
        self.actionId = tostring(id)
        self.staticData = self:ParseConfig(AdventureItemAction[self.actionId])
    end
end

-- 继承以解析配置，主要是参数列
function GreenswardItemActionBaseModel:ParseConfig(config)
    return config
end

-- 获得道具行为的id
function GreenswardItemActionBaseModel:GetId()
    return self.actionId
end

-- 获得道具行为的类型
function GreenswardItemActionBaseModel:GetActionType()
    return self.staticData ~= nil and self.staticData.actionType or nil
end

-- 获得当前道具行为的未加工参数
function GreenswardItemActionBaseModel:GetActionParam()
    return self.staticData ~= nil and self.staticData.actionParam or nil
end

-- 获得当前道具行为的加工后参数
function GreenswardItemActionBaseModel:GetActionCookedParam()
    return nil
end

-- 获得下一个道具行为的id
function GreenswardItemActionBaseModel:GetNextActionId()
    return self.staticData ~= nil and self.staticData.nextAction or nil
end

-- 是否有下一个行为
function GreenswardItemActionBaseModel:HasNextAction()
    local nextActionId = self:GetNextActionId()
    return tobool(nextActionId ~= nil and nextActionId > 0)
end

-- 获得当前道具行为相关联的itemModel
function GreenswardItemActionBaseModel:GetItemModel()
    return self.itemModel
end

-- 设置当前道具行为相关联的itemModel
function GreenswardItemActionBaseModel:SetItemModel(greenswardItemModel)
    self.itemModel = greenswardItemModel
end

function GreenswardItemActionBaseModel:GetBuildModel()
    return self.buildModel
end

function GreenswardItemActionBaseModel:SetBuildModel(greenswardBuildModel)
    self.buildModel = greenswardBuildModel
end

return GreenswardItemActionBaseModel
