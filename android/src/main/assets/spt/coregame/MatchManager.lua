require("emulator.init")
local Sampler = require("emulator.Sampler")
local vector2 = require("emulator.libs.vector")
local EnumType = require("coregame.EnumType")
local ManualOperateType = EnumType.ManualOperateType

local CoreGameController = clr.ActionLayer.CoreGameController
local EmulatorState = clr.ActionLayer.EmulatorState
local DataProvider = clr.ActionLayer.DataProvider
local MatchKeyFrame = clr.ActionLayer.MatchKeyFrame
local MatchEventType = clr.ActionLayer.MatchEventType
local MatchInfo = clr.ActionLayer.MatchInfo
local Action = clr.ActionLayer.Action
local Vector2 = clr.UnityEngine.Vector2
local Vector3 = clr.UnityEngine.Vector3
local AthleteAction = clr.ActionLayer.AthleteAction
local Frame = clr.ActionLayer.Frame
local Animator = clr.UnityEngine.Animator
local BallOffset = clr.ActionLayer.BallOffset
local CoachSkillFrame = clr.ActionLayer.CoachSkillFrame
local TeamFrame = clr.ActionLayer.TeamFrame
local EmulatorInput = clr.EmulatorInput
local DebugInfo = clr.ActionLayer.DebugInfo

local MatchManager = class()

local function toClrVector2(v)
    return Vector2(v.x, v.y)
end

local function getStatData(team)
    local stats = {
        score = team.score,
        shootTimes = team.shootTimes,
        shootOnGoalTimes = team.shootOnGoalTimes,
        interceptTimes = team.interceptTimes,
        stealTimes = team.stealTimes,
        foulTimes = team.foulTimes,
        passTimes = team.passTimes,
        cornerTimes = team.cornerTimes,
        offsideTimes = team.offsideTimes,
        possession = team:getPossession(),
        passing = team:getPassing(),
        penaltyScore = team.shootOutScore,
        event = team.event,
    }
    return stats
end

local function toMatchKeyFrame(match)
    local matchInfo = MatchInfo()
    -- used for transform onfieldId (index of athletes) to athleteId (athlete.id)
    local athleteArray = MatchInfo.CreateAthleteArray()
    for i, athlete in ipairs(match.playerTeam.athletes) do
        assert(athlete.onfieldId ~= nil)
        athleteArray[athlete.onfieldId - 1] = athlete.id
    end
    for i, athlete in ipairs(match.opponentTeam.athletes) do
        assert(athlete.onfieldId ~= nil)
        athleteArray[athlete.onfieldId - 1] = athlete.id
    end

    local penaltyShootOutScoreArray = MatchInfo.CreatePenaltyShootOutScoreArray()
    for i, result in ipairs(match.playerTeam.penaltyShootOutResultsQueue) do
        penaltyShootOutScoreArray[i - 1] = result
    end
    for i, result in ipairs(match.opponentTeam.penaltyShootOutResultsQueue) do
        penaltyShootOutScoreArray[i + 4] = result
    end

    matchInfo.ToAthleteId = athleteArray
    matchInfo.BallPosition = toClrVector2(match.ball.position)
    matchInfo.PlayerScore = match.playerTeam.score
    matchInfo.OpponentScore = match.opponentTeam.score
    matchInfo.PlayerShootOutScore = match.playerTeam.shootOutScore
    matchInfo.OpponentShootOutScore = match.opponentTeam.shootOutScore
    matchInfo.IsPlayerOnNorth = match.playerTeam.field == "north"
    matchInfo.IsGoal = match.state.name == "TimedKickOff"
    matchInfo.GoalAthleteId = match.ball.lastTouchAthlete and match.ball.lastTouchAthlete.id or -1
    matchInfo.FoulAthlete = match.foulOnfieldId and match.foulOnfieldId - 1 or -1
    matchInfo.DisplayTimeOffset = match.displayTimeOffset or 0
    matchInfo.StoppageTime = match.displayStoppageTime or 0
    matchInfo.IsDeployed = match.playerTeam.isDeployed
    matchInfo.BreakReason = match.breakReason or 0
    matchInfo.Stage = match.stage
    matchInfo.PenaltyShootOutRound = match.attackTeam.shootOutAttempts
    matchInfo.PenaltyShootOutScore = penaltyShootOutScoreArray

    match.playerTeam.isDeployed = nil -- reset

    local matchStats = {
        player = getStatData(match.playerTeam),
        opponent = getStatData(match.opponentTeam),
    }

    if match.state.name == "GameOver" then
        matchStats.hashKey = match.validKey
    end

    local matchKeyFrame = MatchKeyFrame()
    matchKeyFrame.Time = match.currentTime
    matchKeyFrame.MatchEvent = match.state.name
    matchKeyFrame.MatchInfo = matchInfo
    matchKeyFrame.MatchStatsJson = json.encode(matchStats)

    return matchKeyFrame
