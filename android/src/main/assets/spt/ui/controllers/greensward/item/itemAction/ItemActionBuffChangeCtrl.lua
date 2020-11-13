local DialogManager = require("ui.control.manager.DialogManager")
local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionBuffChangeCtrl = class(BaseCtrl, "ItemActionBuffChangeCtrl")

-- 绿茵征途道具，修改自身buff行为
function ItemActionBuffChangeCtrl:Init(greenswardItemActionModel, greenswardBuildModel)
    ItemActionBuffChangeCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionBuffChangeCtrl:DoAction()
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

return ItemActionBuffChangeCtrl
