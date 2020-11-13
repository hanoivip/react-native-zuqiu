local CumulativeConsumeItemScrollAtOnce = class(unity.base)

function CumulativeConsumeItemScrollAtOnce:ctor()
    self.scrollRectInParent = nil
    self.scrollRectSelf = self.___ex.scrollRectSelf
end

function CumulativeConsumeItemScrollAtOnce:onInitializePotentialDrag(eventData)
    if self.scrollRectInParent then
        self.scrollRectInParent:OnInitializePotentialDrag(eventData)
        self.scrollRectSelf:OnInitializePotentialDrag(eventData)
    end
end

function CumulativeConsumeItemScrollAtOnce:onBeginDrag(eventData)
    if self.scrollRectInParent then
        self.scrollRectInParent:OnBeginDrag(eventData)
        self.scrollRectSelf:OnBeginDrag(eventData)
    end
end

function CumulativeConsumeItemScrollAtOnce:onDrag(eventData)
    if self.scrollRectInParent then
        self.scrollRectInParent:OnDrag(eventData)
        self.scrollRectSelf:OnDrag(eventData)
    end
end

function CumulativeConsumeItemScrollAtOnce:onEndDrag(eventData)
    if self.scrollRectInParent then
        self.scrollRectInParent:OnEndDrag(eventData)
        self.scrollRectSelf:OnEndDrag(eventData)
    end
end

return CumulativeConsumeItemScrollAtOnce
