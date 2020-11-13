local SerialPayItemScrollAtOnce = class(unity.base)

function SerialPayItemScrollAtOnce:ctor()
    self.scrollRectInParent = nil
    self.scrollRectSelf = self.___ex.scrollRectSelf
end

function SerialPayItemScrollAtOnce:onInitializePotentialDrag(eventData)
    self.scrollRectInParent:OnInitializePotentialDrag(eventData)
    self.scrollRectSelf:OnInitializePotentialDrag(eventData)
end

function SerialPayItemScrollAtOnce:onBeginDrag(eventData)
    self.scrollRectInParent:OnBeginDrag(eventData)
    self.scrollRectSelf:OnBeginDrag(eventData)
end

function SerialPayItemScrollAtOnce:onDrag(eventData)
    self.scrollRectInParent:OnDrag(eventData)
    self.scrollRectSelf:OnDrag(eventData)
end

function SerialPayItemScrollAtOnce:onEndDrag(eventData)
    self.scrollRectInParent:OnEndDrag(eventData)
    self.scrollRectSelf:OnEndDrag(eventData)
end

return SerialPayItemScrollAtOnce
