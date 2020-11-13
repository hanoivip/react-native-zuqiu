local ActionBaseModelPath = "ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel"
local ActionBaseCtrlPath = "ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl"
local ItemActionMap = require("ui.models.greensward.item.itemAction.GreenswardItemActionMap")
local ActionBaseModel = require(ActionBaseModelPath)
local ActionBaseCtrl = require(ActionBaseCtrlPath)
local AdventureItemAction = require("data.AdventureItemAction")

local GreenswardItemActionMainCtrl = class(_, "GreenswardItemActionMainCtrl")

-- 道具行为核心控制类
-- @param greenswardItemModel [GreenswardItemModel]: 绿茵征途道具的model
-- 传入itemModel，调用DoAction，执行道具功能
function GreenswardItemActionMainCtrl:ctor(greenswardItemModel, greenswardBuildModel, ...)
    self.itemModel = nil -- 相关联的道具moel
    self.actionModel = nil -- 具体的行为model
    self.actionCtrl = nil -- 真正的行为ctrl

    self.args = {...}
    self.argc = select("#", ...)

    if greenswardItemModel ~= nil and greenswardBuildModel ~= nil then
        self:Init(greenswardItemModel, greenswardBuildModel)
    end
end

function GreenswardItemActionMainCtrl:Init(greenswardItemModel, greenswardBuildModel)
    self.itemModel = greenswardItemModel
    self.buildModel = greenswardBuildModel
    self:Refresh(greenswardItemModel, greenswardBuildModel)
end

function GreenswardItemActionMainCtrl:Refresh(greenswardItemModel, greenswardBuildModel)
    self.actionModel, self.actionCtrl = self:GetConcreteAction(self.itemModel:GetActionId())
end

-- 实例化真正的行为ctrl与model
function GreenswardItemActionMainCtrl:GetConcreteAction(actionId)
    actionId = tostring(actionId)
    local actionType = AdventureItemAction[actionId] ~= nil and AdventureItemAction[actionId].actionType or nil
    local actionMapConfig = actionType ~= nil and ItemActionMap[actionType] or nil
    local modelPath = actionMapConfig ~= nil and actionMapConfig.model or ActionBaseModelPath
    local ctrlPath = actionMapConfig ~= nil and actionMapConfig.ctrl or ActionBaseCtrlPath

    local ConcreteActionModel = require(modelPath) or ActionBaseModel
    local actionModel = ConcreteActionModel.new(actionId, self.itemModel, self.buildModel, self.args, self.argc)

    local ConcreteActionCtrl = require(ctrlPath) or ActionBaseCtrl
    local actionCtrl = ConcreteActionCtrl.new(actionModel, self.buildModel, self.args, self.argc)
    actionCtrl:SetMainCtrl(self)

    return actionModel, actionCtrl
end

-- 执行道具行为
function GreenswardItemActionMainCtrl:DoAction()
    if self.actionCtrl then
        self.actionCtrl:DoAction()
    end
end

-- 执行下一个行为
function GreenswardItemActionMainCtrl:DoNextAction(...)
    local nextActionId = self.actionCtrl:OnNextAction()

    local args = {...}
    local argc = select("#", ...)
    if argc > 0 then
        self.args = args
        self.argc = argc
    end
    self.actionModel = nil
    self.actionCtrl = nil

    self.actionModel, self.actionCtrl = self:GetConcreteAction(nextActionId)
    self:DoAction()
end

return GreenswardItemActionMainCtrl