end

local function toCoachSkillFrame(match, team)
    local coachSkillFrame = CoachSkillFrame()
    coachSkillFrame.Time = match.currentTime
    coachSkillFrame.CoachSkillId = team.lastCoachSkillId
    return coachSkillFrame
end

local function toTeamFrame(match, team)
    local teamFrame = TeamFrame()
    teamFrame.Time = match.currentTime
    teamFrame.IsManualOperateEnded = team.outputIsManualOperateEnded
    return teamFrame
end

--   public struct Action
--   {
--        public int nameHash;
--        public float transitionPercent;
--        public float transitionDuration;

--        public float parameterValue;

--        public Frame actionStartFrame;

--        public bool hasAthleteAction;
--        public AthleteAction athleteAction;

--        public bool isWithBallAction;
--        public BallOffset firstBallOffset;
--        public BallOffset lastBallOffset;

--        public bool isStartOnNormalPlayOn;
--    }

SaveActionIK = {
    E_C001 = 4,
    E_C002 = 5,
    E_C002_1 = 0,
    E_C003 = 3,
    E_C003_1 = 1,
    E_C004 = 2,
    E_C004_1 = 4,
    E_C004_2 = 4,
    E_C004_3 = 2,
    E_C005 = 5,
    E_C005_1 = 5,
    E_C006 = 5,
    E_C006_1 = 3,
    E_C006_2 = 5,
    E_C006_3 = 1,
    E_C007 = 2,
    E_C007_1 = 4,
    E_C009 = 4,
    E_C009_1 = 2,
    E_C010 = 5,
    E_C010_1 = 5,
    E_C011 = 5,
    E_C011_1 = 5,
    E_C012 = 5,
    E_C012_1 = 5,
    E_C013 = 4,
    E_C013_1 = 2,
    E_C014 = 4,
    E_C014_1 = 2,
    E_C015 = 5,
    E_C015_1 = 5,
}

function splitBlendName(s)
    local len = string.len(s)
    for i = len, 1, -1 do
        if string.sub(s, i, i) == "_" then
            return string.sub(s, 1, i - 1), string.sub(s, -(len - i))
        end
    end
end

local function needStopCallback(matchManager)
    if CoreGameController.NeedToStop() then
        print("need to stop")
        return true
    else
        return false
    end
end

local function operationCallback(matchManager)
    if matchManager:isReplay() then
        matchManager:applyReplayOperation()
    elseif EmulatorInput.GetInstance():GetIsTacticsChanged() then
        matchManager:applyUserTactics()
        matchManager:flushOperation()
    end
end

local function pauseCallback(matchManager)
    collectgarbage()
    print("start to wait signal")
    DataProvider.Wait()
    print("signal received, resume")

    if EmulatorInput.GetInstance():GetIsFormationChanged() then
        matchManager:applyUserFormation()
    end
    matchManager:flushOperation()
