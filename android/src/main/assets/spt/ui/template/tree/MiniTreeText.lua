local UnityEngine = clr.UnityEngine
local MiniTreeText = class(unity.base)
local TeamTotal = require("data.TeamTotal")
local Color = UnityEngine.Color

function MiniTreeText:init(battles, gid)
	if type(battles) == "table" and battles.left and battles.right then
		self.___ex.team1.text = self:getName(battles.left[1].t1.tid, gid)
		self.___ex.team2.text = self:getName(battles.left[1].t2.tid, gid)
		self.___ex.team3.text = self:getName(battles.right[1].t1.tid, gid)
		self.___ex.team4.text = self:getName(battles.right[1].t2.tid, gid)
		for k, v in pairs(self.___ex) do
			if v.text == self.selfName then
				v.color = Color.red
			end
		end
	end
end

function MiniTreeText:getName(tid, gid)
	if string.sub(tid, 1, 4) == "self" then
		self.selfName = TeamTotal[tid].teamName
	end
	return TeamTotal[tid].teamName
end

return MiniTreeText