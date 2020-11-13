if jit then jit.off(true, true) end

local Athlete = import("./Core")
local selector = import("../libs/selector")
local vector2 = import("../libs/vector")
local Actions = import("../actions/Actions")
local AIUtils = import("../AIUtils")
local Ball= import("../Ball")
local Field = import("../Field")
local Tactics = import("../Tactics")
local Animations = import("../animations/Animations")
local Skills = import("../skills/Skills")

-- use for limit the athlete in smaller field
local FieldShrinkDelta = 3
local dribbleAdjustScoreCoe = 2

function Athlete:setCandidateBreakThroughAnimations()
    self.candidateBreakThroughAnimations = self:getCandidateBreakThroughAnimations()
end

-- 选择合适的过人动画，如果能找到，返回true，否则返回false
-- 已经确保了 self.candidateEnemyForBreakThrough ~= nil
function Athlete:calculateBreakThrough()
    self:logAssert(self.candidateEnemyForBreakThrough, "self.candidateEnemyForBreakThrough should not be nil")
    --Manual Operation时，currentAnimation已经清空了，所以需要提前记录下candidateBreakThroughAnimations
    local candidateBreakThroughAnimations = self.candidateBreakThroughAnimations

    -- 设置自身的过人动作
    local btAnimation = selector.randomSelect(candidateBreakThroughAnimations)
    local candidateActions = { }
    local breakThroughAction = Actions.Dribble.new()
    breakThroughAction.animation = btAnimation.animation
    breakThroughAction.animationType = "BreakThrough"
    breakThroughAction.config = btAnimation.config
    breakThroughAction.candidateEnemyForBreakThrough = self.candidateEnemyForBreakThrough
    table.insert(candidateActions, { key = breakThroughAction, weight = 1 })

    self.candidateDribbleActions = candidateActions

    return true
end

function Athlete:calculateBreakThroughDefendInfo()
    if self.chosenDPSAction.animationType == "BreakThrough"
        and not self.dribbleState.stealAthlete
        and not self.dribbleState.foulAthlete then
        -- 设置被过人的被过信息
        local enemy = self.chosenDPSAction.candidateEnemyForBreakThrough
        enemy.breakThroughDefendInfo = {
            startTime = self.match.currentTime,
            delay = self.chosenDPSAction.config.delay,
            defendAnimation = self.chosenDPSAction.config.defendAnimation,
            targetAthlete = self
        }
        enemy:stopAnimation()

        self.candidateBreakThroughAnimations = nil
    end
end

-- 已经确保了 self.candidateEnemyForBreakThrough ~= nil
function Athlete:getCandidateBreakThroughAnimations()
    local lastAnimationKey = self.currentAnimation and self.currentAnimation.animationInfo.name or nil

    local candidateBreakThroughAnimations = { }

    if lastAnimationKey ~= nil then
        local breakthrough = Animations.Next[lastAnimationKey].Cross
        if breakthrough ~= nil then
            self:setFilteredBreakThroughAnimations(breakthrough, candidateBreakThroughAnimations)
        end
    end

    if #candidateBreakThroughAnimations == 0 then
        self:setFilteredBreakThroughAnimations(Animations.Tag.Cross, candidateBreakThroughAnimations)
    end

    return candidateBreakThroughAnimations
end

function Athlete:getAnimationTargetPosition(animationInfo)
    local position, rotation
    if self.currentAnimation and not self.currentAnimation.disableTransition then
        position, rotation = Animations.calcTransitionTarget(self.currentAnimation.animationInfo, animationInfo, self)
    else
        position = animationInfo.targetPosition
    end

    return position
end

