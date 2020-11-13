local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local TabItemView = class(LuaButton)

function TabItemView:ctor()
    TabItemView.super.ctor(self)
    self.title = self.___ex.title
    self.title1 = self.___ex.title1
    self.redPoint = self.___ex.redPoint
end

function TabItemView:Init(title, tag)
    if self.title and self.title1 then
        self.title.text = title
        self.title1.text = title
    end
    self.tabTag = tag

    EventSystem.AddEvent("TabItem_RefreshRedPoint", self, self.RefreshRedPoint)
end

function TabItemView:start()
    
end

function TabItemView:RefreshRedPoint(tag, isShowRedPoint)
    if self.tabTag == tag then
        GameObjectHelper.FastSetActive(self.redPoint, isShowRedPoint)
    end
end

function TabItemView:onDestroy()
    EventSystem.RemoveEvent("TabItem_RefreshRedPoint", self, self.RefreshRedPoint)
end

return TabItemView
