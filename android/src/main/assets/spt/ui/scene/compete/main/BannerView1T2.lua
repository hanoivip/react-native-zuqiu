local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerView1T2 = class(BannerViewBase)

function BannerView1T2:ctor()
	BannerView1T2.super.ctor(self)
    self.myRank = self.___ex.myRank
end

function BannerView1T2:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)
	self.myRank.text = lang.trans("compete_banner_2", content.rank)
end

return BannerView1T2