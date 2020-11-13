local PowerRankItemScroll = class(unity.base)

function PowerRankItemScroll:ctor()
    self.scroll = self.___ex.scroll
    self.scrollSelf = self.___ex.scrollSelf
end

function PowerRankItemScroll:onInitializePotentialDrag(eventData)
    self.scroll:OnInitializePotentialDrag(eventData)
    self.scrollSelf:OnInitializePotentialDrag(eventData)
end

function PowerRankItemScroll:onBeginDrag(eventData)
    self.scroll:OnBeginDrag(eventData)
    self.scrollSelf:OnBeginDrag(eventData)
end

function PowerRankItemScroll:onDrag(eventData)
    self.scroll:OnDrag(eventData)
    self.scrollSelf:OnDrag(eventData)
end

function PowerRankItemScroll:onEndDrag(eventData)
    self.scroll:OnEndDrag(eventData)
    self.scrollSelf:OnEndDrag(eventData)
end

return PowerRankItemScroll
