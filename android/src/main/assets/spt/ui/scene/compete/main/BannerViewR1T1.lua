local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerViewR1T1 = class(BannerViewBase)

function BannerViewR1T1:ctor()
	BannerViewR1T1.super.ctor(self)
    self.desc = self.___ex.desc
end

function BannerViewR1T1:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)

	local matchText = self:GetMatchText(content.matchType)
	self.title.text = lang.trans("compete_banner_9", matchText)
	local player = content.player or {}
	local name = player.name or ""
	local sid = player.sid or ""
	self.desc.text = name .. " " .. sid .. lang.transstr("server")
end

return BannerViewR1T1