local DialogManager = require("ui.control.manager.DialogManager")
local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionWeakenOpponentCtrl = class(BaseCtrl, "ItemActionWeakenOpponentCtrl")

-- 绿茵征途道具，使用豪门小道报行为
function ItemActionWeakenOpponentCtrl:Init(greenswardItemActionModel, greenswardBuildModel, eventModel)
    ItemActionWeakenOpponentCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionWeakenOpponentCtrl:DoAction()
    local itemModel = self.actionModel:GetItemModel()
    if not itemModel then return end

    local eventModel = self.actionModel:GetEventModel()
    if not eventModel then return end

    local itemId = itemModel:GetId()
    local row = eventModel:GetRow()
    local col = eventModel:GetCol()

    local callback = function(data)
        local base = data.base
        local ret = data.ret
        local map = {}
        local cost = nil
        if ret then
            map = ret.map
            cost = ret.cost
        end
        self.buildModel:RefreshBaseInfo(base)
        -- 更新地图
        self.buildModel:RefreshEventData(map)
        res.PopScene()
        EventSystem.SendEvent("GreenswardItemUse_WeakenOpponent")

        self:DoNextAction()
    end

    UseItemHelper.Use(itemId, row, col, callback)
end

return ItemActionWeakenOpponentCtrl