-- 已经确保了 self.candidateEnemyForBreakThrough ~= nil
function Athlete:setFilteredBreakThroughAnimations(breakThroughAnimations, filteredBreakThroughAnimations)
    local sign = self.team:getSign()
    local enemy = self.candidateEnemyForBreakThrough
    local sangle = vector2.sangle(self.bodyDirection, enemy.position - self.position)
    local sqrdist = vector2.sqrdist(self.position, enemy.position)
    local x, y = self.position.x * -sign, self.position.y * -sign
    local directionAngle = vector2.sangle(vector2.new(0, -sign), self.bodyDirection)

    local animations = {}
    for i, animation in ipairs(breakThroughAnimations) do
        animations[animation.name] = animation
    end

    for i, animationConfig in ipairs(Animations.breakThroughAnimationConfig) do
        if animations[animationConfig.name] and Animations.isInAngleRange(animationConfig.angleMin, animationConfig.angleMax, sangle) and
            math.cmpf(animationConfig.sqrdistMin, sqrdist) <= 0 and math.cmpf(sqrdist, animationConfig.sqrdistMax) <= 0 then
            local breakThroughAnimation = animations[animationConfig.name]
            local newPosition = self.position + vector2.vyrotate(self:getAnimationTargetPosition(breakThroughAnimation), self.bodyDirection)
            local newBodyDirection = vector2.rotate(self.bodyDirection, breakThroughAnimation.targetRotation)
            local newToEnemyGoalCenterVector = self.enemyTeam.goal.center - newPosition

            if math.cmpf(vector2.angle(newToEnemyGoalCenterVector, newBodyDirection), math.pi / 2) < 0 then--过人后的朝向与球门方向夹角小于90度
                for j, directionConfig in ipairs(Animations.breakThroughDirectionConfig) do
                    if math.cmpf(directionConfig.xMin, x) <= 0 and math.cmpf(x, directionConfig.xMax) <= 0 and math.cmpf(directionConfig.yMin, y) <= 0 and math.cmpf(y, directionConfig.yMax) <= 0 and
                        math.cmpf(directionConfig.angleMin, directionAngle) <= 0 and math.cmpf(directionAngle, directionConfig.angleMax) <= 0 then

                        table.insert(filteredBreakThroughAnimations, {
                            animation = breakThroughAnimation,
                            config = animationConfig
                        })
                        break
                    end
                end
            end
        end
    end
end

function Athlete:getCandidateMetronomeAnimations()
    local candidateMetronomeAnimations

    if self.currentAnimation then
        candidateMetronomeAnimations = Animations.Next[self.currentAnimation.animationInfo.name].Metronome
    end

    if not candidateMetronomeAnimations then
        candidateMetronomeAnimations = Animations.Tag.Metronome
    end

    return candidateMetronomeAnimations
end

function Athlete:calculateMetronome()
    local candidateMetronomeAnimations = self.candidateMetronomeAnimations or self:getCandidateMetronomeAnimations()
    local metronomeAnimation = selector.randomSelect(candidateMetronomeAnimations)

    self.candidateDribbleActions = { }

    local metronomeAction = Actions.Dribble.new()
    metronomeAction.animation = metronomeAnimation
    metronomeAction.animationType = "Metronome"
    table.insert(self.candidateDribbleActions, { key = metronomeAction, weight = 1 })

    self.candidateMetronomeAnimations = nil
end

function Athlete:getIsPreferCutting()
    return Field.isInCuttingOrToCornerArea(self.position, self.team:getSign())
        and self.team.tactics.sideTactic
        and ((self:isLeftSideF() and self.team.tactics.sideTactic.left == 2)
        or (self:isRightSideF() and self.team.tactics.sideTactic.right == 2))
end

function Athlete:getIsPreferToCorner()
    return Field.isInCuttingOrToCornerArea(self.position, self.team:getSign())
        and self.team.tactics.sideTactic
        and ((self:isLeftSideF() and self.team.tactics.sideTactic.left == 1)
        or (self:isRightSideF() and self.team.tactics.sideTactic.right == 1))
end

function Athlete:calculateDribble()
    local isPreferCutting = self:getIsPreferCutting()
    local isPreferToCorner = self:getIsPreferToCorner()

    local candidateDribbleAnimations = self:getCandidateDribbleAnimations(isPreferCutting)

    local candidateActions = { }
    local originalDistanceToBottomLine = isPreferCutting
        and self:calcAttackDistance(self.position, self.team:getCuttingReferencePosition())
        or self:calcAttackDistance(self.position)

    local originalAngle
    if self.isSideAthlete then
        originalAngle = self:calcAttackAngle(self.position, self.bodyDirection)
    end

    local abilities = self:getAbilities()
    local attackScore = abilities.dribble + abilities.pass + abilities.shoot

    for i, dribbleAnimation in ipairs(candidateDribbleAnimations) do
        local candidateTarget = self.position + vector2.vyrotate(self:getAnimationTargetPosition(dribbleAnimation.animation), self.bodyDirection)

        local score, isCutting = self:calculateDribbleScore(dribbleAnimation, candidateTarget, originalDistanceToBottomLine, isPreferCutting, isPreferToCorner)

        local dribbleAction = Actions.Dribble.new()
        dribbleAction.animation = dribbleAnimation.animation
        dribbleAction.animationType = dribbleAnimation.type
        dribbleAction.isCutting = isCutting

        table.insert(candidateActions, { key = dribbleAction, weight = score })
    end

    self.candidateDribbleActions = selector.maxn(candidateActions, 3, function(t) return t.weight end)
end

