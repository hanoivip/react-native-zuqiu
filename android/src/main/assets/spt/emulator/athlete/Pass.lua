if jit then jit.off(true, true) end

local Athlete = import("./Core")
local Actions = import("../actions/Actions")
local AIUtils = import("../AIUtils")
local Ball = import("../Ball")
local Field = import("../Field")
local Tactics = import("../Tactics")
local selector = import("../libs/selector")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local Skills = import("../skills/Skills")

local FieldShrinkDelta = 1
local minPassDistance = 7.5
local highCrossPassDistance = 15
local highNormalPassDistance = 25
local maxPassDistance = 50
local evaluatedPassPrepareTime = 0.4
local evaluatedCatchGroundPrepareTime = 0.4
local evaluatedCatchHighPrepareTime = 0.5
local evaluatedCatchHighHeaderPrepareTime = 0.6
local expectedLeadPassCatchMoveSpeed = 7
local expectedInterceptMoveSpeed = 7

local groundPassMaxAbsY = 50
local highPassMaxAbsY = 50

function Athlete:getCandidatePassTargets()
    local isAfterBreakThrough = false
    if self.currentAnimation then
        isAfterBreakThrough = self.currentAnimation.type == "BreakThrough"
    end

    local candidatePassTargets = {}

    local isCrossLow = Field.isInCrossLowArea(self.position, self.team:getSign())

    for i, attackAthlete in ipairs(self.team.athletes) do
        local passSqrDistance = vector2.sqrdist(attackAthlete.position, self.position)
        local isLeadPassMoveAttack = attackAthlete.moveStatus == AIUtils.moveStatus.runningForward
        or attackAthlete.moveStatus == AIUtils.moveStatus.runningForwardAfterPass
        or attackAthlete.moveStatus == AIUtils.moveStatus.counterRunningForward
        local minSqrDistToOffSideLine = (isCrossLow or not isLeadPassMoveAttack or math.cmpf(passSqrDistance, 15 ^ 2) <= 0)
            and 0 or math.clamp(0.004 * passSqrDistance + 0.1, 1, 2)
        if attackAthlete ~= self and math.cmpf(self:getDistanceYToOffsideLine(attackAthlete.position), minSqrDistToOffSideLine) >= 0 --不能传给越位位置球员
            then
            local bestPassTarget = self:selectBestPassTargetForOneAthlete(attackAthlete, nil, isAfterBreakThrough)

            if bestPassTarget then
                table.insert(candidatePassTargets, bestPassTarget)
            end
        end
    end

    return selector.maxn(candidatePassTargets, 3, function(t) return t.score end)
end

function Athlete:isNormalCrossLow(targetPosition)
    return Field.isInCrossLowArea(self.position, self.team:getSign())
        and Field.isInCrossLowReceiveArea(targetPosition, self.team:getSign())
        and math.cmpf(vector2.sqrdist(self.position, targetPosition), highCrossPassDistance ^ 2) >= 0
end

--目标接到球或者球飞行了2s以上，判越位
function Athlete:judgeOffside(targetAthlete, offsideDist)
    local sign = targetAthlete.team:getSign()
    if math.cmpf(targetAthlete:getDistanceYToOffsideLine(targetAthlete.position), -offsideDist) < 0 and math.cmpf(sign * (targetAthlete.position.y - self.position.y), 0) < 0 then
        targetAthlete.willBeOffside = true
        return true
    end
    return false
end

function Athlete:executeOffside()
    --目标接到球或者球飞行了2s以上，判越位
    --如果传球中途被截断，不算越位
    self.match:switchRole()
    self.match.foulOnfieldId = self.onfieldId
    self.match.indirectFreeKickPosition = self.position
    self.match.indirectFreeKickOffAthlete = self.match:getIndirectFreeKickOffAthlete()
    self.match.breakReason = "Offside"
    self.match:changeState("IndirectFreeKick")
end

function Athlete:calculatePass()
    local candidateTargets = self:getCandidatePassTargets()
    local candidateActions = {}

    for i, target in ipairs(candidateTargets) do
        local passAction = Actions.Pass.new()
        passAction.targetAthlete = target.targetAthlete
        passAction.targetPosition = target.targetPosition
        passAction.type = target.type
        passAction.isLeadPass = target.isLeadPass
        passAction.isCrossLow = target.isCrossLow
        table.insert(candidateActions, {key = passAction, weight = target.score})
    end

    self.candidatePassActions = candidateActions
    self.isInterceptOrStealBallNoCounterAttack = nil
end

function Athlete:manualPass(targetAthleteOnfieldId)
    if self.manualPassList then
        for _, passInfo in ipairs(self.manualPassList) do
            if passInfo.onfieldId == targetAthleteOnfieldId then
                self.manualOperateSuccessProbability = passInfo.successProbability

                if passInfo.skillId then
                    self.manualOperateSkillId = passInfo.skillId

                    if AIUtils.isSkillIdCorrespondSkill(passInfo.skillId, Skills.ThroughBall) then
                        self:setThroughBallAction(self.team.athletes[targetAthleteOnfieldId], passInfo.targetPosition, passInfo.type, passInfo.isLeadPass)
                    elseif AIUtils.isSkillIdCorrespondSkill(passInfo.skillId, Skills.OverHeadBall) then
                        self:setOverHeadBallAction(self.team.athletes[targetAthleteOnfieldId], passInfo.targetPosition, passInfo.type, passInfo.isLeadPass)
                    else
                        self:setCrossLowAction(self.team.athletes[targetAthleteOnfieldId], passInfo.targetPosition, passInfo.type, passInfo.isLeadPass)
                    end
                else
                    self:setPassAction(self.team.athletes[targetAthleteOnfieldId], passInfo.targetPosition, passInfo.type, passInfo.isLeadPass, nil, passInfo.isCrossLow)
                end
                self.manualPassAnimation = passInfo.animation
            end
        end
    end
end

local maxSpeedConfig = {
    {minAngle = 0, maxAngle = math.pi / 4, maxSpeed = 8},
    {minAngle = math.pi / 4, maxAngle = 3 * math.pi / 5, maxSpeed = 6},
    {minAngle = 3 * math.pi / 5, maxAngle = 3 * math.pi / 4, maxSpeed = 3.5},
    {minAngle = 3 * math.pi / 4, maxAngle = math.pi, maxSpeed = 4.5},
}

local maxLeadPassBallSpeedConfig = {
    Ground = 20,
    High = 28,
}

local maxInterceptBallSpeedConfig = {
    Ground = 25,
    High = 30,
}

local function getEvaluatedCatchPrepareTime(passType, isInHeaderArea)
    return passType == "Ground" and evaluatedCatchGroundPrepareTime or (isInHeaderArea and evaluatedCatchHighHeaderPrepareTime or evaluatedCatchHighPrepareTime)
end

local function isSatisfyCatchMoveSpeed(passAthlete, targetAthlete, candidateTarget, passType)
    local targetPosition = candidateTarget.targetPosition

    local ballFlyPrediction = passAthlete.match.ball:predictFlyTo(passAthlete.match.currentTime, passAthlete.match.ball.position, AIUtils.getDeceleration(passType),
        targetPosition, passAthlete.match.ball:getPassSpeed(targetAthlete, targetPosition, passType, candidateTarget.isLeadPass), passType)
    local turnTime = candidateTarget.isLeadPass and targetAthlete:getCatchTurnTime(targetPosition) or targetAthlete:getCatchTurnTime(passAthlete.position)

    local moveDirection = vector2.norm(targetPosition - targetAthlete.position)
    local catchBodyDirection = candidateTarget.isLeadPass and moveDirection or vector2.norm(passAthlete.position - targetPosition)
    local moveAngle = vector2.angle(catchBodyDirection, moveDirection)

    local maxCatchSpeed
    for i, config in ipairs(maxSpeedConfig) do
        if math.cmpf(moveAngle, config.minAngle) >= 0 and math.cmpf(moveAngle, config.maxAngle) <= 0 then
            maxCatchSpeed = config.maxSpeed
            break
        end
    end

    local passPrepareDuration = evaluatedPassPrepareTime
    if #passAthlete.animationQueue ~= 0 and passAthlete.animationQueue[1].animationInfo.lastTouch then
        passPrepareDuration = passAthlete.animationQueue[1].animationInfo.lastTouch * TIME_STEP - TIME_STEP
    end

    local evaluatedCatchPrepareTime = getEvaluatedCatchPrepareTime(passType, Field.isHeaderArea(targetPosition, passAthlete.team:getSign()))

    local evaluatedCatchMoveTime = ballFlyPrediction.flyDuration - turnTime + passPrepareDuration - evaluatedCatchPrepareTime
    local catchMoveDist = vector2.dist(targetPosition, targetAthlete.position)

    local satisfyLeadPassMinTime = true
    if candidateTarget.isLeadPass then
        local minBallFlyDuration = passAthlete.match.ball:predictFlyTo(passAthlete.match.currentTime, passAthlete.match.ball.position, AIUtils.getDeceleration(passType),
            targetPosition, maxLeadPassBallSpeedConfig[passType], passType)

        local minCatchMoveTime = minBallFlyDuration.flyDuration - turnTime + passPrepareDuration - evaluatedCatchPrepareTime
        satisfyLeadPassMinTime = math.cmpf(minCatchMoveTime, math.roundWithMinStep(catchMoveDist / expectedLeadPassCatchMoveSpeed, TIME_STEP)) <= 0
    end

    return satisfyLeadPassMinTime and math.cmpf(evaluatedCatchMoveTime, math.roundWithMinStep(catchMoveDist / maxCatchSpeed, TIME_STEP)) >= 0
end

local function getEnemiesOnPassRoute(athlete, targetPosition, isInEnemyArea)
    return isInEnemyArea and athlete:findEnemyAthletesInFront(targetPosition - athlete.position, vector2.dist(athlete.position, targetPosition), math.pi / 6, 0.4)
        or athlete:findEnemyAthletesInFront(targetPosition - athlete.position, vector2.dist(athlete.position, targetPosition) * 1.2, math.pi / 3, 0.4)
end

local function getOffTheBallFactor(attackAthlete, targetPosition)
    local factor = 1
    if attackAthlete:isCenterF() then
        factor = 2
    end

    local powerfulHeaderSkill = attackAthlete:getCooldownSkill(Skills.PowerfulHeader)
    if powerfulHeaderSkill and Field.isHeaderArea(targetPosition, attackAthlete.team:getSign()) then
        factor = 10
    end
    return factor
