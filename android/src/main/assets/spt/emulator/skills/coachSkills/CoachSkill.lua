local Skill = import("../Skill")

local CoachSkill = class(Skill, "CoachSkill")

function CoachSkill:ctor()
    --比分状态：0 平局，1 领先，2 落后
    self.DRAW = 0
    self.LEADER = 1
    self.LAGGARD = 2
    self.scoreStatus = self.DRAW
    self.remainingCooldown = 0
end

function CoachSkill:onGoal(team)
    local newScoreStatus = self.DRAW
    if team.enemyTeam.score < team.score then
        newScoreStatus = self.LEADER
    elseif team.score < team.enemyTeam.score then
        newScoreStatus = self.LAGGARD
    end

    local previousScoreStatus = self.scoreStatus
    self.scoreStatus = newScoreStatus
    if previousScoreStatus == self.DRAW and newScoreStatus == self.LEADER then
        self:onBecomingLeader(team)
    elseif previousScoreStatus == self.DRAW and newScoreStatus == self.LAGGARD then
        self:onBecomingLaggard(team)
    elseif previousScoreStatus ~= self.DRAW and newScoreStatus == self.DRAW then
        self:onBecomingDraw(team)
    end
end

--比分变成领先
function CoachSkill:onBecomingLeader(team)
end

--比分变成落后
function CoachSkill:onBecomingLaggard(team)
end

--比分变成平局
function CoachSkill:onBecomingDraw(team)
end

return CoachSkill