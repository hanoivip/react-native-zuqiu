local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local DialogManager = require("ui.control.manager.DialogManager")
local StoreItemModel = require("ui.models.store.StoreItemModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local EventSystem = require("EventSystem")

local StoreItemCtrl = class()

-- function StoreItemCtrl:ctor(data)
--     if type(data) == "table" then
--         self.model = StoreItemModel.new(data)

--         local prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Store/StoreItemBoard.prefab")
--         local item = Object.Instantiate(prefab)
--         local spt = item:GetComponent(clr.CapsUnityLuaBehav)
--         spt:InitView(self.model)
--         spt:RegOnPriceButtonClick(function (eventData)
--             local timesLimit = self.model:GetTimesLimit()
--             local boughtCount = self.model:GetBoughtCount()
--             if timesLimit > 0 and boughtCount >= timesLimit then
--                 DialogManager.ShowToastByLang("no_buy_times")
--             else
--                 local titleKey = lang.trans("buy_confirm")
--                 local msgKey = lang.trans("buy_confirm_msg", self.model:GetItemPrice(), self.model:GetItemName())
--                 local confirmCallback = function ()
--                     clr.coroutine(function()
--                         local response = req.storeItemBuy(self.model:GetProductId(), 1)
--                         if api.success(response) then
--                             DialogManager.ShowToastByLang("buy_item_success")
--                             EventSystem.SendEvent("BuyStoreItem")
--                             local data = response.val
--                             if type(data.cost) == "table" then
--                                 if data.cost["type"] == "d" then
--                                     local playerInfoModel = PlayerInfoModel.new()
--                                     playerInfoModel:AddDiamond(-1 * data.cost.cost)
--                                     local consumeType = 3
--                                     if data.gift.m then
--                                         consumeType = 5
--                                     end
--                                     CustomEvent.ConsumeDiamond(consumeType, tonumber(data.cost.cost))
--                                 end
--                                 RewardUpdateCacheModel.new():UpdateCache(data.gift)
--                             end
--                         end
--                     end)
--                 end
--                 local cancelCallback = function ()
--                 end
--                 DialogManager.ShowConfirmPop(titleKey, msgKey, confirmCallback, cancelCallback, "camera")
--             end
--         end)
--         self.view = spt
--     end
-- end

function StoreItemCtrl:ctor(data)
    if type(data) == "table" then
        self.model = StoreItemModel.new(data)

        local prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Store/StoreItemBoard.prefab")
        local item = Object.Instantiate(prefab)
        local spt = item:GetComponent(clr.CapsUnityLuaBehav)
        spt:InitView(self.model)
        spt:RegOnPriceButtonClick(function (eventData)
            local timesLimit = self.model:GetTimesLimit()
            local boughtCount = self.model:GetBoughtCount()
            if timesLimit > 0 then
                if boughtCount >= timesLimit then
                    DialogManager.ShowToastByLang("no_buy_times")
                else
                    -- 一次只能购买一个的窗口
                    res.PushDialog("ui.controllers.store.StoreItemDetailOneCtrl", self.model)
                end
            else
                -- 购买多个的窗口
                res.PushDialog("ui.controllers.store.StoreItemDetailMultiCtrl", self.model)
            end
        end)
        self.view = spt
    end
end

return StoreItemCtrl

