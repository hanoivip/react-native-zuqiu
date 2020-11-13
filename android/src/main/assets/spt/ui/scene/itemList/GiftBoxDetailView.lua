local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AssetFinder = require("ui.common.AssetFinder")
local CommonConstants = require("ui.common.CommonConstants")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ProbabilityType = require("ui.scene.itemList.ProbabilityType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GiftBoxDetailView = class(unity.base)

function GiftBoxDetailView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.nameTxt = self.___ex.nameTxt
    self.descTxt = self.___ex.descTxt
    self.scroll = self.___ex.scroll
    self.rctContent = self.___ex.rctContent
    self.useBtn = self.___ex.useBtn
    self.multiUseBtn = self.___ex.multiUseBtn
    self.getDescTxt = self.___ex.getDescTxt
    self.boxRect = self.___ex.boxRect
    self.nextImg = self.___ex.nextImg
    self.wayTxt = self.___ex.wayTxt
    self.contentGridGroup = self.___ex.contentGridGroup
    self.btnArea = self.___ex.btnArea
    self.counterView = self.___ex.counterView
    self.rctMain = self.___ex.rctMain
end

function GiftBoxDetailView:InitView(itemModel, notShowBtn)
    self.itemModel = itemModel
    self.nameTxt.text = itemModel:GetName()
    self.descTxt.text = itemModel:GetDesc()
    self.getDescTxt.text = itemModel:GetAccess()
    self.itemType = itemModel:GetProbability()

    local isRedPacket = itemModel:GetIsRedPacket()
    local contents = {}
    if isRedPacket then
        contents.redPacket = {}
        table.insert(contents.redPacket, {id = tostring(self.itemModel:GetId()), num = self.itemModel:GetItemNum()})
        GameObjectHelper.FastSetActive(self.multiUseBtn.gameObject, false)
    else
        local rewardKey = self.itemModel:GetRewardType()
        contents[rewardKey] = {}
        table.insert(contents[rewardKey], {id = tostring(self.itemModel:GetId()), num = self.itemModel:GetItemNum()})
    end
    local rewardParams = {
        parentObj = self.boxRect,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
     }
     RewardDataCtrl.new(rewardParams)

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.useBtn:regOnButtonClick(function()
        self:BuyStoreItem(self.itemModel:GetId(), self:GetUseCount())
    end)
    self.multiUseBtn:regOnButtonClick(function ()
        self:BuyStoreItemMulti()
    end)
    local itemContents = itemModel:GetItemContent()
    itemContents = self:GetLimitItemContent(itemContents) or itemContents
    if itemContents then
        self.scroll:InitView(itemContents)
    end

    GameObjectHelper.FastSetActive(self.nextImg.gameObject, self.rctContent.transform.childCount >= 5)

    GameObjectHelper.FastSetActive(self.btnArea.gameObject, not notShowBtn)
    DialogAnimation.Appear(self.transform, nil)

    local data = {}
    data.maxCount = self.itemModel:GetAddNum() or 0
    data.configMaxCount = self.itemModel:GetUseMaxCount()
    self.counterView:InitView(data)
end

function GiftBoxDetailView:SetCounterViewVisible(isShow)
    GameObjectHelper.FastSetActive(self.counterView.gameObject, isShow)
    self.rctMain.sizeDelta = Vector2(self.rctMain.sizeDelta.x, isShow and 666 or 586)
end

function GiftBoxDetailView:RefreshItemCount(id, num)
    res.ClearChildren(self.boxRect)
    local contents = {}
    contents.item = {}
    local temp = {}
    temp.id = tostring(id)
    temp.num = num
    table.insert(contents.item, temp)
    local rewardParams = {
        parentObj = self.boxRect,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
     }
     RewardDataCtrl.new(rewardParams)

     self:RefreshCounterView()
end

function GiftBoxDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function GiftBoxDetailView:BuyStoreItem(id, num)
    if self.itemModel:GetIsRedPacket() then
        res.PushDialog("ui.controllers.itemList.RedPacketDescCtrl", self.itemModel)
        self:Close()
    else
        if type(self.buyStoreItem) == "function" then
            self.buyStoreItem(id, num)
        end
    end
end

function GiftBoxDetailView:BuyStoreItemMulti()
    if type(self.buyStoreItemMulti) == "function" then
        self.buyStoreItemMulti()
    end
end

-- SS兑换券，S兑换券，A兑换券打开后卡顿,随机取40个
local ExchangeCoin = {["11001"] = 40, ["12001"] = 40, ["13001"] = 40}
function GiftBoxDetailView:GetLimitItemContent(itemContent)
    if ExchangeCoin[tostring(self.itemModel:GetId())] then
        local contents = {}
        local itemLenth = #itemContent
        for i = 1, ExchangeCoin[tostring(self.itemModel:GetId())] do
            local tempIndex = math.random(itemLenth)
            table.insert(contents, itemContent[tempIndex])
            itemContent[tempIndex], itemContent[itemLenth] = itemContent[itemLenth], itemContent[tempIndex]
            itemLenth = itemLenth - 1
        end
        itemContent = nil
        return contents
    end
    return nil
end

function GiftBoxDetailView:GetUseCount()
    return self.counterView:GetCurrCount()
end

function GiftBoxDetailView:RefreshCounterView()
    local data = {}
    data.maxCount = self.itemModel:GetAddNum() or 0
    data.configMaxCount = self.itemModel:GetUseMaxCount()
    self.counterView:Refresh(data)
end

return GiftBoxDetailView
