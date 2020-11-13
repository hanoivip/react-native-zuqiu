local UnlockOptionView = class(unity.base)

function UnlockOptionView:ctor()
    self.optionIcon = self.___ex.optionIcon
    self.optionDescText = self.___ex.optionDescText
    self.comfirm = self.___ex.comfirm
    self.optionTitleText = self.___ex.optionTitleText
end

function UnlockOptionView:start()
    self.comfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function UnlockOptionView:OnBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function UnlockOptionView:InitView(unlockData)
    self.optionTitleText.text = unlockData.title
    self.optionDescText.text = unlockData.desc
    local picPath = "Assets/CapstonesRes/Game/UI/Common/FunctionNotice/Images/" .. unlockData.picIndex .. ".png"
    self.optionIcon.overrideSprite = res.LoadRes(picPath)
end

return UnlockOptionView