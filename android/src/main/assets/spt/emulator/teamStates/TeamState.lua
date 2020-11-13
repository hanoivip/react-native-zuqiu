local TeamState = class()

function TeamState:ctor(team, teamStateName)
    self.team = team
    self.name = teamStateName
end

function TeamState:Enter()

end

function TeamState:Execute()

end

function TeamState:Exit()

end

return TeamState

