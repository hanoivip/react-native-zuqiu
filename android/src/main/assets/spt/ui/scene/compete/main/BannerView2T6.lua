local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerView2T6 = class(BannerViewBase)

function BannerView2T6:ctor()
	BannerView2T6.super.ctor(self)
    self.team = self.___ex.team
end

local FinalMatchIndex = 2 -- 后续补充 决赛时改变描述
function BannerView2T6:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)

	local time = self:GetConvertTime(content.time)
	local opponent = content.opponent or {}
	local name = opponent.name or ""
	local sid = opponent.sid or ""
	self.team.text = time .. " VS " .. name .. "  " .. sid .. lang.transstr("server")

	local seasonTime = content.season or ""
	local matchText = self:GetMatchText(content.matchType)
	local subType = self:GetSubType(content.subType)
	local desc = seasonTime .. " " .. matchText .. " " .. subType
	if subType == FinalMatchIndex then 
		self.title.text = lang.trans("compete_banner_18", desc)
	else
		self.title.text = lang.trans("compete_banner_17", desc)
	end 
end

return BannerView2T6