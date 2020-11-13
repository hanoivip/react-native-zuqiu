if jit then jit.off(true, true) end

local selector = import("../libs/selector")
local vector2 = import("../libs/vector")

local AIUtils = import("../AIUtils")
local Actions = import("../actions/Actions")
local Ball = import("../Ball")
local Field = import("../Field")
local Behavior = import("../Behavior")
local Tactics = import("../Tactics")
local Animations = import("../animations/Animations")
local Skills = import("../skills/Skills")

local Athlete = class()

function Athlete:ctor()
    self.LOG_ONFIELD_ID = 2
    self.logEnabled = false

    self.name = "untitled_athlete"
    self.id = 1  -- unique id for all athletes, start from 1
    self.onfieldId = nil  --  1~11: player athletes on field; 12~22: opponenet athletes on field; other: substitute
    self.number = 1
    self.team = nil
    self.enemyTeam = nil
    self.match = nil
    self.abilities = {
        defendFastSpeed = { forward = 7.2, side = 3, back = 3 },
        defendCoverSpeed = { forward = 2, side = 1.5, back = 1.5 },
        shootAngleLimit = math.pi / 3,
        isBlockedDisabled = false,
    }
    self.initAbilities = {
        dribble = 0,
        intercept = 0,
        pass = 0,
        save = 0,
        shoot = 0,
        steal = 0,
        anticipation = 0,
        commanding = 0,
        composure = 0,
        launching = 0,
    }
    self.maxInitAbility = 0
    self.initAbilitiesSum = 0
    self.role = 26
    self.mainRole = "gk"
    self.isSideAthlete = false
    self.score = 0
    self.graspBall = nil
    self.position = vector2.clone(vector2.zero)
    self.bodyDirection = vector2.clone(vector2.forward)
    self.direction = vector2.clone(vector2.forward)
    self.targetPosition = vector2.new(1, 1)
    self.closing = nil
    self.closedBy = nil
    self.fillingIn = nil
    self.filledInBy = nil
    self.marking = nil
    self.markedBy = { }
    self.covering = nil
    self.coveredBy = { }
    self.area = {
        center = vector2.clone(vector2.zero),
        minX = 0,
        maxX = 0,
        minY = 0,
        maxY = 0,
    }
    self.adeptRole = nil
    self.upComingAction = nil
    self.behaviorTree = nil
    self.candidateDribbleActions = nil
    self.candidatePassActions = nil
    self.candidateShootActions = nil
    self.candidateEnemiesForBreakThrough = nil
    self.lastShootAction = nil -- Record shoot info for goal
    self.chosenDPSAction = nil
    self.outputActionStatus = nil
    self.dribbleState = {
        startPosition = nil,
        lastDecideTime = nil,
        stealAthlete = nil,
        foulAthlete = nil
    }

    self.skills = {}
    self.outputSkills = {}
    self.buffs = {}

    self.catchType = nil

    self.isCalmShoot = nil
    self.isHeavyGunner = nil
    self.willBeOffside = nil
    self.isOffsideCatch = nil

    self.toBeCastedSkills = {}

    self.isEncounteringSlidingTackle = nil
    self.isInterceptOrStealBallNoCounterAttack = nil
    self.selectedIntercept = nil
    self.isEntryModifierExecuted = false
    self.breakThroughSkillTime = nil
    self.shouldBlock = nil
    self.blockEnemy = nil
    self.shouldStagger = nil
    self.staggerAnimationName = nil
    self.staggerStartBodyDirection = nil
    self.moveStatus = 0
    self.moveStatusRemainingTime = {
        runningForward = 0,
        offTheBall = 0,
    }
    self.heavyGunnerEx1BuffCount = 0
    self.lastMoveDirection = nil
    self.focusType = nil -- 1 <= focusType <= 100: 球员id, 101: ball, 102: player gate, 103: opponent gate
    self.passSkillId = nil
    self.passSkillId2 = nil

    self.kickOffPassTarget = nil

    self.currentAnimation = nil
    self.animationQueue = {}

    self.realPassInfo = nil

    self.throughBallAction = nil
    self.overHeadBallAction = nil
    self.crossLowAction = nil

    self.manualDribbleList = nil
    self.manualPassList = nil
    self.manualOperateShootEnabledSkillId = nil
    self.manualOperateAction = nil
    self.isManualFollowedDribble = nil
    self.manualOperateSkillId = nil
    self.manualOperateSuccessProbability = nil
    self.manualPassAnimation = nil

    self.breakThroughDefendInfo = nil

    self.outputStartBuffs = {}
    self.outputEndBuffs = {}

    -- Debug Info, will be remove when released
    self.drawLines = nil
    self.debugLines = nil
    self.debugText = nil
    -- End

    self.selectedSkillId = nil
    self.isStealFail = false
    self.blackHeartCount = 0
    self.sambaIronFenceCount = 0
