local UnityEngine = clr.UnityEngine
local MiniTree = class(unity.base)
local TreeGraph = require("ui.template.tree.TreeGraph")
local Color = UnityEngine.Color

function MiniTree:init(data, gid)
	local curRound = "16to8"
	local nextRound = "8to4"
	local battles = {}
	if data.up.final then
		battles["final"] = data.up.final[1]
	end
	for k, v in pairs(data.up) do
		if data.up["final"] then
			curRound = "semi"
			nextRound = "final"
		elseif data.up["semi"] then
			curRound = "semi"
			nextRound = "final"
		elseif data.up["8to4"] then
			curRound = "8to4"
			nextRound = "semi"
		elseif data.up["16to8"] then
			curRound = "16to8"
			nextRound = "8to4"
		end
	end
	local curRoundNum = 1
	--dump(curRound)
	--dump(data.up[curRound])
	for k, v in pairs(data.up[curRound]) do
		--dump("haha")
		if string.sub(v[1].t1.tid, 1, 1) == "c" then
			v[1].t1.tid = "self" .. string.sub(tostring(gid), 2) 
			battles["right"] = v
			if curRound == "semi" then
				battles["left"] = data.low[curRound][1]
			elseif curRoundNum % 2 == 1 then
				battles["left"] = data.up[curRound][curRoundNum + 1]
			else 
				battles["left"] = data.up[curRound][curRoundNum - 1]
			end
		elseif string.sub(v[1].t2.tid, 1, 1) == "c" then
			v[1].t2.tid = "self" .. string.sub(tostring(gid), 2)
			battles["right"] = v
			if curRound == "semi" then
				battles["left"] = data.low[curRound][1]
			elseif curRoundNum % 2 == 1 then
				battles["left"] = data.up[curRound][curRoundNum + 1]
			else 
				battles["left"] = data.up[curRound][curRoundNum - 1]
			end
		end
		curRoundNum = curRoundNum + 1
	end
	local curRoundNum = 1
	for k, v in pairs(data.low[curRound]) do
		if string.sub(v[1].t1.tid, 1, 1) == "c" then
			v[1].t1.tid = "self" .. string.sub(tostring(gid), 2) 
			battles["left"] = v
			if curRound == "semi" then
				battles["right"] = data.up[curRound][1]
			elseif curRoundNum % 2 == 1 then
				battles["right"] = data.low[curRound][curRoundNum + 1]
			else 
				battles["right"] = data.low[curRound][curRoundNum - 1]
			end
		elseif string.sub(v[1].t2.tid, 1, 1) == "c" then
			v[1].t2.tid = "self" .. string.sub(tostring(gid), 2)
			battles["left"] = v
			if curRound == "semi" then
				battles["right"] = data.up[curRound][1]
			elseif curRoundNum % 2 == 1 then
				battles["right"] = data.low[curRound][curRoundNum + 1]
			else 
				battles["right"] = data.low[curRound][curRoundNum - 1]
			end
		end
		curRoundNum = curRoundNum + 1
	end
	self:paintColor(battles)
	return battles
end

function MiniTree:paintColor(battles)
	if type(battles.left) == "table" then
		if battles.left[1].t1.advance == 1 then
			self.___ex.l4_l1:GetComponent(Image).color = Color.red
			self.___ex.l4_r1:GetComponent(Image).color = Color.red
		elseif battles.left[1].t2.advance == 1 then
			self.___ex.l4_l2:GetComponent(Image).color = Color.red
			self.___ex.l4_r2:GetComponent(Image).color = Color.red
		end
	end
	if type(battles.right) == "table" then
		if battles.right[1].t1.advance == 1 then
			self.___ex.l4_l3:GetComponent(Image).color = Color.red
			self.___ex.l4_r3:GetComponent(Image).color = Color.red
		elseif battles.right[1].t2.advance == 1 then
			self.___ex.l4_l4:GetComponent(Image).color = Color.red
			self.___ex.l4_r4:GetComponent(Image).color = Color.red
		end
	end
	if type(battles.final) == "table" then
		if battles.final[1].t1.advance == 1 then
			self.___ex.l2_l1:GetComponent(Image).color = Color.red
			self.___ex.l1_l1:GetComponent(Image).color = Color.red
		elseif battles.final[1].t2.advance == 1 then
			self.___ex.l2_l2:GetComponent(Image).color = Color.red
			self.___ex.l1_l1:GetComponent(Image).color = Color.red
		end
	end
end 
return MiniTree
