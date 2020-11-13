local NationalWelfareItemScrollAtOnce = class(unity.base)

function NationalWelfareItemScrollAtOnce:ctor()
    self.scrollRectInParent = nil
    self.scrollRectSelf = self.___ex.scrollRectSelf
end

function NationalWelfareItemScrollAtOnce:onInitializePotentialDrag(eventData)
    self.scrollRectInParent:OnInitializePotentialDrag(eventData)
    self.scrollRectSelf:OnInitializePotentialDrag(eventData)
end

function NationalWelfareItemScrollAtOnce:onBeginDrag(eventData)
    self.scrollRectInParent:OnBeginDrag(eventData)
    self.scrollRectSelf:OnBeginDrag(eventData)
end

function NationalWelfareItemScrollAtOnce:onDrag(eventData)
    self.scrollRectInParent:OnDrag(eventData)
    self.scrollRectSelf:OnDrag(eventData)
end

function NationalWelfareItemScrollAtOnce:onEndDrag(eventData)
    self.scrollRectInParent:OnEndDrag(eventData)
    self.scrollRectSelf:OnEndDrag(eventData)
end

return NationalWelfareItemScrollAtOnce
