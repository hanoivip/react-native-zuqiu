local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerView2T4 = class(BannerViewBase)

function BannerView2T4:ctor()
	BannerView2T4.super.ctor(self)
end

function BannerView2T4:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)
	self:SetTitle(content.season, content.matchType, content.server)
end

return BannerView2T4