function Athlete:calculateDribbleScore(dribbleAnimation, candidateTarget, originalDistanceToBottomLine, isPreferCutting, isPreferToCorner)
    local sign = self.team:getSign()

    local attackEmphasisFactor = 1
    if math.cmpf(math.abs(candidateTarget.y - self.enemyTeam.goal.center.y), 55) < 0
        and math.cmpf(math.abs(candidateTarget.y - self.enemyTeam.goal.center.y), 20) > 0 then
        if math.cmpf(math.abs(candidateTarget.x), 21) > 0 then
            if self.team.tactics.attackEmphasisDetail == 2
                or (self.team.tactics.attackEmphasisDetail == 1 and Field.isInLeftCourtArea(candidateTarget, sign))
                or (self.team.tactics.attackEmphasisDetail == 3 and Field.isInRightCourtArea(candidateTarget, sign)) then
                attackEmphasisFactor = Tactics.attackEmphasis["sideDribble"][self.team.tactics.attackEmphasis]
            end
        else
            attackEmphasisFactor = Tactics.attackEmphasis["centerDribble"][self.team.tactics.attackEmphasis]
        end
    end

    local score
    local isCuttingFlag

    if not Field.isInside(candidateTarget) then
        score = AIUtils.avoidanceScore.unreasonable
    elseif (not isPreferCutting and self:hasEnemyAthleteInFront(candidateTarget - self.position, vector2.dist(self.position, candidateTarget), math.pi / 3))
        or (isPreferCutting and self:hasEnemyAthleteInFront(candidateTarget - self.position, vector2.dist(self.position, candidateTarget), math.pi / 6))
        or (not isPreferCutting and not Field.isInsideEx(candidateTarget, FieldShrinkDelta)) then
        score = AIUtils.avoidanceScore.general
    else
        local distanceScore = 1
        if math.cmpf(vector2.sqrdist(candidateTarget, self.enemyTeam.goal.center), 100) < 0 then
            distanceScore = 0
        else
            local targetAttackDistance = isPreferCutting and self:calcAttackDistance(candidateTarget, self.team:getCuttingReferencePosition())
                or self:calcAttackDistance(candidateTarget)
            local deltaDistance = (originalDistanceToBottomLine - targetAttackDistance) / dribbleAnimation.animation.time
            if math.cmpf(vector2.sqrdist(self.position,self.enemyTeam.goal.center), 441) < 0 then
                distanceScore = 0.1 * deltaDistance + 1
            else
                distanceScore = 0.06 * deltaDistance + 1
            end
        end

        local defensePressureScore = 1
        for _, enemyAthlete in ipairs(self.enemyTeam.athletes) do
            local turnTime = enemyAthlete:getCatchTurnTime(candidateTarget)
            local enemyAthleteDistToTargetPosition = vector2.dist(enemyAthlete.position, candidateTarget)
            if math.cmpf(enemyAthleteDistToTargetPosition, (dribbleAnimation.animation.time - turnTime) * 7.5) <= 0 then
                defensePressureScore = defensePressureScore * (1 - 1 / math.max(enemyAthleteDistToTargetPosition ^ 2, 2))
            end
        end

        score = distanceScore * attackEmphasisFactor * defensePressureScore

        if isPreferCutting or isPreferToCorner then
            local dribbleDirection = candidateTarget - self.position

            local newBodyDirection = vector2.rotate(self.bodyDirection, dribbleAnimation.animation.targetRotation)

            local isToCorner = math.cmpf(vector2.angle(dribbleDirection, vector2.new(0, -sign)), math.pi / 12) <= 0

            local toEnemyGoalVec = self.enemyTeam.goal.center - self.position
            local toCenterVec = vector2.new(-self.position.x, -sign * 30 - self.position.y)
            local isCutting = math.cmpf(vector2.angle(toEnemyGoalVec, toCenterVec),
                vector2.angle(toEnemyGoalVec, dribbleDirection) + vector2.angle(toCenterVec, dribbleDirection)) == 0
                or math.cmpf(vector2.angle(toEnemyGoalVec, toCenterVec),
                vector2.angle(toEnemyGoalVec, newBodyDirection) + vector2.angle(toCenterVec, newBodyDirection)) == 0

            if isPreferCutting and isCutting then
                score = score * 5
                isCuttingFlag = true
            elseif isPreferToCorner and isToCorner and not Field.isInCrossLowArea(self.position, sign) then
                score = score * 2.5
            end
        end

        if Field.isInEnemyArea(self.position, sign)
            and not Field.isInCrossLowArea(self.position, sign)
            and not self:hasEnemyAthleteInFront(vector2.norm(self.enemyTeam.goal.center - self.position), 12.5, math.pi / 2) then
            score = score * 10
        end

        if self.match.allowManualOperation
            and self.team.isPlayerTeam
            and self.team.manualOperateEnterTimes < 1
            and Field.isInFirstEnterManualOperateArea(self.position, sign) then
            score = score * 100
        end
    end

    if dribbleAnimation.type == "DribbleAdjust" then
        score = score * dribbleAdjustScoreCoe
    end

    return score, isCuttingFlag
