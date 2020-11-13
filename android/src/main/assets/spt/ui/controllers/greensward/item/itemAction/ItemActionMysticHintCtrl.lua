local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionMysticHintCtrl = class(BaseCtrl, "ItemActionMysticHintCtrl")

-- 绿茵征途道具，查看神秘指令行为
function ItemActionMysticHintCtrl:Init(greenswardItemActionModel, greenswardBuildModel)
    ItemActionMysticHintCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionMysticHintCtrl:DoAction()
    local itemModel = self.actionModel:GetItemModel() -- GreenswardItemModel
    local dialogPath = "ui.controllers.greensward.prop.MysticHintDialogCtrl"
    res.PushDialog(dialogPath, self.buildModel, itemModel)

    self:DoNextAction()
end

return ItemActionMysticHintCtrl
