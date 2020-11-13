local TeamState = import("./TeamState")

local Attack = class(TeamState)

function Attack:ctor(team)
    Attack.super.ctor(self, team, "Attack")
end

function Attack:Enter()

end

function Attack:Execute()
    self.team.nearestAthleteToBall = self.team:selectNearestAthleteToBall()
    self.team:updateOffTheBallTargetsStatus()
    self.team:updateRunningForwardAthletes()

    self.team:updateOffsideLine()
    self.team:updateArea()
end

function Attack:Exit()

end

return Attack
