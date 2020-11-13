local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local EventSystem = require("EventSystem")

local MarblesBuyKeyCtrl = class(BaseCtrl)

MarblesBuyKeyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesBuyKey.prefab"

MarblesBuyKeyCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MarblesBuyKeyCtrl:Init(marblesModel)
    local periodId = marblesModel:GetPeriodId()
    local price = marblesModel:GetBallPrice()
    self.view:Init(price)
    self.view:RegOnBuyBtnClick(function(buyCount)
        local costDiamond = buyCount * tonumber(price)
        CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
            clr.coroutine(function()
                local response = req.marblesBuyBall(periodId, buyCount)
                if api.success(response) then
                    local data = response.val
                    marblesModel:SetBallCnt(data.ballCnt)
                    EventSystem.SendEvent("Marbles_BuyBall")
                    local keyT = lang.transstr("buy_item_success")
                    local keyName = lang.transstr("marbles_ball")
                    keyName = lang.transstr("stage_shop_key_get", keyName, buyCount)
                    DialogManager.ShowToast(keyT .. " " .. keyName)
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

return MarblesBuyKeyCtrl
