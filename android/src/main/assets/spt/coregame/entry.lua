local MatchManager = require("coregame.MatchManager")

local Initializer = nil
if EmulatorInputWrap.GetInitializerJson() then
    Initializer = json.decode(EmulatorInputWrap.GetInitializerJson())
    math.randomseed(Initializer.baseInfo.randSeed)
else
    -- Used for test directly without EntryScene
    Initializer = require("emulator.Initializer")
    math.randomseed(2)
end

matchManager = MatchManager.new()
matchManager:init(Initializer)