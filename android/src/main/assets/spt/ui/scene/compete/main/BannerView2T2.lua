local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerView2T2 = class(BannerViewBase)

function BannerView2T2:ctor()
	BannerView2T2.super.ctor(self)
    self.team = self.___ex.team
    self.desc = self.___ex.desc
end

function BannerView2T2:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)

	local matchText = self:GetMatchText(content.matchType)
	local time = self:GetConvertTime(content.time)
	local opponent = content.opponent or {}
	local name = opponent.name or ""
	local sid = opponent.sid or ""
	self.team.text = time .. " VS " .. name .. "  " .. sid .. lang.transstr("server")
	local winnerNum = content.matchCount or 0
	self.desc.text = lang.trans("compete_banner_6", winnerNum, matchText)
	self:SetTitle(content.season, content.matchType, content.server)
end

return BannerView2T2