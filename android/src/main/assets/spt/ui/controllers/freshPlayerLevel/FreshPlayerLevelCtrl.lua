local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local FreshPlayerLevelModel = require("ui.models.freshPlayerLevel.FreshPlayerLevelModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local FreshPlayerLevelCtrl = class(BaseCtrl, "FreshPlayerLevelCtrl")

FreshPlayerLevelCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/FreshPlayerLevelBox/FreshPlayerLevelBoard.prefab"

function FreshPlayerLevelCtrl:Init()
    self.view.buyBtnClick = function(subID, content) self:OnBuyClick(subID, content) end
    self.view.onTimeOut = function() self:OnTimeOut() end
end

function FreshPlayerLevelCtrl:Refresh()
    FreshPlayerLevelCtrl.super.Refresh(self)
    self.freshPlayerLevelModel = FreshPlayerLevelModel.new()
    self.view:InitView(self.freshPlayerLevelModel)
end

function FreshPlayerLevelCtrl:OnBuyClick(subID, content)
    content = content or {}
    local remainTime = self.freshPlayerLevelModel:GetRemainTimeById(subID)
    if remainTime < 1 then
        DialogManager.ShowToastByLang("belatedGift_item_nil_time")
        return
    end
    local levelData = self.freshPlayerLevelModel:GetStaticDataById(subID)
    local priceType = levelData.priceType
    local price = levelData.price
    local selectId = content.contentId
    if price > 0 then
        local title = lang.trans("tips")
        local currencyName = price .. lang.transstr(CurrencyNameMap[priceType])
        local gift = {}
        gift.item = levelData.item
        local itemName = RewardNameHelper.GetSingleContentName(content.contents or gift)
        local content = lang.trans("itemPurchase_buyTip", currencyName, itemName)
        DialogManager.ShowConfirmPop(title, content, function()
            self:Buy(subID, selectId)
        end)
    else
        self:Buy(subID, selectId)
    end
end

function FreshPlayerLevelCtrl:Buy(subID, selectId)
    self.view:coroutine(function()
        local response = req.levelBoxReceive(subID, selectId)
        if api.success(response) then
            local data = response.val
            local freshPlayerLevelModel = FreshPlayerLevelModel.new()
            freshPlayerLevelModel:RefreshSingleData(data)
            self.view:GetScrollNormalizedPosition()
            self.view:InitView(freshPlayerLevelModel)
            self.view:SetScrollNormalizedPosition()
            local cost = data.cost
            local playerInfoModel = PlayerInfoModel.new()
            playerInfoModel:CostDetail(cost)
            CongratulationsPageCtrl.new(data.contents)
        end
    end)
end

function FreshPlayerLevelCtrl:OnTimeOut()
    self.view:GetScrollNormalizedPosition()
    self.view:InitView(self.freshPlayerLevelModel)
    self.view:SetScrollNormalizedPosition()
end

return FreshPlayerLevelCtrl
