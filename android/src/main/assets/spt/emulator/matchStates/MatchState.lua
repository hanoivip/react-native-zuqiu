if jit then jit.off(true, true) end

local vector2 = import("../libs/vector")

local MatchState = class()

function MatchState:ctor(match, matchStateName)
    self.match = match
    self.name = matchStateName
end

function MatchState:Enter()

end

function MatchState:Execute()
    self.match.playerTeam.state:Execute()
    self.match.opponentTeam.state:Execute()

    self:UpdateSituation()

    if self.name ~= "NormalPlayOn" then
        log.info("%.1f executed: %s", self.match.currentTime, self.name)
    end
end

function MatchState:Exit()

end

function MatchState:UpdateSituation()
    self.match.attackTeam:update()
    self.match.defenseTeam:update()

    self.match.ball:clearOutput()
    for i, athlete in self.match:allAthletes() do
        athlete:clearOutput()
        athlete:playAnimation()
    end

    local ballOwner = self.match.ball.owner
    local passAthleteWithoutBall = self.match:getPassAthleteWithoutBall()

    if ballOwner then
        ballOwner:update()
    end

    if passAthleteWithoutBall then
        passAthleteWithoutBall:update()
    end

    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        if athlete ~= ballOwner and athlete ~= passAthleteWithoutBall then
            athlete:update()
        end
    end

    self.match.attackTeam:judgePenaltyBoxSignalFireTurret()

    self.match.defenseTeam:updateEnemyAthleteWithBall()
    self.match.defenseTeam:updatePredictedBackLine()
    self.match.defenseTeam:updateNearestAthleteToMarkEnemyAthleteWithBall()
    self.match.defenseTeam:updateNearestAthleteToCoverEnemyAthleteWithBall()

    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        if athlete ~= ballOwner and athlete ~= passAthleteWithoutBall then
            athlete:update()
        end
    end

    if not self.match.ballOutOfField then
        self.match.ball:update(self.match.nextTime)
    end

    for i, athlete in self.match:allAthletes() do
        athlete:adjustCurrentAnimation()
    end

    self.match.playerTeam:checkTeamLeaderBuffs()
    self.match.opponentTeam:checkTeamLeaderBuffs()
    self.match.playerTeam:judgeDesperateFight()
    self.match.opponentTeam:judgeDesperateFight()
    self.match.playerTeam:judgeDimensionReductionBlow()
    self.match.opponentTeam:judgeDimensionReductionBlow()
    self.match.playerTeam:judgeTopStudentOnFieldSkill()
    self.match.opponentTeam:judgeTopStudentOnFieldSkill()
end

return MatchState