end

local cmpf = math.cmpf
local max = math.max
local min = math.min

function Athlete:getDistanceYToOffsideLine(position)
    return self.team:getSign() * (position.y - self.team.offsideLine)
end

function Athlete:isInOffSideArea()
    return cmpf(self:getDistanceYToOffsideLine(self.position), 0) < 0
end

function Athlete:getDistanceToEnemyBottomLine()
    return self.position.y * self.team:getSign() + Field.halfLength
end

local function decideDistanceType(athlete)
    local distanceToEnemyBottomLine = athlete:getDistanceToEnemyBottomLine()
    if cmpf(vector2.sqrdist(athlete.position, athlete.enemyTeam.goal.center + vector2.new(0, athlete.enemyTeam:getSign() * 18.8)), 50.8 ^ 2) >= 0 then
        return "DeltaY"
    elseif cmpf(distanceToEnemyBottomLine, 0) >= 0 then
        return "Euclid"
    else
        return "Invalid"
    end
end

function Athlete:calcAttackDistance(position, referencePosition)
    local referencePosition = referencePosition or self.enemyTeam.goal.center

    local distanceType = decideDistanceType(self)
    if distanceType == "DeltaY" then
        return position.y * self.team:getSign() + Field.halfLength
    elseif distanceType == "Euclid" then
        return vector2.dist(position, referencePosition)
    else
        return 0
    end
end

function Athlete:calcAttackAngle(position, bodyDirection)
    local distanceType = decideDistanceType(self)
    if distanceType == "DeltaY" then
        return vector2.angle(bodyDirection, vector2.new(0, -self.team:getSign()))
    end

    return 0
end

function Athlete:randomlySelectCuttingAction()
    local candidateCuttingDribbleActions = { }
    for _, dribbleAction in ipairs(self.candidateDribbleActions) do
        if dribbleAction.key.isCutting then
            table.insert(candidateCuttingDribbleActions, dribbleAction.key)
        end
    end

    if #candidateCuttingDribbleActions > 1 then
        self.chosenDPSAction = selector.randomSelect(candidateCuttingDribbleActions)
    end
end

function Athlete:DPSChoose()
    self.chosenDPSAction = self:getHighestScoreActionAndScore()

    if self.chosenDPSAction.isCutting then
        self:randomlySelectCuttingAction()
    end
end

function Athlete:DPSAdjust()
    if self.chosenDPSAction.name == "Pass" then
        if not self:hasAppropriatePassAnimation() then
            self:choosePassAdjustAction()
        elseif self.chosenDPSAction.isCrossLow then
            local lastAnimationType
            if self.currentAnimation then
                lastAnimationType = self.currentAnimation.type
            end

            local toTargetPositionVector = vector2.norm(self.chosenDPSAction.targetPosition - self.position)
            if lastAnimationType ~= "CrossLowAdjust" and lastAnimationType ~= "BreakThrough" and lastAnimationType ~= "ManualOperateDribble"
                and self:hasNonGkEnemyAthleteInFront(toTargetPositionVector, 3, math.pi / 2) then
                self:chooseCrossLowAdjustAction()
            end
        end
    elseif self.chosenDPSAction.name == "Shoot" then
        if not self:getIsPreferCutting() then
            local lastAnimationType
            if self.currentAnimation then
                lastAnimationType = self.currentAnimation.type
            end

            local toEnemyGoalVector = vector2.norm(self.enemyTeam.goal.center - self.position)
            if lastAnimationType ~= "ShootAdjust" and lastAnimationType ~= "TurnAdjust"
                and self:hasNonGkEnemyAthleteInFront(toEnemyGoalVector, 10, math.pi / 2)
                and math.cmpf(vector2.angle(self.bodyDirection, toEnemyGoalVector), math.pi / 2) < 0 then
                self:chooseShootAdjustAction()
            end
        end
    elseif not self.chosenDPSAction.isCutting then
        local lastAnimationType
        if self.currentAnimation then
            lastAnimationType = self.currentAnimation.type
        end

        local toEnemyGoalVector = vector2.norm(self.enemyTeam.goal.center - self.position)
        if lastAnimationType ~= "TurnAdjust"
            and Field.isInEnemyArea(self.position, self.team:getSign())
            and self:hasEnemyAthleteInFront(toEnemyGoalVector, 12.5, math.pi / 2)
            and math.cmpf(vector2.angle(self.bodyDirection, toEnemyGoalVector), math.pi / 2) < 0 then
            self:chooseTurnAdjustAction()
        end
    end