end

local function pauseOnPreShootCallback(matchManager, preShooter)
    print("start to wait signal, on preShoot")
    DataProvider.hasNewShootAction = false
    DataProvider.Wait()
    print("signal received, resume")

    if EmulatorInput.GetInstance():GetIsTouchShoot() then
        --TODO:touch shoot resume!!
        print(string.format("Apply touch shoot: (%.1f, %.1f), isShootHigh:%s", EmulatorInput.GetInstance():GetShootTargetPositionX(), EmulatorInput.GetInstance():GetShootTargetPositionY(), tostring(EmulatorInput.GetInstance():GetIsShootHigh())))
        local shootTargetPosition = vector2.new(EmulatorInput.GetInstance():GetShootTargetPositionX(), EmulatorInput.GetInstance():GetShootTargetPositionY())
        local shootTargetPositionHeight = EmulatorInput.GetInstance():GetShootTargetPositionHeight()
        local shootControlPoint = vector2.new(EmulatorInput.GetInstance():GetShootControlPointX(), EmulatorInput.GetInstance():GetShootControlPointY())
        local flyDuration = EmulatorInput.GetInstance():GetFlyDuration()

        -- Record operation for sending to server
        local operation = matchManager:getOperation(matchManager.sampler.match.frameCount)
        operation.shoot = {
            target = shootTargetPosition,
            targetH = shootTargetPositionHeight,
            control = shootControlPoint,
            duration = flyDuration,
            isHigh = EmulatorInput.GetInstance():GetIsShootHigh(),
            id = preShooter.id,
        }
        matchManager:flushOperation()

        --output new goal probability
        matchManager.sampler.match:applyShoot(operation.shoot)

        print(string.format("PreShooter=%d", preShooter.id))
    else
        print("no touch shoot detected")
    end
end

local function pauseOnManualOperateCallback(matchManager, manualOperateAthlete)
    print("start to wait signal on manual operate")
    DataProvider.Wait()
    print("signal received, resume")

    local manualOperateType = EmulatorInput.GetInstance():GetManualOperateTypeValue()
    local targetOnfieldId = EmulatorInput.GetInstance():GetManualOperateTargetOnfieldId()
    local directionIndex = EmulatorInput.GetInstance():GetManualOperateDirectionIndex()

    if manualOperateType ~= ManualOperateType.Invalid then
        local operation = matchManager:getOperation(matchManager.sampler.match.frameCount)
        operation.manual = {
            type = manualOperateType,
            id = manualOperateAthlete.id,
        }

        if manualOperateType == ManualOperateType.Pass then
            operation.manual.targetOnfieldId = targetOnfieldId
        elseif manualOperateType == ManualOperateType.Dribble then
            operation.manual.directionIndex = directionIndex
        elseif manualOperateType == ManualOperateType.Shoot then
        end

        matchManager.sampler.match:applyManual(operation.manual)
        matchManager:flushOperation()
    end

    EmulatorInput.GetInstance():ClearManualOperateType()
    EmulatorInput.GetInstance():SetManualOperateDirectionIndex(0)
    EmulatorInput.GetInstance():SetManualOperateTargetOnfieldId(0)
end

local function outputMovementFrameCallback(matchManager, match, isNormalPlayOnStart)
    local ret = {}
    for i, athlete in ipairs(match.playerTeam.athletes) do
        FuncPlayerMovementEnqueue(athlete.onfieldId - 1, match, athlete, isNormalPlayOnStart)
    end
    for i, athlete in ipairs(match.opponentTeam.athletes) do
        FuncOpponentMovementEnqueue(athlete.onfieldId - 12, match, athlete, isNormalPlayOnStart)
    end
    return ret
end

