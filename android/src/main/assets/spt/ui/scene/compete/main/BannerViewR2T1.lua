local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerViewR2T1 = class(BannerViewBase)

function BannerViewR2T1:ctor()
	BannerViewR2T1.super.ctor(self)
    self.desc = self.___ex.desc
end

function BannerViewR2T1:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)

	local player = content.player or {}
	local name = player.name or ""
	local score = content.score or 0
	self.desc.text = lang.trans("compete_banner_14", name, score)
end

return BannerViewR2T1