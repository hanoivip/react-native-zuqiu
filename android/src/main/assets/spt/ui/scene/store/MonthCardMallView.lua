local GameObjectHelper = require("ui.common.GameObjectHelper")

local MonthCardMallView = class(unity.base, "MonthCardMallView")

function MonthCardMallView:ctor()
    self.scrollView = self.___ex.scrollView
end

function MonthCardMallView:start()
end

function MonthCardMallView:EnterScene()
end

function MonthCardMallView:onDestroy()
end

function MonthCardMallView:InitView(monthCardMallModel)
    self.model = monthCardMallModel
    local scrollPos = self.scrollView:GetScrollNormalizedPosition()
    self.scrollView:InitView(self.model:GetItemList())
    self.scrollView:scrollToPosImmediate(scrollPos)
end

function MonthCardMallView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return MonthCardMallView
