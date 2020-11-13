require("init")

local testFolder = "../testdata/"

local Match = require("Match")

local function runTest(data, seed)
    local Initializer = data and dofile(testFolder .. data .. ".lua") or require("Initializer")

    local startClock = os.clock()

    math.randomseed(seed)
    local match = Match.new()
    match:init(Initializer)

    while true do
        if Initializer.ops then
            local operation = Initializer.ops[match.frameCount]
            if operation then
                match:applyOperation(operation)
            end
        end

        match:nextKeyFrame()

        if match.frameCount % 100 == 0 then
            print(match.frameCount)
        end

        if match.state.name == "GameOver" then
            break
        end
    end

    print("playerTeam :".." opponentTeam")
    print("score  "..match.playerTeam.score .." : "..match.opponentTeam.score)
    print("shootOutScore  "..match.playerTeam.shootOutScore .." : "..match.opponentTeam.shootOutScore)
    print("shootTimes  "..match.playerTeam.shootTimes.." : "..match.opponentTeam.shootTimes)
    print("dribbleTimes  "..match.playerTeam.dribbleTimes.." : "..match.opponentTeam.dribbleTimes)
    print("mayBeStolenDribbleTimes  "..match.playerTeam.mayBeStolenDribbleTimes.." : "..match.opponentTeam.mayBeStolenDribbleTimes)
    print("stealTimes  "..match.playerTeam.stealTimes.." : "..match.opponentTeam.stealTimes)
    print("foulTimes  "..match.playerTeam.foulTimes.." : "..match.opponentTeam.foulTimes)
    print("passTimes  "..match.playerTeam.passTimes.." : "..match.opponentTeam.passTimes)
    print("highPassTimes  "..match.playerTeam.highPassTimes.." : "..match.opponentTeam.highPassTimes)
    print("mayBeInterceptedPassTimes  "..match.playerTeam.mayBeInterceptedPassTimes.." : "..match.opponentTeam.mayBeInterceptedPassTimes)
    print("interceptTimes  "..match.playerTeam.interceptTimes.." : "..match.opponentTeam.interceptTimes)
    print("possession  " .. match.playerTeam:getPossession() .. "% : " .. match.opponentTeam:getPossession() .. "%")
    print("passing  " .. match.playerTeam:getPassing() .. "% : " .. match.opponentTeam:getPassing() .. "%")

    printf("Total time: %.2fs", os.clock() - startClock)
end

runTest(nil, 40)

os.execute("pause")
