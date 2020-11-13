local WorldTournamentName = require("data.WorldTournamentName")
local BannerViewBase = class(unity.base)

function BannerViewBase:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    self.content = self.___ex.content
    self.title = self.___ex.title
end

function BannerViewBase:GetMatchText(matchType)
	local matchText = ""
	if matchType then 
		WorldTournamentNameData = WorldTournamentName[tostring(matchType)] or { }
		matchText = WorldTournamentNameData.name
	end
	return matchText
end

function BannerViewBase:GetConvertTime(time)
	local time = time or 0
	local convertTime = os.date(lang.transstr("calendar_time4"), tonumber(time))
	return convertTime
end

-- 5：2->1  4: 4->2    3 : 8->4  2: 16->8   1: 32-> 16
function BannerViewBase:GetSubType(subType)
	if tonumber(subType) == 1 then 
		return 32
	elseif tonumber(subType) == 2 then 
		return 16
	elseif tonumber(subType) == 3 then 
		return 8
	elseif tonumber(subType) == 4 then 
		return 4
	elseif tonumber(subType) == 5 then 
		return 2
	end
	return 1
end

function BannerViewBase:SetTitle(season, matchType, server)
	local seasonTime = season or ""
	local matchText = self:GetMatchText(matchType)
	local serverName = ""
	if server then 
		serverName = server .. lang.transstr("server") .. " "
		if luaevt.reg("__VN__VERSION__") then
			serverName = lang.transstr("server") .. " " .. server .. " "
		end
	end
	self.title.text = seasonTime .. lang.transstr("competition_season") .. " " .. serverName .. matchText
	if luaevt.reg("__VN__VERSION__") then
		self.title.text = lang.transstr("competition_season") .. " " .. seasonTime .. " " .. serverName .. matchText
	end
end

return BannerViewBase