if jit then jit.off(true, true) end

local segment = import("./libs/segment")
local vector2 = import("./libs/vector")
local Actions = import("./actions/Actions")
local MatchStates = import("./matchStates/MatchStates")
local Team = import("./Team")
local Ball = import("./Ball")
local Field = import("./Field")
local InspectorData = import("./InspectorData")
local EventHintMap = import("./EventHintMap")
local Behavior = import("./Behavior")
local Animations = import("./animations/Animations")
local selector = import("./libs/selector")
local AIUtils = import("./AIUtils")
local AIConstants = import("./AIConstants")
local Skills = import("./skills/Skills")

local Match = class()

local BallOutResetType = {
    Invalid = 0,
    Goal = 1,
    OwnGoal = 2,
    CornerKick = 3,
    GoalKick = 4,
    ThrowIn = 5,
}

local timeBeforeKickOut = 3.7

function Match:ctor()
    self.name = "untitled_match"

    self.totalTime = 180
    self.overTime = 60
    self.hasOverTime = false
    self.hasPenaltyShootOut = true
    self.hasPreviousMatch = false

    self.isFrozen = false
    self.frozenType = "Init"

    -- time for game play (in seconds)
    self.currentTime = 0
    self.nextTime = 0.1
    self.actualTime = 0
    self.frameCount = 0

    self.FIRST_HALF_STAGE = 1
    self.SECOND_HALF_STAGE = 2
    self.FIRST_OVERTIME_STAGE = 3
    self.SECOND_OVERTIME_STAGE = 4
    self.PENALTY_SHOOTOUT_STAGE = 5
    self.GAME_OVER_STAGE = 6
    self.stage = 0
    self.canBeEndedNow = false
    self.firstHalfStoppageTime = 0
    self.secondHalfStoppageTime = 0
    self.firstHalfDeltaTime = 0
    self.secondHalfDeltaTime = 0
    self.firstOvertimeDeltaTime = 0
    self.secondOverTimeDeltaTime = 0
    self.displayTimeOffset = 0
    self.displayStoppageTime = 0
    self.firstManualOperateTime = 180
    self.stealCoolDownTime = 0

    self.ball = Ball.new(self)
    self.isGoal = false

    self.playerTeam = Team.new(self)
    self.playerTeam.isPlayerTeam = true
    self.opponentTeam = Team.new(self)

    self.substitutionQueue = {}
    self.ballOutOfField = false
    self.ballOutOfFieldCountDown = 0
    self.ballOutResetType = BallOutResetType.Invalid
    self.noNeedJudgeBallOutOfField = false
    self.foulPosition = nil
    self.indirectFreeKickPosition = nil
    self.indirectFreeKickOffAthlete = nil

    self.states = MatchStates.new(self)
    self.state = self.states.PrepareToKickOff

    self.matchInspectorData = InspectorData.matchInspectorData
    self.athleteInspectorData = InspectorData.athleteInspectorData

    self.weatherEffectSkillIds = {}
    self.weatherEffectSkillDecrease = 0

    self.turnAdjustTimes = 0
    self.shootAdjustTimes = 0

    self.grassTechEffect = {
        dribble = 0,
        pass = 0,
        shoot = 0,
        steal = 0,
        intercept = 0,
    }

    self.candidateCornerKickTargets = { }
    self.candidateWingDirectFreeKickTargets = { }

    self.events = {
        ballOutOfField = event.new()
    }

    self.scoreState = AIConstants.matchScoreState.DRAW

    self.eventHint = "Init"

    self.lastMatchState = nil
    self.isFoulFrame = nil
    self.foulOnfieldId = nil
    self.throwInTarget = nil
    self.gameOverTime = nil
    self.breakReason = nil
    self.isInPenaltyShootOut = nil
    self.lastPenaltyShootOutTeam = nil

    self.shootAthleteForAfterShootSkills = nil
    self.attackAssister = nil
    self.shootAthletePosition = nil

    self.buffId = 0

    self.allowManualOperation = true

    self.validKey = nil
    self.hasFirstGoal = nil
end

function Match:initTeams(initializer)
    local startId = 1
    startId = self.playerTeam:initTeamAthletes(self.opponentTeam, initializer.player, startId, 1)
    startId = self.opponentTeam:initTeamAthletes(self.playerTeam, initializer.opponent, startId, 12)

    self.attackTeam = self.playerTeam
    self.defenseTeam = self.opponentTeam

    self.playerTeam:initTeamStates(initializer.player)
    self.opponentTeam:initTeamStates(initializer.opponent)
    if not self.playerTeam.power then
        self.playerTeam:calculatePower()
    end

    if not self.opponentTeam.power then
        self.opponentTeam:calculatePower()
     end
    self.playerTeam.powerRatio = math.max(self.playerTeam.power / self.opponentTeam.power, (self.playerTeam.power - self.opponentTeam.power) / 200000 + 1)
    self.opponentTeam.powerRatio = math.max(self.opponentTeam.power / self.playerTeam.power, (self.opponentTeam.power - self.playerTeam.power) / 200000 + 1)
end

function Match:initWeatherAndGrassEffect(initializer)
    self.weatherEffectSkillIds, self.weatherEffectSkillDecrease = AIUtils.getWeatherEffect(initializer.baseInfo.weatherTech, initializer.baseInfo.weatherTechLvl)

    local grassTechEffectAbilityNames, grassTechEffectDecreaseRate = AIUtils.getGrassEffect(initializer.baseInfo.grassTech, initializer.baseInfo.grassTechLvl)

    for _, grassTechEffectAbilityName in ipairs(grassTechEffectAbilityNames) do
        self.grassTechEffect[grassTechEffectAbilityName] = grassTechEffectDecreaseRate
    end