end

function Athlete:selectPassAdjustAnimation(animationType, forceNext, shouldInSide)
    local sign = self.team:getSign()
    local expectedDirection = Field.isInCrossLowArea(self.position, sign) and vector2.new(0, -sign) or vector2.norm(self.chosenDPSAction.targetPosition - self.position)
    local passAdjustAnimationList = forceNext and self:getFilteredAnimationList(animationType, function(animation)
        local newPosition = self.position + vector2.vyrotate(self:getAnimationTargetPosition(animation), self.bodyDirection)
        local newBodyDirection = vector2.rotate(self.bodyDirection, animation.targetRotation)
        local newAngle = vector2.angle(newBodyDirection, expectedDirection)
        return math.cmpf(newAngle, math.pi * 2 / 3) <= 0 and not self:hasEnemyAthleteInFront(newPosition - self.position, vector2.dist(self.position, newPosition), math.pi / 3)
    end) or Animations.Tag[animationType]

    local passAdjustAnimation
    local minAngle = math.huge

    for i, animation in ipairs(passAdjustAnimationList) do
        local newBodyDirection = vector2.rotate(self.bodyDirection, animation.targetRotation)
        local newAngle = vector2.angle(newBodyDirection, expectedDirection)

        if math.cmpf(newAngle, minAngle) < 0 then
            local insideFlag = false
            if not shouldInSide then
                insideFlag = true
            else
                local newPosition1 = self.position + vector2.vyrotate(self:getAnimationTargetPosition(animation), self.bodyDirection)
                local newPosition2 = self.position + vector2.vyrotate(animation.firstTouchBallPosition, self.bodyDirection)
                local newPosition3 = self.position + vector2.vyrotate(animation.lastTouchBallPosition, self.bodyDirection)
                if Field.isInside(newPosition1) and Field.isInside(newPosition2) and Field.isInside(newPosition3) then
                    insideFlag = true
                end
            end

            if insideFlag then
                minAngle = newAngle
                passAdjustAnimation = animation
            end
        end
    end

    return passAdjustAnimation
end

function Athlete:choosePassAdjustAction()
    local passAdjustAnimationType = "MovePassAdjust"

    local passAdjustAnimation = self:selectPassAdjustAnimation(passAdjustAnimationType, true, true)

    if not passAdjustAnimation then
        passAdjustAnimation = self:selectPassAdjustAnimation("StayPassAdjust", false, true)
        if not passAdjustAnimation then
            passAdjustAnimation = self:selectPassAdjustAnimation(passAdjustAnimationType, true, false)
            if not passAdjustAnimation then
                passAdjustAnimation = self:selectPassAdjustAnimation(passAdjustAnimationType, false, false)
            end
        end
    end

    local passAdjustAction = Actions.Dribble.new()
    passAdjustAction.animation = passAdjustAnimation
    passAdjustAction.animationType = passAdjustAnimationType

    self.chosenDPSAction = passAdjustAction
end

function Athlete:chooseTurnAdjustAction()
    local turnAdjustAnimations = Animations.Tag.TurnAdjust
    local candidateTurnAdjustAnimations = { }

    for _, animation in ipairs(turnAdjustAnimations) do
        local newPosition = self.position + vector2.vyrotate(self:getAnimationTargetPosition(animation), self.bodyDirection)
        local newBodyDirection = vector2.rotate(self.bodyDirection, animation.targetRotation)

        if Field.isInsideEx(newPosition, 0.5) and math.cmpf(vector2.angle(self.enemyTeam.goal.center - newPosition, newBodyDirection), math.pi / 2) < 0 then
            table.insert(candidateTurnAdjustAnimations, animation)
        end
    end

    if #candidateTurnAdjustAnimations > 0 then
        local turnAdjustAnimationType = "TurnAdjust"
        local turnAdjustAnimation = selector.randomSelect(candidateTurnAdjustAnimations)

        local turnAdjustAction = Actions.Dribble.new()
        turnAdjustAction.animation = turnAdjustAnimation
        turnAdjustAction.animationType = turnAdjustAnimationType

        self.chosenDPSAction = turnAdjustAction

        self.match.turnAdjustTimes = self.match.turnAdjustTimes + 1
    end
end