end

-- 选择最高分的Action和分数
function Athlete:getHighestScoreActionAndScore()
    local candidateActions = { }
    table.imerge(candidateActions, self.candidateDribbleActions)
    table.imerge(candidateActions, self.candidatePassActions)
    table.imerge(candidateActions, self.candidateShootActions)

    local chosenDPSAction, score = selector.max(candidateActions)

    return chosenDPSAction, score
end

-- 选择最高分的n个Action和分数
function Athlete:getNHighestScoreActionAndScore(n)
    local candidateActions = { }
    table.imerge(candidateActions, self.candidateDribbleActions)
    table.imerge(candidateActions, self.candidatePassActions)
    table.imerge(candidateActions, self.candidateShootActions)

    return selector.maxn(candidateActions, n, function(action) return action.weight end)
end

function Athlete:catchMoveTo(targetPosition, towardPosition, speed, movePriority)
    local adjustedSpeed = nil
    if speed then
        adjustedSpeed = min(10, speed)
    end

    local towardDirection = towardPosition - self.position

    if self.match.ball.nextTask.isLeadPass then
        self:smoothMoveTo(targetPosition, towardDirection, adjustedSpeed)
    else
        self:moveTo(targetPosition, towardDirection, adjustedSpeed, nil, movePriority)
    end
end

function Athlete:selectCatchAnimation()
    local ballNextTask = self.match.ball.nextTask

    local isIntercept = ballNextTask.class == Ball.PassAndIntercept
    local isLeadPass = ballNextTask.isLeadPass
    if isIntercept then
        isLeadPass = false
        ballNextTask.passer:judgeThroughBallEx1(ballNextTask.interceptor, ballNextTask.skillId)
        ballNextTask.passer:judgeOverHeadBallEx1(ballNextTask.interceptor, ballNextTask.skillId)
    else
        self:judgeCorePlayMakerEx1(ballNextTask.passer)
        if ballNextTask.skillId == Skills.PuntKickEx1.id then
            ballNextTask.passer:judgePuntKickEx1()
        end
        if ballNextTask.skillId2 == Skills.LongPassDispatch.id or ballNextTask.skillId2 == Skills.LongPassDispatchEx1.id then
            ballNextTask.passer:judgeLongPassDispatchCatcherEffect(self)
        end
        self:judgeGracefulArcsEx1("Catch")
        ballNextTask.passer:judgeGracefulArcsEx1("Pass")
    end

    self:judgeFoxInTheBoxEx1(ballNextTask.skillId)
    self:judgePowerfulHeaderEx1(ballNextTask.skillId)
    self:judgeVolleyShootEx1(ballNextTask.skillId)

    if isLeadPass then
        local targetPosition = ballNextTask.receiverArrivePosition

        local sign = self.team:getSign()
        local passType = ballNextTask.type

        local isHighPassToShoot = (Field.isInVolleyShootArea(targetPosition, sign) and passType == "High")
            or (Field.isHeaderArea(targetPosition, sign) and passType == "High")

        if not isHighPassToShoot then
            local towardPosition = (Field.isInForceShootArea(targetPosition, sign) or (self.position.y * -sign >= 30 and math.abs(self.position.x) <= 20)) and self.enemyTeam.goal.center
                or vector2.new(self.position.x, self.enemyTeam.goal.center.y)

            local anticipatedBodyDirection = towardPosition - targetPosition
            local angle = vector2.sangle(self.bodyDirection, anticipatedBodyDirection)
            local actualAngle = math.sign(angle) * math.min(math.abs(angle), math.pi / 6)
            self.bodyDirection = vector2.rotate(self.bodyDirection, actualAngle)
            self.direction = clone(self.bodyDirection)
        end
    end

    self:selectBestCatchAnimation(self.match.ball.flyType, isLeadPass, isIntercept)
    self:judgeRomanWarSpirit(false)
end

