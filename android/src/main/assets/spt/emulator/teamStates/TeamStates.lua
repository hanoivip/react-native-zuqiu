local TeamStates = class()
TeamStates.Idle = import("./Idle")
TeamStates.Attack = import("./Attack")
TeamStates.Defend = import("./Defend")

function TeamStates:ctor(team)
    self.Idle = TeamStates.Idle.new(team)
    self.Attack = TeamStates.Attack.new(team)
    self.Defend = TeamStates.Defend.new(team)
end

return TeamStates
