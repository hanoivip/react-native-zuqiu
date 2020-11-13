local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AssetFinder = require("ui.common.AssetFinder")
local CommonConstants = require("ui.common.CommonConstants")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ArenaStoreItemPopView = class(unity.base)

function ArenaStoreItemPopView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.nameTxt = self.___ex.nameTxt
    self.iconImg = self.___ex.iconImg
    self.descTxt = self.___ex.descTxt
    self.scroll = self.___ex.scroll
    self.useBtn = self.___ex.useBtn
    self.multiUseBtn = self.___ex.multiUseBtn
    self.getDescTxt = self.___ex.getDescTxt
    self.iconBG = self.___ex.iconBG
    self.contentRect = self.___ex.contentRect
    self.nextImg = self.___ex.nextImg
    self.wayTxt = self.___ex.wayTxt
    self.contentGridGroup = self.___ex.contentGridGroup
    self.btnArea = self.___ex.btnArea
end

function ArenaStoreItemPopView:InitView(itemModel, notShowBtn)
    self.itemModel = itemModel
    self.nameTxt.text = itemModel:GetName()
    self.iconImg.overrideSprite = AssetFinder.GetItemIcon(itemModel:GetIconIndex())
    self.descTxt.text = itemModel:GetDesc()
    self.getDescTxt.text = itemModel:GetAccess()
    self.iconBG.overrideSprite = AssetFinder.GetItemQualityBoard(itemModel:GetQuality())
    
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.useBtn:regOnButtonClick(function()
        self:BuyStoreItem()
    end)
    self.multiUseBtn:regOnButtonClick(function ()
        self:BuyStoreItemMulti()
    end)
    local itemContents = itemModel:GetItemContent()
    if itemContents then
        res.ClearChildren(self.contentRect)
        for i, v in ipairs(itemContents) do
            local rewardParams = {
                parentObj = self.contentRect,
                rewardData = v.contents,
                isShowName = false,
                isReceive = false,
                isShowBaseReward = true,
                isShowCardReward = true,
                isShowDetail = true,
             }
             RewardDataCtrl.new(rewardParams)
        end
    end

    if self.contentRect.transform.childCount >= 5 then
        self.nextImg:SetActive(true)
    end

    self.btnArea:SetActive(not notShowBtn)
    DialogAnimation.Appear(self.transform, nil)
end

function ArenaStoreItemPopView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function ArenaStoreItemPopView:BuyStoreItem()
    if type(self.buyStoreItem) == "function" then
        self.buyStoreItem()
    end
end

function ArenaStoreItemPopView:BuyStoreItemMulti()
    if type(self.buyStoreItemMulti) == "function" then
        self.buyStoreItemMulti()
    end
end

return ArenaStoreItemPopView
