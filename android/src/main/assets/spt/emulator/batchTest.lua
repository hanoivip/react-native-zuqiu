require("init")

local Initializer = require("Initializer")
local Match = require("Match")

local playerScores = {}
local opponentScores = {}
local playerWins = 0
local opponentWins = 0
local draws = 0

function calcStat(scores)
    local sumScore = 0
    for i, score in ipairs(scores) do
        sumScore = sumScore + score
    end
    local avgScore = sumScore / #scores

    local varianceScore = 0
    for i, score in ipairs(scores) do
        varianceScore = varianceScore + (score - avgScore) ^ 2
    end
    varianceScore = varianceScore / #scores

    return avgScore, math.sqrt(varianceScore)
end


local playerWinTimes = 0
local opponentWinTimes = 0
local drawTimes = 0
local playerScore = 0
local opponentScore = 0
local playerShootTimes = 0
local opponentShootTimes = 0
local playerShootOnGoalTimes = 0
local opponentShootOnGoalTimes = 0
local playerInterceptTimes = 0
local opponentInterceptTimes = 0
local playerDribbleTimes = 0
local opponentDribbleTimes = 0
local playerMaybeStolenDribbleTimes = 0
local opponentMaybeStolenDribbleTimes = 0
local playerStealTimes = 0
local opponentStealTimes = 0
local playerFoulTimes = 0
local opponentFoulTimes = 0
local playerPassTimes = 0
local opponentPassTimes = 0
local playerHighPassTimes = 0
local opponentHighPassTimes = 0
local playerLeadPassTimes = 0
local opponentLeadPassTimes = 0
local playerHighLeadPassTimes = 0
local opponentHighLeadPassTimes = 0
local playerMaybeInterceptedTimes = 0
local opponentMaybeInterceptedTimes = 0
local playerPassing = 0
local opponentPassing = 0
local playerPossession = 0
local opponentPossession = 0
local playerOffsideTimes = 0
local opponentOffsideTimes = 0
local playerCornerKickTimes = 0
local opponentCornerKickTimes = 0
local playerInterceptedCornerKickTimes = 0
local opponentInterceptedCornerKickTimes = 0
local playerMaxScore = 0
local opponentMaxScore = 0
local firstManualOperateTime = 0
local manualOperateEnterTimes = 0
local manualOperateTriggerTimes = 0
local errorTimes = 0
local turnAdjustTimes = 0
local shootAdjustTimes = 0
local currentSeed = 0
local errorSeeds = ""

function runTest(seed)
    local startClock = os.clock()

    math.randomseed(seed)
    local match = Match.new()
    match:init(Initializer)

    while true do
        match:nextKeyFrame()
        if match.frameCount % 100 == 0 then
            print(match.frameCount)
        end

        if match.state.name == "GameOver" then
            break
        end
    end

    if match.playerTeam.score > match.opponentTeam.score then
        playerWinTimes = playerWinTimes + 1
    elseif match.playerTeam.score < match.opponentTeam.score then
        opponentWinTimes = opponentWinTimes + 1
    else
        drawTimes = drawTimes + 1
    end

    if playerMaxScore < match.playerTeam.score then
        playerMaxScore = match.playerTeam.score
    end

    if opponentMaxScore < match.opponentTeam.score then
        opponentMaxScore = match.opponentTeam.score
    end

    playerScore = playerScore + match.playerTeam.score
    opponentScore = opponentScore + match.opponentTeam.score
    playerShootTimes = playerShootTimes + match.playerTeam.shootTimes
    opponentShootTimes = opponentShootTimes + match.opponentTeam.shootTimes
    playerShootOnGoalTimes = playerShootOnGoalTimes + match.playerTeam.shootOnGoalTimes
    opponentShootOnGoalTimes = opponentShootOnGoalTimes + match.opponentTeam.shootOnGoalTimes
    playerDribbleTimes = playerDribbleTimes + match.playerTeam.dribbleTimes
    opponentDribbleTimes = opponentDribbleTimes + match.opponentTeam.dribbleTimes
    playerMaybeStolenDribbleTimes = playerMaybeStolenDribbleTimes + match.playerTeam.mayBeStolenDribbleTimes
    opponentMaybeStolenDribbleTimes = opponentMaybeStolenDribbleTimes + match.opponentTeam.mayBeStolenDribbleTimes
    playerStealTimes = playerStealTimes + match.playerTeam.stealTimes
    opponentStealTimes = opponentStealTimes + match.opponentTeam.stealTimes
    playerFoulTimes = playerFoulTimes + match.playerTeam.foulTimes
    opponentFoulTimes = opponentFoulTimes + match.opponentTeam.foulTimes
    playerPassTimes = playerPassTimes + match.playerTeam.passTimes
    opponentPassTimes = opponentPassTimes + match.opponentTeam.passTimes
    playerHighPassTimes = playerHighPassTimes + match.playerTeam.highPassTimes
    opponentHighPassTimes = opponentHighPassTimes + match.opponentTeam.highPassTimes
    playerLeadPassTimes = playerLeadPassTimes + match.playerTeam.leadPassTimes
    opponentLeadPassTimes = opponentLeadPassTimes + match.opponentTeam.leadPassTimes
    playerHighLeadPassTimes = playerHighLeadPassTimes + match.playerTeam.highLeadPassTimes
    opponentHighLeadPassTimes = opponentHighLeadPassTimes + match.opponentTeam.highLeadPassTimes
    playerInterceptTimes = playerInterceptTimes + match.playerTeam.interceptTimes
    opponentInterceptTimes = opponentInterceptTimes + match.opponentTeam.interceptTimes
    playerMaybeInterceptedTimes = playerMaybeInterceptedTimes + match.playerTeam.mayBeInterceptedPassTimes
    opponentMaybeInterceptedTimes = opponentMaybeInterceptedTimes + match.opponentTeam.mayBeInterceptedPassTimes
    playerOffsideTimes = playerOffsideTimes + match.playerTeam.offsideTimes
    opponentOffsideTimes = opponentOffsideTimes + match.opponentTeam.offsideTimes
    playerCornerKickTimes = playerCornerKickTimes + match.playerTeam.cornerKickTimes
    opponentCornerKickTimes = opponentCornerKickTimes + match.opponentTeam.cornerKickTimes
    playerInterceptedCornerKickTimes = playerInterceptedCornerKickTimes + match.playerTeam.interceptedCornerKickTimes
    opponentInterceptedCornerKickTimes = opponentInterceptedCornerKickTimes + match.opponentTeam.interceptedCornerKickTimes
    manualOperateEnterTimes = manualOperateEnterTimes + match.playerTeam.manualOperateEnterTimes
    manualOperateTriggerTimes = manualOperateTriggerTimes + match.playerTeam.manualOperateTriggerTimes
    firstManualOperateTime = firstManualOperateTime + match.firstManualOperateTime
    turnAdjustTimes = turnAdjustTimes + match.turnAdjustTimes
    shootAdjustTimes = shootAdjustTimes+ match.shootAdjustTimes

    playerPassing = playerPassing + match.playerTeam:getPassing()
    opponentPassing = opponentPassing + match.opponentTeam:getPassing()
    playerPossession = playerPossession + match.playerTeam:getPossession()
    opponentPossession = opponentPossession + match.opponentTeam:getPossession()

    printf("Total time: %.2fs", os.clock() - startClock)
