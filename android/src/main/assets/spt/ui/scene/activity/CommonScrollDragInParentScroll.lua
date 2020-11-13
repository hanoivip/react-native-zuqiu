local CommonScrollDragInParentScroll = class(unity.base)

function CommonScrollDragInParentScroll:ctor()
    self.scrollRectInParent = nil
    self.scrollRectSelf = self.___ex.scrollRectSelf
end

function CommonScrollDragInParentScroll:onInitializePotentialDrag(eventData)
    self.scrollRectInParent:OnInitializePotentialDrag(eventData)
    self.scrollRectSelf:OnInitializePotentialDrag(eventData)
end

function CommonScrollDragInParentScroll:onBeginDrag(eventData)
    self.scrollRectInParent:OnBeginDrag(eventData)
    self.scrollRectSelf:OnBeginDrag(eventData)
end

function CommonScrollDragInParentScroll:onDrag(eventData)
    self.scrollRectInParent:OnDrag(eventData)
    self.scrollRectSelf:OnDrag(eventData)
end

function CommonScrollDragInParentScroll:onEndDrag(eventData)
    self.scrollRectInParent:OnEndDrag(eventData)
    self.scrollRectSelf:OnEndDrag(eventData)
end

return CommonScrollDragInParentScroll
