local OldPlayerItemBaseView = require("ui.scene.oldPlayer.OldPlayerItemBaseView")
local OldPlayerTimeShoppingItemView = class(OldPlayerItemBaseView)

function OldPlayerTimeShoppingItemView:ctor()
    self.mName = self.___ex.mName
    self.oldPrice = self.___ex.oldPrice
    self.moneyIcon = self.___ex.moneyIcon
    self.costGroup = self.___ex.costGroup
    self.rediusTime = self.___ex.rediusTime
    self.currPrice = self.___ex.currPrice
    self.priceArea = self.___ex.priceArea
    self.moneyType = self.___ex.moneyType
    OldPlayerTimeShoppingItemView.super.ctor(self)
    self:RegBtn()
end

function OldPlayerTimeShoppingItemView:RegBtn()
    self.recvBtn:regOnButtonClick(function()
        self:OnBuy()
    end)
end

function OldPlayerTimeShoppingItemView:OnBuy()
    if self.onBuy then
        self.onBuy(function(args)
            if args then
                self:InitRewardButtonState(args.status)
            end
        end)
    end
end

function OldPlayerTimeShoppingItemView:InitView(itemData)
    OldPlayerTimeShoppingItemView.super.InitView(self, itemData)
    self.mName.text = lang.trans("oldPlayer_item_day", itemData.condition)
    self.oldPrice.text = itemData.payAmount[2]
    self.currPrice.text = "x" .. itemData.payAmount[1]
    self.recvText.text = ""
    if itemData.status == 0 then
        self.rediusTime.text = lang.trans("oldPlayer_endTime", string.convertSecondToMonth(itemData.endTime))
    elseif itemData.status == -1 then
        local rediusDay = itemData.condition - itemData.value
        if rediusDay == 1 then
            self.rediusTime.text = lang.trans("carnival_unlockTomorrow")
        elseif rediusDay == 2 then
            self.rediusTime.text = lang.trans("carnival_unlockTheDayAfterTomorrow")
        elseif rediusDay > 0 then
            self.rediusTime.text = lang.trans("oldPlayer_openTime", rediusDay)
        end
        self.recvText.text = lang.trans("commingSoon")
    else
        self.rediusTime.text = ""
    end
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        self.costGroup:SetActive(false)
        self.priceArea:SetActive(false)
        unity.waitForNextEndOfFrame()
        self.costGroup:SetActive(true)
        self.priceArea:SetActive(itemData.status == 0)
    end)
end

return OldPlayerTimeShoppingItemView