local HomeBannerSignCtrl = class()

function HomeBannerSignCtrl:ctor(view, parentScript)
    self.signView = view
    self.parentScript = parentScript
end

function HomeBannerSignCtrl:ChangeSign(signIndex)
    self.signView:ChangeSign(signIndex)
end

function HomeBannerSignCtrl:InitView(bannerCount)
    self.signView:InitView(bannerCount)
end

return HomeBannerSignCtrl