end

function Athlete:selectBestPassTargetForOneAthlete(attackAthlete, isCrossLow, isAfterBreakThrough)
    local candidateTargetPositions = self:getCandidateTargetPositionsForOneAthlete(attackAthlete)
    local sign = self.team:getSign()
    local originalDistanceToBottomLine = self:calcAttackDistance(self.position)
    local isNotInCrossLowArea = not Field.isInCrossLowArea(self.position, sign)
    local isInEnemyArea = Field.isInEnemyArea(self.position, sign)

    local maxScore = -math.huge
    local bestPassTarget = nil

    for i, candidateTarget in ipairs(candidateTargetPositions) do
        local targetPosition = candidateTarget.targetPosition

        if not isCrossLow then
            isCrossLow = self:isNormalCrossLow(targetPosition)
        end

        local deltaX = math.abs(self.position.x - targetPosition.x)
        local deltaY = self.position.y * sign - targetPosition.y * sign
        local deltaY2 = (attackAthlete.position.y - targetPosition.y) * sign

        local passType = self:getPassType(isCrossLow, candidateTarget.isLeadPass, deltaX, deltaY,
            vector2.sqrdist(self.position, targetPosition), vector2.sqrdist(attackAthlete.position, targetPosition))

        local yLimit = passType == "High" and highPassMaxAbsY or groundPassMaxAbsY

        local enemiesInGroundPassRouteCount = passType == "Ground"
            and #getEnemiesOnPassRoute(self, targetPosition, isInEnemyArea) or 0

        if enemiesInGroundPassRouteCount > 0 and candidateTarget.isLeadPass
            and math.cmpf(vector2.sqrdist(self.position, targetPosition), 400) >= 0 then
            passType = "High"
        end

        local ballFlyPrediction = self.match.ball:predictFlyTo(self.match.currentTime, self.match.ball.position, AIUtils.getDeceleration(passType),
        targetPosition, self.match.ball:getPassSpeed(attackAthlete, targetPosition, passType, candidateTarget.isLeadPass), passType)

        local defensePressureScore = 1
        local hasNearerEnemy = false

        local offTheBallFactor = 1
        if isCrossLow and not self:getIsPreferCutting() then
            offTheBallFactor = getOffTheBallFactor(attackAthlete, targetPosition)
        else
            local catchDistance = vector2.dist(attackAthlete.position, targetPosition)
            for _, enemyAthlete in ipairs(self.enemyTeam.athletes) do
                local turnTime = 0.3

                local enemyAthleteDistToTargetPosition = vector2.dist(enemyAthlete.position, targetPosition)
                local isGoalkeeper = enemyAthlete:isGoalkeeper()
                if (candidateTarget.isLeadPass and isGoalkeeper and
                    math.cmpf(enemyAthleteDistToTargetPosition, catchDistance) < 0
                    and math.cmpf(enemyAthleteDistToTargetPosition, 9) <= 0)
                    or (not isGoalkeeper and math.cmpf(enemyAthleteDistToTargetPosition + AIUtils.leadPassDefenseDistance, catchDistance) < 0) then  --3米是转身时间所跑的距离
                    hasNearerEnemy = true
                end

                if math.cmpf(enemyAthleteDistToTargetPosition, (ballFlyPrediction.flyDuration + evaluatedPassPrepareTime - turnTime) * 7.5) <= 0 then
                    defensePressureScore = defensePressureScore * (1 - 1 / math.max(enemyAthleteDistToTargetPosition + 1, 2))
                end
            end
        end

        local passTacticFactor = 1
        local passSqrDist = vector2.sqrdist(self.position, targetPosition)
        if passType == "High" and not isCrossLow and math.cmpf(deltaY, deltaX * 0.75) > 0
            and math.cmpf(math.abs(self.position.y - self.enemyTeam.goal.center.y), 60) < 0 then
            passTacticFactor = attackAthlete:isForward()
                and Tactics.passTactic["HighToF"][self.team.tactics.passTactic]
                or Tactics.passTactic["HighToOthers"][self.team.tactics.passTactic]
        elseif math.cmpf(passSqrDist, 400) < 0 and Field.isInShortPassArea(self.position, sign) and Field.isInEnemyArea(targetPosition, sign) then
            passTacticFactor = Tactics.passTactic["GroundToOthers"][self.team.tactics.passTactic]
        end

        local attackEmphasisFactor = 1
        if math.cmpf(math.abs(self.position.y - self.enemyTeam.goal.center.y), 20) > 0 then
            if Field.isInSideReceiveArea(targetPosition, sign)
                and not Field.isInSideReceiveArea(self.position, sign) then
                if self.team.tactics.attackEmphasisDetail == 2
                    or (self.team.tactics.attackEmphasisDetail == 1 and Field.isInLeftCourtArea(targetPosition, sign))
                    or (self.team.tactics.attackEmphasisDetail == 3 and Field.isInRightCourtArea(targetPosition, sign)) then
                    attackEmphasisFactor = Tactics.attackEmphasis["sidePass"][self.team.tactics.attackEmphasis]
                end
            elseif math.cmpf(math.abs(targetPosition.x), 21) < 0 then
                attackEmphasisFactor = Tactics.attackEmphasis["centerPass"][self.team.tactics.attackEmphasis]
            end
        end

        local sideFReceiveFactor = 1
        if attackAthlete:isSideF() and not Field.isInSideFReceiveArea(targetPosition, sign) then
            sideFReceiveFactor = 0.5
        end

        local sideMFReceiveFactor = 1
        if attackAthlete:isSideMidFieldPreferRunningForward() and Field.isInSideMidFieldReceiveArea(targetPosition, sign) then
            sideMFReceiveFactor = 1.5
        end

        local score

        if hasNearerEnemy then --有离目标点更近的防守球员
            score = AIUtils.avoidanceScore.forbidden_has_nearer_enemy
        elseif (enemiesInGroundPassRouteCount > 0 and not candidateTarget.isLeadPass) then --倒脚传球线路上有人
            score = AIUtils.avoidanceScore.forbidden_has_enemy_in_pass_line
        elseif not isSatisfyCatchMoveSpeed(self, attackAthlete, candidateTarget, passType) then -- 不满足速度条件
            score = AIUtils.avoidanceScore.forbidden_speed_not_satisfied
        elseif math.cmpf(vector2.sqrdist(self.position, targetPosition), vector2.sqrdist(attackAthlete.position, targetPosition)) < 0 then --持球球员离目标点更近
            score = AIUtils.avoidanceScore.forbidden_ball_owner_nearer
        elseif math.cmpf(math.abs(targetPosition.y), yLimit) > 0 then --传球y值限制
            score = AIUtils.avoidanceScore.forbidden_y_limit
        elseif math.cmpf(vector2.sqrdist(self.position, targetPosition), minPassDistance ^ 2) < 0 then --不满足最短传球距离条件
            score = AIUtils.avoidanceScore.forbidden_min_pass_distance_not_satisfied
        elseif math.cmpf(vector2.sqrdist(self.position, targetPosition), maxPassDistance ^ 2) > 0 then --最大传球距离限制
            score = AIUtils.avoidanceScore.forbidden_max_pass_distance_not_satisfied
        elseif (math.cmpf(deltaX, 35) > 0 and math.cmpf(deltaY, deltaX * 0.4) < 0)--避免大范围横向长传球
            or not Field.isInsideEx(targetPosition, FieldShrinkDelta)--传球目标点应在界内
            or (isAfterBreakThrough and not isCrossLow and not Field.isInForceShootArea(targetPosition, sign) and math.cmpf(deltaY, 0) < 0) --避免过人后回传
            or (isCrossLow and (math.cmpf(deltaY2, 0) < 0))--传中不能往目标球员后面传
            or (math.cmpf(deltaY, deltaX * 0.3) < 0 and passType ~= "Ground"
            and not Field.isInVolleyShootArea(targetPosition, sign) and not Field.isHeaderArea(targetPosition, sign)) --避免稍短的横向长传
        then
            score = AIUtils.avoidanceScore.unreasonable
        else
            local distanceScore = 1
            local deltaDistance = originalDistanceToBottomLine - self:calcAttackDistance(targetPosition)
            if isNotInCrossLowArea and passType == "High" then
                distanceScore = math.min(0.05 * deltaDistance + 1, 1.4)
            else
                distanceScore = math.cmpf(vector2.sqrdist(self.position, self.enemyTeam.goal.center), 441) < 0
                    and 0.1 * deltaDistance + 1
                    or 0.05 * deltaDistance + 1
            end

            local dpsFactor = 1
            local targetAthleteInitAbilities = attackAthlete.initAbilities
            if attackAthlete:isCenterF() and math.cmpf(targetPosition.y * -sign, 35) < 0 then
                dpsFactor = math.clamp((3 / 2 * (targetAthleteInitAbilities.pass + targetAthleteInitAbilities.dribble)
                    / (targetAthleteInitAbilities.pass + targetAthleteInitAbilities.dribble + targetAthleteInitAbilities.shoot)), 0.75, 1)
            end

            local isAfterInterceptOrStealPass = self.isInterceptOrStealBallNoCounterAttack and math.cmpf(passSqrDist, 225) < 0
                and self:hasAppropriatePassAnimationCore(targetPosition, self:getPassAnimationTypeCore(targetPosition, passType))

            if isAfterInterceptOrStealPass then
                score = attackEmphasisFactor * passTacticFactor * defensePressureScore * dpsFactor * offTheBallFactor * sideFReceiveFactor * sideMFReceiveFactor
            else
                score = distanceScore * attackEmphasisFactor * passTacticFactor * defensePressureScore * dpsFactor * offTheBallFactor * sideFReceiveFactor * sideMFReceiveFactor
            end

            if enemiesInGroundPassRouteCount == 0 and passType == "Ground" and Field.isInRollingArea(self.position, sign) then
                score = score * Tactics.attackRhythm["rolling"][self.team.tactics.attackRhythm]
            end

            if isAfterInterceptOrStealPass then
                score = score * 100
            end
        end

        local candidatePassTarget = {targetAthlete = attackAthlete, targetPosition = targetPosition, type = passType, isLeadPass = candidateTarget.isLeadPass, isCrossLow = isCrossLow, score = score}

        if math.cmpf(score, maxScore) > 0 then
            maxScore = score
            bestPassTarget = candidatePassTarget
        end
    end

    return bestPassTarget