function Athlete:catch()
    local catchAnimation = self.match.ball.nextTask.catchAnimation
    self.match.ball.nextTask.receiveTime = self.match.ball.nextTask.receiveTime + catchAnimation.animation.firstTouch * TIME_STEP - TIME_STEP
    self.animationQueue = {}
    self:pushAnimationWithType(catchAnimation.animation, true, nil, nil, catchAnimation.type)

    self:setMoveStatus(0)
    self.isOffsideCatch = self.willBeOffside
    self.dribbleSuccessProbability = 1
end

function Athlete:updateOutputCatchActionStatus()
    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        self.outputActionStatus = Actions.Catch.new()
    end
end

function Athlete:intercept()
    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        local interceptAction = Actions.Action.new()
        interceptAction.name = "Intercept"
        self.outputActionStatus = interceptAction
    end

    self:castPlannedSkills()
    self:judgeAllAroundFighter("intercept")

    local task = self.match.ball.nextTask
    task.receiver.willBeOffside = nil
    task.receiver.catchType = nil

    self.team.interceptTimes = self.team.interceptTimes + 1

    self.isInterceptOrStealBallNoCounterAttack = true
    self.team.isStealOrIntercept = true
end

function Athlete:startSteal()
    -- Update outputActionStatus for status output
    self.isStealFail = false
    if self.outputActionStatus == nil then
        local stealAction = Actions.Action.new()
        stealAction.name = "Steal"
        self.outputActionStatus = stealAction
    end

    self:castPlannedSkills()

    local nextTask = self.match.ball.nextTask
    local stealAnimation = nextTask.stealAnimation

    self:pushAnimation(stealAnimation.animation, true, stealAnimation.startBodyDirection)
    self.enemyTeam.isStolenInOwnArea = Field.isInEnemyArea(self.match.ball.position, self.team:getSign())

    local stealTargetAthlete = nextTask.stealTargetAthlete
    if stealTargetAthlete ~= nil then
        stealTargetAthlete:judgeWindChasingBoy(self)
    end

    self:logInfo("start steal, animationName = " .. stealAnimation.animation.name)
end

function Athlete:startFoul()
    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        local foulAction = Actions.Action.new()
        foulAction.name = "Foul"
        self.outputActionStatus = foulAction
    end

    local nextTask = self.match.ball.nextTask
    local foulAnimation = nextTask.foulAnimation

    self:pushAnimation(foulAnimation.animation, true, foulAnimation.startBodyDirection)

    self:logInfo("start foul, animationName = " .. foulAnimation.animation.name)
end

function Athlete:judgeCounterRunningForward()
    if Field.isInForceCounterAttackArea(self.position, self.team:getSign())
     or selector.tossCoin(Tactics.attackRhythm["counterAttackProb"][self.team.tactics.attackRhythm]) then
        self:counterRunningForward()
        self.isInterceptOrStealBallNoCounterAttack = nil
    end
end

function Athlete:counterRunningForward()
    for _, friend in ipairs(self.team.athletes) do
        if friend ~= self and (friend:isForward() or friend:isMidfield()) then
            friend:setMoveStatus(AIUtils.moveStatus.counterRunningForward)
        end
    end
end

function Athlete:steal()
    local ball = self.match.ball
    local task = ball.nextTask

    local owner = ball.owner
    self:logAssert(owner ~= nil, "R U kidding me, where is the ball owner?")

    local stolenAnimation = task.isDiving and selector.randomSelect(Animations.Tag.Diving) or selector.randomSelect(Animations.Tag.Stumble)
    owner:stopAnimation(true)
    owner:pushAnimation(stolenAnimation, nil, nil, true)

    ball:setOwner(nil)

    self:logInfo("stop athlete %d, play stolen animation %s", owner.id, stolenAnimation.name)

    self.team.stealTimes = self.team.stealTimes + 1

    self.isInterceptOrStealBallNoCounterAttack = true
    self.team.isStealOrIntercept = true
    self:judgeCounterRunningForward()
    if task.hasGamesmanshipDebuff then
        self:judgeFiercelyDogfightEx1()
    end
    self:judgeAllAroundFighter("steal")
    self.match.stealCoolDownTime = 3
end

function Athlete:foul()
    local ball = self.match.ball
    local task = ball.nextTask

    self.match.foulOnfieldId = self.onfieldId

    local owner = ball.owner
    self:logAssert(owner ~= nil, "R U kidding me, where is the ball owner?")

    local fallAnimation = task.isDiving and selector.randomSelect(Animations.Tag.Diving) or selector.randomSelect(Animations.Tag.Fall)
    owner:stopAnimation(true)
    owner:pushAnimation(fallAnimation, nil, nil, true)

    self:logInfo("stop athlete %d, play fall animation %s", owner.id, fallAnimation.name)

    self.team.foulTimes = self.team.foulTimes + 1

    self.match.noNeedJudgeBallOutOfField = true

    ball:freeFly(self.match.currentTime, ball.position, 6, AIUtils.getDeceleration("Ground"), owner.bodyDirection, "Ground")
