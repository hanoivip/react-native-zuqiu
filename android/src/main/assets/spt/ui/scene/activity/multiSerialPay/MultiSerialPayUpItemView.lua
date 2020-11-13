local GameObjectHelper = require("ui.common.GameObjectHelper")

local MultiSerialPayUpItemView = class(unity.base)

function MultiSerialPayUpItemView:ctor()
    self.dateTxt = self.___ex.dateTxt
    self.dateTxtToday = self.___ex.dateTxtToday
    self.todaySelected = self.___ex.todaySelected
    self.finish = self.___ex.finish
    self.redPoint = self.___ex.redPoint
    self.clickBtn = self.___ex.clickBtn
end

function MultiSerialPayUpItemView:Init(data, isSelected)
    local isFinish = data.isFinish
    local isShowRedPoint = data.isShowRedPoint
    local price = data.price

    self.dateTxt.text = lang.trans("serial_pay_tip", price)
    self.dateTxtToday.text = self.dateTxt.text
    GameObjectHelper.FastSetActive(self.dateTxt.gameObject, not isSelected)
    GameObjectHelper.FastSetActive(self.dateTxtToday.gameObject, isSelected)
    GameObjectHelper.FastSetActive(self.todaySelected, isSelected)
    GameObjectHelper.FastSetActive(self.finish, isFinish)
    GameObjectHelper.FastSetActive(self.redPoint, isShowRedPoint)

    self.clickBtn:regOnButtonClick(function ()
        if self.onClickBtn then
            self.onClickBtn()
        end
    end)
end

return MultiSerialPayUpItemView