end

local function hasSideLeadPassTargetPosition(passer, targetAthlete)
    local sign = passer.team:getSign()
    return math.cmpf(-sign * targetAthlete.position.y, -sign * passer.position.y) >= 0 and math.cmpf(math.abs(targetAthlete.position.x), 20) > 0
end

function Athlete:getLeadPassDirection(targetAthlete, perfectDirection)
    return AIUtils.getBestDirection(perfectDirection, AIUtils.getLeadPassForbiddenDirectionRanges(self, targetAthlete.position))
end

function Athlete:getCandidateTargetPositionsForOneAthlete(targetAthlete, isThroughBall, isOverheadBallOrPuntKick)
    local candidateTargetPositions = {}
    local targetAthleteMoveDirection = vector2.norm(targetAthlete.targetPosition - targetAthlete.position)
    local bestLeadPassDirection

    if targetAthlete.moveStatus == AIUtils.moveStatus.runningForward
        or targetAthlete.moveStatus == AIUtils.moveStatus.runningForwardAfterPass
        or targetAthlete.moveStatus == AIUtils.moveStatus.counterRunningForward then
        bestLeadPassDirection = self:getLeadPassDirection(targetAthlete, targetAthleteMoveDirection)
        if bestLeadPassDirection ~= nil then
            for i = 5, 30, 2.5 do
                table.insert(candidateTargetPositions, {targetPosition = targetAthlete.position + bestLeadPassDirection * i, isLeadPass = true})
            end
        end
    elseif isThroughBall or isOverheadBallOrPuntKick then
        if isThroughBall then
            local leadPassTargetPosition = vector2.new((self.position.x + targetAthlete.position.x) / 2, -self.team:getSign() * 46)
            bestLeadPassDirection = vector2.norm(leadPassTargetPosition - targetAthlete.position)
        else
            bestLeadPassDirection = vector2.norm(self.enemyTeam.goal.center - targetAthlete.position)
        end

        for i = 5, 30, 2.5 do
            table.insert(candidateTargetPositions, {targetPosition = targetAthlete.position + bestLeadPassDirection * i, isLeadPass = true})
        end
    elseif targetAthlete.moveStatus == AIUtils.moveStatus.offTheBall then
        bestLeadPassDirection = self:getLeadPassDirection(targetAthlete, targetAthleteMoveDirection)
        if bestLeadPassDirection ~= nil then
            for i = 2.5, 20, 2.5 do
                table.insert(candidateTargetPositions, {targetPosition = targetAthlete.position + bestLeadPassDirection * i, isLeadPass = true})
            end
        end
    end

    if targetAthlete.isSideAthlete and targetAthlete.mainRole ~= "b" then
        bestLeadPassDirection = vector2.new(0, -self.team:getSign())
        for i = 5, 30, 2.5 do
            table.insert(candidateTargetPositions, {targetPosition = targetAthlete.position + bestLeadPassDirection * i, isLeadPass = true})
        end
    end

    for i = 0, 10, 2.5 do
        table.insert(candidateTargetPositions, {targetPosition = targetAthlete.position + targetAthleteMoveDirection * i, isLeadPass = false})
    end
    for i = 2.5, 10, 2.5 do
        table.insert(candidateTargetPositions, {targetPosition = targetAthlete.position + vector2.norm(self.position - targetAthlete.position) * i, isLeadPass = false})
    end
    for i = 2.5, 10, 2.5 do
        table.insert(candidateTargetPositions, {targetPosition = targetAthlete.position + vector2.norm(self.enemyTeam.goal.center - targetAthlete.position) * i, isLeadPass = false})
    end

    return candidateTargetPositions
end

function Athlete:getPassType(isCrossLow, isLeadPass, deltaX, deltaY, passSqrDist, leadPassSqrDist)
    if isCrossLow then
        return "High"
    elseif isLeadPass and math.cmpf(deltaY, deltaX * 0.5) >= 0 then
        return math.cmpf(passSqrDist, Tactics.passTactic["HighLeadPassDist"][self.team.tactics.passTactic] ^ 2) >= 0
            and "High" or "Ground"
    end

    return math.cmpf(passSqrDist, highNormalPassDistance ^ 2) >= 0 and "High" or "Ground"
end

function Athlete:getPassAnimationTypeCore(targetPosition, passType, isManualOperate)
    if passType == "High" then
         if Field.isInCrossLowArea(self.position, self.team:getSign()) then
            return "CrossPass"
         else
            return math.cmpf(vector2.sqrdist(self.position, targetPosition), 40 ^ 2) >= 0 and "HighPassLong" or "HighPassShort"
         end
    end

    return isManualOperate and (math.cmpf(vector2.sqrdist(self.position, targetPosition), 15 ^ 2) >= 0 and "ManualOperatePassLong" or "ManualOperatePassShort")
        or (math.cmpf(vector2.sqrdist(self.position, targetPosition), 7 ^ 2) >= 0 and "PassLong" or "PassShort")
end

function Athlete:getPassAnimationType()
    return self:getPassAnimationTypeCore(self.chosenDPSAction.targetPosition, self.chosenDPSAction.type)
end

function Athlete:selectPassAnimation()
    self:selectAndPushPassAnimationByTargetPosition(self:getPassAnimationType(), self.chosenDPSAction.targetPosition, true)
end

function Athlete:hasAppropriatePassAnimationCore(targetPosition, passAnimationType, isThroughBallOrOverheadBall)
    local forceUseNext = true
    if isThroughBallOrOverheadBall then
        forceUseNext = false
    end

    local filteredPassAnimations = self:getFilteredAnimationList(passAnimationType, function(animation)
        local rawData = Animations.RawData[animation.name]
        local sangle = vector2.sangle(self.bodyDirection, vector2.norm(targetPosition - self.position))
        local ballOutPosition = self.position + vector2.vyrotate(animation.firstTouchBallPosition, self.bodyDirection)
        return (rawData.outAngle == nil or Animations.isInAngleRange(rawData.outAngle.Start, rawData.outAngle.End, sangle)) and Field.isInside(ballOutPosition)
    end, false, forceUseNext)

    return #filteredPassAnimations ~= 0
end

function Athlete:hasAppropriatePassAnimation(isThroughBallOrOverheadBall)
    return self:hasAppropriatePassAnimationCore(self.chosenDPSAction.targetPosition, self:getPassAnimationType(), isThroughBallOrOverheadBall)
end

function Athlete:getNormalPassSpeed(targetPosition, passStartBallPosition, isHeaderPass, isIntercept)
    local ballSpeed
    if isHeaderPass then
        local passDist = vector2.dist(passStartBallPosition, targetPosition)
        if self.catchType == AIUtils.catchType.CatchPass then
            ballSpeed = math.clamp(0.8 * passDist, 8, 12)
        else
            ballSpeed = math.clamp(0.4 * passDist, 6, 10)
        end
    else
        ballSpeed = self.match.ball:getPassSpeed(self, targetPosition, self.chosenDPSAction.type, self.chosenDPSAction.isLeadPass)
    end

    if self.graspBall then
        ballSpeed = math.clamp(0.25 * vector2.dist(passStartBallPosition, targetPosition) + 6, 10, 15)
    end

    return ballSpeed
end

function Athlete:getIsLeadPassAndExpectedCatchMoveSpeed(isIntercept)
    local isLeadPass, expectedCatchMoveSpeed
    if not isIntercept then
        isLeadPass = self.chosenDPSAction.isLeadPass
        if isLeadPass then
            expectedCatchMoveSpeed = expectedLeadPassCatchMoveSpeed
        end
    else
        expectedCatchMoveSpeed = expectedInterceptMoveSpeed
    end

    return isLeadPass, expectedCatchMoveSpeed
end

function Athlete:calcCatchAnimation(targetPosition, targetAthlete, isIntercept)
    local passAnimation = self.animationQueue[1].animationInfo
    local passPrepareDuration = passAnimation.lastTouch * TIME_STEP - TIME_STEP
    local passStartTime = self.match.currentTime + passPrepareDuration
    local passStartBallPosition = self.position + vector2.vyrotate(passAnimation.lastTouchBallPosition, self.bodyDirection)
    local isHeaderPass = (self.catchType == AIUtils.catchType.CatchPass
        or self.catchType == AIUtils.catchType.InterceptCatchPass)
        and self.chosenDPSAction.type == "High"
    local isInHeaderArea = Field.isHeaderArea(targetPosition, self.team:getSign())
    local isHeaderCrossLow = self.chosenDPSAction.isCrossLow and isInHeaderArea

    local isLeadPass, expectedCatchMoveSpeed = self:getIsLeadPassAndExpectedCatchMoveSpeed(isIntercept)

    local ball = self.match.ball
    local ballSpeed
    if self.match.frozenType == "ThrowIn" then
        ballSpeed = 8
    elseif isHeaderCrossLow then
        ballSpeed = self.match.ball:getCrossLowSpeed(passStartBallPosition, targetPosition, isLeadPass)
    else
        ballSpeed = self:getNormalPassSpeed(targetPosition, passStartBallPosition, isHeaderPass, isIntercept)
    end

    local passType = self.chosenDPSAction.type
    local evaluatedCatchPrepareTime = getEvaluatedCatchPrepareTime(passType, isInHeaderArea)
    local ballFlyPrediction = ball:predictFlyTo(passStartTime, passStartBallPosition, AIUtils.getDeceleration(passType), targetPosition, ballSpeed, passType)
    ballFlyPrediction.flyDuration = math.max(0.8, ballFlyPrediction.flyDuration)
    local moveDuration = math.max(passPrepareDuration + ballFlyPrediction.flyDuration - evaluatedCatchPrepareTime, 0.1)

    if expectedCatchMoveSpeed and not isHeaderPass then
        local maxBallSpeed = isHeaderCrossLow
            and self.match.ball:getCrossLowSpeed(passStartBallPosition, targetPosition, isLeadPass)
            or (isIntercept and maxInterceptBallSpeedConfig[passType] or maxLeadPassBallSpeedConfig[passType])
        moveDuration = math.min(vector2.dist(targetAthlete.position, targetPosition) / expectedCatchMoveSpeed, moveDuration)
        ballSpeed = math.min(maxBallSpeed, Ball.predictPassSpeed(math.max(0.1, moveDuration - passPrepareDuration + evaluatedCatchPrepareTime), AIUtils.getDeceleration(passType), vector2.dist(passStartBallPosition, targetPosition)))
        ballFlyPrediction = ball:predictFlyTo(passStartTime, passStartBallPosition, AIUtils.getDeceleration(passType), targetPosition, ballSpeed, passType)
        local maxSpeedBallFlyPrediction = ball:predictFlyTo(passStartTime, passStartBallPosition, AIUtils.getDeceleration(passType), targetPosition, maxBallSpeed, passType)
        moveDuration = math.max(passPrepareDuration + ballFlyPrediction.flyDuration - evaluatedCatchPrepareTime, passPrepareDuration + maxSpeedBallFlyPrediction.flyDuration)
    end

    targetAthlete:stopAnimation()

    self.realPassInfo = {
        arriveTime = self.match.currentTime + moveDuration,
        startCatchPosition = targetPosition,
        ballFlyDuration = ballFlyPrediction.flyDuration,
        ballFlySpeed = ballSpeed,
    }

    if isIntercept then
        self:logInfo("will be intercepted by athlete %d, intercept position %s, type=%s", targetAthlete.id, tostring(targetPosition), passType)
    else
        self:logInfo("pass to athlete %d, catch position %s, type=%s", targetAthlete.id, tostring(targetPosition), passType)
    end
