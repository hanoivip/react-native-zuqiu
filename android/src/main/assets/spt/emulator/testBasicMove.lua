require("init")

local Athlete = require("athlete.Athlete")
local vector = require("libs.vector")

local athlete = Athlete.new()

local targetPosition = vector.new(10, 10)
athlete:predictMoveTo_Animation(1, targetPosition)

os.execute("pause")
