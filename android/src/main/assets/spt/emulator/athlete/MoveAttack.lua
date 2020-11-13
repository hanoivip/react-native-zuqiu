if jit then jit.off(true, true) end

local Athlete = import("./Core")
local AIUtils = import("../AIUtils")
local vector2 = import("../libs/vector")
local Field = import("../Field")
local selector = import("../libs/selector")
local Animations = import("../animations/Animations")

function Athlete:getDefenseForce()
    local defenseForce = vector2.new(0, 0)
    for i, defenseAthlete in ipairs(self.enemyTeam.athletes) do
        defenseForce = defenseForce + vector2.norm(self.position - defenseAthlete.position) / math.max(vector2.sqrdist(self.position, defenseAthlete.position), 1)
    end

    return defenseForce
end

function Athlete:isInCoolDownState(moveStatus)
    if moveStatus == AIUtils.moveStatus.runningForward then
        return math.sign(self.moveStatusRemainingTime.runningForward) > 0
    elseif moveStatus == AIUtils.moveStatus.offTheBall then
        return math.sign(self.moveStatusRemainingTime.offTheBall) > 0
    end

    return false
end

function Athlete:getBallOwnerForce(ballOwnerPosition, selfToBallOwnerNormVec)
    local forceSourcePosition = ballOwnerPosition - selfToBallOwnerNormVec * 10
    return vector2.norm(forceSourcePosition - self.position) * math.min(vector2.sqrdist(self.position, forceSourcePosition) / 10, 1)
end

function Athlete:getAttackDirectionForce()
    local forceSourcePosition = self.isSideAthlete and vector2.new(self.area.center.x, self.enemyTeam.goal.center.y)
        or self.enemyTeam.goal.center

    return vector2.norm(forceSourcePosition - self.position) * math.min(vector2.sqrdist(self.position, forceSourcePosition) / 100, 1)
end

function Athlete:getBestRunningForwardDestination(ballOwnerPosition, ballOwnerToSelfNormVec)
    local passForbiddenDirectionRanges = AIUtils.getPassForbiddenDirectionRanges(self, ballOwnerPosition, math.pi / 6)
    local bestRunningForwardDestination
    if AIUtils.isInForbiddenDirectionRanges(ballOwnerToSelfNormVec, passForbiddenDirectionRanges) then
        local minToEnemyGoalSqrDist = math.huge
        for i, forbiddenDirectionRange in ipairs(passForbiddenDirectionRanges) do
            if not AIUtils.isInForbiddenDirectionRanges(forbiddenDirectionRange.startDirection, passForbiddenDirectionRanges) then
                local startRunningForwardDestnation = ballOwnerPosition + forbiddenDirectionRange.startDirection * math.cos(vector2.angle(ballOwnerToSelfNormVec, forbiddenDirectionRange.startDirection)) * vector2.dist(self.position, ballOwnerPosition)
                local startSqrDist = math.abs(startRunningForwardDestnation.y - self.enemyTeam.goal.center.y)
                if math.cmpf(startSqrDist, minToEnemyGoalSqrDist) < 0 then
                    minToEnemyGoalSqrDist = startSqrDist
                    bestRunningForwardDestination = startRunningForwardDestnation
                end
            end

            if not AIUtils.isInForbiddenDirectionRanges(forbiddenDirectionRange.endDirection, passForbiddenDirectionRanges) then
                local endRunningForwardDestnation = ballOwnerPosition + forbiddenDirectionRange.endDirection * math.cos(vector2.angle(ballOwnerToSelfNormVec, forbiddenDirectionRange.endDirection)) * vector2.dist(self.position, ballOwnerPosition)
                local endSqrDist = math.abs(endRunningForwardDestnation.y - self.enemyTeam.goal.center.y)
                if math.cmpf(endSqrDist, minToEnemyGoalSqrDist) < 0 then
                    minToEnemyGoalSqrDist = endSqrDist
                    bestRunningForwardDestination = endRunningForwardDestnation
                end
            end
        end
    else
        bestRunningForwardDestination = self.position
    end

    return bestRunningForwardDestination
end

function Athlete:getRunningForwardEmptySpaceForce(bestRunningForwardDestination)
    self:logAssert(bestRunningForwardDestination ~= nil, "bestRunningForwardDestination should not be nil")
    return vector2.norm(bestRunningForwardDestination - self.position) * math.min(vector2.sqrdist(self.position, bestRunningForwardDestination) / 10, 1)
end