end

function Athlete:setPassAction(targetAthlete, targetPosition, passType, isLeadPass, isShowingBallEffect, isCrossLow)
    local passAction = Actions.Pass.new()
    passAction.targetAthlete = targetAthlete
    passAction.targetPosition = targetPosition
    passAction.type = passType
    passAction.isLeadPass = isLeadPass
    passAction.isShowingBallEffect = isShowingBallEffect
    passAction.isCrossLow = isCrossLow

    if self.inManualOperating then
        passAction.isManualPass = true
    end

    self.chosenDPSAction = passAction
end

function Athlete:setThroughBallAction(targetAthlete, targetPosition, passType, isLeadPass)
    local passAction = Actions.Pass.new()
    passAction.targetAthlete = targetAthlete
    passAction.targetPosition = targetPosition
    passAction.type = passType
    passAction.isLeadPass = isLeadPass

    self.throughBallAction = passAction
end

function Athlete:setOverHeadBallAction(targetAthlete, targetPosition, passType, isLeadPass)
    local passAction = Actions.Pass.new()
    passAction.targetAthlete = targetAthlete
    passAction.targetPosition = targetPosition
    passAction.type = passType
    passAction.isLeadPass = isLeadPass

    self.overHeadBallAction = passAction
end

function Athlete:setCrossLowAction(targetAthlete, targetPosition, passType, isLeadPass)
    local passAction = Actions.Pass.new()
    passAction.targetAthlete = targetAthlete
    passAction.targetPosition = targetPosition
    passAction.type = passType
    passAction.isLeadPass = isLeadPass

    self.crossLowAction = passAction
end

function Athlete:startPass(noNeedJudgeIntercept)
    self:logAssert(self ~= self.chosenDPSAction.targetAthlete, "can not pass to self")

    self.team.passTimes = self.team.passTimes + 1
    self.passSuccessProbability = 1

    if self.chosenDPSAction.isLeadPass then
        self.team.leadPassTimes = self.team.leadPassTimes + 1
    end

    self:calcCatchAnimation(self.chosenDPSAction.targetPosition, self.chosenDPSAction.targetAthlete)
    self:stopEnemyGkAnimation()

    local deltaY = -self.team:getSign() * (self.chosenDPSAction.targetPosition.y - self.position.y)
    if math.cmpf(math.abs(self.chosenDPSAction.targetPosition.x - self.position.x), 20) <= 0
        and math.cmpf(deltaY, -10) >= 0 and math.cmpf(deltaY, 20) <= 0
        and (self.mainRole ~= "b" or self.isSideAthlete) then
        self.team.latestPassAthlete = self
    else
        self.team.latestPassAthlete = nil
    end

    self:judgeCorePlayMaker()
    self:judgeLongPassDispatch()

    if not noNeedJudgeIntercept then
        self:judgeIntercept()
    end

    if self.chosenDPSAction.type == "High" then
        self.team.highPassTimes = self.team.highPassTimes + 1

        if self.chosenDPSAction.isLeadPass then
            self.team.highLeadPassTimes = self.team.highLeadPassTimes + 1
        end
    end
    self.team:judgeHeavyGunnerEx1()
    self.enemyTeam:judgeAccurateAnticipationEx1(self)
end

-- 选择一脚出球动作
-- @param inAngle 球射入的朝向
-- @param outAngle 期望的出球朝向
-- @param animationType 动作类型
-- @param forceChoose 在没有合适动作的情况下, 是否强行选择一个动作
-- @return 如果没有合适动作: forceChoose == true, 返回符合animationType的随机动作, forceChoose == false, 返回nil; 如果有合适动作, 返回随机选择的合适动作动作
local function selectCatchAndOutAnimation(inAngle, outAngle, animationType, forceChoose)
    local animations = Animations.Tag[animationType]
    local filteredAnimations = {}
    for i, animation in ipairs(animations) do
        local rawData = Animations.RawData[animation.name]
        if (rawData.inAngle == nil or Animations.isInAngleRange(rawData.inAngle.Start, rawData.inAngle.End, inAngle)) and
            (rawData.outAngle == nil or Animations.isInAngleRange(rawData.outAngle.Start, rawData.outAngle.End, outAngle)) then
            table.insert(filteredAnimations, animation)
        end
    end

    if #filteredAnimations == 0 then
        if forceChoose then
            return selector.randomSelect(animations)
        else
            return nil
        end
    else
        return selector.randomSelect(filteredAnimations)
    end
end

function Athlete:getBestCatchAnimationType(passType, isLeadPass, isIntercept)
    local sign = self.team:getSign()
    local catchAnimationType
    if isIntercept and self:isGoalkeeper() and Field.isInPenaltyArea(self.position, -sign) then
        catchAnimationType = passType == "High" and "InterceptHighGK" or "InterceptGK"
        self.graspBall = true
    else
        if self.upComingAction == "KickOffPass2" then
            catchAnimationType = "StayCatch"
        elseif isIntercept and passType ~= "High" then
            catchAnimationType = "Intercept"
        else
            local hasDef = self:hasEnemyAthleteInFront(self.bodyDirection, 3, 2 * math.pi)
            if passType == "High" then
                catchAnimationType = isLeadPass and "MoveCatchHigh" or (hasDef and "StayCatchHighDef" or "StayCatchHighNoDef")
            else
                catchAnimationType = isLeadPass and "MoveCatchGround" or (hasDef and "StayCatchGroundDef" or
                    (Field.isInFrontCourtArea(self.position, sign) and "StayCatchGroundNoDefFront" or
                        Field.isInBackCourtArea(self.position, sign) and "StayCatchGroundNoDefBack" or "StayCatchGroundNoDef"
                        )
                    )
            end
        end
    end
    return catchAnimationType
end