function Athlete:chooseShootAdjustAction()
    local shootAdjustAnimations = Animations.Tag.ShootAdjust
    local candidateShootAdjustAnimations = { }

    for _, animation in ipairs(shootAdjustAnimations) do
        local newPosition = self.position + vector2.vyrotate(self:getAnimationTargetPosition(animation), self.bodyDirection)
        local newBodyDirection = vector2.rotate(self.bodyDirection, animation.targetRotation)

        if Field.isInsideEx(newPosition, 0.5)
            and Field.isInForceShootArea(newPosition, self.team:getSign())
            and math.cmpf(vector2.angle(self.enemyTeam.goal.center - newPosition, newBodyDirection), math.pi / 2) < 0
            and math.cmpf(vector2.sqrdist(newPosition, self.enemyTeam.goal.center), 81) >= 0 then
            table.insert(candidateShootAdjustAnimations, animation)
        end
    end

    if #candidateShootAdjustAnimations > 0 then
        local shootAdjustAnimationType = "ShootAdjust"
        local shootAdjustAnimation = selector.randomSelect(candidateShootAdjustAnimations)

        local shootAdjustAction = Actions.Dribble.new()
        shootAdjustAction.animation = shootAdjustAnimation
        shootAdjustAction.animationType = shootAdjustAnimationType

        self.chosenDPSAction = shootAdjustAction

        self.match.shootAdjustTimes = self.match.shootAdjustTimes + 1
    end
end

function Athlete:chooseCrossLowAdjustAction()
    local crossLowAdjustAnimations = Animations.Tag.CrossLowAdjust
    local candidateCrossLowAdjustAnimations = { }

    for _, animation in ipairs(crossLowAdjustAnimations) do
        local newPosition = self.position + vector2.vyrotate(self:getAnimationTargetPosition(animation), self.bodyDirection)
        local newBodyDirection = vector2.rotate(self.bodyDirection, animation.targetRotation)

        if Field.isInsideEx(newPosition, 2)
            and Field.isInCrossLowArea(newPosition, self.team:getSign())
            and math.cmpf(vector2.angle(self.team:getPenaltyKickPosition() - newPosition, newBodyDirection), 7 * math.pi / 12) < 0
            and (math.cmpf(vector2.angle(newBodyDirection, vector2.new(0, 1)), math.pi / 6) <= 0
                or math.cmpf(vector2.angle(newBodyDirection, vector2.new(0, -1)), math.pi / 6) <= 0)
                then
            table.insert(candidateCrossLowAdjustAnimations, animation)
        end
    end

    if #candidateCrossLowAdjustAnimations > 0 then
        local crossLowAdjustAnimationType = "CrossLowAdjust"
        local crossLowAdjustAnimation = selector.randomSelect(candidateCrossLowAdjustAnimations)

        local crossLowAdjustAction = Actions.Dribble.new()
        crossLowAdjustAction.animation = crossLowAdjustAnimation
        crossLowAdjustAction.animationType = crossLowAdjustAnimationType

        self.chosenDPSAction = crossLowAdjustAction

        return true
    end

    return false
end

function Athlete:manualDribble(manualDribbleIndex)
    if self.manualDribbleList then
        for _, dribbleInfo in ipairs(self.manualDribbleList) do
            if dribbleInfo.index == manualDribbleIndex then
                self.manualOperateSuccessProbability = dribbleInfo.successProbability

                if dribbleInfo.skillId then
                    self.manualOperateSkillId = dribbleInfo.skillId
                else
                    local dribbleAction = Actions.Dribble.new()
                    dribbleAction.animation = dribbleInfo.animation
                    dribbleAction.animationType = "Dribble"
                    dribbleAction.sprintAnimation = dribbleInfo.sprintAnimation

                    self.chosenDPSAction = dribbleAction
                end
            end
        end
    end
end

function Athlete:makeDefenderStagger(dribbleAnimationName)
    for _, defender in ipairs(self.markedBy) do
        if AIUtils.isInSector(defender.position, self.position, self.enemyTeam.goal.center - self.position, 5, math.pi) then
            local rawData = Animations.RawData[dribbleAnimationName]
            local crossAngle = nil
            if rawData and rawData.crossDefense and rawData.btAngle then
                local toDefenderDirection = vector2.norm(defender.position - self.position)
                local sangle = vector2.sangle(toDefenderDirection, self.bodyDirection)
                if Animations.isInAngleRange(rawData.btAngle.Start, rawData.btAngle.End, sangle) and
                    math.cmpf(vector2.sqrdist(self.position, defender.position), 25) <= 0 then
                    defender.shouldStagger = true
                    defender.staggerAnimationName = rawData.crossDefense
                    defender.staggerStartBodyDirection = vector2.norm(self.position - defender.position)
                end
            end
        end
    end