function Athlete:getRunningForwardForce(ballOwnerPosition, bestRunningForwardDestination)
    return self:getDefenseForce() + self:getAttackDirectionForce(ballOwnerPosition, vector2.norm(ballOwnerPosition - self.position))
end

function Athlete:getAttackAthleteRepulsiveForce()
    local attackAthleteRepulsiveForce = vector2.new(0, 0)
    for i, attackAthlete in ipairs(self.team.athletes) do
        if attackAthlete ~= self then
            attackAthleteRepulsiveForce = attackAthleteRepulsiveForce + vector2.norm(self.position - attackAthlete.position) / vector2.sqrdist(self.position, attackAthlete.position)
        end
    end

    return attackAthleteRepulsiveForce
end

function Athlete:getOffTheBallTargetForce(offTheBallTargetPosition)
    return vector2.norm(offTheBallTargetPosition - self.position) * math.min(vector2.sqrdist(self.position, offTheBallTargetPosition) / 10, 1)
end

function Athlete:getOffTheBallForce(offTheBallTargetPosition)
    return self:getDefenseForce() + self:getOffTheBallTargetForce(offTheBallTargetPosition)
end

function Athlete:isRunningForwardAthlete()
    return self.team.runningForwardAthletes.leftAthlete == self
        or self.team.runningForwardAthletes.centerAthlete == self
        or self.team.runningForwardAthletes.rightAthlete == self
end

function Athlete:isRunningForwardAfterPassAthlete()
    return self.team.latestPassAthlete == self
end

function Athlete:getOffTheBallTargetPosition()
    if self.team.offTheBallTargetsStatus.leftTarget.bestAthlete == self then
        return self.team.offTheBallTargetsStatus.leftTarget.position
    elseif self.team.offTheBallTargetsStatus.centerTarget.bestAthlete == self then
        return self.team.offTheBallTargetsStatus.centerTarget.position
    elseif self.team.offTheBallTargetsStatus.rightTarget.bestAthlete == self then
        return self.team.offTheBallTargetsStatus.rightTarget.position
    end

    return nil
end

function Athlete:isContinueOffTheBall()
    local result = self.moveStatus == AIUtils.moveStatus.offTheBall
        and not self:isInOffSideArea()

    if not result and self.moveStatus == AIUtils.moveStatus.offTheBall then
        self.moveStatusRemainingTime.offTheBall = 5
    end

    return result
end

function Athlete:isContinueRunningForward()
    local result = not self:isInOffSideArea()
        and self.moveStatus == AIUtils.moveStatus.runningForward
        and math.cmpf(vector2.sqrdist(self.position, self.match.ball.position), 1600) <= 0
        and math.cmpf(self.position.y * self.team:getSign(), self.area.center.y * self.team:getSign() - 10) > 0

    if not result and self.moveStatus == AIUtils.moveStatus.runningForward then
        self.moveStatusRemainingTime.runningForward = 5
    end

    return result
end

function Athlete:isContinueRunningForwardAfterPass()
    return not self:isInOffSideArea()
        and self.moveStatus == AIUtils.moveStatus.runningForwardAfterPass
        and math.cmpf(vector2.sqrdist(self.position, self.match.ball.position), 1600) <= 0
        and math.cmpf(vector2.sqrdist(self.position, self.area.center), self:isBack() and 100 or 225) <= 0
end

function Athlete:isContinueCounterAttackRunningForward()
    return not self:isInOffSideArea()
        and math.cmpf(-self.team:getSign() * self.position.y, 38.5) < 0
        and self.moveStatus == AIUtils.moveStatus.counterRunningForward
        and math.cmpf(self.position.y * self.team:getSign(), self.area.center.y * self.team:getSign() - 10) > 0
end