end

function Match:init(initializer)
    if initializer.baseInfo.weatherTech and initializer.baseInfo.weatherTechLvl
        and initializer.baseInfo.grassTech and initializer.baseInfo.grassTechLvl then
        self:initWeatherAndGrassEffect(initializer)
    end

    for i = 1, 3 do
        self.validKey = math.random(2147483647)
    end

    self:initTeams(initializer)

    if initializer.baseInfo.matchTime == 1 then
        self.hasOverTime = true
        self.hasPenaltyShootOut = true
    elseif initializer.baseInfo.matchTime == 2 then
        self.hasOverTime = false
        self.hasPenaltyShootOut = false
    elseif initializer.baseInfo.matchTime == 3 then
        self.hasOverTime = false
        self.hasPenaltyShootOut = true
    elseif initializer.baseInfo.matchTime == 4 then
        self.hasOverTime = true
        self.hasPenaltyShootOut = false
    elseif initializer.baseInfo.matchTime == 5 then
        self.hasOverTime = true
        self.hasPenaltyShootOut = true
        self.hasPreviousMatch = true
    end

    if initializer.baseInfo.allowManualOperation == 0 then
        self.allowManualOperation = false
    end

    if initializer.baseInfo.game then
        AIUtils.initPowerRatioMap(initializer.baseInfo.game)
    end

    self.currentTime = 0
    self.actualTime = 0
    --常规时间上下半场结束时，随机补时2min至4min
    self.firstHalfStoppageTime = math.random(2, 4) * 2
    self.secondHalfStoppageTime = math.random(2, 4) * 2
    self.stage = self.FIRST_HALF_STAGE
    self.canBeEndedNow = false
    self.firstHalfDeltaTime = 0
    self.secondHalfDeltaTime = 0
    self.firstOvertimeDeltaTime = 0
    self.secondOverTimeDeltaTime = 0
    self.displayTimeOffset = timeBeforeKickOut
    self.displayStoppageTime = self.firstHalfStoppageTime

    self.playerTeam.score = 0
    self.opponentTeam.score = 0
    self.playerTeam.previousScore = 0
    self.opponentTeam.previousScore = 0
    self.playerTeam.shootTimes = 0
    self.opponentTeam.shootTimes = 0
    self.playerTeam.interceptTimes = 0
    self.opponentTeam.interceptTimes = 0
    self.playerTeam.stealTimes = 0
    self.opponentTeam.stealTimes = 0
    self.playerTeam.passTimes = 0
    self.opponentTeam.passTimes = 0

    if initializer.baseInfo.preRace ~= nil then
        self.playerTeam.previousScore = initializer.baseInfo.preRace.player or 0
        self.opponentTeam.previousScore = initializer.baseInfo.preRace.opponent or 0
    end

    if initializer.baseInfo.home ~= nil then
        if initializer.baseInfo.home == 0 then
            self.playerTeam.side = "away"
            self.opponentTeam.side = "home"
        elseif initializer.baseInfo.home == 1 then
            self.playerTeam.side = "home"
            self.opponentTeam.side = "away"
        elseif initializer.baseInfo.home == 2 then
            self.playerTeam.side = "neutral"
            self.opponentTeam.side = "neutral"
        end
    end

    local questCondition = initializer.baseInfo.questCondition
    if questCondition then
        if questCondition.beginScore and #questCondition.beginScore == 2 then
            self.playerTeam.score = questCondition.beginScore[1]
            self.playerTeam.shootTimes = self.playerTeam.score
            self.opponentTeam.score = questCondition.beginScore[2]
            self.opponentTeam.shootTimes = self.opponentTeam.score
        end
        local beginTime = questCondition.beginTime
        if beginTime then
            self.actualTime = beginTime * 2
            self.displayTimeOffset = - beginTime * 2

            -- Timer starts at kickoff
            if math.cmpf(beginTime, 0) == 0 or math.cmpf(beginTime, 45) == 0 then
                self.displayTimeOffset = self.displayTimeOffset + timeBeforeKickOut
            end

            if math.cmpf(beginTime, 45) < 0 then
            elseif math.cmpf(beginTime, 90) < 0 then
                self.stage = self.SECOND_HALF_STAGE
                self:halfTimeSwitch()
            elseif math.cmpf(beginTime, 105) < 0 then
                self.stage = self.FIRST_OVERTIME_STAGE
            else
                self.stage = self.SECOND_OVERTIME_STAGE
                self:halfTimeSwitch()
            end
        end
        self.questCondition = questCondition
    end

    self.kickOffTeam = self.playerTeam
    self.nonKickOffTeam = self.opponentTeam

    self.attackTeam = self.playerTeam
    self.defenseTeam = self.opponentTeam

    self.ball.events.setOwner:addHandler(self.onGetBall, self)
    self.events.ballOutOfField:addHandler(self.ball.resetBallStateOnBallOut, self)

    self:changeState("PrepareToKickOff")
end

function Match:moveToDefaultState()
    for i, athlete in ipairs(self.attackTeam.athletes) do
        local sign = athlete.team:getSign()
        athlete.position = Field.formations[athlete.team.formation]["athletes"][athlete.role].attack.kickOff * sign
        athlete.bodyDirection = -vector2.norm(athlete.position)
        athlete.direction = athlete.bodyDirection
    end

    for i, athlete in ipairs(self.defenseTeam.athletes) do
        local sign = athlete.team:getSign()
        athlete.position = Field.formations[athlete.team.formation]["athletes"][athlete.role].defense.kickOff * sign
        athlete.bodyDirection = -vector2.norm(athlete.position)
        athlete.direction = athlete.bodyDirection
    end
