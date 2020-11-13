local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionTreasureMapCtrl = class(BaseCtrl, "ItemActionTreasureMapCtrl")

-- 绿茵征途道具，查看藏宝图行为
function ItemActionTreasureMapCtrl:Init(greenswardItemActionModel, greenswardBuildModel)
    ItemActionTreasureMapCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionTreasureMapCtrl:DoAction()
    local itemModel = self.actionModel:GetItemModel() -- GreenswardItemModel
    local treasureMapType = itemModel:GetSubType()
    local dialogPath = ""
    if treasureMapType == 1 then
        dialogPath = "ui.controllers.greensward.prop.MapAppointDialogCtrl"
    elseif treasureMapType == 2 then
        dialogPath = "ui.controllers.greensward.prop.MapConditionDialogCtrl"
    end
    res.PushDialog(dialogPath, self.buildModel, itemModel)

    self:DoNextAction()
end

return ItemActionTreasureMapCtrl
