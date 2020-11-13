local UnityEngine = clr.UnityEngine
local TreeText = class(unity.base)
local TeamTotal = require("data.TeamTotal")
local Color = UnityEngine.Color

function TreeText:LoadData(data, gid)
	if data.low.scores["16to8"] and data.up.scores["16to8"] then
		total = 16
		teams = "16to8"
	else
		total = 8
		teams = "8to4"
	end
	local textName = "t"..total
	for k, v in pairs(self.___ex[textName]) do
		v.gameObject:SetActive(true)
	end
	local left = 1
	local right = 1
	for k, v in pairs (data.low.scores[teams]) do
		local teamsInfo = v[1]
		--dump(teamsInfos)
		local side = "l"
		--dump(self:getTeamName(teamsInfo.t1.tid, gid))
		-- dump(textName)
		-- dump(side..left)
		self.___ex[textName][side..left].text = self:getTeamName(teamsInfo.t1.tid, gid)
		left = left + 1
		self.___ex[textName][side..left].text = self:getTeamName(teamsInfo.t2.tid, gid)
		left = left + 1
	end
	for k, v in pairs (data.up.scores[teams]) do
		local teamsInfo = v[1]
		local side = "r"
		self.___ex[textName][side..right].text = self:getTeamName(teamsInfo.t1.tid, gid)
		right = right + 1
		self.___ex[textName][side..right].text = self:getTeamName(teamsInfo.t2.tid, gid)
		right = right + 1
	end
	for k, v in pairs(self.___ex[textName]) do
		if v.text == self.selfName then
			v.color = Color.red
		end
	end
end

function TreeText:getTeamName(tid, gid)
	if string.sub(tid, 1, 1) == "c" then
		tid = "self" .. string.sub(tostring(gid), 2)
		self.selfName = TeamTotal[tid].teamName
	end
	return TeamTotal[tid].teamName
end
return TreeText
