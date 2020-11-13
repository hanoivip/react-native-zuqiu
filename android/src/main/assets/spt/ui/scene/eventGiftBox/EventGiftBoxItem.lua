local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local ItemModel = require("ui.models.ItemModel")
local EventGiftBoxItem = class(unity.base)

function EventGiftBoxItem:ctor()
    self.timeLabel = self.___ex.timeLabel
    self.buyButton = self.___ex.buyButton
    self.sellOut = self.___ex.sellOut
    self.buyLabel = self.___ex.buyLabel
    self.moneyIcon = self.___ex.moneyIcon
    self.moneyNumber = self.___ex.moneyNumber
    self.content = self.___ex.content
    self.boxName1 = self.___ex.boxName1
    self.boxName2 = self.___ex.boxName2
    self.buyTimes = self.___ex.buyTimes
    --self.scrollAtOnce = self.___ex.scrollAtOnce
end

function EventGiftBoxItem:start()
    self.buyButton:regOnButtonClick(function()
        self:OnBuyClick()
    end)
end

function EventGiftBoxItem:InitView(data, parentRect)
    self.data = data
    --self.scrollAtOnce.scrollRectInParent = parentRect

    self.boxName1.text = data.name
    self.boxName2.text = data.name

    --for k, v in pairs(rewardData) do
        local rewardParams = {
            parentObj = self.content,
            rewardData = data.contents,
            isShowName = true,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            isShowBg = true,
            itemParams = {
                nameColor = '#333333FF',
                nameShadowColor = '#333333FF',
                numFont = 17
            }
        }
        RewardDataCtrl.new(rewardParams)
    --end
    self:SetBuyInfo()
end

function EventGiftBoxItem:UpdateTime(time)
    self.timeLabel.text = string.convertSecondToTime(time)
end

function EventGiftBoxItem:SetBuyInfo()
    local buyTimes = self.data.buyCnt
    local allTimes = self.data.limitCount
    if buyTimes >= allTimes then
        GameObjectHelper.FastSetActive(self.buyButton.gameObject, false)
        GameObjectHelper.FastSetActive(self.sellOut, true)
    else
        GameObjectHelper.FastSetActive(self.buyButton.gameObject, true)
        GameObjectHelper.FastSetActive(self.sellOut, false)
        self.moneyIcon.overrideSprite = res.LoadRes(CurrencyImagePath[self.data.currencyType])
        self.moneyNumber.text = 'x' .. string.formatIntWithTenThousands(self.data.price)
        self.buyTimes.text = lang.trans('event_time_buyTimes', buyTimes, allTimes)
    end
end

function EventGiftBoxItem:OnBuyClick()
    if self.onBuyClick then
        self.onBuyClick()
    end
end

return EventGiftBoxItem