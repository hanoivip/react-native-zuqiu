local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerView2T3 = class(BannerViewBase)

function BannerView2T3:ctor()
	BannerView2T3.super.ctor(self)
    self.team = self.___ex.team
end

function BannerView2T3:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)

	local lvl = content.level or 1
	local lvlDesc = lang.trans("compete_team_desc" .. lvl) or ""
	self.team.text = lvlDesc
	self:SetTitle(content.season, content.matchType, content.server)
end

return BannerView2T3