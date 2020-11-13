local LuaButton = require("ui.control.button.LuaButton")
local TeamHistoryTabBarItemView = class(LuaButton)

function TeamHistoryTabBarItemView:ctor()
    self.super.ctor(self)
    self.btnUpText = self.___ex.btnUpText
    self.btnDownText = self.___ex.btnDownText
end

function TeamHistoryTabBarItemView:InitView(tabValue)
    local matchDate = string.convertSecondToYearAndMonthAndDay(tabValue.time)
    local date = matchDate.year .. "/" .. matchDate.month .. "/" .. matchDate.day
    self.btnUpText.text = date
    self.btnDownText.text = date
end

return TeamHistoryTabBarItemView