end

function Athlete:updateArea()
    local ball = self.match.ball
    local ballPosition = ball.owner and ball.position or ball.flyTargetPosition
    local sign = self.team:getSign()
    local role = self.team:isAttackRole() and "attack" or "defense"
    local areaDefinition = Field.formations[self.team.formation]["athletes"][self.role][role].area

    local areaCenter = areaDefinition.relativeCenter(ballPosition.x * sign, ballPosition.y * sign, 0) * sign

    local centerLimitX = areaDefinition.centerLimit.x
    local xLimitMin = centerLimitX.min(ballPosition.x * sign, ballPosition.y * sign, 0) * sign
    local xLimitMax = centerLimitX.max(ballPosition.x * sign, ballPosition.y * sign, 0) * sign
    xLimitMin, xLimitMax = min(xLimitMin, xLimitMax), max(xLimitMin, xLimitMax)

    local centerLimitY = areaDefinition.centerLimit.y
    local yLimitMin = centerLimitY.min(ballPosition.x * sign, ballPosition.y * sign, 0) * sign
    local yLimitMax = centerLimitY.max(ballPosition.x * sign, ballPosition.y * sign, 0) * sign
    yLimitMin, yLimitMax = min(yLimitMin, yLimitMax), max(yLimitMin, yLimitMax)

    areaCenter.x = math.clamp(areaCenter.x, xLimitMin, xLimitMax)
    areaCenter.y = math.clamp(areaCenter.y, yLimitMin, yLimitMax)

    if not self:isGoalkeeper() then
        local competitionMentality = self.team:isAttackRole() and self.team.tactics.attackMentality or self.team.tactics.defenseMentality
        local mentalityFactor = Tactics.competitionMentality[role][math.ceil(self.role / 5)][competitionMentality]
        local referencePosition = Tactics.competitionMentality["referencePosition"][competitionMentality] == "enemy"
            and self.enemyTeam.goal.center or self.team.goal.center

        local posY = referencePosition.y + (areaCenter.y - referencePosition.y) * mentalityFactor
        posY = math.sign(posY) * min(Field.halfLength, math.abs(posY))
        areaCenter.y = posY

        if self:isBack() and not self.isSideAthlete and (self.team.dcCount <= 1 or self.team.bestAttackDc ~= self) then
            areaCenter.y = max(sign * posY, 0) * sign
        end
    end

    local areaSize = areaDefinition.size
    self.area.center = areaCenter
    self.area.minX = areaCenter.x - areaSize.x / 2
    self.area.maxX = areaCenter.x + areaSize.x / 2
    self.area.minY = areaCenter.y - areaSize.y / 2
    self.area.maxY = areaCenter.y + areaSize.y / 2
end

function Athlete:findAthletesInCircle(circleCenter, team, radius, includeSelf)
    local athlete = self
    return function(_, i)
        repeat
            i = i + 1
            if i <= #team.athletes then
                if (includeSelf or team.athletes[i] ~= athlete) and AIUtils.isInCircle(team.athletes[i].position, { center = circleCenter, radius = radius } ) then
                    return i, team.athletes[i]
                end
            end
        until i > #team.athletes
    end, nil, 0
end

function Athlete:updateMoveStatusRemainingTime()
    for k, remainingTime in pairs(self.moveStatusRemainingTime) do
        self.moveStatusRemainingTime[k] = max(0, remainingTime - TIME_STEP)
    end
end

function Athlete:resetMoveStatusRemainingTime()
    for k, remainingTime in pairs(self.moveStatusRemainingTime) do
        self.moveStatusRemainingTime[k] = 0
    end
end

function Athlete:update()
    self:updateBuffAndSkillRemainingTime()
    self:updateMoveStatusRemainingTime()
    Behavior:run(self, self.behaviorTree)
end

function Athlete:clearOutput()
    self.outputActionStatus = nil
    self.drawLines = nil
    self.debugLines = nil
    self.debugText = nil
    self.interceptRate = nil
    self.stealRate = nil
    self.influenceRate = nil
    self.saveRate = nil

    if #self.outputStartBuffs > 0 then
        self.outputStartBuffs = {}
    end
    if #self.outputEndBuffs > 0 then
        self.outputEndBuffs = {}
    end
    if #self.outputSkills > 0 then
        self.outputSkills = {}
    end
