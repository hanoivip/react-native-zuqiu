local SignPlateView = class(unity.base)

function SignPlateView:ctor()
    self.signView = self.___ex.signView
    self.clickArea = self.___ex.clickArea
end

function SignPlateView:start()
    self.clickArea:regOnButtonClick(function()
        self:OnClick()
    end)
end

function SignPlateView:InitView(plateModel)
    self.signView:InitView(plateModel)
end

function SignPlateView:OnClick()
    if self.clickBack then 
        self.clickBack()
    end
end

return SignPlateView
