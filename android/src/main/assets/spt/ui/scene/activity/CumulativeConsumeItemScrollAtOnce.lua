local CumulativeConsumeItemScrollAtOnce = class(unity.base)

function CumulativeConsumeItemScrollAtOnce:ctor()
    self.scrollRectInParent = nil
    self.scrollRectSelf = self.___ex.scrollRectSelf
end

function CumulativeConsumeItemScrollAtOnce:onInitializePotentialDrag(eventData)
    self.scrollRectInParent:OnInitializePotentialDrag(eventData)
    self.scrollRectSelf:OnInitializePotentialDrag(eventData)
end

function CumulativeConsumeItemScrollAtOnce:onBeginDrag(eventData)
    self.scrollRectInParent:OnBeginDrag(eventData)
    self.scrollRectSelf:OnBeginDrag(eventData)
end

function CumulativeConsumeItemScrollAtOnce:onDrag(eventData)
    self.scrollRectInParent:OnDrag(eventData)
    self.scrollRectSelf:OnDrag(eventData)
end

function CumulativeConsumeItemScrollAtOnce:onEndDrag(eventData)
    self.scrollRectInParent:OnEndDrag(eventData)
    self.scrollRectSelf:OnEndDrag(eventData)
end

return CumulativeConsumeItemScrollAtOnce
