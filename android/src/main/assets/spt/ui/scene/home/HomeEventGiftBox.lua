local HomeEventGiftBox = class(unity.base)

function HomeEventGiftBox:ctor()
    self.clickBtn = self.___ex.clickBtn
    self.remainTimeTxt = self.___ex.remainTimeTxt
    self.redPoint = self.___ex.redPoint
end

function HomeEventGiftBox:start()
    self.clickBtn:regOnButtonClick(function()
        self:OnBtnEventTimeGiftClick()
    end)
end

function HomeEventGiftBox:SetTimeStr(str)
    self.remainTimeTxt.text = str
end

function HomeEventGiftBox:SetRedPoint(bShow)
	self.redPoint:SetActive(bShow)
end

function HomeEventGiftBox:OnBtnEventTimeGiftClick()
    if self.onBtnGiftClick then
        self.onBtnGiftClick()
    end
end

return HomeEventGiftBox