local SpecialEventsMainView = class(unity.base)

function SpecialEventsMainView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.animator = self.___ex.animator
    self.scrollView = self.___ex.scrollView
    self.rightSwitchBtn = self.___ex.rightSwitchBtn
    self.leftSwitchBtn = self.___ex.leftSwitchBtn
    self.scrollViewViewport = self.___ex.scrollViewViewport
    self.scrollViewContent = self.___ex.scrollViewContent
    self.helpBtn = self.___ex.helpBtn
end

function SpecialEventsMainView:InitView(model)
    self.leftSwitchBtn:SetActive(false)
    self.rightSwitchBtn:SetActive(true)

    local timeString

    if model.nextBeginLocalTime then
        local secondsToNextBegin = math.max(0, model.nextBeginLocalTime - os.time())
        local hour = math.floor(secondsToNextBegin / 3600)
        local minute = math.floor(math.fmod(secondsToNextBegin, 3600) / 60)
        timeString = string.format(lang.transstr("special_events_open_in"), hour, minute)
    end

    self.scrollView:InitView(model.main, timeString)

    self.endScrollNormalizedPos = 1 - self.scrollViewViewport.rect.width / self.scrollViewContent.rect.width
end

function SpecialEventsMainView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function SpecialEventsMainView:update()
    local pos = self.scrollView:getScrollNormalizedPos()
    if pos <= 0 then
        self.leftSwitchBtn:SetActive(false)
    else
        self.leftSwitchBtn:SetActive(true)
    end

    if pos >= (self.endScrollNormalizedPos or 1) then
        self.rightSwitchBtn:SetActive(false)
    else
        self.rightSwitchBtn:SetActive(true)
    end
end

return SpecialEventsMainView