end

function Athlete:goal()
    if not self.match.isInPenaltyShootOut then
        self.score = self.score + 1
    end

    local event = {
        time = self.match:getDisplayTime(),
        type = "Goal",
        striker = self.id,
        strikerPos = self.role,
        reason = self.lastShootAction.reason,
        skill = self.lastShootAction.skill,
        touch = self.lastShootAction.isHeader and "Head",
    }
    local ball = self.match.ball
    if ball.preTouchAthlete ~= nil and ball.preTouchAthlete ~= self and ball.preTouchAthlete.team == self.team then
        event.assister = ball.preTouchAthlete.id
        event.assisterPos = ball.preTouchAthlete.role
        self.match.attackAssister = ball.preTouchAthlete
    end
    table.insert(self.team.event, event)

    for _, enemy in ipairs(self.enemyTeam.athletes) do
        enemy:removeBuffs(Skills.ImpactWave, "base")
    end
end

function Athlete:canBeInterruptible()
    return #self.animationQueue == 0 or not self.animationQueue[1].uninterruptible
end

function Athlete:stopAnimation(isForced)
    if isForced or self:canBeInterruptible() then
        self.animationQueue = {}
        Behavior:stopRunning(self.behaviorTree)
    end
end

function Athlete:stopEnemyGkAnimation()
    self.enemyTeam.athleteOfRole[26]:stopAnimation()
end

--[[
    @param hasBall 是否有球动作
    @param bodyDirection 强掰动作开始时的身体朝向，默认值nil
    @param uninterruptible 是否强制不可打断，例如被铲倒时，慎用
]]
function Athlete:pushAnimation(animationInfo, hasBall, startBodyDirection, uninterruptible, disableTransition)
    self:logAssert(animationInfo ~= nil, "animationInfo is nil")

    local item = {
        animationInfo = animationInfo,
        hasBall = hasBall,
        startBodyDirection = startBodyDirection,
        uninterruptible = uninterruptible,
        disableTransition = disableTransition,
    }

    return self:pushAnimationRaw(item)
end

function Athlete:pushAnimationEx(animationInfo, hasBall, startBodyDirection, uninterruptible, isAutoMotion, originalAngleDiff, remainAngleDiff, animationAngle, speed, moveType)
    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
        self:logInfo('pushAnimation ' .. animationInfo.name .. ', speed: ' .. tostring(speed))
    end

    self:logAssert(animationInfo ~= nil, "animationInfo is nil")

    local item = {
        animationInfo = animationInfo,
        hasBall = hasBall,
        startBodyDirection = startBodyDirection,
        uninterruptible = uninterruptible,
        isAutoMotion = isAutoMotion,
        originalAngleDiff = originalAngleDiff,
        remainAngleDiff = remainAngleDiff,
        animationAngle = animationAngle,
        speed = speed,
        moveType = moveType,
    }

    return self:pushAnimationRaw(item)
end

function Athlete:pushAnimationWithType(animationInfo, hasBall, startBodyDirection, uninterruptible, type)
    self:logAssert(animationInfo, "animationInfo is nil")
    self:logAssert(type, "type is nil")

    local item = {
        animationInfo = animationInfo,
        hasBall = hasBall,
        startBodyDirection = startBodyDirection,
        uninterruptible = uninterruptible,
        type = type,
    }

    return self:pushAnimationRaw(item)
end

