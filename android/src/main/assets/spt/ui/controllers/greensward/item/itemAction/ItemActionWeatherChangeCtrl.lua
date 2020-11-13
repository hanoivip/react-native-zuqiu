local DialogManager = require("ui.control.manager.DialogManager")
local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionWeatherChangeCtrl = class(BaseCtrl, "ItemActionWeatherChangeCtrl")

-- 绿茵征途道具，使用天气卡行为
function ItemActionWeatherChangeCtrl:Init(greenswardItemActionModel, greenswardBuildModel)
    ItemActionWeatherChangeCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionWeatherChangeCtrl:DoAction()
    local itemModel = self.actionModel:GetItemModel()
    if not itemModel then return end

    local itemId = itemModel:GetId()

    local callback = function(data)
        local base = data.base
        local ret = data.ret
        local cost = nil
        if ret then
            cost = ret.cost
        end
        self.buildModel:RefreshBaseInfo(base)

        self:DoNextAction()
    end

    UseItemHelper.Use(itemId, nil, nil, callback)
end

return ItemActionWeatherChangeCtrl