local function outputBallFrameCallback(matchManager, time, ball, isNormalPlayOnStart)
    local id = ball.outputOwner and ball.outputOwner.onfieldId - 1 or -1
    local curveType = ball.outputAnimation and ball.outputAnimation.curveType or 0
    if ball.output then
        FuncBallFrameEnqueue(time, ball.position, ball.height or 0.11, ball.output, curveType, id, isNormalPlayOnStart)
    end

    if ball.nextOutput and ball.nextOutput == "ShootPause" then
        FuncBallFrameEnqueue(time + 0.1, ball.nextPosition, ball.nextHeight or 0.11, ball.nextOutput, curveType, id, isNormalPlayOnStart)
    end
end

local function outputPlayerKeyFrameCallback(matchManager, athlete, time, isStartOnNormalPlayOn)
    local id = athlete.onfieldId - 1
    FuncPlayerEnqueue(id, athlete, time, isStartOnNormalPlayOn)
end

local function outputOpponentKeyFrameCallback(matchManager, athlete, time, isStartOnNormalPlayOn)
    local id = athlete.onfieldId - 12
    FuncOpponentEnqueue(id, athlete, time, isStartOnNormalPlayOn)
end

local function outputPlayerCoachSkillFrameCallback(matchManager, match, team)
    DataProvider.PlayerCoachSkillEnqueue(toCoachSkillFrame(match, team))
end

local function outputOpponentCoachSkillFrameCallback(matchManager, match, team)
    DataProvider.OpponentCoachSkillEnqueue(toCoachSkillFrame(match, team))
end

local function outputPlayerTeamFrameCallback(matchManager, match, team)
    DataProvider.PlayerTeamEnqueue(toTeamFrame(match, team))
end

local function outputOpponentTeamFrameCallback(matchManager, match, team)
    DataProvider.OpponentTeamEnqueue(toTeamFrame(match, team))
end

local function outputMatchKeyFrameCallback(matchManager, match)
    DataProvider.MatchEnqueue(toMatchKeyFrame(match))
end

local function outputDeployedEventCallback(matchManager, currentTime)
    DataProvider.DeployedEventEnqueue(currentTime)
end

local function outputLatestTimeCallback(matchManager, currentTime)
    FuncSetLatestTime(currentTime)
end

local function outputPenaltyShootOutSequenceCallBack(matchManager, match)
    for i, athlete in ipairs(match.playerTeam.rankedPenaltyShootOutAthletes) do
        DataProvider.playerPenaltyShootOutIds[i - 1] = athlete.id
    end

    for i, athlete in ipairs(match.opponentTeam.rankedPenaltyShootOutAthletes) do
        DataProvider.opponentPenaltyShootOutIds[i - 1] = athlete.id
    end
end

local function outputAthleteEffectCallback(matchManager, time, athlete)
    FuncAthleteEffectEnqueue(time, athlete.onfieldId - 1, athlete.outputBuffLevel or 0, false, false,
        athlete.interceptRate or 0, athlete.stealRate or 0, athlete.influenceRate or 0, athlete.saveRate or 0)
end

local function outputAthleteSkillCallback(matchManager, time, athlete)
    local skills = athlete.outputSkills
    local onfieldId = athlete.onfieldId - 1
    for i, skill in ipairs(skills) do
        if type(skill) == "table" then
            FuncAthleteSkillEnqueue(time, onfieldId, skill.id, skill.target or 0, skill.parameter1 or 0, skill.parameter2 or 0)
        else
            FuncAthleteSkillEnqueue(time, onfieldId, skill)
        end
    end
end

local function outputAthleteBuffCallback(matchManager, time, athlete)
    local buffs = athlete.outputStartBuffs
    for i, buff in ipairs(buffs) do
        FuncAthleteBuffEnqueue(
            buff.id, --BuffId
            time, --Time
            athlete.id, --AthleteId
            athlete.onfieldId, --OnfieldId
            buff.value, --Value
            0, --State==Start
            buff.type.skill.id, --SkillId
            buff.markedSkillId or "" --Marked SkillId
        )
    end
    buffs = athlete.outputEndBuffs
    for i, buff in ipairs(buffs) do
        FuncAthleteBuffEnqueue(
            buff.id, --BuffId
            time, --Time
            athlete.id, --AthleteId
            athlete.onfieldId, --OnfieldId
            buff.value, --Value
            1, --State=End
            buff.type.skill.id, --SkillId
            buff.markedSkillId or "" --Marked SkillId
        )
    end
