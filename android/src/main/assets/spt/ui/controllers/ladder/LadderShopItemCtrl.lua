local LadderShopItemModel = require("ui.models.ladder.LadderShopItemModel")
local LadderShopEquipModel = require("ui.models.ladder.LadderShopEquipModel")
local LadderShopEquipPieceModel = require("ui.models.ladder.LadderShopEquipPieceModel")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local LimitType = require("ui.scene.itemList.LimitType")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ItemPlateType = require("ui.scene.itemList.ItemPlateType")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local LadderShopItemCtrl = class()

function LadderShopItemCtrl:ctor(view)
    self.view = view
end

function LadderShopItemCtrl:InitView(ladderModel, data)
    self.ladderModel = ladderModel
    self.data = data
    self.view.fillItemArea = function() self:FillItemArea() end
    self.view.onBuy = function() self:OnBuy() end
    self.view:InitView(self.data)
    self:InitEquipUseSymbol()
end

function LadderShopItemCtrl:FillItemArea()
    if self.data.cate == "item" then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
        self.view:AddItemBox(obj)
        local itemModel = LadderShopItemModel.new(self.data.id, self.data.num)
        spt:InitView(itemModel, self.data.id, true, true, true, ItemOriginType.OTHER)
    elseif self.data.cate == "eqs" or self.data.cate == "equipPiece" then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
        self.view:AddItemBox(obj)
        if self.data.cate == "eqs" then
            local equipModel = LadderShopEquipModel.new(self.data.id, self.data.num)
            spt:InitView(equipModel, self.data.id, true, true, false, true, ItemOriginType.OTHER)
        elseif self.data.cate == "equipPiece" then
            local equipPieceModel = LadderShopEquipPieceModel.new(self.data.id, self.data.num)
            spt:InitView(equipPieceModel, self.data.id, true, true, true, true, ItemOriginType.OTHER)
        end
    end
end

function LadderShopItemCtrl:InitEquipUseSymbol()
    if self.data.cate == "eqs" or self.data.cate == "equipPiece" then
        local playerTeamsModel = PlayerTeamsModel.new()
        playerTeamsModel:Init()
        local initPlayerData = playerTeamsModel:GetInitPlayersData(playerTeamsModel:GetNowTeamId())
        for k, pcid in pairs(initPlayerData) do
            local playerModel = CardBuilder.GetStarterModel(pcid)
            playerModel:InitEquipsAndSkills()
            if playerModel:HasNeedEquip(self.data.id) then
                self.view:InitEquipUseSymbol(true)
                return
            end
        end
    end
    self.view:InitEquipUseSymbol(false)
end

function LadderShopItemCtrl:OnBuy()
    -- 单次购买
    local plateType = ItemPlateType.OrdinaryItemOne
    if self.data.cate == "item" then
        plateType = ItemPlateType.OrdinaryItemMultiWithMax
    end
    local price = self.data.price / (self.data.discount + 1)
    local limitAmount = math.floor(self.ladderModel:GetMyCurrentHonorPoint() / price)
    if limitAmount < 1 then
        DialogManager.ShowToast(lang.trans("landder_shop_no_full"))
        return
    end
    -- 在这里弹出购买弹板
    local data = {
        currencyType = CurrencyType.LadderDiamond,
        price = price,
        plateType = plateType,
        boughtTime = 0,
        itemId = self.data.id,
        limitAmount = limitAmount,
        limitType = LimitType.NoLimit,
        itemType = self.data.cate
    }

    local function purchaseCallback(num)
        clr.coroutine(function()
            local respone = req.ladderStoreBuy(self.data.slot, self.data.id, self.data.discount, num)
            if api.success(respone) then
                local data = respone.val
                -- 更新花费，更新获奖数据
                if data.cost and data.cost.type == CurrencyType.LadderDiamond then
                    self.ladderModel:SetMyCurrentHonorPoint(data.cost.curr_num)
                end
                if data.contents then
                    CongratulationsPageCtrl.new(data.contents)
                end
                if data.goods then
                    self.ladderModel:RefreshShopList(data.goods)
                end
            end
        end)
    end

    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", data, function (num)
        purchaseCallback(num)
    end)
end

return LadderShopItemCtrl