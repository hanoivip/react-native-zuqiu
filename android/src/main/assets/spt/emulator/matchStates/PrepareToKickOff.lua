local MatchState = import("./MatchState")

local PrepareToKickOff = class(MatchState)

function PrepareToKickOff:ctor(match)
    PrepareToKickOff.super.ctor(self, match, "PrepareToKickOff")
end

function PrepareToKickOff:Enter()

end

function PrepareToKickOff:Execute()
    self.match:changeState("NontimedKickOff")
end

function PrepareToKickOff:Exit()

end

return PrepareToKickOff