end

function Match:resetAthletesStates()
    for i, athlete in ipairs(self.kickOffTeam.athletesAll) do
        athlete.upComingAction = nil
        athlete.behaviorTree = Behavior:createInstance()
        athlete:clearOutput()
        athlete:resetBuffs()
        athlete.cachedAbilities = nil
    end

    for i, athlete in ipairs(self.nonKickOffTeam.athletesAll) do
        athlete.upComingAction = nil
        athlete.behaviorTree = Behavior:createInstance()
        athlete:clearOutput()
        athlete:resetBuffs()
        athlete.cachedAbilities = nil
    end
end

function Match:switchRole(isGoal)
    self:judgeBeforeSwitchRoleSkills()
    self.playerTeam:clearTeamManualOperate()
    self.opponentTeam:clearTeamManualOperate()
    self.playerTeam.role, self.opponentTeam.role = self.opponentTeam.role, self.playerTeam.role
    self.attackTeam, self.defenseTeam = self.defenseTeam, self.attackTeam
    if self.playerTeam.role == "Defend" then
        self.playerTeam:changeState(self.playerTeam.role)
        self.opponentTeam:changeState(self.opponentTeam.role)
    else
        self.opponentTeam:changeState(self.opponentTeam.role)
        self.playerTeam:changeState(self.playerTeam.role)
    end
    self:judgeAfterSwitchRoleSkills()
    if not isGoal then
        self.attackTeam:judgeSambaIronFenceSelfBuff()
        self.defenseTeam:judgeThreeLionsGateGodExtraBuff()
    end
end

function Match:onGetBall(ball, athlete)
    if athlete.team:isDefendRole() then
        self:switchRole()
    end
end

function Match:moveTime()
    self.currentTime = self.nextTime
    self.nextTime = self.currentTime + TIME_STEP
    self.actualTime = self.actualTime + TIME_STEP
end

function Match:generateBuffId()
    self.buffId = self.buffId + 1
    return self.buffId
end

function Match:cannotBeEndedNow()
    for i, athlete in self:allAthletes() do
        if athlete.outputActionStatus ~= nil
            and (athlete.outputActionStatus.name == "PreShoot"
            or athlete.outputActionStatus.name == "Shoot") then
            return true
        end
    end
    -- 遇过顶和手术刀则完成本次传球再结算
    return self.ball.nextTask and (AIUtils.isSkillIdCorrespondSkill(self.ball.nextTask.skillId, Skills.OverHeadBall)
    or AIUtils.isSkillIdCorrespondSkill(self.ball.nextTask.skillId, Skills.ThroughBall))
end

function Match:nextKeyFrame()
    self.frameCount = self.frameCount + 1
    self.breakReason = nil

    if math.cmpf(self.stealCoolDownTime, 0) > 0 then
        self.stealCoolDownTime = self.stealCoolDownTime - TIME_STEP
    end

    if self.state == self.states.GameOver then
        self:moveTime()
        log.info("%.1f end of nextKeyFrame: game over", self.currentTime)
        return
    end

    --判断比赛阶段（进入下半场、加时赛上下半场、点球大战、比赛结束），点球大战期间不判断
    if not self.isInPenaltyShootOut and self:judgeMatchTimeStage() then
        self:moveTime()
        self.ballOutOfField = false
        self.canBeEndedNow = false
        log.info("%.1f end of nextKeyFrame: judgeMatchTimeStage", self.currentTime)
        return
    end

    self.canBeEndedNow = false

    if self.ballOutOfField then
        if math.cmpf(self.ballOutOfFieldCountDown, 0) == 0 then
            self.ballOutOfField = false
            self:resetPositionAndDirectionOnBallOut()

            self:moveTime()

            log.info("%.1f end of nextKeyFrame: %s (resetPositionAndDirectionOnBallOut)", self.currentTime, self.state.name)
            return
        else
            self.ballOutOfFieldCountDown = self.ballOutOfFieldCountDown - 0.1
            self:moveTime()
            self.state:Execute()
            return
        end
    end

    self:moveTime()
    self.state:Execute()

    if self.isFoulFrame then
        local task = self.ball.nextTask
        self.foulPosition = task.foulPosition
        self:judgeSubstitution()

        if task.destMatchState == "IndirectFreeKick" then
            self:switchRole()
            self.indirectFreeKickPosition = task.foulPosition
            self.indirectFreeKickOffAthlete = self:getIndirectFreeKickOffAthlete()
        end

        self.breakReason = "Foul"
        self:changeState(task.destMatchState)
        self.ball.nextTask = nil

        self.isFoulFrame = nil
    end

    for i, athlete in self:allAthletes() do
        if athlete.willBeOffside then
            if athlete.isOffsideCatch or 0 <= math.cmpf(self.currentTime, self.ball.flyStartTime + 2) then
                athlete.team.offsideTimes = athlete.team.offsideTimes + 1
                athlete:executeOffside()
                break
            end
        end
    end

    for i, athlete in self:allAthletes() do
        if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "PreShoot" then
            athlete.chosenDPSAction = athlete:evaluateShoot(athlete.chosenDPSAction.targetPosition, nil, nil, nil, false, Actions.PreShoot, true)
            athlete.outputActionStatus = shallowClone(athlete.chosenDPSAction)
            break
        end
    end

    if not self.ballOutOfField then
        if not Field.isInside(self.ball.position) and not self.noNeedJudgeBallOutOfField and not (self.ball.owner and self.ball.owner.graspBall) then
            self.ballOutOfField = true

            if self.isInPenaltyShootOut and self.isGoal then
                self.ballOutOfFieldCountDown = 3.5
            else
                self.ballOutOfFieldCountDown = 0.8
            end

            self:onBallOut()
        end
    end

    --点球大战门将扑住球动作做完后进行下一轮点球判断
    if self.willJudgePenaltyShootOutKickAfterGrasp then
        self:judgePenaltyShootOutKick()
        self.willJudgePenaltyShootOutKickAfterGrasp = nil
    end

    if self.state.name ~= self.lastMatchState then
        log.info("%.1f end of nextKeyFrame: %s", self.currentTime, self.state.name)
        self.lastMatchState = self.state.name
    end
