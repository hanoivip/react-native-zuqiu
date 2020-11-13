local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionDialogConfirmCtrl = class(BaseCtrl, "ItemActionDialogConfirmCtrl")

-- 绿茵征途道具，弹出对话框行为
function ItemActionDialogConfirmCtrl:Init(greenswardItemActionModel, greenswardBuildModel)
    ItemActionDialogConfirmCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionDialogConfirmCtrl:DoAction()
    local onConfirmCallback = function()
        self:DoNextAction()
    end
    local title, msg = self.actionModel:GetActionCookedParam()
    DialogManager.ShowConfirmPop(title, msg, onConfirmCallback)
end

return ItemActionDialogConfirmCtrl
