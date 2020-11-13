local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ItemType = require("ui.scene.itemList.ItemType")

local FanShopRecycleView = class(unity.base)

function FanShopRecycleView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView
    self.pieceInfo = self.___ex.pieceInfo
    self.itemName = self.___ex.itemName
    self.itemNum = self.___ex.itemNum
    self.itemType = self.___ex.itemType
    self.itemArea = self.___ex.itemArea
    self.sellNum = self.___ex.sellNum
    self.sellAllMoney = self.___ex.sellAllMoney
    self.addBtn = self.___ex.addBtn
    self.subBtn = self.___ex.subBtn
    self.recycleBtn = self.___ex.recycleBtn
    self.buttonState = self.___ex.buttonState
    self.specialTip = self.___ex.specialTip

    DialogAnimation.Appear(self.transform, nil)
end

function FanShopRecycleView:start()
    self:RegBtn()
end

function FanShopRecycleView:RegBtn()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    local pressAddData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:OnAdd(self.pieceName, self.itemData.itemType)
        end,
        durationCallback = function()
            self:OnAdd(self.pieceName, self.itemData.itemType)
        end,
    }
    self.addBtn:regOnButtonPressing(pressAddData)
    self.addBtn:regOnButtonUp(function()
        if self.onSetAddTipShown then
            self.onSetAddTipShown(false)
        end
    end)

    local pressMinusData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:OnSub()
        end,
        durationCallback = function()
            self:OnSub()
        end,
    }
    self.subBtn:regOnButtonPressing(pressMinusData)

    self.recycleBtn:regOnButtonClick(function()
        self:OnClickRecycle()
    end)
end

function FanShopRecycleView:InitView(fanShopModel)
    self.pieceInfo:SetActive(false)
    self.scrollView:InitView(fanShopModel:GetItemList())
end

function FanShopRecycleView:OnClickRecycle()
    if self.onClickRecycle then
        self.onClickRecycle()
    end
end

function FanShopRecycleView:OnAdd(pieceName, itemType)
    if self.onAdd then
        self.onAdd(pieceName, itemType)
    end
end

function FanShopRecycleView:OnSub()
    if self.onSub then
        self.onSub()
    end
end

function FanShopRecycleView:Close()
    if self.onClose then
        self.onClose()
    end
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function FanShopRecycleView:onDestroy()
end

function FanShopRecycleView:InitPieceInfo(itemData)
    self.itemData = itemData
    self.pieceInfo:SetActive(true)
    self.pieceName = itemData.name
    self.itemName.text = self.pieceName
    self.itemNum.text =  lang.transstr("fanshop_has_num", itemData.num or 0)
    self.itemType.text = itemData.typeName
    if itemData.hasAscend then
        self.specialTip.text = lang.trans("fanshop_special_tip_ascend")
    elseif itemData.isLock then
        self.specialTip.text = lang.trans("fanshop_special_tip_lock")
    elseif itemData.hasMedal or itemData.hasPaster then
        self.specialTip.text = lang.trans("fanshop_special_tip_equip_item")
    elseif itemData.isSupporter then
        self.specialTip.text = lang.transstr("supporter_lock") .. lang.transstr("support_cannot_recycle")
    elseif itemData.isSupported then
        self.specialTip.text = lang.transstr("supported_lock") .. lang.transstr("support_cannot_recycle")
    else
        self.specialTip.text = ""
    end

    for k,v in pairs(self.buttonState) do
        v.interactable = itemData.num > 0
        if itemData.itemType == ItemType.Card then
            v.interactable = v.interactable and itemData.canRecycle
        end
    end
    res.ClearChildren(self.itemArea.transform)
    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = itemData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function FanShopRecycleView:SetSellNum(num)
    self.sellNum.text = tostring(num)
    self.sellAllMoney.text = "x" .. (num * self.itemData.fanCoinRecycle)
end

return FanShopRecycleView