end

function Match:onBallOut()
    if self.isGoal then
        self.ballOutResetType = BallOutResetType.Goal
    else
        local flySegment = segment.new(self.ball.flyStartPosition, self.ball.position)
        self.ball.outOfFieldPoint = Field.getIntersectPoint(flySegment, self.ball.position)

        if self.ball.outOfFieldPoint == nil or not Field.isInside(self.ball.outOfFieldPoint) then
            local p = vector2.clone(self.ball.position)
            p.y = math.clamp(p.y, -Field.halfLength, Field.halfLength)
            p.x = math.clamp(p.x, -Field.halfWidth, Field.halfWidth)
            self.ball.outOfFieldPoint = p
        end

        local lastTouchBallAthlete = self.ball.lastTouchAthlete
        if math.cmpf(self.ball.outOfFieldPoint.y, Field.halfLength) == 0 or math.cmpf(self.ball.outOfFieldPoint.y, -Field.halfLength) == 0 then
            log.info("LastTouchBallAthlete: Team=%s, OnFieldId=%d", lastTouchBallAthlete.team.name, lastTouchBallAthlete.onfieldId)

            if math.cmpf(self.ball.outOfFieldPoint.y, lastTouchBallAthlete.team.goal.center.y) == 0 then
                if Field.isInGoal(self.ball.outOfFieldPoint) and not (self.ball.isFree and self.ball.flyType == "High") then
                    self.ballOutResetType = BallOutResetType.OwnGoal
                else
                    self.ballOutResetType = BallOutResetType.CornerKick
                end
            else
                self.ballOutResetType = BallOutResetType.GoalKick
            end
        elseif math.cmpf(self.ball.outOfFieldPoint.x, Field.halfWidth) == 0 or math.cmpf(self.ball.outOfFieldPoint.x, -Field.halfWidth) == 0 then
            self.ballOutResetType = BallOutResetType.ThrowIn
        else
            log.error("logic cannot fall here!! Ball position: %s, Ball outOfFieldPoint: %s", self.ball.position, self.ball.outOfFieldPoint)
        end
    end
end

function Match:resetPositionAndDirectionOnBallOut()
    if not self.isInPenaltyShootOut then
        self:judgeSubstitution()
    end

    self.ball:setOwner(nil)

    if self.ballOutResetType == BallOutResetType.Goal then
        self.ball.lastTouchAthlete:goal()
        self:onGoal()
        self.isGoal = false
    else
        --点球大战踢飞或被扑飞后进行下一轮点球判断
        if self.isInPenaltyShootOut then
            self:judgePenaltyShootOutKick()
        else
            local lastTouchBallAthlete = self.ball.lastTouchAthlete
            lastTouchBallAthlete.team:clearTeamManualOperate()
            if lastTouchBallAthlete.team:isAttackRole() then
                self:switchRole()
            end

            if self.ballOutResetType == BallOutResetType.OwnGoal then
                self:ownGoal()
            elseif self.ballOutResetType == BallOutResetType.CornerKick then
                self:changeState("CornerKick")
            elseif self.ballOutResetType == BallOutResetType.GoalKick then
                self:changeState("GoalKick")
            elseif self.ballOutResetType == BallOutResetType.ThrowIn then
                self:changeState("ThrowIn")
            end
        end
    end

    self.events.ballOutOfField:trigger()
end

function Match:initPenaltyShootOutResultsQueue()
    self.attackTeam:initTeamPenaltyShootOutResultsQueue()
    self.defenseTeam:initTeamPenaltyShootOutResultsQueue()
end

function Match:updatePenaltyShootOutResultsQueue()
    if self.playerTeam.shootOutAttempts == self.opponentTeam.shootOutAttempts and self.playerTeam.shootOutAttempts >= 5 then
        self.playerTeam:updateTeamPenaltyShootOutResultsQueue()
        self.opponentTeam:updateTeamPenaltyShootOutResultsQueue()
    end
end

function Match:ownGoal()
    self:onGoal()
end

function Match:onGoal()
    self.attackTeam:onGoal()
    self.defenseTeam:onGoal()

    self:updateScoreState()

    --点球大战进球后进行下一轮点球判断
    if self.isInPenaltyShootOut then
        self:judgePenaltyShootOutKick()
        return
    end

    self:switchRole(true)
    self:changeState("TimedKickOff")
end