end

local function insertDribbleAnimations(candidateDribbleAnimations, subDribbleAnimations, subDribbleAnimationType, excludedAnimationKey)
    if subDribbleAnimations then
        for i, dribbleAnimation in ipairs(subDribbleAnimations) do
            if dribbleAnimation.name ~= excludedAnimationKey then
                table.insert(candidateDribbleAnimations, {animation = dribbleAnimation, type = subDribbleAnimationType})
            end
        end
    end
end

function Athlete:getCandidateDribbleAnimations(isPreferCutting)
    local candidateDribbleAnimations = { }

    local hasEnemyAthleteAround = self:hasEnemyAthleteInFront(self.bodyDirection, 3, 2 * math.pi)

    local lastAnimationType
    if self.currentAnimation then
        lastAnimationType = self.currentAnimation.type
    end

    if isPreferCutting then
        insertDribbleAnimations(candidateDribbleAnimations, self:getFilteredAnimationList("Cutting", nil, true, nil), "Cutting", nil)
    else
        if not hasEnemyAthleteAround --附近防守压力小
            and Field.isInDribbleAdjustArea(self.position) --在带球调整区域
            and lastAnimationType == "StayCatchGroundNoDef" then --上次动作为原地接球
            insertDribbleAnimations(candidateDribbleAnimations, self:getFilteredAnimationList("DribbleAdjust", nil, nil, true), "DribbleAdjust")
            return candidateDribbleAnimations
        end

        if self:hasEnemyAthleteInFront(self.enemyTeam.goal.center - self.position, 4, math.pi / 2)then
            insertDribbleAnimations(candidateDribbleAnimations, self:getFilteredAnimationList("RapidDribble", nil, nil, true), "RapidDribble", nil)
        elseif Field.isInEnemyArea(self.position, self.team:getSign()) then
            insertDribbleAnimations(candidateDribbleAnimations, self:getFilteredAnimationList("Dribble", nil, nil, true), "Dribble", nil)
            insertDribbleAnimations(candidateDribbleAnimations, self:getFilteredAnimationList("HighSpeedDribble", nil, nil, true), "HighSpeedDribble", nil)
        else
            insertDribbleAnimations(candidateDribbleAnimations, self:getFilteredAnimationList("Dribble", nil, nil, true), "Dribble", nil)
        end
        insertDribbleAnimations(candidateDribbleAnimations, self:getFilteredAnimationList("TurnDribble", nil, nil, true), "TurnDribble", nil)
    end

    return candidateDribbleAnimations
end

function Athlete:pushDribbleAnimation()
    local animation = self:pushAnimationWithType(self.chosenDPSAction.animation, true, nil, nil, self.chosenDPSAction.animationType)
    animation.isDribble = true
end

function Athlete:startDribble()
    self.team.dribbleTimes = self.team.dribbleTimes + 1
    self.dribbleSuccessProbability = self.dribbleSuccessProbability or 1
    self.team.continuousCatchPassCount = 0

    self:pushDribbleAnimation()

    self.targetPosition = self.animationQueue[1].targetPosition

    self.dribbleState.startPosition = self.position
    self.dribbleState.startBodyDirection = self.bodyDirection
    self.dribbleState.lastDecideTime = self.match.currentTime
    self.dribbleState.stealAthlete = nil
    self.dribbleState.foulAthlete = nil

    self:stopEnemyGkAnimation()

    self.match:checkCanBeEndedNow()

    if self.inManualOperating and self.chosenDPSAction.sprintAnimation then
        self:makeDefenderStagger(self.chosenDPSAction.animation.name)
    end
end

function Athlete:updateOutputDribbleActionStatus()
    local ball = self.match.ball
    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        local dribbleAction = Actions.Dribble.new()
        dribbleAction.successProbability = self.dribbleSuccessProbability

        if self.dribbleState.stealAthlete ~= nil then
            dribbleAction.isStolen = true
            dribbleAction.stealPosition = ball.nextTask.stealPosition
            dribbleAction.stealAthlete = ball.nextTask.stealer
            dribbleAction.stealDuration = ball.nextTask.stealTime - self.match.currentTime
        end

        if self.dribbleState.foulAthlete ~= nil then
            dribbleAction.isFouled = true
            dribbleAction.foulPosition = ball.nextTask.foulPosition
            dribbleAction.foulAthlete = ball.nextTask.fouler
            dribbleAction.foulDuration = ball.nextTask.foulTime - self.match.currentTime
        end

        self.outputActionStatus = dribbleAction
    end
end