function Athlete:pushAnimationRaw(item)
    self:logAssert(item.animationInfo, "unexpected argument")

    local animationInfo = item.animationInfo

    local startTime
    local startPosition
    local startBodyDirection = item.startBodyDirection

    if #self.animationQueue == 0 then
        startTime = self.match.currentTime
        startPosition = self.position
        startBodyDirection = startBodyDirection or self.bodyDirection
    else
        local last = self.animationQueue[#self.animationQueue]
        startTime = last.startTime + last.animationInfo.time
        startPosition = last.startPosition + vector2.vyrotate(last.animationInfo.targetPosition, last.startBodyDirection)
        startBodyDirection = startBodyDirection or vector2.rotate(last.startBodyDirection, last.animationInfo.targetRotation)
    end

    item.startTime = startTime
    item.startPosition = startPosition
    if self.currentAnimation and not self.currentAnimation.disableTransition and not item.isAutoMotion then
        local position, rotation = Animations.calcTransitionTarget(self.currentAnimation.animationInfo, animationInfo, self)
        item.targetPosition = startPosition + vector2.vyrotate(position, startBodyDirection)
        item.targetBodyDirection = vector2.rotate(startBodyDirection, rotation)
    else
        item.targetPosition = startPosition + vector2.vyrotate(animationInfo.targetPosition, startBodyDirection)
        item.targetBodyDirection = vector2.rotate(startBodyDirection, animationInfo.targetRotation)
    end

    if not item.startBodyDirection then
        item.startBodyDirection = startBodyDirection
    end

    table.insert(self.animationQueue, item)

    return item
end

function Athlete:getNextAnimationList(animationType)
    if self.currentAnimation and Animations.Next[self.currentAnimation.animationInfo.name] then
         return Animations.Next[self.currentAnimation.animationInfo.name][animationType]
    end

    return nil
end

function Athlete:getFilteredAnimationList(animationType, filter, forceUseTag, forceUseNext)
    local filteredAnimationList = {}

    local animationList

    if forceUseTag then
        animationList = Animations.Tag[animationType]
    else
        animationList = self:getNextAnimationList(animationType)

        if not animationList then
           animationList = forceUseNext and { } or Animations.Tag[animationType]
        end
    end

    for i, animation in ipairs(animationList) do
        if filter == nil or filter(animation) then
            table.insert(filteredAnimationList, animation)
        end
    end

    return filteredAnimationList, animationList
end

function Athlete:selectAndPushAnimation(animationType, filter, hasBall, forceUseTag)
    local selectedAnimation = self:selectAnimation(animationType, filter, forceUseTag)

    self:logAssert(selectedAnimation, "Can't find " .. animationType .. " animation")
    self:logInfo("[" .. selectedAnimation.name .. "] is selected")

    self:pushAnimation(selectedAnimation, hasBall)
end

function Athlete:selectAnimation(animationType, filter, forceUseTag)
    local filteredAnimationList, animationList = self:getFilteredAnimationList(animationType, filter, forceUseTag)
    local selectedAnimation = #filteredAnimationList == 0 and selector.randomSelect(animationList) or selector.randomSelect(filteredAnimationList)

    return selectedAnimation
end

function Athlete:selectAndPushPassAnimationByTargetPosition(animationType, targetPosition, hasBall)
    local selectedAnimation = nil
    if self.manualPassAnimation then
        selectedAnimation = self.manualPassAnimation
        self.manualPassAnimation = nil
    else
        selectedAnimation = self:selectPassAnimationByTargetPosition(animationType, targetPosition)
    end

    self:logAssert(selectedAnimation, "Can't find " .. animationType .. " animation")
    self:logInfo("[" .. selectedAnimation.name .. "] is selected")

    self:pushAnimation(selectedAnimation, hasBall)
end

function Athlete:selectPassAnimationByTargetPosition(animationType, targetPosition)
    return self:selectAnimation(animationType, function (animation)
        local rawData = Animations.RawData[animation.name]
        local sangle = vector2.sangle(self.bodyDirection, vector2.norm(targetPosition - self.position))
        local ballOutPosition = self.position + vector2.vyrotate(animation.firstTouchBallPosition, self.bodyDirection)
        return (rawData.outAngle == nil or Animations.isInAngleRange(rawData.outAngle.Start, rawData.outAngle.End, sangle)) and Field.isInside(ballOutPosition)
    end)
end

function Athlete:canEndAnimationAtCurrentPositionAndTime(currentAnimation, nextTime)
    local squareDistance = vector2.sqrdist(self.targetPosition, self.position)
    if currentAnimation.isAutoMotion and cmpf(squareDistance, 0.01) < 0 and
        self:isNonTurnAnimation(currentAnimation.moveType) and
        not self:isStayAnimationName(currentAnimation.animationInfo.name) then
        --原地动作不用打断，否则会频繁地被打断
        return true
    end
    return false
end

function Athlete:isAnimationEnd(nextTime)
    if #self.animationQueue == 0 then
        return true
    end
    if #self.animationQueue > 1 then
        return false
    end
    local currentAnimation = self.animationQueue[1]

    if self:canEndAnimationAtCurrentPositionAndTime(currentAnimation, nextTime) then
        return true
    end
    local leftTime = currentAnimation.animationInfo.time - (nextTime - currentAnimation.startTime)
    if cmpf(leftTime, 0) > 0 then
        -- 这个动作还没做完
        return false
    elseif cmpf(leftTime, 0) == 0 then
        -- 做完了
        return true
    else
        -- 动作已经做完了，并且做过了，正常逻辑是不应该走到这里的
        self:logError("Animation has finished, should not be here! leftTime=" .. leftTime)
        return true
    end
end

-- 判断当前动作是否做到出球帧
function Athlete:isBallOut(nextTime)
    local currentAnimation = self.animationQueue[1]
    local leftTime = currentAnimation.animationInfo.lastTouch * TIME_STEP - (nextTime - currentAnimation.startTime)
    if cmpf(leftTime, 0) == 0 then
        self:logInfo("lastTouch frame, ball out")
        return true
    else
        return false
    end
end

-- 判断当前位置朝特定方向扇形区域是否有对方球员
function Athlete:hasEnemyAthleteInFront(direction, radius, angle)
    for i, enemy in ipairs(self.enemyTeam.athletes) do
        if AIUtils.isInSector(enemy.position, self.position, direction, radius, angle) then
            return true
        end
    end

    return false
end

-- 判断当前位置朝特定方向扇形区域是否有对方球员
function Athlete:hasNonGkEnemyAthleteInFront(direction, radius, angle)
    for i, enemy in ipairs(self.enemyTeam.athletes) do
        if enemy.role ~= 26 and AIUtils.isInSector(enemy.position, self.position, direction, radius, angle) then
            return true
        end
    end

    return false
end

-- 查找当前位置朝特定方向扇形区域的对方球员
function Athlete:findEnemyAthletesInFront(direction, radius, angle, prepareTime)
    local athletes = {}
    for i, enemy in ipairs(self.enemyTeam.athletes) do
        local basePosition = enemy.position
        if prepareTime and enemy.lastMoveDirection and enemy.currentAnimation and enemy.currentAnimation.speed then
            basePosition = enemy.position + enemy.lastMoveDirection * (enemy.currentAnimation.speed * prepareTime)
        end

        if AIUtils.isInSector(basePosition, self.position, direction, radius, angle) then
            table.insert(athletes, enemy)
        end
    end

    return athletes
end

function Athlete:findEnemyAthletesInCircle(circleCenter, radius)
    local athletes = {}
    for i, enemy in self:findAthletesInCircle(circleCenter, self.enemyTeam, radius, false) do
        table.insert(athletes, enemy)
    end

    return athletes
end

function Athlete:isForward()
    return self.mainRole == "f"
end

function Athlete:isMidfield()
    return self.mainRole == "m"
end

function Athlete:isBack()
    return self.mainRole == "b"
end
-- 进攻中场
function Athlete:isAttackMidField()
    return self.role == 7 or self.role == 8 or self.role == 9
end
-- 后腰
function Athlete:isDefensiveMidfield()
    return self.role == 17 or self.role == 18 or self.role == 19
end

function Athlete:isGoalkeeper()
    return self.role == 26
end

function Athlete:isSideF()
    return self:isLeftSideF() or self:isRightSideF()
end

function Athlete:isLeftSideF()
    return self.role == 1 or self.role == 6
end

function Athlete:isRightSideF()
    return self.role == 5 or self.role == 10
end

function Athlete:isLeftSideGuard()
    return self.role == 16 or self.role == 21
end

function Athlete:isRightSideGuard()
    return self.role == 20 or self.role == 25
end

function Athlete:isLeftSideMidField()
    return self.role == 11
end

function Athlete:isRightSideMidField()
    return self.role == 15
end

function Athlete:isCenterF()
    return self.role == 2 or self.role == 3 or self.role == 4
end

function Athlete:setMoveStatus(moveStatus)
    if moveStatus ~= self.moveStatus then
        if self.moveStatus ~= 0 then
            self.team.moveStatusCount[self.moveStatus] = self.team.moveStatusCount[self.moveStatus] - 1
        end

        self.moveStatus = moveStatus

        if moveStatus ~= 0 then
            self.team.moveStatusCount[moveStatus] = self.team.moveStatusCount[moveStatus] ~= nil
                and self.team.moveStatusCount[moveStatus] + 1 or 1
        end
    end
end

function Athlete:hasBall()
    return self.match.ball.owner == self
end

function Athlete:weightProbabilityArray(array)
    local sw = 0
    for i, v in ipairs(array) do
        sw = sw + v.probability
    end

    if math.cmpf(sw, 1) > 0 then
        for i, v in ipairs(array) do
            v.probability = v.probability / sw
        end
    end
end

return Athlete