function Match:updateScoreState()
    if self.playerTeam.score > self.opponentTeam.score then
        self.scoreState = AIConstants.matchScoreState.PLAYERLEAD
        self.playerTeam.scoreState = AIConstants.teamScoreState.LEAD
        self.opponentTeam.scoreState = AIConstants.teamScoreState.LAG
    elseif self.opponentTeam.score > self.playerTeam.score then
        self.scoreState = AIConstants.matchScoreState.PLYAERLAG
        self.playerTeam.scoreState = AIConstants.teamScoreState.LAG
        self.opponentTeam.scoreState = AIConstants.teamScoreState.LEAD
    else
        self.scoreState = AIConstants.matchScoreState.DRAW
        self.playerTeam.scoreState = AIConstants.teamScoreState.DRAW
        self.opponentTeam.scoreState = AIConstants.teamScoreState.DRAW
    end
end

function Match:judgeSubstitution()
    if next(self.substitutionQueue) then
        self:changeState("Substitution")
    end
end

function Match:isDraw()
    if self.hasPreviousMatch then
        return self.playerTeam.score + self.playerTeam.previousScore == self.opponentTeam.score + self.opponentTeam.previousScore and
        self.playerTeam.score == self.opponentTeam.previousScore
    else
        return self.playerTeam.score == self.opponentTeam.score
    end
end

function Match:judgeBeforeSwitchRoleSkills()
    -- 禁区烽火台Ex1
    local defendGk = self.defenseTeam.athleteOfRole[26]
    defendGk:judgePenaltyBoxSignalFireTurretEx1()
end

function Match:judgeAfterSwitchRoleSkills()
    self.playerTeam:judgeAfterSwitchRoleSkills()
    self.opponentTeam:judgeAfterSwitchRoleSkills()
end

function Match:judgeAfterGoalSkills()
    --自信心
    --炮台
    if self.shootAthleteForAfterShootSkills then
        self.shootAthleteForAfterShootSkills:judgeSelfConfidence()
        self.shootAthleteForAfterShootSkills:judgeSoulFluctuationOnGoal()
        self.shootAthleteForAfterShootSkills:judgeBattery()
        self.shootAthleteForAfterShootSkills:judgeLegendaryNO7()
        self.shootAthletePosition = nil
        self.shootAthleteForAfterShootSkills = nil
    end
    --助攻王
    if self.attackAssister then
        self.attackAssister:judgeTopAssister()
        self.attackAssister:judgeGoldenWolfGuti()
        self.attackAssister = nil
    end
    self.attackTeam:judgeAfterLosePointSkills()
    self.defenseTeam:judgeAfterGoalSkills()

    if not self.hasFirstGoal then
        self:setTheFirstGoalInformation()
        self.attackTeam:judgeSpurWithLongAccumulationWithoutFirstGoal()
        self.defenseTeam:judgeSpurWithLongAccumulationWithFirstGoal()
    end
end

function Match:judgeAfterShootMissSkills()
    if self.shootAthleteForAfterShootSkills then
        self.shootAthleteForAfterShootSkills:judgeSoulFluctuationOnShootMiss()
        self.shootAthleteForAfterShootSkills = nil
    end
end

function Match:setTheFirstGoalInformation()
    if self.playerTeam.score + self.opponentTeam.score == 1 then
        self.attackTeam.isFirstGoalTeam = false
        self.defenseTeam.isFirstGoalTeam = true
        self.hasFirstGoal = true
    end
end

function Match:getStageEndTime(stage)
    if stage == self.FIRST_HALF_STAGE then
        return self.totalTime / 2 + self.firstHalfStoppageTime + self.firstHalfDeltaTime
    elseif stage == self.SECOND_HALF_STAGE then
        return self.totalTime + self.firstHalfStoppageTime + self.secondHalfStoppageTime +
            self.firstHalfDeltaTime + self.secondHalfDeltaTime
    elseif stage == self.FIRST_OVERTIME_STAGE then
        return self:getStageEndTime(self.SECOND_HALF_STAGE) + self.overTime / 2 + self.firstOvertimeDeltaTime
    else
        return self:getStageEndTime(self.SECOND_HALF_STAGE) + self.overTime + self.firstOvertimeDeltaTime +
            self.secondOverTimeDeltaTime
    end
end

function Match:isOverStageTime(stage)
    return 0 <= math.cmpf(self:getNextActualTime(), self:getStageEndTime(stage))
end

function Match:getDisplayTime()
    local displayTime = self.actualTime * 0.5
    if self:isStageEnded(self.SECOND_OVERTIME_STAGE) then
        return 120
    elseif self:isStageEnded(self.FIRST_OVERTIME_STAGE) then
        return math.min(120, displayTime)
    elseif self:isStageEnded(self.SECOND_HALF_STAGE) then
        return math.min(105, displayTime)
    elseif self:isStageEnded(self.FIRST_HALF_STAGE) then
        return math.min(90, displayTime)
    else
        return math.min(45, displayTime)
    end
end

function Match:getActualDisplayTime()
    local displayTime = (self.actualTime - self.displayTimeOffset + timeBeforeKickOut) * 0.5
    if self:isStageEnded(self.SECOND_OVERTIME_STAGE) then
        return 120
    elseif self:isStageEnded(self.FIRST_OVERTIME_STAGE) then
        return math.min(120, displayTime)
    elseif self:isStageEnded(self.SECOND_HALF_STAGE) then
        return math.min(105, displayTime)
    elseif self:isStageEnded(self.FIRST_HALF_STAGE) then
        return math.min(90, displayTime)
    else
        return math.min(45, displayTime)
    end
end