function Athlete:moveAttackDecide()
    local isAnimationEnd = self:isAnimationEnd(self.match.currentTime)
    if not isAnimationEnd and not self:canBeBroken() then
        return
    end

    if self:hasBall() then
        self.match.ball:setOwner(nil)
    end

    if self.match.isFrozen then
        if isAnimationEnd then
            self:frozenStay()
        end
        return
    end

    local sign = self.team:getSign()
    local targetPosition = self.area.center

    if self.match.ballOutOfField then
        if self.match.isGoal and Field.isInEnemyArea(self.position, sign) then
            if self.match.isInPenaltyShootOut then
                self:stayCelebrateAfterGoal()
            else
                self:setMoveStatus(AIUtils.moveStatus.attackKeepFormation)
                self:predictMoveAttack(vector2.new(Field.halfWidth, Field.halfLength) * -sign)
            end
            return
        end
    end

    if self.match.ballOutOfField or (self.match.ball.nextTask and self.match.ball.nextTask.isBounced) then
        self:openingStandAfterBallOut()
        return
    end

    local ball = self.match.ball
    local ballOwner = ball.owner
    local ballPosition = ball.owner and ball.position or ball.flyTargetPosition

    local offTheBallTargetPosition = self:getOffTheBallTargetPosition()
    local isInOffSideArea = self:isInOffSideArea()

    local isCounterAttackRunningForward = self:isContinueCounterAttackRunningForward()
    local isRunningForwardAfterPass = self:isContinueRunningForwardAfterPass() or
            (self:isRunningForwardAfterPassAthlete()
            and not self:isGoalkeeper())
    local isRunningForward = self:isRunningForwardAthlete()

    --断球后前插
    if isCounterAttackRunningForward then
        targetPosition = vector2.new(self.position.x, self.area.center.y - sign * 12)
        self:setMoveStatus(AIUtils.moveStatus.counterRunningForward)
    --传球后前插
    elseif isRunningForwardAfterPass then
        local runningForwardForce  = self:getRunningForwardForce(ballPosition, bestRunningForwardDestination)
        targetPosition = vector2.norm(runningForwardForce) * 10 * vector2.magnitude(runningForwardForce) + self.position
        self:setMoveStatus(AIUtils.moveStatus.runningForwardAfterPass)
        if self.team.latestPassAthlete == self then
            self.team.latestPassAthlete = nil
        end
    --抢点
    elseif offTheBallTargetPosition then
        local offTheBallForce = self:getOffTheBallForce(offTheBallTargetPosition)
        targetPosition = vector2.norm(offTheBallForce) * 10 * vector2.magnitude(offTheBallForce) + self.position

        self:setMoveStatus(AIUtils.moveStatus.offTheBall)
    --前插
    elseif isRunningForward then
        local runningForwardForce  = self:getRunningForwardForce(ballPosition, bestRunningForwardDestination)
        targetPosition = vector2.norm(runningForwardForce) * 10 * vector2.magnitude(runningForwardForce) + self.position
        self:setMoveStatus(AIUtils.moveStatus.runningForward)
    else
        self:setMoveStatus(AIUtils.moveStatus.attackKeepFormation)
    end

    if self.moveStatus ~= AIUtils.moveStatus.runningForward
        and self.moveStatus ~= AIUtils.moveStatus.runningForwardAfterPass
        and self.moveStatus ~= AIUtils.moveStatus.offTheBall
        and math.cmpf(self:getDistanceYToOffsideLine(targetPosition), 1) < 0 then
        targetPosition = vector2.new(targetPosition.x, self.team.offsideLine + sign)
    end

    -- 防止目标点跑出场外
    targetPosition = Field.forceInsideEx(targetPosition, 1)

    if self:isGoalkeeper() then
        self.targetPosition = targetPosition
        if not Field.isInNormalGkArea(self.position, -sign) then
            self:predictMoveAttack(targetPosition, 8)
        else
            self:predictGoalKeeperMove(targetPosition, vector2.norm(ballPosition - targetPosition))
        end
    else
        self:predictMoveAttack(targetPosition)
    end
end

function Athlete:isSideGuardPreferRunningForward()
    return self.team.tactics.sideGuardTactic
        and ((self:isLeftSideGuard() and self.team.tactics.sideGuardTactic.left == 1)
        or (self:isRightSideGuard() and self.team.tactics.sideGuardTactic.right == 1))
end

function Athlete:isSideGuardPreferKeepFormation()
    return self.team.tactics.sideGuardTactic
        and ((self:isLeftSideGuard() and self.team.tactics.sideGuardTactic.left == 2)
        or (self:isRightSideGuard() and self.team.tactics.sideGuardTactic.right == 2))
end

function Athlete:isSideMidFieldPreferRunningForward()
    return self.team.tactics.sideMidFieldTactic
        and ((self:isLeftSideMidField() and self.team.tactics.sideMidFieldTactic.left == 1)
        or (self:isRightSideMidField() and self.team.tactics.sideMidFieldTactic.right == 1))
end

function Athlete:isSideMidFieldPreferKeepFormation()
    return self.team.tactics.sideMidFieldTactic
        and ((self:isLeftSideMidField() and self.team.tactics.sideMidFieldTactic.left == 2)
        or (self:isRightSideMidField() and self.team.tactics.sideMidFieldTactic.right == 2))
end
