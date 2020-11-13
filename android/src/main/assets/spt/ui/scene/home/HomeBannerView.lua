local GameObjectHelper = require("ui.common.GameObjectHelper")
local HomeBannerView = class(unity.base)

function HomeBannerView:ctor()
    self.scroll = self.___ex.scroll
    self.bannerSignContent = self.___ex.bannerSignContent
end

function HomeBannerView:InitView(isShowBanner)
    GameObjectHelper.FastSetActive(self.gameObject, isShowBanner)
end

return HomeBannerView