function Match:checkCanBeEndedNow()
    if self.frozenType == "CornerKick" or self.frozenType == "WingDirectFreeKick" or
        self.frozenType == "ThrowIn" or self.frozenType == "IndirectFreeKick" then
        return
    end

    local transformedBallPositionY = self.ball.position.y * -self.attackTeam:getSign()
    if 0 <= math.cmpf(transformedBallPositionY, 25) then
        return
    end

    if self.attackTeam.inManualOperating then
        return
    end

    for i = self.FIRST_HALF_STAGE, self.SECOND_OVERTIME_STAGE do
        if not self:isStageEnded(i) and self:isOverStageTime(i) then
            self.canBeEndedNow = true
            break
        end
    end
end

function Match:canStageEnded(stage)
    --如果半场可以正常结束，或者比赛时间>=正常结束时间+15min，则结算半场
    if not self:isStageEnded(stage) then
        if not self:cannotBeEndedNow()
            and ((self.canBeEndedNow and self:isOverStageTime(stage))
            or 0 <= math.cmpf(self:getNextActualTime() - self:getStageEndTime(stage), 30)) then
            return true
        end
    end
    return false
end

function Match:isStageEnded(stage)
    return stage < self.stage and true or false
end

function Match:canPenaltyShootOutBeEnded()
    --5轮点球内若某一队剩余点球次数小于与敌方比分的差，则比赛结束
    if self.playerTeam.shootOutAttempts <= 5 and self.opponentTeam.shootOutAttempts <= 5 then
        if (5 - self.playerTeam.shootOutAttempts < self.opponentTeam.shootOutScore - self.playerTeam.shootOutScore)
            or (5 - self.opponentTeam.shootOutAttempts < self.playerTeam.shootOutScore - self.opponentTeam.shootOutScore) then
            return true
        end

    --5轮外两队都踢完后判断比赛结果，若轮数已超过33轮或两队比分不一致，则比赛结束
    elseif self.playerTeam.shootOutAttempts == self.opponentTeam.shootOutAttempts
        and self.playerTeam.shootOutScore ~= self.opponentTeam.shootOutScore then
        return true
    end

    return false
end

function Match:judgePenaltyShootOutKick()
    if self:canPenaltyShootOutBeEnded() then
        self:changeState("GameOver")
        return true
    else
        --如果点球后未转换过攻守角色，则转换攻守角色
        if self.lastPenaltyShootOutTeam.role == self.attackTeam.role then
            self:switchRole()
        end

        self:switchField()

        self:updatePenaltyShootOutResultsQueue()

        self:changeState("PenaltyShootOutKick")
        return true
    end
end

function Match:judgeMatchTimeStage()
    local t = self:getNextActualTime()

    if self.questCondition then
        local questCondition = self.questCondition
        local scoreGap = self.playerTeam.score - self.opponentTeam.score
        if questCondition.winGap and questCondition.winGap == scoreGap
            or questCondition.loseGap and questCondition.loseGap == scoreGap
            or questCondition.winGoal and questCondition.winGoal == self.playerTeam.score
            or questCondition.loseGoal and questCondition.loseGoal == self.opponentTeam.score
        then
            self.gameOverTime = self:getDisplayTime()
            self:changeState("GameOver")
            return true
        end
    end

    if self:canStageEnded(self.FIRST_HALF_STAGE) then
        self.stage = self.SECOND_HALF_STAGE
        self.firstHalfDeltaTime = t - self:getStageEndTime(self.FIRST_HALF_STAGE)
        self.displayTimeOffset = self.displayTimeOffset + self.firstHalfStoppageTime + self.firstHalfDeltaTime
        self.displayStoppageTime = self.secondHalfStoppageTime
        self:halfTimeSwitch()
        self:changeState("NontimedKickOff")
        return true
    end

    if self:canStageEnded(self.SECOND_HALF_STAGE) then
        self.secondHalfDeltaTime = t - self:getStageEndTime(self.SECOND_HALF_STAGE)
        self.displayTimeOffset = self.displayTimeOffset + self.secondHalfStoppageTime + self.secondHalfDeltaTime
        self.displayStoppageTime = 0
        if self.hasOverTime and self:isDraw() then
            self.stage = self.FIRST_OVERTIME_STAGE
            self:resetField()
            self.kickOffTeam = self.playerTeam
            self.nonKickOffTeam = self.opponentTeam
            self:changeState("NontimedKickOff")
        elseif self.hasPenaltyShootOut and self:isDraw() then
            self:enterPenaltyShootOut()
            self:changeState("PenaltyShootOutKick")
        else
            self.stage = self.GAME_OVER_STAGE
            self:changeState("GameOver")
        end
        return true
    end

    if self.hasOverTime and self:canStageEnded(self.FIRST_OVERTIME_STAGE) then
        self.stage = self.SECOND_OVERTIME_STAGE
        self.firstOvertimeDeltaTime = t - self:getStageEndTime(self.FIRST_OVERTIME_STAGE)
        self.displayTimeOffset = self.displayTimeOffset + self.firstOvertimeDeltaTime
        self.kickOffTeam, self.nonKickOffTeam = self.nonKickOffTeam, self.kickOffTeam
        self:changeState("NontimedKickOff")
        return true
    end

    if self.hasOverTime and self:canStageEnded(self.SECOND_OVERTIME_STAGE) then
        self.secondOverTimeDeltaTime = t - self:getStageEndTime(self.SECOND_OVERTIME_STAGE)
        if self.hasPenaltyShootOut and self:isDraw() then
            self:enterPenaltyShootOut()
            self:changeState("PenaltyShootOutKick")
        else
            self.stage = self.GAME_OVER_STAGE
            self:changeState("GameOver")
        end
        return true
    end

    return false
