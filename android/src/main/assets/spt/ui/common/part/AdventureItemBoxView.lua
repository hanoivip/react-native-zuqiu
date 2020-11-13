local ItemBoxView = require("ui.common.part.ItemBoxView")

local AdventureItemBoxView = class(ItemBoxView, "AdventureItemBoxView")

function AdventureItemBoxView:ctor()
    AdventureItemBoxView.super.ctor(self)
end

function AdventureItemBoxView:start()
    AdventureItemBoxView.super.start(self)
end

function AdventureItemBoxView:OnItemClick()
    local MenuType = require("ui.controllers.itemList.MenuType")
    local dialogPath = self.itemModel:GetDialogPath()
    res.PushDialog(dialogPath, MenuType.ADVITEM, self.itemModel)
end

return AdventureItemBoxView