function Athlete:addStealTask(selectedSteal, isDiving)
    local stealAthlete = selectedSteal.stealAthlete
    self.dribbleState.stealAthlete = stealAthlete
    self.match.ball.nextTask = Ball.Steal.new({
        stealer = stealAthlete,
        stealTime = self.match.currentTime + selectedSteal.dribbleTimeBeforeStolen,
        stealPosition = selectedSteal.stealPosition,
        stealAnimation = selectedSteal.stealAnimation,
        isDiving = isDiving,
        hasGamesmanshipDebuff = self:hasBuff(Skills.Gamesmanship, "base"),
        stealTargetAthlete = self,
    })
    stealAthlete:setMark(nil)
    stealAthlete:setCover(nil)
    stealAthlete:stopAnimation()
    self:logInfo("stop athlete %d, add steal task", stealAthlete.id)
end

function Athlete:addFoulTask(selectedFoul, isDiving)
    local foulAthlete = selectedFoul.foulAthlete
    self.dribbleState.foulAthlete = foulAthlete
    self.match.ball.nextTask = Ball.Foul.new({
        fouler = foulAthlete,
        foulTime = self.match.currentTime + selectedFoul.dribbleTimeBeforeFouled,
        foulPosition = Field.forceInsideEx(selectedFoul.foulPosition, 0.3),
        foulAnimation = selectedFoul.foulAnimation,
        destMatchState = selectedFoul.destMatchState,
        isDiving = isDiving,
    })
    foulAthlete:setMark(nil)
    foulAthlete:setCover(nil)
    foulAthlete:stopAnimation(true)
    self:logInfo("stop athlete %d, add foul task", foulAthlete.id)
    self:judgeGreatSpeedEx1("Foul")
    self.enemyTeam.athleteOfRole[26]:judgePenaltyKickKillerEx1Sign()
end

function Athlete:judgeEnemyStealAndFoul()
    if self.isEncounteringSlidingTackle then
        self.isEncounteringSlidingTackle = nil
        return
    end

    if self.match:notIsInStealCD() then
        local candidateSteals, candidateFouls = AIUtils.getCandidateStealsAndFouls(self)

        local isDiving = self:hasBuff(Skills.Diving)
        if not self:tryToSelectSteal(candidateSteals, isDiving) then
            self:judgeEnemyFouls(candidateFouls, isDiving)
        end
    end
end

function Athlete:tryToSelectSteal(candidateSteals, isDiving)
    if #candidateSteals ~= 0 then
        self.team.mayBeStolenDribbleTimes = self.team.mayBeStolenDribbleTimes + 1
    end

    local selectedSteal

    local dribbleAbility = self:getAbilities().dribble
    self.dribbleSuccessProbability = 1

    for i, v in ipairs(candidateSteals) do
        local enemy = v.key.stealAthlete
        enemy:judgePoacher()

        v.probability = AIUtils.getStealProbability(dribbleAbility, enemy:getAbilities().steal, enemy, self.isSideAthlete)
        v.probability = enemy:judgeStealMasterEx1(v.probability)

        v.key.bounceProbability = AIUtils.getStealBounceProbability(v.probability)

        local newProbability = self.dribbleSuccessProbability * (1 - v.probability)

        if not (self.manualOperateSuccessProbability
            and math.cmpf(newProbability, self.manualOperateSuccessProbability) < 0) then
            enemy.stealRate = v.probability
            self.dribbleSuccessProbability = newProbability

            if not selectedSteal and selector.tossCoin(v.probability) then
                selectedSteal = v.key
            end
        end
    end

    self.dribbleSuccessProbability = math.max(self.manualOperateSuccessProbability or self.dribbleSuccessProbability, 0.01)
    self.dribbleSuccessProbability = self:judgeDribbleMasterEx1(self.dribbleSuccessProbability)

    if selectedSteal then
        self:addStealTask(selectedSteal, isDiving)

        local poacherSkill = selectedSteal.stealAthlete:getFirstBuffSkill(Skills.Poacher)
        if poacherSkill ~= nil then
            if selectedSteal.stealAthlete:judgePoacherEx1() then
                table.insert(selectedSteal.stealAthlete.toBeCastedSkills, poacherSkill.class)
            end
        end

        local rationalStealSkill = selectedSteal.stealAthlete:getFirstBuffSkill(Skills.RationalSteal)
        if rationalStealSkill ~= nil then
            table.insert(selectedSteal.stealAthlete.toBeCastedSkills, rationalStealSkill.class)
        end

        local blackHeartSkill = selectedSteal.stealAthlete:getFirstBuffSkill(Skills.BlackHeart)
        if blackHeartSkill ~= nil then
            table.insert(selectedSteal.stealAthlete.toBeCastedSkills, blackHeartSkill.class)
            selectedSteal.stealAthlete:judgeBlackHeartEnemyBuff()
        end

        return true
    end

    return false
