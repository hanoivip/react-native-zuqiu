require("init")

local cur = os.date('%Y_%m_%d_%H_%M_%S')
local fileName = '../logs/output' .. cur .. '.txt'
local testFolder = "../testdata/"

math.randomseed(os.time())

io.output(fileName)
coreGameVer = coreGameVer and coreGameVer or "invalid"
io.write('CoreGame Version: ', coreGameVer, '\n')

local Sampler = require("Sampler")
local vector2 = require("libs.vector")

local function needStopCallback(matchManager)
    return false
end

local function pauseCallback(matchManager)
end

local function pauseOnPreShootCallback(matchManager, preShooter)
end

local ManualOperateType =
{
    Invalid = -1,
    Auto = 0,
    Pass = 1,
    Dribble = 2,
    Shoot = 3,
}
local manualOperateConfig =
{
    --[1] = {manualOperateType = ManualOperateType.Pass, param = 2},
}
local manualOperateTimes = 0
--0: auto; 1: pass; 2: dribble; 3: shoot
local function pauseOnManualOperateCallback(matchManager, manualOperateAthlete)
    manualOperateTimes = manualOperateTimes + 1
    if manualOperateTimes <= #manualOperateConfig then
        manualOperateAthlete.manualOperateType = manualOperateConfig[manualOperateTimes].manualOperateType
        if manualOperateAthlete.manualOperateType == ManualOperateType.Auto then
        elseif manualOperateAthlete.manualOperateType == ManualOperateType.Pass then
            manualOperateAthlete:manualPass(manualOperateConfig[manualOperateTimes].param)
        elseif manualOperateAthlete.manualOperateType == ManualOperateType.Dribble then
            manualOperateAthlete:manualDribble(manualOperateConfig[manualOperateTimes].param)
        elseif manualOperateAthlete.manualOperateType == ManualOperateType.Shoot then
            manualOperateAthlete:manualShoot()
        end
    else
        manualOperateAthlete.manualOperateType = ManualOperateType.Auto
    end
end

local enterTimes = 0
local function pauseOnManualOperateCallbackForRecord(matchManager, manualOperateAthlete)
    if 1 == manualOperateAthlete.team.manualOperateTimes then
        manualOperateTimes = 0
        enterTimes = enterTimes + 1
        io.write('Begin Time: ' .. tostring(manualOperateAthlete.match.currentTime) .. '\n')
    end

    manualOperateTimes = manualOperateTimes + 1
    if manualOperateTimes == 1 then
        manualOperateAthlete.manualOperateType = ManualOperateType.Pass
        manualOperateAthlete:manualPass(manualOperateAthlete.manualPassList[1].onfieldId)
        io.write('Pass onfieldId: ' .. tostring(manualOperateAthlete.manualPassList[1].onfieldId) .. '\n')
    elseif manualOperateTimes == 2 then
        manualOperateAthlete.manualOperateType = ManualOperateType.Dribble
        manualOperateAthlete:manualDribble(1)
        io.write('Dribble onfieldId: ' .. tostring(manualOperateAthlete.manualDribbleList[1].targetPosition) .. '\n')
    elseif manualOperateTimes == 3 and manualOperateAthlete.outputActionStatus.isShootEnabled then
        manualOperateAthlete.manualOperateType = ManualOperateType.Shoot
        manualOperateAthlete:manualShoot()
        if enterTimes == 1 then
            io.write('####################################### ManualOperate Complete Time: ' .. tostring(manualOperateAthlete.match.currentTime) .. '\n')
        end
    else
        manualOperateAthlete.manualOperateType = ManualOperateType.Auto
    end
end

local function outputMovementFrameCallback(matchManager, match)
end

local function outputBallFrameCallback(matchManager, currentTime, ball, isNormalPlayOnStart)
end

local function outputPlayerKeyFrameCallback(matchManager, athlete, time, isStartOnNormalPlayOn)
end

local function outputOpponentKeyFrameCallback(matchManager, athlete, time, isStartOnNormalPlayOn)
end

local function outputPlayerCoachSkillFrameCallback(matchManager, match, team)
end

