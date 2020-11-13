local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerView2T1 = class(BannerViewBase)

function BannerView2T1:ctor()
	BannerView2T1.super.ctor(self)
    self.desc = self.___ex.desc
end

function BannerView2T1:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)

	local matchText = self:GetMatchText(content.matchType)
	local time = self:GetConvertTime(content.time)
	self.desc.text = lang.trans("compete_banner_4", matchText, time)
	self:SetTitle(content.season, content.matchType, content.server)
end

return BannerView2T1