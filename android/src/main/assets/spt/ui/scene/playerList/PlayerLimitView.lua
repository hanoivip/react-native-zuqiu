local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local Mall = require("data.Mall") 
local PlayerLimitView = class(unity.base)

function PlayerLimitView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.close = self.___ex.close
    self.displayArea = self.___ex.displayArea
    self.cost = self.___ex.cost
    self.desc = self.___ex.desc
    self.limitArea = self.___ex.limitArea
    self.limitCount = self.___ex.limitCount
    self.showArea = self.___ex.showArea
end

function PlayerLimitView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)

    self.close:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform)
end

function PlayerLimitView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function PlayerLimitView:OnBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm(self.costNum)
    end
end

function PlayerLimitView:InitView(useTime, PlayerCapacity)
    GameObjectHelper.FastSetActive(self.displayArea, true)
    local limitData = Mall[tostring(PlayerCapacity)]
    local timesLimit = limitData.timesLimit
    local isBuy = false
    local limitStr = ""
    if tonumber(useTime) < tonumber(timesLimit) then 
        isBuy = true
        local priceMap = limitData.price
        local cost = priceMap[tonumber(useTime) + 1]
        self.costNum = tonumber(cost)
        local plus = limitData.bagLimit
        self.cost.text = "x" .. cost
        local extra = "+ " .. plus
        self.desc.text = lang.trans("player_buy_desc", extra)
        local remainCount = tonumber(timesLimit) - tonumber(useTime)
        limitStr = lang.trans("buy_count", remainCount, timesLimit)
    end
    self.limitCount.text = limitStr
    GameObjectHelper.FastSetActive(self.showArea, isBuy)
    GameObjectHelper.FastSetActive(self.limitArea, not isBuy)
end

return PlayerLimitView
