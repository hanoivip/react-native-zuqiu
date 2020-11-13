if jit then jit.off(true, true) end

local MatchState = import("./MatchState")

local NontimedKickOff = class(MatchState)

function NontimedKickOff:ctor(match)
    NontimedKickOff.super.ctor(self, match, "NontimedKickOff")
end

function NontimedKickOff:Enter()
    self.match:resetAthletesStates()

    self.match.kickOffTeam.role = "Attack"
    self.match.kickOffTeam:changeState("Attack")
    self.match.nonKickOffTeam.role = "Defend"
    self.match.nonKickOffTeam:changeState("Defend")
    self.match.attackTeam = self.match.kickOffTeam
    self.match.defenseTeam = self.match.nonKickOffTeam

    self.match.isFrozen = true
    self.match.frozenType = "KickOff"
    self.match.cornerKickDefender = nil
    self.match.wingDirectFreeKickDefender = nil

    self.match.attackTeam:enterStage()
    self.match.defenseTeam:enterStage()

    self.match.defenseTeam:judgeDefendTacticsSkill()
    self.match.attackTeam:judgeDefendTacticsSkill()
end

function NontimedKickOff:Execute()
    self.match.ball.nextTask = nil
    self.match.ball:setOwner(self.match.kickOffTeam.kickOffPlayer)
    self.match.kickOffTeam.kickOffPlayer.upComingAction = "PreKickOff"

    self.match:moveToDefaultState()

    self.super.Execute(self)

    self.match:changeState("NormalPlayOn")
end

function NontimedKickOff:Exit()

end

return NontimedKickOff
