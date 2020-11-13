local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GoalDisplayView = class(unity.base)

function GoalDisplayView:ctor()
    self.goal1View = self.___ex.goal1View
    self.goal2View = self.___ex.goal2View

    DialogAnimation.Appear(self.transform)
end

function GoalDisplayView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

local function GetGoalScore(useData)
    local score = 0
    for i, v in ipairs(useData) do
        score = score + tonumber(v.score)
    end
    return score
end

local function GetPenaltyScore(penaltyMatch, roleId, opponentId)
    local rolePenaltyScore, opponentPenaltyScore = 0, 0
	if next(penaltyMatch) then 
		local attacker = penaltyMatch.attacker or { }
		local defender = penaltyMatch.defender or { }
		if attacker.attackerPid == roleId then
			rolePenaltyScore = rolePenaltyScore + tonumber(attacker.score) + tonumber(attacker.penaltyScore)
		elseif attacker.attackerPid == opponentId then
			opponentPenaltyScore = opponentPenaltyScore + tonumber(attacker.score) + tonumber(attacker.penaltyScore)
		end

		if defender.opponentPid == roleId then
			rolePenaltyScore = rolePenaltyScore + tonumber(defender.score) + tonumber(defender.penaltyScore)
		elseif defender.opponentPid == opponentId then
			opponentPenaltyScore = opponentPenaltyScore + tonumber(defender.score) + tonumber(defender.penaltyScore)
		end
	end
	return rolePenaltyScore, opponentPenaltyScore
end

function GoalDisplayView:InitView(teamData, teamList)
    local match = teamData.match
    local pid1 = teamData.player1
    local pid2 = teamData.player2
    if not pid1 or not pid2 then return end
    local vid1, vid2
    local homeData = {}
    local visitData = {}
    for i, v in ipairs(match) do
        local attacker = v.attacker
        local defender = v.defender
        if attacker.attackerPid == pid1 then 
            homeData[i] = attacker
            vid1 = v.vid
        elseif attacker.attackerPid == pid2 then 
            vid2 = v.vid
            visitData[i] = attacker
        end
        if defender.opponentPid == pid1 then
            homeData[i] = defender
            vid2 = v.vid
        elseif defender.opponentPid == pid2 then
            visitData[i] = defender
            vid1 = v.vid
        end
    end

    local homeScore = GetGoalScore(homeData)
    local visitScore = GetGoalScore(visitData)

	local penaltyMatch = teamData.penaltyMatch or {}
	local homePenaltyScore, visitPenaltyScore = GetPenaltyScore(penaltyMatch, pid1, pid2)
    if homePenaltyScore == 0 and visitPenaltyScore == 0 then 
        homePenaltyScore = ""
        visitPenaltyScore = ""
    end

    local h_firstData = homeData[1] or {}
    local v_firstData = visitData[1] or {}
    local h_secondData = homeData[2] or {}
    local v_secondData = visitData[2] or {}
    self.goal1View:InitView(pid1, h_firstData, v_firstData, teamList, homeScore, homePenaltyScore, true, vid1)
    self.goal2View:InitView(pid2, v_secondData, h_secondData, teamList, visitScore, visitPenaltyScore, false, vid2)
end

return GoalDisplayView