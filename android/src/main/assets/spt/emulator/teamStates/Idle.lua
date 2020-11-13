local TeamState = import("./TeamState")

local Idle = class(TeamState)

function Idle:ctor(team)
    Idle.super.ctor(self, team, "Idle")
end

function Idle:Enter()
end

function Idle:Execute()
end

function Idle:Exit()
end

return Idle
