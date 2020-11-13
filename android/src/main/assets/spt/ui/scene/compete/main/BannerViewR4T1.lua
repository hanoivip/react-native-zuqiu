local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerViewR4T1 = class(BannerViewBase)

function BannerViewR4T1:ctor()
	BannerViewR4T1.super.ctor(self)
    self.desc = self.___ex.desc
    self.team = self.___ex.team
end

local FinalMatchIndex = 2 -- 后续补充 决赛时改变描述
function BannerViewR4T1:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)
	local player1 = content.player1 or { }
	local player2 = content.player2 or { }
	local team1 = player1.name or ""
	local sid1 = player1.sid or ""
	local team2 = player2.name or ""
	local sid2 = player2.sid or ""
	self.team.text = team1 .. " " .. sid1 .. lang.transstr("server") .. " VS " .. team2 .. " " .. sid2 .. lang.transstr("server")

	local matchText = self:GetMatchText(content.matchType)
	local time = self:GetConvertTime(content.time)
	local subType = self:GetSubType(content.subType)
	if subType == FinalMatchIndex then 
		self.desc.text = time .. " " .. lang.transstr("compete_banner_18", subType)
	else
		self.desc.text = time .. " " .. lang.transstr("compete_banner_17", subType)
	end 
end

return BannerViewR4T1