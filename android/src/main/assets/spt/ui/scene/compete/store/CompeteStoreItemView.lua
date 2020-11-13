local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local CompeteStoreItemView = class(unity.base, "CompeteStoreItemView")

function CompeteStoreItemView:ctor()
    self.txtName = self.___ex.name
    self.txtLimit = self.___ex.limit
    self.btnBuy = self.___ex.btnBuy
    self.txtPrice = self.___ex.price
    self.iconCurrency = self.___ex.iconCurrency
    self.itemArea = self.___ex.itemArea
    self.payTypeImg = self.___ex.payTypeImg
end

function CompeteStoreItemView:InitView(itemData)
    self.data = itemData
    if not self.data.num then self.data.num = 0 end -- 未购买过为nil
    self:InitItemArea()
    self.txtLimit.text = self:InitLimitTxt(self.data.limitType, self.data.num, self.data.limitAmount)
    self.txtPrice.text = tostring(self.data.price)
    self:InitCurrencyType()

    self.btnBuy:regOnButtonClick(function()
        if type(self.onClickBuy) == "function" then
            self.onClickBuy()
        end
    end)
end

-- 初始化购买限制文本
function CompeteStoreItemView:InitLimitTxt(limitType, currAmount, limitAmount)
    if limitType == 0 then     -- 不限购
        return ""
    elseif limitType == 1 then     -- 每日限购
        return lang.trans("compete_store_limit1", limitAmount - currAmount, limitAmount)
    elseif limitType == 2 then     -- 整期活动限购
        return lang.trans("compete_store_limit2", limitAmount - currAmount, limitAmount)
    else
        return "limit type error"
    end
end

-- 初始化货币类型
function CompeteStoreItemView:InitCurrencyType()
    self.payTypeImg.overrideSprite = res.LoadRes(CurrencyImagePath[self.data.currencytype])
end

-- 初始化物品图标
function CompeteStoreItemView:InitItemArea()
    assert(self.data.contents, "data.contents is nil")

    local id = nil
    local itemType = nil
    for k, v in pairs(self.data.contents) do
        itemType = k
        id = v[1].id
    end

    if itemType == "item" then
        self.txtName.text = ItemModel.new(id):GetName()
    elseif itemType == "card" then
        self.txtName.text = StaticCardModel.new(id):GetName()
    elseif itemType == "paster" then
        local pasterModel = CardPasterModel.new()
        pasterModel:InitWithStatic(id)
        self.txtName.text = pasterModel:GetName()
    elseif itemType == "cardPiece" then
        local pieceModel = CardPieceModel.new()
        pieceModel:InitWithStatic(id)
        self.txtName.text = pieceModel:GetName() .. lang.transstr("piece")
    elseif itemType == "pasterPiece" then
        local pieceModel = CardPasterPieceModel.new()
        pieceModel:InitWithStatic(id)
        self.txtName.text = pieceModel:GetName()
    elseif itemType == "eqs" then
        self.txtName.text = EquipModel.new(id):GetName()
    end


    res.ClearChildren(self.itemArea)
    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = self.data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)


    local args = {
        boughtTime = self.data.num,
        limitAmount = self.data.limitAmount,
        itemId = id,
        currencyType = self.data.currencytype,
        price = self.data.price,
        limitType = self.data.limitType,
        plateType = tonumber(self.data.plate),
        itemType = itemType
    }

    self.onClickBuy = (function()
        if self.data.limitAmount - self.data.num <= 0 and self.data.limitType ~= 0 then
            DialogManager.ShowToast(lang.trans("can_buy_is_full"))
            return
        end
        res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args,
            function(num)
                self:BuyCallback(num)
            end)
    end)
end

function CompeteStoreItemView:BuyCallback(num)
    clr.coroutine(function()
        local response = req.worldTournamentShopBuy(self.data.id, num)
        if api.success(response) then
            EventSystem.SendEvent("refresh_after_bought")
            local dataRes = response.val
            CongratulationsPageCtrl.new(dataRes.contents)
            local cost = dataRes.cost
            if cost.type == "wtc" then
                PlayerInfoModel.new():SetCompeteCurrency(cost.curr_num)
            end
        end
    end)
end

return CompeteStoreItemView