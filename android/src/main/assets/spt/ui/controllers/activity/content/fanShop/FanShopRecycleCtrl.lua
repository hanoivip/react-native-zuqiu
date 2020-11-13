local FanShopRecycleModel = require("ui.models.activity.fanShop.FanShopRecycleModel")
local EventSystem = require("EventSystem")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local ItemType = require("ui.scene.itemList.ItemType")

local BaseCtrl = require("ui.controllers.BaseCtrl")
local FanShopRecycleCtrl = class(BaseCtrl)

FanShopRecycleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FanShop/FanShopRecycleBroad.prefab"
FanShopRecycleCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function FanShopRecycleCtrl:Init()
end

function FanShopRecycleCtrl:Refresh()
    self.view.onAdd = function(pieceName, itemType) self:OnAdd(pieceName, itemType) end
    self.view.onSetAddTipShown = function(hasShown) self:SetHasShownLackItemTip(hasShown) end
    self.view.onSub = function() self:OnSub() end
    self.view.onClose = function() self:OnClose() end
    self.view.onClickRecycle = function() self:OnClickRecycle() end
    self.view.scrollView.clickCardPiece = function(itemData) self:OnClickCardPiece(itemData) end
    self.view:InitView(self.fanShopRecycleModel)

    self.hasShownLackItemTip = false
end

function FanShopRecycleCtrl:AheadRequest(period)
    self.period = period
    local response = req.fanShopRecycleStore(self.period)
    if api.success(response) then
        self.fanShopRecycleModel = FanShopRecycleModel.new(isSelf)
        self.fanShopRecycleModel:InitWithProtocol(response.val)
    end
end

function FanShopRecycleCtrl:OnClickCardPiece(itemData)
    self.sellNum = itemData.num > 0 and 1 or 0
    self.canRecycle = true
    if itemData.canRecycle ~= nil then
        self.canRecycle = itemData.canRecycle
    end
    self.sellItemData = itemData
    self.view:InitPieceInfo(itemData)
    self.view:SetSellNum(self.sellNum)
end

function FanShopRecycleCtrl:OnAdd(pieceName, itemType)
    if self.canRecycle then
        if self.sellNum + 1 <= self.sellItemData.num then
            self.sellNum = self.sellNum + 1
            self.view:SetSellNum(self.sellNum)
        else
            if not self.hasShownLackItemTip then
                local selectPieceName = pieceName
                if itemType == ItemType.Card then
                    selectPieceName = selectPieceName .. lang.transstr("fanshop_whole_card")
                    DialogManager.ShowToast(lang.transstr("fan_shop_recycle_wholecard_tip", selectPieceName))
                else
                    selectPieceName = pieceName .. lang.transstr("piece")
                    DialogManager.ShowToast(lang.transstr("lack_item_tips", selectPieceName))
                end
                self.hasShownLackItemTip = true
            end
        end
    end
end

function FanShopRecycleCtrl:SetHasShownLackItemTip(hasShown)
    self.hasShownLackItemTip = hasShown
end

function FanShopRecycleCtrl:OnClose()
    EventSystem.SendEvent("RefreshFanCoin")
end

function FanShopRecycleCtrl:OnSub()
    if self.sellNum - 1 > 0 then
        self.sellNum = self.sellNum - 1
        self.view:SetSellNum(self.sellNum)
    end
end

function FanShopRecycleCtrl:OnClickRecycle()
    if self.sellNum > 0 and self.canRecycle then
        local pieceName = self.sellItemData.fullName
        local pieceQuality  = nil
        local fixQuality = nil
        local pcid = nil
        if self.sellItemData.itemType ~= ItemType.Card then
            pieceQuality = self.sellItemData.itemModel:GetQuality()
            fixQuality = CardHelper.GetQualityFixed(pieceQuality, self.sellItemData.itemModel:GetQualitySpecial())
        else
            fixQuality = self.sellItemData.itemModel:GetCardFixQuality()
            pcid = self.sellItemData.pcid
        end
        pieceQuality = CardHelper.GetQualitySign(fixQuality)
        pieceName = pieceQuality .. pieceName
        pieceName = lang.transstr("fanShop_sell_tip", self.sellNum, pieceName)
        DialogManager.ShowConfirmPop(lang.trans("tips"), pieceName, function()
            clr.coroutine(function()
                local response = req.fanShopSell(self.sellItemData.recycleId, self.sellNum, pcid)
                if api.success(response) then
                    local data = response.val
                    if self.sellItemData.itemType ~= ItemType.Card then
                        self.sellItemData.num = self.sellItemData.num - self.sellNum
                        self.fanShopRecycleModel:RefreshItemData(self.sellItemData, self.sellNum)
                        self:OnClickCardPiece(self.sellItemData)
                        self.fanShopRecycleModel:CostItem(data.cost)
                        local cost = data.cost
                        local cardPiece = data.cost.cardPiece[1]
                        if next(data) and cardPiece then
                            local cid = cardPiece.cid
                            local finalNum = cardPiece.num
                            local playerPiecesMapModel = PlayerPiecesMapModel.new()
                            if finalNum > 0 then
                                playerPiecesMapModel:ResetPieceData(cid, cardPiece)
                            else
                                playerPiecesMapModel:RemovePieceData(cid)
                            end
                        end
                    else
                        self.sellItemData.num = self.sellItemData.num - self.sellNum
                        self.fanShopRecycleModel:RefreshItemData(self.sellItemData, self.sellNum)
                        self.view:InitView(self.fanShopRecycleModel)
                        self.fanShopRecycleModel:RemoveCardData(pcid)
                    end

                    if data and data.gift and next(data.gift) then
                        CongratulationsPageCtrl.new(data.gift)
                    end
                end
            end)
        end)
    end
end

function FanShopRecycleCtrl:OnEnterScene()
end

function FanShopRecycleCtrl:OnExitScene()
end

return FanShopRecycleCtrl