local function outputOpponentCoachSkillFrameCallback(matchManager, match, team)
end

local function outputPlayerTeamFrameCallback(matchManager, match, team)
end

local function outputOpponentTeamFrameCallback(matchManager, match, team)
end

local function outputMatchKeyFrameCallback(matchManager, match)
end

local function outputAthleteEffectCallback(matchManager, currentTime, athlete)
end

local function outputLatestTimeCallback(matchManager, currentTime)
end

local function outputPenaltyShootOutSequenceCallBack(matchManager, match)
end

local function outputDebugInfoCallback(matchManager, currentTime, athlete)
end

local function outputAthleteBuffCallback(matchManager, currentTime, athlete)
end

local function outputAthleteSkillCallback(matchManager, currentTime, athlete)
end

local function operationCallback(matchManager)
end

local function sleepCallback(matchManager)
end

local function outputDeployedEventCallback(matchManager, currentTime)
end

function runTest(seed, initializer)
    print(seed)

    math.randomseed(seed)
    local callbackFuntions = {
        needStopCallback = needStopCallback,
        pauseCallback = pauseCallback,
        pauseOnPreShootCallback = pauseOnPreShootCallback,
        --pauseOnManualOperateCallback = pauseOnManualOperateCallback,
        pauseOnManualOperateCallback = pauseOnManualOperateCallbackForRecord,
        outputMovementFrameCallback = outputMovementFrameCallback,
        outputBallFrameCallback = outputBallFrameCallback,
        outputPlayerKeyFrameCallback = outputPlayerKeyFrameCallback,
        outputOpponentKeyFrameCallback = outputOpponentKeyFrameCallback,
        outputPlayerCoachSkillFrameCallback = outputPlayerCoachSkillFrameCallback,
        outputOpponentCoachSkillFrameCallback = outputOpponentCoachSkillFrameCallback,
        outputPlayerTeamFrameCallback = outputPlayerTeamFrameCallback,
        outputOpponentTeamFrameCallback = outputOpponentTeamFrameCallback,
        outputMatchKeyFrameCallback = outputMatchKeyFrameCallback,
        outputAthleteEffectCallback = outputAthleteEffectCallback,
        outputLatestTimeCallback = outputLatestTimeCallback,
        outputPenaltyShootOutSequenceCallBack = outputPenaltyShootOutSequenceCallBack,
        outputAthleteBuffCallback = outputAthleteBuffCallback,
        outputAthleteSkillCallback = outputAthleteSkillCallback,
        operationCallback = operationCallback,
        sleepCallback = sleepCallback,
        outputDeployedEventCallback = outputDeployedEventCallback,
        outputDebugInfoCallback = outputDebugInfoCallback,
    }
    local sampler = Sampler.new(
        callbackObj,
        callbackFuntions
        )
    sampler:init(initializer)
    sampler:main()
end

function onError(err)
    io.write(err, "\n")
    io.write(debug.traceback(), "\n")
end

local failCount = 0

local function isFileExist(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
end

for cnt = 1, 500 do
    local testFile = testFolder .. (cnt % 40 + 1) .. ".lua"
    --if isFileExist(testFile) then
        --local seed = math.random(2147483646)
        --local seed = 28
        --local seed = 29
        local seed = cnt
        enterTimes = 0
        --local initializer = dofile(testFolder .. testFile)
        local initializer = require('Initializer')

        io.write("===========================================\n")
        io.write(string.format("run test: %d, test file: %s, seed: %s\n", cnt, testFile, seed))
        print(string.format("run test: %d, test file: %s, seed: %s\n", cnt, testFile, seed))
        io.flush()

        local startClock = os.clock()
        local status = xpcall(function() runTest(seed, initializer) end, onError)
        local totalTime = os.clock() - startClock

        if status then
            io.write("ok", "\n")
        else
            failCount = failCount + 1
        end

        io.write(string.format("time=%.2fs\n", totalTime))

        io.write(string.format("fail count = %d, fail rate = %.6f%%\n", failCount, failCount * 100 / cnt))
        io.flush()
    --end
end