end

function onError(err)
    errorTimes = errorTimes + 1
    errorSeeds = errorSeeds .. "\n" .. currentSeed

    io.write(err, "\n")
    io.write(debug.traceback(), "\n")
end

function main()
    local simulateTimes = 100

    local startClock = os.clock()

    math.randomseed(os.time())

    for j = 1, simulateTimes do
        currentSeed = j * simulateTimes --math.random(100000000)
        print("Seed: " .. currentSeed)
        xpcall(function() runTest(currentSeed) end, onError)
    end

    print("playerTeam :".." opponentTeam")
    print("winTimes  "..playerWinTimes.." : "..opponentWinTimes.."(drawTimes: "..drawTimes..")")
    print("maxScore  "..playerMaxScore.." : "..opponentMaxScore)
    print("score  "..playerScore / simulateTimes.." : "..opponentScore / simulateTimes)
    print("shootTimes  "..playerShootTimes / simulateTimes.." : "..opponentShootTimes / simulateTimes)
    print("shootOnGoalTimes  "..playerShootOnGoalTimes / simulateTimes.." : "..opponentShootOnGoalTimes / simulateTimes)
    print("dribbleTimes  "..playerDribbleTimes / simulateTimes.." : "..opponentDribbleTimes / simulateTimes)
    print("mayBeStolenDribbleTimes  "..playerMaybeStolenDribbleTimes / simulateTimes.." : "..opponentMaybeStolenDribbleTimes / simulateTimes)
    print("stealTimes  "..playerStealTimes / simulateTimes.." : "..opponentStealTimes / simulateTimes)
    print("foulTimes  "..playerFoulTimes / simulateTimes.." : "..opponentFoulTimes / simulateTimes)
    print("passTimes  "..playerPassTimes / simulateTimes.." : "..opponentPassTimes / simulateTimes)
    print("highPassTimes  "..playerHighPassTimes / simulateTimes.." : "..opponentHighPassTimes / simulateTimes)
    print("leadPassTimes "..playerLeadPassTimes / simulateTimes.." : "..opponentLeadPassTimes / simulateTimes)
    print("highLeadPassTimes "..playerHighLeadPassTimes / simulateTimes.." : "..opponentHighLeadPassTimes / simulateTimes)
    print("mayBeInterceptedPassTimes  "..playerMaybeInterceptedTimes / simulateTimes.." : "..opponentMaybeInterceptedTimes / simulateTimes)
    print("interceptTimes  "..playerInterceptTimes / simulateTimes.." : "..opponentInterceptTimes / simulateTimes)
    print("offsideTimes  "..playerOffsideTimes / simulateTimes.." : "..opponentOffsideTimes / simulateTimes)
    print("cornerKickTimes  "..playerCornerKickTimes / simulateTimes.." : "..opponentCornerKickTimes / simulateTimes)
    print("interceptedCornerKickTimes  "..playerInterceptedCornerKickTimes / simulateTimes.." : "..opponentInterceptedCornerKickTimes / simulateTimes)
    print("manualOperateEnterTimes  "..manualOperateEnterTimes / simulateTimes)
    print("manualOperateTriggerTimes  "..manualOperateTriggerTimes  / simulateTimes)

    print("passing  "..playerPassing / simulateTimes.." : "..opponentPassing / simulateTimes)
    print("possession  "..playerPossession / simulateTimes.." : "..opponentPossession / simulateTimes)

    print("firstManualOperateTime = "..firstManualOperateTime / simulateTimes)
    print("turnAdjustTimes = "..turnAdjustTimes / simulateTimes)
    print("shootAdjustTimes = "..shootAdjustTimes / simulateTimes)
    print("avgRunningTime = "..(os.clock() - startClock) / simulateTimes)
    print("errorTimes = ".. errorTimes)
    print("errorSeeds = " .. errorSeeds)

    print("END")
end

main()

--os.execute("pause")

