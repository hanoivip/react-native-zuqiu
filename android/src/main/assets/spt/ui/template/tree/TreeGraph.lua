local UnityEngine = clr.UnityEngine
local TreeGraph = class(unity.base)
local Color = UnityEngine.Color

function TreeGraph:LoadData(data)
	data.base = nil
	for k, v in pairs(data) do
		if k == 'low' then
			side = "l"
		elseif k == 'up' then
			side = "r"
		end
		for k1, v1 in pairs(v.scores) do
			local state = self:getState(k1)
			for i, v2 in ipairs(v1) do
				local startLine = 2 * i - 1
				local v3 = v2[1]
				if v3.t1.advance and v3.t1.advance == 1 then
					dump(v3.t1.tid)
					num = startLine
				elseif v3.t2.advance and v3.t2.advance == 1 then
					dump(v3.t2.tid)
					num = startLine + 1
				end
				if num and state > 2 then
					local turn = "l"..state
					local lineNum = side..num
					local rowNum = side.."v"..num
					self.___ex.line[turn][lineNum]:GetComponent(Image).color = Color.red
					self.___ex.line[turn][rowNum]:GetComponent(Image).color = Color.red
				elseif state == 2 then
					dump("决赛为什么这么难搞！")
				end
				num = nil		
			end
		end
	end
end

function TreeGraph:getState(string)
	local state = {
	["16to8"] = 16,
	["8to4"] = 8,
	["semi"] = 4,
	["final"] = 2,
	}
	return state[string]
end

return TreeGraph