end

local function sleepCallback(matchManager)
    FuncCoreGameSleep()
end

local function outputDebugInfoCallback(matchManager, time, athlete)
    FuncDebugInfoEnqueue(time, athlete)
end

function MatchManager:ctor(...)
    local callbackFuntions = {
        needStopCallback = needStopCallback,
        pauseCallback = pauseCallback,
        pauseOnPreShootCallback = pauseOnPreShootCallback,
        pauseOnManualOperateCallback = pauseOnManualOperateCallback,
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
        outputAthleteBuffCallback = outputAthleteBuffCallback,
        outputAthleteSkillCallback = outputAthleteSkillCallback,
        operationCallback = operationCallback,
        sleepCallback = sleepCallback,
        outputDeployedEventCallback = outputDeployedEventCallback,
        outputDebugInfoCallback = outputDebugInfoCallback,
        outputPenaltyShootOutSequenceCallBack = outputPenaltyShootOutSequenceCallBack,
    }

    self.sampler = Sampler.new(self, callbackFuntions)
    self.operation = nil
end

function MatchManager:init(initializer)
    self.sampler:init(initializer)
    self.operation = {}
    self.initializer = initializer
end

function MatchManager:isReplay()
    return self.initializer and self.initializer.baseInfo and self.initializer.baseInfo.isReplay
end

function MatchManager:applyReplayOperation()
    if self.initializer.ops then
        local operation = self.initializer.ops[self.sampler.match.frameCount] or self.initializer.ops[tostring(self.sampler.match.frameCount)]
        if operation then
            self.sampler.match:applyOperation(operation)
        end
    end
end

function MatchManager:getOperation(frameCount)
    if self.operation[self.sampler.match.frameCount] == nil then
        self.operation[self.sampler.match.frameCount] = {}
    end
    return self.operation[self.sampler.match.frameCount]
end

function MatchManager:flushOperation()
    DataProvider.operationJson = json.encode(self.operation)
end

function MatchManager:applyUserTactics()
    print("Apply tactics: " .. EmulatorInput.GetInstance():GetTacticsJson())
    EmulatorInput.GetInstance():SetIsTacticsChanged(false)
    local tactics = json.decode(EmulatorInput.GetInstance():GetTacticsJson())

    self.sampler.match:applyTactics(tactics)
    self.sampler.match.playerTeam.isDeployed = true

    local operation = self:getOperation(self.sampler.match.frameCount)
    operation.tactics = tactics
end

function MatchManager:applyUserFormation()
    print("Apply formation: " .. EmulatorInput.GetInstance():GetFormatonJson())
    EmulatorInput.GetInstance():SetIsFormationChanged(false)
    local node = json.decode(EmulatorInput.GetInstance():GetFormatonJson())

    local roles = {}
    for i, athlete in ipairs(node.athletes) do
        table.insert(roles, athlete.role)
    end

    local operation = self:getOperation(self.sampler.match.frameCount)
    operation.formation = node.formation
    operation.roles = roles

    operation.captain = node.captain
    operation.cornerKicker = node.cornerKicker
    operation.freeKickShooter = node.freeKickShooter
    operation.freeKickPasser = node.freeKickPasser
    operation.penaltyKicker = node.penaltyKicker

    self.sampler.match:applyFormation(operation)

    self.sampler.match.playerTeam.isDeployed = true
end

function MatchManager:main()
    print("MatchManager main loop start")
    self.sampler:main()
    print("MatchManager main loop end")
end

return MatchManager
