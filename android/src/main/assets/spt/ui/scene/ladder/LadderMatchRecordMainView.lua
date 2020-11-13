local LadderMatchRecordMainView = class(unity.base)

function LadderMatchRecordMainView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnBack = self.___ex.btnBack
end

function LadderMatchRecordMainView:start()
    self:BindButtonHandler()
end

function LadderMatchRecordMainView:InitView(ladderModel)
end

function LadderMatchRecordMainView:BindButtonHandler()
    self.btnBack:regOnButtonClick(function()
        if self.onBack then
            self.onBack()
        end
    end)
end

return LadderMatchRecordMainView