-- 对于所有可以和lastMoveAnimation进行融合的Catch动作进行遍历，找到触球点距离targetPosition最近的动作
function Athlete:selectBestCatchAnimation(passType, isLeadPass, isIntercept)
    local sign = self.team:getSign()
    local inAngle = vector2.sangle(self.bodyDirection, -self.match.ball.flyDirection)
    local isSatisfyCatchPassCondition = math.cmpf(self.team.continuousCatchPassCount, 5) < 0

    local nextTask = self.match.ball.nextTask
    local isThroughBall = AIUtils.isSkillIdCorrespondSkill(nextTask.skillId, Skills.ThroughBall)
    local isOverHeadBall = AIUtils.isSkillIdCorrespondSkill(nextTask.skillId, Skills.OverHeadBall)

    if not isIntercept then
        if self.match.cornerKickDefender then
            self.match.cornerKickDefender = nil
        end

        if self.match.wingDirectFreeKickDefender then
            self.match.wingDirectFreeKickDefender = nil
        end
    end

    if self.upComingAction ~= "KickOffPass2" and not isIntercept and not self.willBeOffside then
        local enemyGk = self.enemyTeam.athleteOfRole[26]

        local skillProbabilities = { }
        if not isThroughBall and passType == "High" then
            local volleyShootSkill = self:getCooldownSkill(Skills.VolleyShoot)
            if volleyShootSkill and Field.isInVolleyShootArea(self.position, sign) then
                table.insert(skillProbabilities, {key = volleyShootSkill.class.id, probability = volleyShootSkill.probability})
            end

            local powerfulHeaderSkill = self:getCooldownSkill(Skills.PowerfulHeader)
            if powerfulHeaderSkill and Field.isHeaderArea(self.position, sign) then
                table.insert(skillProbabilities, {key = powerfulHeaderSkill.class.id, probability = powerfulHeaderSkill.probability})
            end
        end

        self:weightProbabilityArray(skillProbabilities)
        local selectedSkillId = selector.random(skillProbabilities)

        if selectedSkillId then
            if AIUtils.isSkillIdCorrespondSkill(selectedSkillId, Skills.VolleyShoot) then
                local outAngle = vector2.sangle(self.bodyDirection, self.enemyTeam.goal.center - self.position)
                local shootType = "VolleyShoot"
                local volleyShootAnimation = selectCatchAndOutAnimation(inAngle, outAngle, shootType, true)
                local volleyShootAnimationInfo = {
                    animation = volleyShootAnimation,
                    type = shootType,
                }

                self:judgeKnifeGuard()
                self.catchType = AIUtils.catchType.VolleyShoot

                self.match.ball.nextTask.catchAnimation = volleyShootAnimationInfo
                return
            elseif AIUtils.isSkillIdCorrespondSkill(selectedSkillId, Skills.PowerfulHeader) then
                local outAngle = vector2.sangle(self.bodyDirection, self.enemyTeam.goal.center - self.position)
                local shootType = "Header"
                local powerfulHeaderAnimation = selectCatchAndOutAnimation(inAngle, outAngle, shootType, true)
                local powerfulHeaderAnimationInfo = {
                    animation = powerfulHeaderAnimation,
                    type = shootType,
                }

                self:judgeKnifeGuard()

                self.catchType = AIUtils.catchType.PowerfulHeader

                self.match.ball.nextTask.catchAnimation = powerfulHeaderAnimationInfo

                return
            end
        end

        --普通头球
        if not isThroughBall and passType == "High" and Field.isHeaderArea(self.position, sign) then
            local outAngle = vector2.sangle(self.bodyDirection, self.enemyTeam.goal.center - self.position)
            local shootType = "Header"
            local headerAnimation = selectCatchAndOutAnimation(inAngle, outAngle, shootType, false)
            if headerAnimation then
                local headerAnimationInfo = {
                    animation = headerAnimation,
                    type = shootType,
                }

                self:judgeKnifeGuard()

                self.catchType = AIUtils.catchType.NormalHeader

                self.match.ball.nextTask.catchAnimation = headerAnimationInfo
                return
            end
        end

        --抢点射门
        if isThroughBall or (Field.isInForceShootArea(self.position, sign) and passType == "Ground") then
            local outAngle = vector2.sangle(self.bodyDirection, self.enemyTeam.goal.center - self.position)
            local shootType = "CatchShoot"
            local offTheBallAnimation = selectCatchAndOutAnimation(inAngle, outAngle, shootType, false)
            if offTheBallAnimation then
                local offTheBallAnimationInfo = {
                    animation = offTheBallAnimation,
                    type = shootType,
                }

                self.catchType = AIUtils.catchType.OffTheBall

                self.match.ball.nextTask.catchAnimation = offTheBallAnimationInfo
                return
            end
        end

        --接过顶强制射门
        if isOverHeadBall then
            local outAngle = vector2.sangle(self.bodyDirection, self.enemyTeam.goal.center - self.position)
            local shootType = "VolleyShoot"
            local volleyShootAnimation = selectCatchAndOutAnimation(inAngle, outAngle, shootType, true)
            local volleyShootAnimationInfo = {
                animation = volleyShootAnimation,
                type = shootType,
            }

            self:judgeKnifeGuard()

            if self:getCooldownSkill(Skills.VolleyShoot) then
                self.catchType = AIUtils.catchType.VolleyShoot
            else
                self.catchType = AIUtils.catchType.NormalVolleyShoot
            end

            self.match.ball.nextTask.catchAnimation = volleyShootAnimationInfo
            return
        end

        --普通凌空抽射
        if not isThroughBall and passType == "High" and Field.isInVolleyShootArea(self.position, sign) then
            local outAngle = vector2.sangle(self.bodyDirection, self.enemyTeam.goal.center - self.position)
            local shootType = "VolleyShoot"
            local volleyshootAnimation = selectCatchAndOutAnimation(inAngle, outAngle, shootType, false)
            if volleyshootAnimation then
                local volleyshootAnimationInfo = {
                    animation = volleyshootAnimation,
                    type = shootType,
                }

                self:judgeKnifeGuard()

                self.catchType = AIUtils.catchType.NormalVolleyShoot

                self.match.ball.nextTask.catchAnimation = volleyshootAnimationInfo
                return
            end
        end

        --接球直接下底传中
        if not self:getIsPreferCutting() and passType == "Ground"
            and Field.isInCrossLowArea(self.position, sign) and self:judgeCrossLowTeammate() then
            local outAngle = vector2.sangle(self.bodyDirection, self.chosenDPSAction.targetPosition - self.position)
            local crossLowPassAnimation = selectCatchAndOutAnimation(inAngle, outAngle, "CrossPass", false)
            if crossLowPassAnimation then
                self.catchType = AIUtils.catchType.CatchCrossPass

                local catchAnimation = {
                    animation = crossLowPassAnimation,
                    type = "CrossPass",
                    passAction = self.chosenDPSAction,
                }

                catchAnimation.passAction.type = "High"

                self.match.ball.nextTask.catchAnimation = catchAnimation
                return
            end
        end

        -- 一脚出球
        if not self:getIsPreferCutting() and not self.team.inManualOperating
            and (passType == "Ground" or (passType == "High" and not self:isGoalkeeper()))
            and isSatisfyCatchPassCondition and Field.isInCatchPassArea(self.position, sign) then
            self:calculateDribble()
            self:calculatePass()
            self:calculateShoot()
            local DPSActionItems = self:getNHighestScoreActionAndScore(3)

            -- 找出评分最高的3个Action,依此判断,如果有传球,执行一脚出球,直到遇到一个非传球Action
            for i = 1, 3 do
                local chosenDPSAction = DPSActionItems[i].key
                if not chosenDPSAction or chosenDPSAction.name ~= "Pass" then
                    break
                end

                local direction = chosenDPSAction.targetPosition - self.position
                local sqrDist = vector2.sqrmagnitude(direction)

                local isGround = passType == "Ground"
                if (isGround and math.cmpf(sqrDist, 20 ^ 2) < 0)
                    or (not isGround and math.cmpf(sqrDist, 15 ^ 2) < 0) then
                    local outAngle = vector2.sangle(self.bodyDirection, direction)
                    local catchPassAnimationType = isGround and "CatchPassGround" or "CatchPassHigh"

                    local catchPassAnimation = selectCatchAndOutAnimation(inAngle, outAngle, catchPassAnimationType, false)

                    if catchPassAnimation then
                        self.catchType = AIUtils.catchType.CatchPass
                        local catchAnimation = {
                            animation = catchPassAnimation,
                            type = catchPassAnimationType,
                            passAction = chosenDPSAction,
                        }

                        -- 接到低球则传出低球, 接到高球则传出高球
                        catchAnimation.passAction.type = passType

                        self.match.ball.nextTask.catchAnimation = catchAnimation
                        if catchPassAnimationType == "CatchPassHigh" then
                            self.team.continuousCatchPassCount = 5
                        else
                            self.team.continuousCatchPassCount = self.team.continuousCatchPassCount + 1
                        end
                        return
                    end
                end
            end
        end
    end

    --intercept and pass
    if passType ~= "Ground" and isIntercept and not self:isGoalkeeper() then
        local excluedAthletes = { }
        table.insert(excluedAthletes, self.team.athleteOfRole[26])
        local bestPassTargetInCircle = self:selectBestInterceptPassTargetInCircle(25, inAngle, excluedAthletes)

        if bestPassTargetInCircle then
            local passAction = Actions.Pass.new()
            passAction.targetAthlete = bestPassTargetInCircle.targetAthlete
            passAction.targetPosition = bestPassTargetInCircle.targetPosition
            passAction.type = bestPassTargetInCircle.type
            passAction.isLeadPass = bestPassTargetInCircle.isLeadPass

            local direction = passAction.targetPosition - self.position

            local outAngle = vector2.sangle(self.bodyDirection, direction)
            local catchPassAnimationType = "InterceptPassHigh"
            local catchPassAnimation = selectCatchAndOutAnimation(inAngle, outAngle, catchPassAnimationType, false)

            if catchPassAnimation then
                self.catchType = AIUtils.catchType.InterceptCatchPass
                local catchAnimation = {
                    animation = catchPassAnimation,
                    type = catchPassAnimationType,
                    passAction = passAction,
                }

                catchAnimation.passAction.type = "High"

                self.match.ball.nextTask.catchAnimation = catchAnimation
                self.team.continuousCatchPassCount = 5
                self.enemyTeam.continuousCatchPassCount = 0
                self.isInterceptOrStealBallNoCounterAttack = nil

                return
            end
        end
    end

    local catchAnimation
    local catchAnimationType

    if isLeadPass then --leadpass大趟接球
        local largeStepDribbleCatchAnimation = Animations.RawData.B_D027_6
        local afterLargerStepDribbleCatchPosition = self.position + vector2.vyrotate(largeStepDribbleCatchAnimation.targetPosition, self.bodyDirection)
        if passType == "Ground" and math.cmpf(vector2.sqrdist(self.position, self.enemyTeam.goal.center), 400) > 0
            and Field.isInLargeStepDribbleCatchArea(self.position, sign)
            and Field.isInside(afterLargerStepDribbleCatchPosition)
            and not self:hasEnemyAthleteInFront(self.bodyDirection, 3, math.pi * 4 / 3)
            and not self:hasEnemyAthleteInFront(self.bodyDirection, 12.5, math.pi / 3)
            and math.cmpf(self.bodyDirection.y * self.enemyTeam.goal.center.y, 0) > 0 then --必须向前接球
            catchAnimation = largeStepDribbleCatchAnimation
            catchAnimationType = "LargeStepDribbleCatch"
            self:logAssert(catchAnimationType ~= nil and catchAnimation ~= nil, "Can't find a LargeStepDribbleCatch animation!")
        else
            catchAnimationType = self:getBestCatchAnimationType(passType, isLeadPass, isIntercept)
            local filteredCatchAnimations = self:getFilteredAnimationList(catchAnimationType, function (animation)
                local rawData = Animations.RawData[animation.name]
                local sangle = vector2.sangle(self.bodyDirection, -self.match.ball.flyDirection)
                local afterCatchPosition = self.position + vector2.vyrotate(animation.targetPosition, self.bodyDirection)
                return (rawData.inAngle == nil or Animations.isInAngleRange(rawData.inAngle.Start, rawData.inAngle.End, sangle))
                 and Field.isInsideExXY(afterCatchPosition, 0, 1)
            end)

            if #filteredCatchAnimations == 0 then
                filteredCatchAnimations = Animations.Tag[catchAnimationType]
            end

            catchAnimation = catchAnimationType == "MoveCatchGround" and selector.randomSelect(filteredCatchAnimations)
                or self:selectBestCatchAnimationToOneDirection(vector2.norm(self.enemyTeam.goal.center - self.position), filteredCatchAnimations)
            self:logAssert(catchAnimationType ~= nil and catchAnimation ~= nil, "Can't find a leadPass catch animation! " .. tostring(catchAnimationType) .. " num = " .. #filteredCatchAnimations)
        end
    else
        catchAnimationType = self:getBestCatchAnimationType(passType, isLeadPass, isIntercept)
        if isIntercept then
            catchAnimation = self:selectBestInterceptAnimation(self.match.ball.nextTask.interceptPosition, Animations.Tag[catchAnimationType])
            self:logAssert(catchAnimationType ~= nil and catchAnimation ~= nil, "Can't find a intercept animation! " .. tostring(catchAnimationType) .. " num = " .. #Animations.Tag[catchAnimationType])
        else
            catchAnimation = catchAnimationType == "MoveCatchGround" and selector.randomSelect(Animations.Tag.MoveCatchGround)
                or self:selectBestCatchAnimationToOneDirection(vector2.norm(self.enemyTeam.goal.center - self.position), Animations.Tag[catchAnimationType])
            self:logAssert(catchAnimationType ~= nil and catchAnimation ~= nil, "Can't find a normalCatch animation! " .. tostring(catchAnimationType) .. " num = " .. #Animations.Tag[catchAnimationType])
        end
    end

    self:logAssert(catchAnimation ~= nil, "Can't find a catch animation!")

    self.match.ball.nextTask.catchAnimation = {
        animation = catchAnimation,
        type = catchAnimationType,
    }
    self.team.continuousCatchPassCount = 0
    self.enemyTeam.continuousCatchPassCount = 0
end

function Athlete:selectBestInterceptPassTargetInCircle(radius, inAngle, excluedAthletes)
    local bestTargetAthlete = nil
    local bestTargetPosition = nil
    local minAttackDistance = math.huge
    for _, friend in ipairs(self.team.athletes) do
        if friend ~= self and not table.isArrayInclude(excluedAthletes, friend) and math.cmpf(vector2.sqrdist(self.position, friend.position), radius ^ 2) <= 0 then
            local candidateTargetPositions = self:getCandidateTargetPositionsForOneAthlete(friend)
            for _, candidateTarget in ipairs(candidateTargetPositions) do
                local targetPosition = candidateTarget.targetPosition
                local attackDistance = math.abs(self.position.y - candidateTarget.targetPosition.y)
                local direction = targetPosition - self.position
                local sqrDist = vector2.sqrmagnitude(direction)
                if Field.isInsideEx(targetPosition, FieldShrinkDelta) and math.cmpf(sqrDist, 25 ^ 2) <= 0 and math.cmpf(sqrDist, 10 ^ 2) >= 0 then
                    local outAngle = vector2.sangle(self.bodyDirection, direction)
                    local catchPassAnimation = selectCatchAndOutAnimation(inAngle, outAngle, "CatchPassHigh", false)
                    if catchPassAnimation and math.cmpf(attackDistance, minAttackDistance) < 0 then
                        bestTargetAthlete = friend
                        bestTargetPosition = targetPosition
                        minAttackDistance = attackDistance
                    end
                end
            end
        end
    end

    local bestPassTargetInCircle = nil
    if bestTargetAthlete then
        bestPassTargetInCircle = {targetAthlete = bestTargetAthlete, targetPosition = bestTargetPosition, type = "High", isLeadPass = false}
    end

    return bestPassTargetInCircle
end

function Athlete:selectBestCatchAnimationToOneDirection(targetDirection, catchAnimations)
    local catchAnimation
    local minAngle = math.huge
    for i, animation in ipairs(catchAnimations) do
        local newBodyDirection = vector2.rotate(self.bodyDirection, animation.targetRotation)
        local newAngle = vector2.angle(newBodyDirection, targetDirection)
        if math.cmpf(newAngle, minAngle) < 0 then
            minAngle = newAngle
            catchAnimation = animation
        end
    end

    return catchAnimation
end

function Athlete:selectBestInterceptAnimation(targetPosition, interceptAnimations)
    local interceptAnimation
    local minSqrDist = math.huge
    for i, animation in ipairs(interceptAnimations) do
        local newPosition = self.position + vector2.vyrotate(animation.firstTouchBallPosition, self.bodyDirection)
        local newSqrDist = vector2.sqrdist(newPosition, targetPosition)
        if math.cmpf(newSqrDist, minSqrDist) < 0 then
            minSqrDist = newSqrDist
            interceptAnimation = animation
        end
    end

    return interceptAnimation
end

function Athlete:passBall()
    -- 修正之后规定球按照计算出的速度飞行
    local ball = self.match.ball
    ball:setOwner(self)
    ball:flyTo(self.match.currentTime, ball.position, AIUtils.getDeceleration(self.chosenDPSAction.type), self.realPassInfo.startCatchPosition, self.realPassInfo.ballFlySpeed, self.chosenDPSAction.type, "Pass")

    if not ball.nextTask.noNeedJudgeOffside then
        if self.chosenDPSAction.isManualPass then
            self:judgeOffside(self.chosenDPSAction.targetAthlete, 1)
        elseif self.chosenDPSAction.targetAthlete:isSideF() then
            self:judgeOffside(self.chosenDPSAction.targetAthlete, 1)
        elseif self:hasBuff(Skills.ThroughBall) then
            self:judgeOffside(self.chosenDPSAction.targetAthlete, 2)
        elseif self:hasBuff(Skills.OverHeadBall) then
            self:judgeOffside(self.chosenDPSAction.targetAthlete, 2.5)
        else
            self:judgeOffside(self.chosenDPSAction.targetAthlete, 0)
        end
    end

    if self.catchType == AIUtils.catchType.InterceptCatchPass then
        self:judgeCounterRunningForward()
        self.catchType = nil
    end

    if self.catchType == AIUtils.catchType.CatchPass or self.catchType == AIUtils.catchType.CatchCrossPass then
        self.catchType = nil
    end
end

function Athlete:getPassAbilityForCalculation()
    return self:isGoalkeeper() and self:getAbilitiesSum() / 5 + 0.8 * self:getAbilities().launching or self:getAbilities().pass
end

function Athlete:judgeIntercept()
    self:judgeInterceptSkills()
    --judge if pass is successful
    local judgeInterceptType = self.chosenDPSAction.type == "Ground" and "Ground" or "High"
    local getCandidateInterceptsFuncName = "getCandidateInterceptsFor" .. judgeInterceptType .. "Pass"
    local candidiateIntercepts = AIUtils[getCandidateInterceptsFuncName](self)

    if #candidiateIntercepts ~= 0 then
        self.team.mayBeInterceptedPassTimes = self.team.mayBeInterceptedPassTimes + 1
    end
    self.team:judgeBlauwbrugBrainEx1(self, self.chosenDPSAction.targetAthlete and self.chosenDPSAction.targetAthlete.position or self.chosenDPSAction.targetPosition)

    local passAbility = self:getPassAbilityForCalculation()

    self.passSuccessProbability = 1
    self.passSuccessProbability = self:judgePassMasterEx1(self.passSuccessProbability)

    local enemyGk = self.enemyTeam.athleteOfRole[26]
    local airDominatorEx1Skill = enemyGk:getSkill(Skills.AirDominatorEx1)
    local forcedInterceptTargetPosition = vector2.div(vector2.add(self.chosenDPSAction.targetPosition, enemyGk.position), 2)

    if airDominatorEx1Skill ~= nil and selector.tossCoin(airDominatorEx1Skill.ex1Probability) and Field.isInPenaltyArea(forcedInterceptTargetPosition, self.team:getSign()) then
        local gkIntercepts = AIUtils[getCandidateInterceptsFuncName .. "WithTarget"](self, enemyGk, forcedInterceptTargetPosition, self.animationQueue[1].animationInfo.lastTouchBallPosition, self.animationQueue[1].animationInfo.lastTouch, self.chosenDPSAction.isCornerkick)
        if #gkIntercepts > 0 then
            self.selectedIntercept = gkIntercepts[1].key
        else
            self.selectedIntercept = {
                athlete = enemyGk,
                interceptPosition = forcedInterceptTargetPosition,
            }
        end
        enemyGk:addBuff(airDominatorEx1Skill.buff, enemyGk)
        enemyGk:castSkill(airDominatorEx1Skill.class, 0)
        self.passSuccessProbability = 0.01
    else
        for i, v in ipairs(candidiateIntercepts) do
            local enemy = v.key.athlete
            enemy:judgePoacher()

            local interceptProbability = AIUtils.getInterceptProbability(enemy, passAbility, v.key.isCornerkick, v.key.isCrossLow, self.chosenDPSAction.targetAthlete.isSideAthlete)
            interceptProbability = enemy:judgeInterceptMasterEx1(interceptProbability)

            local newProbability = self.passSuccessProbability * (1 - interceptProbability)

            if not (self.manualOperateSuccessProbability
                and math.cmpf(newProbability, self.manualOperateSuccessProbability) < 0) then
                enemy.interceptRate = interceptProbability
                self.passSuccessProbability = newProbability

                if not self.selectedIntercept and selector.tossCoin(interceptProbability) then
                    self.selectedIntercept = v.key
                end
            end
        end

        self.passSuccessProbability = math.max(self.manualOperateSuccessProbability or self.passSuccessProbability, 0.01)
        self.passSuccessProbability = self:isShortPassSuccess(self.chosenDPSAction.targetPosition) and 1 or self.passSuccessProbability
        self.passSuccessProbability = math.min(self.passSuccessProbability, 1)
    end

    self:castPassSkills()

    if self.selectedIntercept then
        self.selectedIntercept.athlete:judgePoacherEx1()
        self.selectedIntercept.athlete:setToBeCastedInterceptSkills()
        self.selectedIntercept.athlete:judgeBlackHeartEnemyBuff() --要放在setCast之后
    else
        if self.chosenDPSAction.isCornerkick then
            local excludedAthletes = {self.enemyTeam.athleteOfRole[26]}
            self.chosenDPSAction.targetAthlete:judgeCornerKickMasterEx1(self)
            self.match.cornerKickDefender = self.enemyTeam:selectNearestAthlete(self.chosenDPSAction.targetAthlete.position, excludedAthletes)
        end

        if self.chosenDPSAction.isWingDirectFreeKick then
            local excludedAthletes = {self.enemyTeam.athleteOfRole[26]}
            self.match.wingDirectFreeKickDefender = self.enemyTeam:selectNearestAthlete(self.chosenDPSAction.targetAthlete.position, excludedAthletes)
        end

        return
    end

    self:calcCatchAnimation(self.selectedIntercept.interceptPosition, self.selectedIntercept.athlete, true)
end

function Athlete:judgeAccurateAnticipation()
    if self:isDivingEx1Blocked() then
        return
    end
    --judge if accurateAnticipation skill is successful
    local candidiateIntercepts = AIUtils.getCandidateInterceptsForGroundPass(self)

    for i, intercept in ipairs(candidiateIntercepts) do
        local interceptAthlete = intercept.key.athlete
        local skill = interceptAthlete:getCooldownSkill(Skills.AccurateAnticipation)
        if skill and selector.tossCoin(skill.probability) then
            interceptAthlete:addBuff(skill.buff, interceptAthlete)
            self.manualOperateSuccessProbability = nil
        end
    end
end

function Athlete:judgeFlakTower()
    if self:isDivingEx1Blocked() then
        return
    end
    --judge if flakTower skill is successful
    local candidiateIntercepts = AIUtils.getCandidateInterceptsForHighPass(self)

    for i, intercept in ipairs(candidiateIntercepts) do
        local interceptAthlete = intercept.key.athlete
        local skill = interceptAthlete:getCooldownSkill(Skills.FlakTower)
        if skill and selector.tossCoin(skill.probability) then
            interceptAthlete:addBuff(skill.buff, interceptAthlete)
            self.manualOperateSuccessProbability = nil
        end
    end
end

function Athlete:judgeEnemyRationalIntercept()
    for _, enemy in ipairs(self.enemyTeam.athletes) do
        enemy:judgeRationalIntercept()
    end
end

function Athlete:judgeAirDominator()
    --judge if airDominator skill is successful
    local candidiateIntercepts = AIUtils.getCandidateInterceptsForHighPass(self)

    for i, intercept in ipairs(candidiateIntercepts) do
        local interceptAthlete = intercept.key.athlete
        if interceptAthlete:isGoalkeeper() then
            local skill = interceptAthlete:getCooldownSkill(Skills.AirDominator)
            if skill and selector.tossCoin(skill.probability) then
                interceptAthlete:addBuff(skill.buff, interceptAthlete)
                self.manualOperateSuccessProbability = nil
                break
            end
        end
    end
end

function Athlete:setBallPassTask()
    if self.selectedIntercept == nil then
        --pass is successful
        self.match.ball.nextTask = Ball.Pass.new({
            type = self.chosenDPSAction.type,
            receiver = self.chosenDPSAction.targetAthlete,
            receiverArrivePosition = self.chosenDPSAction.targetPosition,
            receiveTime = self.realPassInfo.arriveTime,
            receiverArriveTime = self.realPassInfo.arriveTime,
            targetPosition = vector2.clone(self.realPassInfo.startCatchPosition),
            catchAnimation = self.realPassInfo.catchAnimation,
            isLeadPass = self.chosenDPSAction.isLeadPass,
            passer = self,
            frozenType = self.match.frozenType,
            skillId = self.passSkillId,
            skillId2 = self.passSkillId2,
            noNeedJudgeOffside = self.noNeedJudgeOffside,
        })
        self:judgeBlackHeartSelfBuff()
        self:judgeAllAroundFighter("pass")
    else
        --pass is not successful, intercept happens here
        local interceptAthlete = self.selectedIntercept.athlete

        self.match.ball.nextTask = Ball.PassAndIntercept.new({
            type = self.chosenDPSAction.type,
            receiver = self.chosenDPSAction.targetAthlete,
            receiverArrivePosition = self.chosenDPSAction.targetPosition,
            receiveTime = self.realPassInfo.arriveTime,
            receiverArriveTime = self.realPassInfo.arriveTime,
            targetPosition = vector2.clone(self.realPassInfo.startCatchPosition),
            interceptor = interceptAthlete,
            interceptTime = self.realPassInfo.arriveTime,
            interceptorArriveTime = self.realPassInfo.arriveTime,
            interceptPosition = vector2.clone(self.realPassInfo.startCatchPosition),
            passType = self.chosenDPSAction.type,
            catchAnimation = self.realPassInfo.catchAnimation,
            isLeadPass = self.chosenDPSAction.isLeadPass,
            passer = self,
            noNeedJudgeOffside = self.noNeedJudgeOffside,
            skillId = self.passSkillId,
        })

        self.selectedIntercept = nil

        interceptAthlete:setMark(nil)
        interceptAthlete:setCover(nil)
        self:logDebug("stop athlete %d, to intercept", interceptAthlete.id)
    end

    self.noNeedJudgeOffside = nil
    self.passSkillId = nil
    self.passSkillId2 = nil
end

function Athlete:updateOutputPassActionStatus()
    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil or self.outputActionStatus.name == "Intercept" then
        local passAction = Actions.Pass.new()
        passAction.targetAthlete = self.chosenDPSAction.targetAthlete
        passAction.targetPosition = self.realPassInfo.startCatchPosition
        passAction.type = self.chosenDPSAction.type
        passAction.duration = self.realPassInfo.ballFlyDuration
        passAction.isShowingBallEffect = self.chosenDPSAction.isShowingBallEffect
        passAction.passSkillId = self.passSkillId

        passAction.successProbability = self.passSuccessProbability

        local ballNextTask = self.match.ball.nextTask
        if ballNextTask.class == Ball.PassAndIntercept then
            passAction.isIntercepted = true
            passAction.interceptPosition = ballNextTask.interceptPosition
            passAction.interceptAthlete = ballNextTask.interceptor
            passAction.interceptDuration = ballNextTask.interceptTime - self.match.currentTime
        end

        if passAnimationType == "GKShortThrow" or passAnimationType == "GKLongThrow" then
            athlete.outputActionStatus.passBodyPartType = AIUtils.passBodyPartType.hand
        end

        self.outputActionStatus = passAction
    end

    self.passSkillId = nil
    self.passSkillId2 = nil
end

function Athlete:judgeThroughBallTeammate(existingTargetAthlete)
    local bestTargetAthlete
    local bestTargetPosition
    local bestPassType
    local maxScore = 0
    local sign = self.team:getSign()

    for _, friend in ipairs(self.team.athletes) do
        if friend ~= self and friend ~= existingTargetAthlete
            and math.cmpf(self:getDistanceToEnemyBottomLine(), friend:getDistanceToEnemyBottomLine() + 5) > 0 --满足离底线距离条件
            and math.cmpf(vector2.sqrdist(self.position, friend.position), highNormalPassDistance ^ 2) < 0 --满足短传距离条件
            and math.cmpf(self:getDistanceYToOffsideLine(friend.position), 0) >= 0 --不能传给越位位置球员
            then
            local candidateTargetPositions = self:getCandidateTargetPositionsForOneAthlete(friend, true)
            local originalDistanceToBottomLine = self:calcAttackDistance(self.position)

            for i, candidateTarget in ipairs(candidateTargetPositions) do
                local targetPosition = candidateTarget.targetPosition
                local catchDistance = vector2.dist(friend.position, targetPosition)
                local passSqrDist = vector2.sqrdist(self.position, targetPosition)

                local passType = math.cmpf(passSqrDist, 27.5 ^ 2) <= 0 and "Ground" or "High"
                local passMaxAbsY = passType == "Ground" and groundPassMaxAbsY or highPassMaxAbsY

                local hasNearerEnemy = false
                for _, enemyAthlete in ipairs(self.enemyTeam.athletes) do
                    if enemyAthlete:isGoalkeeper() then
                        local turnTime = 0.3

                        local enemyAthleteDistToTargetPosition = vector2.dist(enemyAthlete.position, targetPosition)
                        local isGoalkeeper = enemyAthlete:isGoalkeeper()
                        if (candidateTarget.isLeadPass and isGoalkeeper and
                            math.cmpf(enemyAthleteDistToTargetPosition, catchDistance) < 0
                            and math.cmpf(enemyAthleteDistToTargetPosition, 9) <= 0)
                            or (not isGoalkeeper and math.cmpf(enemyAthleteDistToTargetPosition + 7 * turnTime, catchDistance) < 0) then
                            hasNearerEnemy = true
                        end
                    end
                end

                if not (hasNearerEnemy
                    or not Field.isInThroughBallForceShootArea(targetPosition, sign)
                    or not isSatisfyCatchMoveSpeed(self, friend, candidateTarget, passType) -- 不满足速度条件
                    or math.cmpf(math.abs(targetPosition.y), passMaxAbsY) > 0 --传球y值限制
                    or math.cmpf(passSqrDist, vector2.sqrdist(friend.position, targetPosition)) < 0 --持球球员离目标点更近
                    or not Field.isInsideEx(targetPosition, FieldShrinkDelta)) then--传球目标点应在界内
                    local score = friend:getAbilities().shoot * (originalDistanceToBottomLine - self:calcAttackDistance(targetPosition))
                    if math.cmpf(score, maxScore) > 0 then
                        maxScore = score
                        bestTargetAthlete = friend
                        bestTargetPosition = targetPosition
                        bestPassType = passType
                    end
                end
            end
        end
    end

    if bestTargetAthlete then
        self:setPassAction(bestTargetAthlete, bestTargetPosition, bestPassType, true)

        if not self:hasAppropriatePassAnimation(true) then
            return false
        end

        self.throughBallAction = self.chosenDPSAction

        return true
    end

    return false
end

function Athlete:getManualOperationThroughBallActions()
    local manualOperationThroughBallActions = {}
    table.insert(manualOperationThroughBallActions, self.throughBallAction)

    if self:judgeThroughBallTeammate(self.throughBallAction.targetAthlete) then
        table.insert(manualOperationThroughBallActions, self.throughBallAction)
    end

    return manualOperationThroughBallActions
end

function Athlete:judgeOverHeadBallTeammate(existingTargetAthlete)
    local bestTargetAthlete
    local bestTargetPosition
    local bestPassType
    local maxScore = -math.huge
    local sign = self.team:getSign()

    for _, friend in ipairs(self.team.athletes) do
        if friend ~= self and friend ~= existingTargetAthlete
            and math.cmpf(self:getDistanceToEnemyBottomLine(), friend:getDistanceToEnemyBottomLine() + 15) > 0 --满足离底线距离条件
            and math.cmpf(vector2.sqrdist(self.position, friend.position), 20 ^ 2) >= 0 --满足过顶球最短距离条件
            and math.cmpf(self:getDistanceYToOffsideLine(friend.position), 0) >= 0 --不能传给越位位置球员
            then

            local volleyShootCoefficient = 1
            if friend:getCooldownSkill(Skills.VolleyShoot) then
                volleyShootCoefficient = 1.5
            end

            local candidateTargetPositions = self:getCandidateTargetPositionsForOneAthlete(friend, nil, true)
            local originalDistanceToBottomLine = self:calcAttackDistance(self.position)

            for i, candidateTarget in ipairs(candidateTargetPositions) do
                local targetPosition = candidateTarget.targetPosition
                local catchDistance = vector2.dist(friend.position, targetPosition)

                local passType = "High"

                local hasNearerGk = false
                local enemyGk = self.enemyTeam.athleteOfRole[26]
                local enemyGkDistToTargetPosition = vector2.dist(enemyGk.position, targetPosition)
                if math.cmpf(enemyGkDistToTargetPosition, catchDistance) < 0 and math.cmpf(enemyGkDistToTargetPosition, 9) <= 0 then
                    hasNearerGk = true
                end

                if not (hasNearerGk
                    or not Field.isInVolleyShootArea(targetPosition, sign)
                    or math.cmpf(math.abs(targetPosition.y), highPassMaxAbsY) > 0 --传球y值限制
                    or not isSatisfyCatchMoveSpeed(self, friend, candidateTarget, passType) -- 不满足速度条件
                    or math.cmpf(vector2.sqrdist(self.position, targetPosition), vector2.sqrdist(friend.position, targetPosition)) < 0 --持球球员离目标点更近
                    or not Field.isInsideEx(targetPosition, FieldShrinkDelta)) then--传球目标点应在界内
                    local score = (originalDistanceToBottomLine - self:calcAttackDistance(targetPosition)) * volleyShootCoefficient

                    if math.cmpf(score, maxScore) > 0 then
                        maxScore = score
                        bestTargetAthlete = friend
                        bestTargetPosition = targetPosition
                        bestPassType = passType
                    end
                end
            end
        end
    end

    if bestTargetAthlete then
        self:setPassAction(bestTargetAthlete, bestTargetPosition, bestPassType, true)

        if not self:hasAppropriatePassAnimation(true) then
            return false
        end

        self.overHeadBallAction = self.chosenDPSAction

        return true
    end

    return false
end

function Athlete:getManualOperationOverHeadBallActions()
    local manualOperationOverHeadBallActions = {}
    table.insert(manualOperationOverHeadBallActions, self.overHeadBallAction)

    if self:judgeOverHeadBallTeammate(self.overHeadBallAction.targetAthlete) then
        table.insert(manualOperationOverHeadBallActions, self.overHeadBallAction)
    end

    return manualOperationOverHeadBallActions
end

function Athlete:judgeCrossLowTeammate(existingTargetAthlete)
    local candidateCrossLowTargets = { }
    local sign = self.team:getSign()

    for _, friend in ipairs(self.team.athletes) do
        if friend ~= self and friend ~= existingTargetAthlete
            and math.cmpf(self:getDistanceYToOffsideLine(friend.position), 0) >= 0 --不能传给越位位置球员
            then
            local candidateTargetPositions = self:getCandidateTargetPositionsForOneAthlete(friend)

            for i, candidateTarget in ipairs(candidateTargetPositions) do
                local targetPosition = candidateTarget.targetPosition
                local offTheBallFactor = getOffTheBallFactor(friend, targetPosition)

                if not (not Field.isHeaderArea(targetPosition, sign)
                    or math.cmpf(vector2.sqrdist(self.position, targetPosition), highCrossPassDistance ^ 2) < 0 --不满足传中高球距离条件
                    or not isSatisfyCatchMoveSpeed(self, friend, candidateTarget, "High") -- 不满足速度条件
                    or math.cmpf(math.abs(targetPosition.y), highPassMaxAbsY) > 0 --传球y值限制
                    or not Field.isInsideEx(targetPosition, FieldShrinkDelta)) then--传球目标点应在界内
                    table.insert(candidateCrossLowTargets,
                        {key = {targetAthlete = friend, targetPosition = targetPosition, isLeadPass = candidateTarget.isLeadPass},
                        weight = friend:getAbilities().shoot * offTheBallFactor})
                end
            end
        end
    end

    local crossLowTarget = selector.weightedRandom(candidateCrossLowTargets)
    if crossLowTarget then
        self:setPassAction(crossLowTarget.targetAthlete, crossLowTarget.targetPosition, "High", crossLowTarget.isLeadPass, nil, true)

        self.crossLowAction = self.chosenDPSAction
        return true
    end

    return false
end

function Athlete:getManualOperationCrossLowActions()
    local manualOperationCrossLowActions = {}
    table.insert(manualOperationCrossLowActions, self.crossLowAction)

    if self:judgeCrossLowTeammate(self.crossLowAction.targetAthlete) then
        table.insert(manualOperationCrossLowActions, self.crossLowAction)
    end

    return manualOperationCrossLowActions
end

function Athlete:judgePuntKickTeammate()
    local bestTargetAthlete
    local bestTargetPosition
    local bestPassType
    local maxScore = -math.huge
    local sign = self.team:getSign()

    for _, friend in ipairs(self.team.athletes) do
        if friend ~= self
            and math.cmpf(self:getDistanceToEnemyBottomLine(), friend:getDistanceToEnemyBottomLine() + 15) > 0 --满足离底线距离条件
            and math.cmpf(self:getDistanceYToOffsideLine(friend.position), 0) >= 0 --不能传给越位位置球员
            then
            local candidateTargetPositions = self:getCandidateTargetPositionsForOneAthlete(friend, nil, true)
            local originalDistanceToBottomLine = self:calcAttackDistance(self.position)

            for i, candidateTarget in ipairs(candidateTargetPositions) do
                local targetPosition = candidateTarget.targetPosition
                local catchDistance = vector2.dist(friend.position, targetPosition)
                local passSqrDist = vector2.sqrdist(self.position, targetPosition)

                local passType = "High"

                local hasNearerGk = false
                local enemyGk = self.enemyTeam.athleteOfRole[26]
                local enemyGkDistToTargetPosition = vector2.dist(enemyGk.position, targetPosition)
                if math.cmpf(enemyGkDistToTargetPosition, catchDistance) < 0 and math.cmpf(enemyGkDistToTargetPosition, 9) <= 0 then
                    hasNearerGk = true
                end

                if not (math.cmpf(math.abs(targetPosition.y), highPassMaxAbsY) > 0 --传球y值限制
                    or not isSatisfyCatchMoveSpeed(self, friend, candidateTarget, passType) -- 不满足速度条件
                    or math.cmpf(vector2.sqrdist(self.position, targetPosition), vector2.sqrdist(friend.position, targetPosition)) < 0 --持球球员离目标点更近
                    or not Field.isInsideEx(targetPosition, FieldShrinkDelta)) then--传球目标点应在界内
                    local score = originalDistanceToBottomLine - self:calcAttackDistance(targetPosition)

                    if math.cmpf(score, maxScore) > 0 then
                        maxScore = score
                        bestTargetAthlete = friend
                        bestTargetPosition = targetPosition
                        bestPassType = passType
                    end
                end
            end
        end
    end

    if bestTargetAthlete then
        self:setPassAction(bestTargetAthlete, bestTargetPosition, bestPassType, true)

        return true
    end

    return false
end

function Athlete:selectCrossLowAnimation()
    self:selectAndPushPassAnimationByTargetPosition("CrossPass", self.chosenDPSAction.targetPosition, true)
end

function Athlete:getThrowInTarget()
    return self:hasBuff(Skills.Popeye) and self:getPopeyeThrowInTarget() or self:getNormalThrowInTarget()
end

local function getNearAthletes(match)
    local sortedAthletesByDistance = {}
    for i, attackAthlete in ipairs(match.attackTeam.athletes) do
        table.insert(sortedAthletesByDistance, attackAthlete)
    end

    table.sort(sortedAthletesByDistance, function(a, b)
        local sqrDistanceA = vector2.sqrdist(a.position, match.ball.outOfFieldPoint)
        local sqrDistanceB = vector2.sqrdist(b.position, match.ball.outOfFieldPoint)
        return math.cmpf(sqrDistanceA, sqrDistanceB) < 0
    end)

    return sortedAthletesByDistance[2], sortedAthletesByDistance[3]
end

function Athlete:getNormalThrowInTarget()
    local nearAthlete1, nearAthlete2 = getNearAthletes(self.match)
    nearAthlete1.position = Field.getRandomThrowInCoordinateAthletePosition(self.match.ball.outOfFieldPoint, 7.5, 15)
    nearAthlete2.position = Field.getRandomThrowInCoordinateAthletePosition(self.match.ball.outOfFieldPoint, 7.5, 15)

    if nearAthlete1 == self then
        return {targetAthlete = nearAthlete2, targetPosition = nearAthlete2.position}
    elseif nearAthlete2 == self then
        return {targetAthlete = nearAthlete1, targetPosition = nearAthlete1.position}
    end

    return selector.tossCoin(0.5) and {targetAthlete = nearAthlete1, targetPosition = nearAthlete1.position}
        or {targetAthlete = nearAthlete2, targetPosition = nearAthlete2.position}
end

function Athlete:getPopeyeThrowInTarget()
    local candidatePassTargets = self:getCandidatePassTargets()
    self:logAssert(candidatePassTargets and #candidatePassTargets > 0, "Number of candidate pass targets for Popeye throw in should not be 0")

    return {targetAthlete = candidatePassTargets[1].targetAthlete, targetPosition = candidatePassTargets[1].targetPosition}
end

function Athlete:calcPassSuccessProbability(targetAthlete, targetPosition, passType, passAnimation, skillId)
    local funcPassType = passType == "Ground" and "Ground" or "High"
    local getCandidateInterceptsFuncName = "getCandidateInterceptsFor" .. funcPassType .. "PassWithTarget"
    local candidiateIntercepts = AIUtils[getCandidateInterceptsFuncName](
        self,
        targetAthlete,
        targetPosition,
        passAnimation.lastTouchBallPosition,
        passAnimation.lastTouch,
        true
        )

    local passAbility
    if skillId then
        local skill = self:getCooldownSkill(AIUtils.getSkillById(skillId))
        local tempAthleteAbilities = shallowClone(self:getAbilities())
        skill.buff.abilitiesModifier(tempAthleteAbilities, self, self)

        passAbility = tempAthleteAbilities.pass
    else
        passAbility = self:getPassAbilityForCalculation()
    end

    local passSuccessProbability = 1
    for i, v in ipairs(candidiateIntercepts) do
        local enemy = v.key.athlete

        local interceptProbability = AIUtils.getInterceptProbability(enemy, passAbility, v.key.isCornerkick, v.key.isCrossLow, targetAthlete.isSideAthlete)
        interceptProbability = enemy:judgeInterceptMasterEx1(interceptProbability)
        passSuccessProbability = passSuccessProbability * (1 - interceptProbability)
    end

    return self:isShortPassSuccess(targetPosition) and 1 or math.max(passSuccessProbability, 0.01)
end

function Athlete:judgePassMasterEx1(currentSuccessProbility)
    local skill = self:getCooldownSkill(Skills.PassMasterEx1)
    if skill ~= nil and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
        return skill.buff.successProbilityModifier(currentSuccessProbility)
    end
    return currentSuccessProbility
end