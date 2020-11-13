local ArenaOutTeamBar = class(unity.base)

function ArenaOutTeamBar:ctor()
    self.bar1 = self.___ex.bar1
    self.bar2 = self.___ex.bar2
    self.lineX = self.___ex.lineX
    self.lineY = self.___ex.lineY
    self.lineImageX = self.___ex.lineImageX
    self.lineImageY = self.___ex.lineImageY
end

-- 第一场先客后主的球队。第二场先主后客的球队。(按照服务器顺序t1为第一支队伍，t2为第二支队伍)
function ArenaOutTeamBar:InitView(teamData, arenaScheduleTeamModel, playerId, matchScheduleType, index)
    local totalMatchNum = #teamData
    local isOnlyOneMatch = tobool(totalMatchNum == 1)
    local firstData = teamData[1] or {}
    local secondData = teamData[2] or {}
    local firstTeamOne = firstData.t1 or {}
    local secondTeamOne = firstData.t2 or {}

    local firstTeamTwo = secondData.t2 or {} 
    local secondTeamTwo = secondData.t1 or {} 

    local firstMatchData = {}
    table.insert(firstMatchData, firstTeamOne)
    table.insert(firstMatchData, firstTeamTwo)

    local secondMatchData = {}
    table.insert(secondMatchData, secondTeamOne)
    table.insert(secondMatchData, secondTeamTwo)
    local teamBarIndex1 = index * 2 - 1
    local teamBarIndex2 = index * 2

    local firstPenaltyScoreOne = firstTeamOne.goal_penalty
    local secondPenaltyScoreOne = secondTeamOne.goal_penalty
    local firstPenaltyScoreTwo = firstTeamTwo.goal_penalty
    local secondPenaltyScoreTwo = secondTeamTwo.goal_penalty

    local hasPenaltyScore = false
    if firstPenaltyScoreOne and secondPenaltyScoreOne and not(firstPenaltyScoreOne == 0 and secondPenaltyScoreOne == 0) then 
        hasPenaltyScore = true
    elseif firstPenaltyScoreTwo and secondPenaltyScoreTwo and not(firstPenaltyScoreTwo == 0 and secondPenaltyScoreTwo == 0) then 
        hasPenaltyScore = true
    end

    self.bar1:InitView(firstMatchData, arenaScheduleTeamModel, firstData.h == 1, isOnlyOneMatch, playerId, matchScheduleType, teamBarIndex1, hasPenaltyScore)
    self.bar2:InitView(secondMatchData, arenaScheduleTeamModel, secondData.h == 0, isOnlyOneMatch, playerId, matchScheduleType, teamBarIndex2, hasPenaltyScore)
end

return ArenaOutTeamBar
