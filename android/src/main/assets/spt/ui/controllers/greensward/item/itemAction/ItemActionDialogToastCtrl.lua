local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionDialogToastCtrl = class(BaseCtrl, "ItemActionDialogToastCtrl")

-- 绿茵征途道具，白条提示行为
function ItemActionDialogToastCtrl:Init(greenswardItemActionModel, greenswardBuildModel)
    ItemActionDialogToastCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionDialogToastCtrl:DoAction()
    DialogManager.ShowToast(self.actionModel:GetMsg())
    self:DoNextAction()
end

return ItemActionDialogToastCtrl