end

function Athlete:judgeEnemyFouls(candidateFouls, isDiving)
    for i, v in ipairs(candidateFouls) do
        if selector.tossCoin(v.probability) then
            self:addFoulTask(v.key, isDiving)
            break
        end
    end
end

function Athlete:judgeEnemySlidingTackle()
    if self.match:notIsInStealCD() then
        local candidiateSteals = AIUtils.getCandidateStealsAndFouls(self, 4, Animations.Tag.SlidingTackle)

        local dribbleAbility = self:getAbilities().dribble
        for i, candidateSteal in ipairs(candidiateSteals) do
            local candidateStealKey = candidateSteal.key
            local stealAthlete = candidateStealKey.stealAthlete
            local skillInstance = stealAthlete:getCooldownSkill(Skills.SlidingTackle)
            if not stealAthlete:isDivingEx1Blocked() and skillInstance and selector.tossCoin(skillInstance.probability) then
                --先加buff，后计算抢断成功率
                stealAthlete:addBuff(skillInstance.buff, stealAthlete)
                candidateSteal.probability = AIUtils.getStealProbability(dribbleAbility, stealAthlete:getAbilities().steal, stealAthlete, self.isSideAthlete)
                candidateStealKey.bounceProbability = AIUtils.getStealBounceProbability(candidateSteal.probability)

                if selector.tossCoin(candidateSteal.probability) then
                    self:addStealTask(candidateStealKey, self:hasBuff(Skills.Diving))
                    table.insert(stealAthlete.toBeCastedSkills, skillInstance.class)
                    stealAthlete:judgeSlidingTackleEx1(self)
                    local rationalStealSkill = stealAthlete:getFirstBuffSkill(Skills.RationalSteal)
                    if rationalStealSkill ~= nil then
                        table.insert(stealAthlete.toBeCastedSkills, rationalStealSkill.class)
                    end

                end
                --不管有没有抢断成功，都不再进行普通抢断的判断
                self.isEncounteringSlidingTackle = true
                break
            end
        end
    end
end

function Athlete:calcDribbleSuccessProbability(targetDribbleAnimationInfo, skillId)
    local candidateSteals, candidateFouls = AIUtils.getCandidateStealsAndFoulsWithTarget(self, nil, nil, nil, targetDribbleAnimationInfo)

    local tempAthleteAbilities = nil
    if AIUtils.isSkillIdCorrespondSkill(skillId, Skills.BreakThrough) or AIUtils.isSkillIdCorrespondSkill(skillId, Skills.Diving) then
        local skill = nil
        if AIUtils.isSkillIdCorrespondSkill(skillId, Skills.BreakThrough) then
            skill = self:getCooldownSkill(Skills.BreakThrough)
        elseif AIUtils.isSkillIdCorrespondSkill(skillId, Skills.Diving) then
            skill = self:getCooldownSkill(Skills.Diving)
        end

        if skill ~= nil then
            tempAthleteAbilities = shallowClone(self:getAbilities())
            skill.buff.abilitiesModifier(tempAthleteAbilities, self, self)
        end
    else
        tempAthleteAbilities = self:getAbilities()
    end

    local successProbability = 1

    if not AIUtils.isSkillIdCorrespondSkill(skillId, Skills.Metronome) then
        local dribbleAbility = tempAthleteAbilities.dribble
        for i, v in ipairs(candidateSteals) do
            local enemy = v.key.stealAthlete
            local enemyStealAbility = enemy:getAbilities().steal
            v.probability = AIUtils.getStealProbability(dribbleAbility, enemyStealAbility, enemy, self.isSideAthlete)
            successProbability = successProbability * (1 - v.probability)
        end
    end

    successProbability = math.min(self:judgeDribbleMasterEx1(successProbability), 1)
    return math.max(successProbability, 0.01)
end

function Athlete:judgeEnemyRationalSteal()
    if self.match:notIsInStealCD() then
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:judgeRationalSteal()
        end
    end
end

function Athlete:isMeetStealAndFoulConditions()
   return not self.isManualFollowedDribble
    and self.chosenDPSAction.animationType ~= "ShootAdjust"
    and self.chosenDPSAction.animationType ~= "CrossLowAdjust"
end

function Athlete:judgeDribbleMasterEx1(currentSuccessProbility)
    local skill = self:getCooldownSkill(Skills.DribbleMasterEx1)
    if skill ~= nil and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
        return skill.buff.successProbilityModifier(currentSuccessProbility)
    end
    return currentSuccessProbility
end