end

function Match:resetAthleteEffectiveSkills()
    for _, athlete in self:allAthletes() do
        local effectiveSkillInstances = {}
        for _, skillInstance in ipairs(athlete.skills) do
            if table.isArrayInclude(AIUtils.penaltyShootOutEffectiveSkillIds, skillInstance.id) then
                table.insert(effectiveSkillInstances, skillInstance)
            end
        end
        athlete.skills = effectiveSkillInstances
    end
end

function Match:enterPenaltyShootOut()
    self.stage = self.PENALTY_SHOOTOUT_STAGE

    self:resetAthletesStates()

    self:resetAthleteEffectiveSkills()

    --计算罚点球出场顺序
    self.playerTeam:calcRankedPenaltyShootOutAthletes()
    self.opponentTeam:calcRankedPenaltyShootOutAthletes()

    self.isInPenaltyShootOut = true

    --随机选择先罚点球的队伍
    if math.cmpf(math.random(), 0.5) < 0 then
        self:switchRole()
    end

    --随机选择罚点球场地
    if math.cmpf(math.random(), 0.5) < 0 then
        self:switchField()
    end

    if math.cmpf(math.random(), 0.5) < 0 then
        self.playerTeam.penaltyShootOutXsign = 1
        self.opponentTeam.penaltyShootOutXsign = -1
    else
        self.playerTeam.penaltyShootOutXsign = -1
        self.opponentTeam.penaltyShootOutXsign = 1
    end

    self:initPenaltyShootOutResultsQueue()
end

function Match:halfTimeSwitch()
    self.kickOffTeam, self.nonKickOffTeam = self.nonKickOffTeam, self.kickOffTeam
    self.attackTeam, self.defenseTeam = self.kickOffTeam, self.nonKickOffTeam
    self:switchField()
end

function Match:switchField()
    self.playerTeam.field, self.opponentTeam.field = self.opponentTeam.field, self.playerTeam.field
    self.playerTeam.goal, self.opponentTeam.goal = self.opponentTeam.goal, self.playerTeam.goal
end

function Match:resetField()
    self.playerTeam.goal = Field.goals.north
    self.playerTeam.field = "north"
    self.opponentTeam.goal = Field.goals.south
    self.opponentTeam.field = "south"
end

function Match:unfreeze(excludeAttackAthletes, excludeDefendAthletes)
    for i, attackAthlete in ipairs(self.attackTeam.athletes) do
        if not table.isArrayInclude(excludeAttackAthletes, attackAthlete) then
            attackAthlete:stopAnimation()
        end
    end

    local wallAthletes = { }

    if self.frozenType == "WingDirectFreeKick" then
        wallAthletes = self.defenseTeam.wingDirectFreeKickWall
    elseif self.frozenType == "CenterDirectFreeKick" then
        wallAthletes = self.defenseTeam.centerDirectFreeKickWall
    end

    for i, defendAthlete in ipairs(self.defenseTeam.athletes) do
        if not table.isArrayInclude(excludeDefendAthletes, defendAthlete) then
            defendAthlete:stopAnimation()

            if table.isArrayInclude(wallAthletes, defendAthlete) then
                local animationList = Animations.Tag.Wall
                local animation = selector.randomSelect(animationList)

                defendAthlete:pushAnimation(animation, nil, defendAthlete.bodyDirection, true)
            end
        end
    end

    self.isFrozen = false
    self.frozenType = "Init"
end

function Match:changeState(stateName)
    if stateName ~= "NormalPlayOn" then
        self.ball.nextTask = nil
        self.isGoal = false
        self.playerTeam:clearTeamManualOperate()
        self.playerTeam.latestPassAthlete = nil
        self.opponentTeam.latestPassAthlete = nil
        self.playerTeam.continuousCatchPassCount = 0
        self.opponentTeam.continuousCatchPassCount = 0
        self.playerTeam.isStolenInOwnArea = false
        self.opponentTeam.isStolenInOwnArea = false
        self.playerTeam.isStealOrIntercept = nil
        self.opponentTeam.isStealOrIntercept = nil

        for i, athlete in self:allAthletes() do
            if athlete.behaviorTree ~= nil then
                athlete:stopAnimation(true)
                athlete:logDebug("stop athlete %d, change match state", athlete.id)
            end
            -- 当比赛状态切换时，清除掉球员上次做的动作
            athlete.currentAnimation = nil
            athlete.animationQueue = {}
            athlete.outputActionStatus = nil
            athlete.willBeOffside = nil
            athlete.isOffsideCatch = nil
            athlete.chosenDPSAction = nil
            athlete.catchType = nil
            athlete.isHeavyGunner = nil
            athlete.isCalmShoot = nil
            athlete.toBeCastedSkills = { }
            athlete.dribbleState = {
                startPosition = nil,
                lastDecideTime = nil,
                stealAthlete = nil,
                foulAthlete = nil
            }
            athlete:setMoveStatus(0)
            athlete:resetMoveStatusRemainingTime()
            athlete.graspBall = nil
            athlete.isInterceptOrStealBallNoCounterAttack = nil
            athlete.breakThroughDefendInfo = nil
            athlete.shouldHeadingDual = nil
            athlete:setMark(nil)
            athlete:setCover(nil)
        end
    end

    if self.state ~= nil then
        self.state:Exit()
    end

    self.state = self.states[stateName]
    self.state:Enter()

    log.info("%.1f enter match state: %s", self.currentTime, stateName)

    self.eventHint = EventHintMap[stateName]
    if self.eventHandler then
        self.eventHandler(self.eventHint)
    end
