local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local BannerViewR4T2 = class(BannerViewBase)

function BannerViewR4T2:ctor()
	BannerViewR4T2.super.ctor(self)
    self.title = self.___ex.title
    self.team1 = self.___ex.team1
    self.team2 = self.___ex.team2
end

local ScoreSymbol = 
{
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"
}
function BannerViewR4T2:InitView(bannerCollectionModel, typeIndex, index)
	local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)
	local sortList = content.sortList or {}
	for i, v in ipairs(sortList) do
		if i <= 2 then 
			local name = v.name or ""
			local sid = v.sid or ""
			local lvl = v.level or 1
			local lvlDesc = lang.transstr("compete_team_desc" .. lvl) or ""
			local team = v.team or 1
			local sign = ScoreSymbol[tonumber(team)]
			local combine = name .. " " .. sid .. lang.transstr("server") .. "   " .. lvlDesc.. " " .. sign .. lang.transstr("team")
			if luaevt.trig("__VN__VERSION__") then
				combine = name .. " " .. sid .. lang.transstr("server") .. "   " .. lvlDesc.. " " .. lang.transstr("team") .. " " .. sign
			end
			self["team" .. i].text = tostring(combine)
		end
	end

	local seasonTime = content.season or ""
	local matchText = self:GetMatchText(content.matchType)
	self.title.text = seasonTime .. lang.transstr("competition_season") .. " " .. lang.transstr("compete_banner_15", matchText)
	if luaevt.trig("__VN__VERSION__") then
		self.title.text = lang.transstr("competition_season") .. " " .. seasonTime .. " " .. lang.transstr("compete_banner_15", matchText)
	end
end

return BannerViewR4T2