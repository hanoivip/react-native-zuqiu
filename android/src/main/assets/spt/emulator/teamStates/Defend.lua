local TeamState = import("./TeamState")

local Defend = class(TeamState)

function Defend:ctor(team)
    Defend.super.ctor(self, team, "Defend")
end

function Defend:Enter()

end

function Defend:Execute()
    self.team.nearestAthleteToBall = self.team:selectNearestAthleteToBall()

    self.team.offsideLine = 0
    self.team:updateArea()
    self.team:updateBackLine()
end

function Defend:Exit()

end

return Defend