end

function Match:allAthletes()
    return function(_, i)
        i = i + 1
        if i >= 1 and i <= 11 then
            return i, self.attackTeam.athletes[i]
        end
        if i >= 12 and i <= 22 then
            return i, self.defenseTeam.athletes[i - 11]
        end
        return nil, nil
    end, nil, 0
end

function Match:getPassAthleteWithoutBall()
    if not self.ballOutOfField then
        for i, athlete in self:allAthletes() do
            if athlete:isAnimationEnd(athlete.match.nextTime)
                and (athlete.catchType == AIUtils.catchType.CatchPass
                    or athlete.catchType == AIUtils.catchType.CatchCrossPass
                    or athlete.catchType == AIUtils.catchType.InterceptCatchPass) then
                return athlete
            end
        end
    end

    return nil
end

function Match:getNextActualTime()
    return self.actualTime + TIME_STEP
end

function Match:applyTactics(tactics)
    print("Apply tactics!")

    assert(tactics.attackEmphasis)
    assert(tactics.attackMentality)
    assert(tactics.defenseMentality)
    assert(tactics.passTactic)
    assert(tactics.attackRhythm)

    self.playerTeam.tactics = tactics
    return true
end

function Match:applyFormation(operation)
    local isExpected = nil

    if operation.formation and operation.roles then
        print("Apply formation!")

        if operation.captain then
            self.playerTeam.captain = operation.captain
        end
        if operation.cornerKicker then
            self.playerTeam.cornerKicker = operation.cornerKicker
        end
        if operation.freeKickShooter then
            self.playerTeam.freeKickShooter = operation.freeKickShooter
        end
        if operation.freeKickPasser then
            self.playerTeam.freeKickPasser = operation.freeKickPasser
        end
        if operation.penaltyKicker then
            self.playerTeam.penaltyKicker = operation.penaltyKicker
        end

        self.playerTeam.formation = operation.formation
        self.playerTeam:substitute(operation.roles)

        isExpected = true
    end

    return isExpected
end

function Match:applyShoot(shoot)
    local isExpected = nil
    for i, athlete in ipairs(self.playerTeam.athletes) do
        if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "ShootPause" then
            print("Apply shoot!")
            isExpected = true
            local target = shoot.target
            athlete.chosenDPSAction = athlete:evaluateShoot(vector2.new(target.x, target.y), shoot.targetH, shoot.control, shoot.duration, shoot.isHigh)
        end
    end
    return isExpected
end

function Match:applyManual(manual)
    local manualOperateType = manual.type
    local targetOnfieldId = manual.targetOnfieldId
    local directionIndex = manual.directionIndex
    local isExpected = nil

    for i, athlete in ipairs(self.playerTeam.athletes) do
        if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "ManualOperate" then
            print("Apply manual operate!")
            isExpected = true

            athlete.manualOperateType = manualOperateType
            if manualOperateType == 1 and targetOnfieldId then
                athlete:manualPass(targetOnfieldId)
            elseif manualOperateType == 2 and directionIndex then
                athlete:manualDribble(directionIndex)
            elseif manualOperateType == 3 then
                athlete:manualShoot()
            elseif manualOperateType ~= 0 then
                isExpected = false
            end

            break
        end
    end

    return isExpected
end

function Match:applyOperation(operation)
    local isExpected = nil
    if operation.tactics then
        isExpected = self:applyTactics(operation.tactics) or isExpected
    end
    if self.state.name ~= "NormalPlayOn" then
        isExpected = self:applyFormation(operation) or isExpected
    end
    if operation.shoot then
        isExpected = self:applyShoot(operation.shoot) or isExpected
    end
    if operation.manual then
        isExpected = self:applyManual(operation.manual) or isExpected
    end
    return isExpected
end

function Match:getIndirectFreeKickOffAthlete()
    if Field.isInPenaltyArea(self.indirectFreeKickPosition, -self.attackTeam:getSign()) then
        self.indirectFreeKickPosition = vector2.new(math.clamp(self.indirectFreeKickPosition.x, -5, 5), self.indirectFreeKickPosition.y)
        return self.attackTeam.athleteOfRole[26]
    end

    local minSqrDistance = math.huge
    local indirectFreeKickOffAthlete = nil

    local minSqrDistanceM = math.huge
    local minSqrDistanceMAthlete = nil

    for i, athlete in ipairs(self.attackTeam.athletes) do
        if athlete:isBack() then
            local sqrdist = vector2.sqrdist(athlete.position, self.indirectFreeKickPosition)
            if math.cmpf(minSqrDistance, sqrdist) > 0 then
                minSqrDistance = sqrdist
                indirectFreeKickOffAthlete = athlete
            end
        elseif athlete:isMidfield() then
            local sqrdist = vector2.sqrdist(athlete.position, self.indirectFreeKickPosition)
            if math.cmpf(minSqrDistanceM, sqrdist) > 0 then
                minSqrDistanceM = sqrdist
                minSqrDistanceMAthlete = athlete
            end
        end
    end
    return indirectFreeKickOffAthlete or minSqrDistanceMAthlete
end

function Match:notIsInStealCD()
    return not self.stealCoolDownTime or math.cmpf(self.stealCoolDownTime, 0) <= 0
end

return Match
