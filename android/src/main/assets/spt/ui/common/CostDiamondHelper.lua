local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local DialogManager = require("ui.control.manager.DialogManager")

local CostDiamondHelper = {}

-- custNum 将要消耗的钻石数
-- view 跳转的到充值界面前的view
-- func 花费钻石的请求
function CostDiamondHelper.CostDiamond(costNum, view, func)
    local playerInfoModel = PlayerInfoModel.new()
    local playerDiamondNum = playerInfoModel:GetDiamond()
    -- 处理友情点抽卡,costNum为nil的话直接执行func
    if costNum and tonumber(costNum) > tonumber(playerDiamondNum) then
        local confirmCallback = function()
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
        end
        DialogManager.ShowConfirmPopByLang("tips", "diamondNotEnoughAndBuy", confirmCallback)
    else
        func()
    end
end

-- custNum 将要消耗的钻石数
-- view 跳转的到充值界面前的view
-- func 花费钻石的请求
function CostDiamondHelper.CostDiamondNotToBuy(costNum, view, func)
    local playerInfoModel = PlayerInfoModel.new()
    local playerDiamondNum = playerInfoModel:GetDiamond()
    -- 处理友情点抽卡,costNum为nil的话直接执行func
    if costNum and tonumber(costNum) > tonumber(playerDiamondNum) then
        DialogManager.ShowAlertPopByLang("tips", "diamondNotEnough")
    else
        func()
    end
end

-- 花费豪门币
function CostDiamondHelper.CostBlackDiamond(costNum, view, func)
    local playerInfoModel = PlayerInfoModel.new()
    local playerBlackDiamondNum = playerInfoModel:GetBlackDiamond()
    if costNum and tonumber(costNum) > tonumber(playerBlackDiamondNum) then
        local confirmCallback = function()
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
        end
        DialogManager.ShowConfirmPopByLang("tips", "store_gacha_tip_3", confirmCallback)
    else
        func()
    end
end

-- 花费豪门币或者钻石
function CostDiamondHelper.CostCurrency(costNum, view, func, currencyType)
    if currencyType == CurrencyType.Diamond then
        CostDiamondHelper.CostDiamond(costNum, view, func)
    elseif currencyType == CurrencyType.BlackDiamond then
        CostDiamondHelper.CostBlackDiamond(costNum, view, func)
    else
        if func and type(func) == "function" then
            func()
        end
    end
end

return CostDiamondHelper
