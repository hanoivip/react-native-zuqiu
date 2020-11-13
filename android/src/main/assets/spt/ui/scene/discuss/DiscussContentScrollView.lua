local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local ScrollViewSameSize = require("ui.control.scroll.ScrollViewSameSize")

local EventSystem = require("EventSystem")
local DiscussContentScrollView = class(ScrollViewSameSize)

function DiscussContentScrollView:ctor()
    DiscussContentScrollView.super.ctor(self)
    self.endDragCallBack = nil
end

function DiscussContentScrollView:InitView(model, pos, ...)
    self.data = model
    self.args = {...}
    self.argc = select("#", ...)
    self:refresh(self.data, pos)
end

function DiscussContentScrollView:onEndDrag()
    local pos = self:GetScrollNormalizedPosition()
    self:OnEndDrag(pos)
end

function DiscussContentScrollView:RegOnEndDrag(func)
    if type(func) == "function" then
        self.endDragCallBack = func
    end
end

function DiscussContentScrollView:OnEndDrag(pos)
    if self.endDragCallBack then
        self.endDragCallBack(pos)
    end
end

function DiscussContentScrollView:UnregOnEndDrag(func)
    self.endDragCallBack = nil
end

return DiscussContentScrollView
