local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local EventSystem = require("EventSystem")

local StoreItemDetailMultiCtrl = class(BaseCtrl)

StoreItemDetailMultiCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Store/StoreItemDetailMulti.prefab"

StoreItemDetailMultiCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function StoreItemDetailMultiCtrl:Init(model)
    self.model = model
    self.view:Init(model)
    self.view:RegOnBuyBtnClick(function(buyCount)
        local costDiamond = buyCount * model:GetItemPrice()
        CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
			local confirmCallback = function()
				clr.coroutine(function()
					local response = req.storeItemBuy(self.model:GetProductId(), buyCount)
					if api.success(response) then
						EventSystem.SendEvent("BuyStoreItem")
						DialogManager.ShowToastByLang("buy_item_success")
						local data = response.val
						if type(data.cost) == "table" then
							if data.cost["type"] == "d" then
								local playerInfoModel = PlayerInfoModel.new()
								playerInfoModel:AddDiamond(-1 * data.cost.cost)
								local consumeType = 3
								if data.gift.m then
									consumeType = 5
								end
								CustomEvent.ConsumeDiamond(consumeType, tonumber(data.cost.cost))
							end
							RewardUpdateCacheModel.new():UpdateCache(data.gift)
							self.view:Close()
						end
					end
				end)
			end
			DialogMultipleConfirmation.MultipleConfirmation(lang.trans("tips"), lang.trans("comfirm_tips"), confirmCallback)
        end)
    end)
end

return StoreItemDetailMultiCtrl

