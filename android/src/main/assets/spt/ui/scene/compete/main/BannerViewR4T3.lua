local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerViewR4T3 = class(BannerViewBase)

function BannerViewR4T3:ctor()
	BannerViewR4T3.super.ctor(self)
    self.title = self.___ex.title
    self.team4 = self.___ex.team4
    self.team3 = self.___ex.team3
    self.team2 = self.___ex.team2
    self.team1 = self.___ex.team1
end

local DefaultSubType = 2 -- 默认16强
function BannerViewR4T3:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)
	local sortList = content.sortList or {}
	for i, v in ipairs(sortList) do
		if i <= 4 then 
			local name = v.name or ""
			local sid = v.sid or ""
			local combine = name .. " " .. sid .. lang.transstr("server")
			self["team" .. i].text = tostring(combine)
		end
	end

	local seasonTime = content.season or ""
	local matchText = self:GetMatchText(content.matchType)
	local subNum = content.subType or DefaultSubType
	local subType = self:GetSubType(subNum)
	local desc = matchText .. " " .. subType
	self.title.text = seasonTime .. lang.transstr("competition_season") .. " " .. lang.transstr("compete_banner_16", desc)
end

return BannerViewR4T3