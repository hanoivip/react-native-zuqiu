local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerView2T7 = class(BannerViewBase)

function BannerView2T7:ctor()
	BannerView2T7.super.ctor(self)
    self.team1 = self.___ex.team1
    self.team2 = self.___ex.team2
    self.team3 = self.___ex.team3
    self.team4 = self.___ex.team4
end

local FinalMatchIndex = 2 -- 后续补充 决赛时改变描述
function BannerView2T7:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)

	local sortList = content.sortList or {}
	for i, v in ipairs(sortList) do
		if i <= 4 then 
			local player1 = v.player1 or {}
			local player2 = v.player2 or {}
			local team1 = player1.name or ""
			local sid1 = player1.sid or ""
			local team2 = player2.name or ""
			local sid2 = player2.sid or ""
			local desc = team1 .. "  " .. sid1 .. lang.transstr("server") .. " VS " .. team2 .. "  " .. sid2 .. lang.transstr("server")
			self["team" .. i].text = desc
		end
	end

	local seasonTime = content.season or ""
	local matchText = self:GetMatchText(content.matchType) or ""
	local subType = self:GetSubType(content.subType) or ""
	local desc = seasonTime .. " " .. matchText .. " " .. subType
	if subType == FinalMatchIndex then 
		self.title.text = lang.trans("compete_banner_18", desc)
	else
		self.title.text = lang.trans("compete_banner_17", desc)
	end 
end

return BannerView2T7