local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local EventSystem = require("EventSystem")

local PlayerTreasureBuyKeyCtrl = class(BaseCtrl)

PlayerTreasureBuyKeyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureBuyKey.prefab"

PlayerTreasureBuyKeyCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PlayerTreasureBuyKeyCtrl:Init(playerTreasureModel, showTitle)
    local periodId = playerTreasureModel:GetPeriod()
    local price = playerTreasureModel:GetKeysPrice()
    self.view:Init(price, showTitle)
    self.view:RegOnBuyBtnClick(function(buyCount)
        local costDiamond = buyCount * tonumber(price)
        CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
            clr.coroutine(function()
                local response = req.activityBuyPlayerTreasureKey(periodId, buyCount)
                if api.success(response) then
                    local data = response.val
                    playerTreasureModel:SetKeysCount(data.keysCount)
                    EventSystem.SendEvent("BuyPlayerTreasureKey")
                    DialogManager.ShowToastByLang("buy_item_success")
                    if type(data.cost) == "table" then
                        local playerInfoModel = PlayerInfoModel.new()
                        playerInfoModel:CostDetail(data.cost)
                        self.view:Close()
                    end
                end
            end)
        end)
    end)
end

return PlayerTreasureBuyKeyCtrl
