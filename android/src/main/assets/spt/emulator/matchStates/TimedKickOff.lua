local MatchState = import("./MatchState")

local TimedKickOff = class(MatchState)

function TimedKickOff:ctor(match)
    TimedKickOff.super.ctor(self, match, "TimedKickOff")
end

function TimedKickOff:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "KickOff"
end

function TimedKickOff:Execute()
    self.match:moveToDefaultState()

    self.match.ball:setOwner(self.match.attackTeam.kickOffPlayer)
    self.match.attackTeam.kickOffPlayer.upComingAction = "PreKickOff"

    self.super.Execute(self)

    self.match:judgeAfterGoalSkills()

    self.match:changeState("NormalPlayOn")
end

function TimedKickOff:Exit()

end

return TimedKickOff
