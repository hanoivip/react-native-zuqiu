local MenuType = require("ui.controllers.itemList.MenuType")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local ItemDetailCtrl = require("ui.controllers.itemList.ItemDetailCtrl")

local AdventureItemDetailCtrl = class(ItemDetailCtrl, "AdventureItemDetailCtrl")

AdventureItemDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/ItemDetail.prefab"

AdventureItemDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AdventureItemDetailCtrl:Init(itemType, model)
    self.itemType = itemType
    self.model = model
end

function AdventureItemDetailCtrl:InitView()
    self.view:InitView(self.itemType, self.model, ItemOriginType.OTHER)
    self.view:ShowOrHidePlayerBoard(false)
end

return AdventureItemDetailCtrl
