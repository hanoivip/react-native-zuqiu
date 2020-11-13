local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
-- 实例化各类物品所需
local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")

local AuctionMainScrollItemHistoryView = class(unity.base, "AuctionMainScrollItemHistoryView")

local itemPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Auction/Main/Prefabs/AuctionMainItem.prefab"

function AuctionMainScrollItemHistoryView:ctor()
    self.txtIndex = self.___ex.txtIndex
    self.txtName = self.___ex.txtName
    self.txtTime = self.___ex.txtTime
    self.txtPrice = self.___ex.txtPrice
    self.txtItemName = self.___ex.txtItemName
    self.itemsContainer = self.___ex.itemsContainer
    self.inAuction = self.___ex.inAuction
    self.btnReceive = self.___ex.btnReceive
    self.txtReceive = self.___ex.txtReceive
    self.buttonReceive = self.___ex.buttonReceive
    self.btnClick = self.___ex.btnClick
    self.efxReceive = self.___ex.efxReceive
end

function AuctionMainScrollItemHistoryView:start()
    self:RegBtnEvent()
end

function AuctionMainScrollItemHistoryView:InitView(data)
    self.data = data
    self.txtIndex.text = tostring(data.scrollIndex)
    self.txtName.text = lang.trans("auction_main_scroll_item_name", data.id, data.subId % 10)
    local timeTable = string.convertSecondToYearAndMonthAndDay(data.beginTime)
    self.txtTime.text = lang.transstr("matchLoading_time") .. timeTable.year .. "." .. timeTable.month .. "." .. timeTable.day
    self.txtPrice.text = string.formatNumWithUnit(data.myMoney)
    self:InitItemView()
    if data.step == AuctionMainConstants.AuctionStep.FINISH then
        GameObjectHelper.FastSetActive(self.inAuction.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnReceive.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.inAuction.gameObject, true)
        GameObjectHelper.FastSetActive(self.btnReceive.gameObject, false)
    end
    if data.canGain == 1 then
        self.buttonReceive.interactable = true
        self.txtReceive.text = lang.trans("receive")
        GameObjectHelper.FastSetActive(self.efxReceive.gameObject, true)
    else
        self.buttonReceive.interactable = false
        self.txtReceive.text = lang.trans("have_received")
        GameObjectHelper.FastSetActive(self.efxReceive.gameObject, false)
    end
end

function AuctionMainScrollItemHistoryView:InitItemView()
    local itemType = self.data.itemType
    local id = self.data.itemID[1].id
    local name = ""
    if itemType == "item" then
        name = ItemModel.new(id):GetName()
    elseif itemType == "card" then
        name = StaticCardModel.new(id):GetName()
    elseif itemType == "paster" then
        local pasterModel = CardPasterModel.new()
        pasterModel:InitWithStatic(id)
        name = pasterModel:GetName()
    elseif itemType == "cardPiece" then
        local pieceModel = CardPieceModel.new()
        pieceModel:InitWithStatic(id)
        name = pieceModel:GetName()
    elseif itemType == "pasterPiece" then
        local pieceModel = CardPasterPieceModel.new()
        pieceModel:InitWithStatic(id)
        name = pieceModel:GetName()
    elseif itemType == "eqs" then
        name = EquipModel.new(id):GetName()
    end
    self.txtItemName.text = name

    res.ClearChildren(self.itemsContainer.transform)
    local itemData = {}
    itemData.itemType = self.data.itemType
    itemData.step = self.data.step
    itemData.content = {}
    itemData.content[self.data.itemType] = self.data.itemID
    itemData.scrollItemType = self.data.scrollItemType
    itemData.isSuccess = self.data.data.topPlayer.pid == PlayerInfoModel.new():GetID()
    itemData.isSold = true

    local obj, spt = res.Instantiate(itemPrefabPath)
    obj.transform:SetParent(self.itemsContainer.transform)
    obj.transform.localPosition = Vector3.zero
    obj.transform.localScale = Vector3.one
    spt:InitView(itemData)
end

function AuctionMainScrollItemHistoryView:RegBtnEvent()
    self.btnReceive:regOnButtonClick(function()
        self:OnClickBtnReceive()
    end)

    self.btnClick:regOnButtonClick(function()
        self:OnItemClick()
    end)
end

function AuctionMainScrollItemHistoryView:OnClickBtnReceive()
    if self.data.canGain == 1 then
        EventSystem.SendEvent("AuctionMain_Receive", self.data.id, self.data.subId, self.data.scrollIndex)
    end
end

function AuctionMainScrollItemHistoryView:OnItemClick()
    if self.data.step == AuctionMainConstants.AuctionStep.FINISH then
        return
    end

    EventSystem.SendEvent("AuctionMain_OnScrollItemClick", self.data.scrollIndex, AuctionMainConstants.History)
end

return AuctionMainScrollItemHistoryView