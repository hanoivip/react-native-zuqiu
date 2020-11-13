local HomePlayerLevelEntryView = class(unity.base)

function HomePlayerLevelEntryView:ctor()
    self.freshPlayerLevelBtn = self.___ex.freshPlayerLevelBtn
    self.remainTimeTxt = self.___ex.remainTimeTxt
end

function HomePlayerLevelEntryView:start()
    self.freshPlayerLevelBtn:regOnButtonClick(function()
        self:OnBtnFreshPlayerLevelClick()
    end)
end

function HomePlayerLevelEntryView:SetTimeStr(str)
    self.remainTimeTxt.text = str
end

function HomePlayerLevelEntryView:OnBtnFreshPlayerLevelClick()
    if self.onBtnFreshClick then
        self.onBtnFreshClick()
    end
end

return HomePlayerLevelEntryView