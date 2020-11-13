local LuaButton = require("ui.control.button.LuaButton")
local SingleBannerView = class(LuaButton)

function SingleBannerView:ctor()
    SingleBannerView.super.ctor(self)
    self.bannerIcon = self.___ex.bannerIcon
    self.bannerTips = self.___ex.bannerTips
end

function SingleBannerView:start()
    self:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function SingleBannerView:InitView(data)
    if data.type then
        self.bannerIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Home/Images/Banner/" .. data.type .. ".png")
    end
    
    if data.bannerTip and data.bannerTip ~= "0" then
        self.bannerTips.text = data.bannerTip
        self.bannerTips.gameObject:SetActive(true)
    else
        self.bannerTips.gameObject:SetActive(false)
    end
end

function SingleBannerView:OnBtnClick()
    if self.clickBack then 
        self.clickBack()
    end
end

return  SingleBannerView
