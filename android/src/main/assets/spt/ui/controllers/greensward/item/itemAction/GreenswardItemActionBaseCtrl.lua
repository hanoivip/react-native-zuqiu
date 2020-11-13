local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardItemActionBaseCtrl = class()

-- 道具行为的ctrl基类
function GreenswardItemActionBaseCtrl:ctor(greenswardItemActionModel, greenswardBuildModel, args, argc)
    self.actionModel = nil
    self.buildModel = nil

    if greenswardItemActionModel then
        self:Init(greenswardItemActionModel, greenswardBuildModel, unpack(args, 1, argc))
    end
end

-- 可获取mainCtrl传下的其他参数
function GreenswardItemActionBaseCtrl:Init(greenswardItemActionModel, greenswardBuildModel)
    self.actionModel = greenswardItemActionModel
    self.buildModel = greenswardBuildModel
end

function GreenswardItemActionBaseCtrl:Refresh(greenswardItemActionModel, greenswardBuildModel)
end

function GreenswardItemActionBaseCtrl:DoAction()
    DialogManager.ShowToastByLang("itemList_itemMenuItem")
end

function GreenswardItemActionBaseCtrl:DoNextAction(...)
    if self.mainCtrl and self.actionModel:HasNextAction() then
        self.mainCtrl:DoNextAction(...)
    end
end

function GreenswardItemActionBaseCtrl:OnNextAction()
    local nextActionId = self.actionModel:GetNextActionId()
    -- do something
    return nextActionId
end

function GreenswardItemActionBaseCtrl:SetMainCtrl(greenswardItemActionMainCtrl)
    self.mainCtrl = greenswardItemActionMainCtrl
end

return GreenswardItemActionBaseCtrl
