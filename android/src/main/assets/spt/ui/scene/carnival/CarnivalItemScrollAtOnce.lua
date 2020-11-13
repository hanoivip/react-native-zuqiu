local CarnivalItemScrollAtOnce = class(unity.base)

function CarnivalItemScrollAtOnce:ctor()
    self.scrollRectInParent = nil
    self.scrollRectSelf = self.___ex.scrollRectSelf
end

function CarnivalItemScrollAtOnce:onInitializePotentialDrag(eventData)
    self.scrollRectInParent:OnInitializePotentialDrag(eventData)
    self.scrollRectSelf:OnInitializePotentialDrag(eventData)
end

function CarnivalItemScrollAtOnce:onBeginDrag(eventData)
    self.scrollRectInParent:OnBeginDrag(eventData)
    self.scrollRectSelf:OnBeginDrag(eventData)
end

function CarnivalItemScrollAtOnce:onDrag(eventData)
    self.scrollRectInParent:OnDrag(eventData)
    self.scrollRectSelf:OnDrag(eventData)
end

function CarnivalItemScrollAtOnce:onEndDrag(eventData)
    self.scrollRectInParent:OnEndDrag(eventData)
    self.scrollRectSelf:OnEndDrag(eventData)
end

return CarnivalItemScrollAtOnce
