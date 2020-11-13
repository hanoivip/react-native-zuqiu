local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ArenaStoreModel = require("ui.models.arena.store.ArenaStoreModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local ArenaStoreItemPopCtrl = class(BaseCtrl, "ArenaStoreItemPopCtrl")


ArenaStoreItemPopCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaStorePopBoard.prefab"

ArenaStoreItemPopCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function ArenaStoreItemPopCtrl:Init(itemModel, notShowBtn)
    self.view.buyStoreItem = function () self:BuyStoreItem() end
    self.view.buyStoreItemMulti = function () self:BuyStoreItemMulti() end
end

function ArenaStoreItemPopCtrl:Refresh(itemModel, notShowBtn)
    self.itemModel = itemModel
    self.notShowBtn = notShowBtn
    self.view:InitView(itemModel, notShowBtn)
end

function ArenaStoreItemPopCtrl:GetStatusData(itemModel, notShowBtn)
    return self.itemModel, self.notShowBtn
end

function ArenaStoreItemPopCtrl:BuyStoreItem()
    clr.coroutine(function ()
        local response = req.useItem(self.view.itemModel:GetId(), 1)
        if api.success(response) then
            local data = response.val
            ItemsMapModel.new():ResetItemNum(data.item.id, data.item.num)
            if tonumber(data.item.num) == 0 then
                self.view:Close()
            end
            CongratulationsPageCtrl.new(data.contents)
        end
    end)
end

function ArenaStoreItemPopCtrl:BuyStoreItemMulti()
    self.view:Close()
    clr.coroutine(function ()
        local response = req.multiUseItem(self.view.itemModel:GetId())
        if api.success(response) then
            local data = response.val
            ItemsMapModel.new():ResetItemNum(data.item.id, data.item.num)
            CongratulationsPageCtrl.new(data.contents)
        end
    end)
end

return ArenaStoreItemPopCtrl