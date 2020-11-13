local GameObjectHelper = require("ui.common.GameObjectHelper")

local SerialDayUpItemView = class(unity.base)

function SerialDayUpItemView:ctor()
    self.dateTxt = self.___ex.dateTxt
    self.dateTxtToday = self.___ex.dateTxtToday
    self.todaySelected = self.___ex.todaySelected
    self.finish = self.___ex.finish
end

function SerialDayUpItemView:Init(datetxt, isSelected, isFinish)
    self.dateTxt.text = datetxt
    self.dateTxtToday.text = datetxt
    GameObjectHelper.FastSetActive(self.dateTxt.gameObject, not isSelected)
    GameObjectHelper.FastSetActive(self.dateTxtToday.gameObject, isSelected)
    GameObjectHelper.FastSetActive(self.todaySelected, isSelected)
    GameObjectHelper.FastSetActive(self.finish, isFinish)
end

return SerialDayUpItemView