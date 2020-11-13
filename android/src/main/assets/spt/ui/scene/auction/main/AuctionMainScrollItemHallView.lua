local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")
local DialogManager = require("ui.control.manager.DialogManager")
-- 实例化各类物品所需
local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")

local AuctionMainScrollItemHallView = class(unity.base, "AuctionMainScrollItemHallView")

local itemPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Auction/Main/Prefabs/AuctionMainItem.prefab"

function AuctionMainScrollItemHallView:ctor()
    self.txtIndex = self.___ex.txtIndex
    self.txtName = self.___ex.txtName
    self.txtDesc = self.___ex.txtDesc
    self.txtItemName = self.___ex.txtItemName
    self.itemsContainer = self.___ex.itemsContainer
    self.btnClick = self.___ex.btnClick

    self.remainTimeCounter = nil
    self.isForceUpdate = false
end

function AuctionMainScrollItemHallView:InitView(data)
    self.data = data
    self.txtIndex.text = tostring(data.index)
    if not data.isPast then
        self.txtName.text = lang.trans("auction_main_scroll_item_name", data.id, data.subId % 10)
    else
        self.txtName.text = lang.trans("auction_main_scroll_item_name_past",  data.id, data.subId % 10)
    end
    self.remainTimeCounter = data.showRemainTime
    self.isForceUpdate = false
    self:UpdateTxtDesc()
    self:InitItemView()
end

function AuctionMainScrollItemHallView:start()
    self:RegBtnEvent()
end

function AuctionMainScrollItemHallView:update()
    if self.gameObject.activeInHierarchy and self.remainTimeCounter and self:IsInAuction() then
        if self.remainTimeCounter <= 0 then
            -- 下一阶段，静默网络请求
            if not self.isForceUpdate then
                EventSystem.SendEvent("AuctionMain_ForceRequrestUpdateItem", true)
                self.isForceUpdate = true
                self.remainTimeCounter = nil
            end
        else
            self.remainTimeCounter = self.remainTimeCounter - Time.deltaTime
            self:UpdateTxtDesc()
        end
    end
end

function AuctionMainScrollItemHallView:IsInAuction()
    if not self.data then
        return false
    end
    return self.data.step ~= AuctionMainConstants.AuctionStep.NOT_START and self.data.step ~= AuctionMainConstants.AuctionStep.FINISH
end

function AuctionMainScrollItemHallView:UpdateTxtDesc()
    local remainTimeStr = string.convertSecondToTime(self.remainTimeCounter)
    local step = self.data.step
    if step == AuctionMainConstants.AuctionStep.NOT_START then-- 未开启，显示开启时间
        self.txtDesc.text = lang.trans("auction_main_scroll_item_start_time", string.formatTimestampAllWithDot(self.data.beginTime))
    elseif step == AuctionMainConstants.AuctionStep.STEP_1 then-- 第一阶段
        self.txtDesc.text = lang.trans("auction_main_scroll_item_step_1", remainTimeStr)
    elseif step == AuctionMainConstants.AuctionStep.STEP_2 then-- 第二阶段
        self.txtDesc.text = lang.trans("auction_main_scroll_item_step_2", remainTimeStr)
    elseif step == AuctionMainConstants.AuctionStep.STEP_3 then-- 第三阶段
        self.txtDesc.text = lang.trans("auction_main_scroll_item_step_3", remainTimeStr)
    elseif step == AuctionMainConstants.AuctionStep.STEP_4 then-- 第四阶段
        if self.remainTimeCounter <= AuctionMainConstants.Auction_Step4_Core_Time then
            self.txtDesc.text = lang.trans("auction_main_scroll_item_step_sprint")
        else
            self.txtDesc.text = lang.trans("auction_main_scroll_item_step_4", remainTimeStr)
        end
    elseif step == AuctionMainConstants.AuctionStep.FINISH then-- 第五阶段，显示中标者和价格
        local topPlayer = self.data.data.topPlayer
        if topPlayer then
            self.txtDesc.text = lang.trans("auction_main_scroll_item_step_finish", topPlayer.serverName .. " " .. topPlayer.name, string.formatNumWithUnit(topPlayer.money))
        else
            self.txtDesc.text = lang.trans("auction_main_none")
        end
    end
end

function AuctionMainScrollItemHallView:InitItemView()
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
    itemData.isSold = self.data.data.topPlayer ~= nil

    local obj, spt = res.Instantiate(itemPrefabPath)
    obj.transform:SetParent(self.itemsContainer.transform)
    obj.transform.localPosition = Vector3.zero
    obj.transform.localScale = Vector3.one
    spt:InitView(itemData)
end

function AuctionMainScrollItemHallView:RegBtnEvent()
    self.btnClick:regOnButtonClick(function()
        self:OnItemClick()
    end)
end

function AuctionMainScrollItemHallView:OnItemClick()
    if self.data.step == AuctionMainConstants.AuctionStep.NOT_START then
        DialogManager.ShowToast(lang.trans("auction_main_scroll_item_start"))
        return
    end

    EventSystem.SendEvent("AuctionMain_OnScrollItemClick", self.data.scrollIndex, AuctionMainConstants.AuctionHall)
end

return AuctionMainScrollItemHallView