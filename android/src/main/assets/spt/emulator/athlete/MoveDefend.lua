if jit then jit.off(true, true) end

local Athlete = import("./Core")
local vector2 = import("../libs/vector")
local AIUtils = import("../AIUtils")
local Field = import("../Field")
local Ball = import("../Ball")
local geometry = import("../libs/geometry")
local segment = import("../libs/segment")
local Skills = import("../skills/Skills")
local Tactics = import("../Tactics")
local selector = import("../libs/selector")
local Animations = import("../animations/Animations")

local function calcMarkVector(defender, basePosition)
    local attackPosition = vector2.new(basePosition.x * 0.54, defender.team.goal.center.y) -- 把球场宽度大致映射到禁区宽度
    local markVector = vector2.norm(attackPosition - basePosition)
    return markVector
end

local function calcMarkDist(defender, basePosition)
    local baseDist = vector2.dist(defender.team.goal.center, basePosition)
    return math.clamp(baseDist * 0.06 + 0.8, 1.8, 4.5) + math.clamp(0.04 * vector2.sqrdist(defender.position, basePosition) - 1, 0, 8)
end

function Athlete:markPosition(speedSpec, basePosition, direction)
    local markVector = calcMarkVector(self, basePosition)
    local markDist = calcMarkDist(self, basePosition)
    local markTargetPosition = basePosition + markVector * markDist
    local angle = vector2.angle(markVector, self.position - basePosition - markVector)
    local towardPosition = basePosition + markVector * angle

    self:predictMoveDefend(markTargetPosition, towardPosition, true)
end

function Athlete:markTargetPosition(speedSpec, enemy)
    self:setMoveStatus(AIUtils.moveStatus.markHandler)
    self:markPosition(speedSpec, enemy.position, enemy.direction)
end

function Athlete:markCatchPosition(speedSpec, ballNextTask)
    if ballNextTask.type == "High" and ballNextTask.isLeadPass
        and (AIUtils.isSkillIdCorrespondSkill(ballNextTask.skillId, Skills.PuntKick) or AIUtils.isSkillIdCorrespondSkill(ballNextTask.skillId, Skills.OverHeadBall)) then
        self:setMoveStatus(AIUtils.moveStatus.markHighLeadPassCatcher)
    elseif ballNextTask.type == "Ground" and ballNextTask.isLeadPass and AIUtils.isSkillIdCorrespondSkill(ballNextTask.skillId, Skills.ThroughBall) then
        self:setMoveStatus(AIUtils.moveStatus.markGroundLeadPassCatcher)
    else
        self:setMoveStatus(AIUtils.moveStatus.markCatcher)
    end
    -- 预估接球位置
    if ballNextTask.isLeadPass then
        if ballNextTask.type == "Ground" and AIUtils.isSkillIdCorrespondSkill(ballNextTask.skillId, Skills.ThroughBall) then
            self:markPosition(speedSpec, ballNextTask.targetPosition, ballNextTask.receiver.direction)
        else
            self:markPosition(speedSpec, ballNextTask.targetPosition + ballNextTask.receiver.direction * 2, ballNextTask.receiver.direction)
        end
    else
        if self.match.cornerKickDefender == self or self.match.wingDirectFreeKickDefender == self then
            self:predictMoveDefend(ballNextTask.receiver.position, ballNextTask.receiver.position, true)
        else
            self:markPosition(speedSpec, ballNextTask.targetPosition, ballNextTask.receiver.direction)
        end
    end
end

function Athlete:assistMarkTargetPosition(speedSpec, enemy)
    local markVector = calcMarkVector(self, enemy.position)
    local markDist = calcMarkDist(self, enemy.position) + 1
    local markTargetPosition = enemy.position + markVector * markDist
    local markTargetPosition1 = vector2.new(markTargetPosition.x - 1, markTargetPosition.y)
    local markTargetPosition2 = vector2.new(markTargetPosition.x + 1, markTargetPosition.y)
    if not Field.isInside(markTargetPosition1) then
        markTargetPosition = markTargetPosition2
    elseif not Field.isInside(markTargetPosition2) then
        markTargetPosition = markTargetPosition1
    else
        if math.cmpf(vector2.sqrdist(self.position, markTargetPosition1), vector2.sqrdist(self.position, markTargetPosition2)) <= 0 then
            markTargetPosition = markTargetPosition1
        else
            markTargetPosition = markTargetPosition2
        end
    end
    local angle = vector2.angle(markVector, self.position - enemy.position - markVector)
    local towardPosition = enemy.position + markVector * angle

    self:setMoveStatus(AIUtils.moveStatus.assitmarkHandler)
    self:predictMoveDefend(markTargetPosition, towardPosition, true)
end

function Athlete:markNoBallTargetPosition(speedSpec, enemy, predictedBackLine)
    local enemyPosition = enemy.position
    local markCoe = 1 - math.clamp((math.abs(self.team.goal.center.y - enemyPosition.y) - 30) / 50, 0, 1)
    local markVector = calcMarkVector(self, enemyPosition)
    local markDist = calcMarkDist(self, enemyPosition)
    local markTargetPosition = (enemyPosition + markVector * markDist) * markCoe + self.area.center * (1 - markCoe)

    local offsideLineY = enemy.team.offsideLine
    local sign = self.team:getSign()

    if self:isBack() then
        markTargetPosition.y = predictedBackLine
    elseif math.cmpf(markTargetPosition.y * sign, offsideLineY * sign) > 0 then
         markTargetPosition.y = offsideLineY
    end

    self:setMoveStatus(AIUtils.moveStatus.markNonHandler)
    self:predictMoveDefend(markTargetPosition)
end

function Athlete:cover(speedSpec, enemy, targetY)
    local enemyNextPosition = enemy.currentAnimation == nil and enemy.position or enemy.currentAnimation.targetPosition
    local coverTargetPosition = vector2.new(enemyNextPosition.x, targetY)

    self:setMoveStatus(AIUtils.moveStatus.markNonHandler)
    self:predictMoveDefend(coverTargetPosition)
end

function Athlete:frozenDefend()
    if not self:isAnimationEnd(self.match.currentTime) then
        return
    end

    if (self.match.frozenType == "CenterDirectFreeKick" and table.isArrayInclude(self.team.centerDirectFreeKickWall, self))
        or (self.match.frozenType == "WingDirectFreeKick" and table.isArrayInclude(self.team.wingDirectFreeKickWall, self)) then
        self:wallStand()
    else
        self:frozenStay()
    end
end

function Athlete:gkMoveDefendDecide()
    if self.match.ballOutOfField then
        self:openingStandAfterBallOut()
        return
    end

    local ball = self.match.ball
    local abilities = self:getAbilities()
    local defendArea = self.area
    local sign = self.team:getSign()
    local ballPosition = ball.position
    local nextTask = self.match.ball.nextTask
    if nextTask and nextTask.class == Ball.Pass then
        ballPosition = nextTask.targetPosition
    end

    if not AIUtils.isInArea(self.position, defendArea) then
        self:setMark(nil)
        self:setMoveStatus(AIUtils.moveStatus.defendKeepFormation)
        self:predictMoveDefend(defendArea.center, ballPosition)
        return
    end

    local targetPosition = vector2.clone(defendArea.center)
    targetPosition.x = math.clamp(ballPosition.x * 0.15, -Field.halfGoalWidth + 0.3, Field.halfGoalWidth - 0.3)

    self:setMark(nil)

    local dir = vector2.norm(ballPosition - targetPosition)
    if math.cmpf(math.sign(dir.y) * sign, 0) > 0 then
        dir.y = 0
        if math.cmpf(dir.x, 0) == 0 then
            dir.y = -sign
        else
            dir = vector2.norm(dir)
        end
    end

    self:predictGoalKeeperMove(targetPosition, dir)
end

function Athlete:nonGkMoveDefendDecide()
    if not self:isAnimationEnd(self.match.currentTime) and not self:canBeBroken() then
        return
    end

    self:setMoveStatus(0)
    self.team.latestPassAthlete = nil

    -- 处于不可打断状态时解除盯防
    if not (self:canBeInterruptible() or self:isAnimationEnd(self.match.nextTime)) then
        self:setMark(nil)
        self:setClosingDown(nil)
        self:setFillingIn(nil)
        return
    end

    if self.match.ballOutOfField or (self.match.ball.nextTask and self.match.ball.nextTask.isBounced) then
        self:openingStandAfterBallOut()
        return
    end

    local abilities = self:getAbilities()
    -- 紧盯持球人
    local enemyAthleteWithBall = self.team.enemyAthleteWithBall
    if enemyAthleteWithBall and not enemyAthleteWithBall:isGoalkeeper() then
        if not enemyAthleteWithBall.closedBy and self.team.nearestAthleteToMarkEnemyAthleteWithBall == self
            or enemyAthleteWithBall.closedBy == self then
            self:setMark(nil)
            self:setClosingDown(enemyAthleteWithBall)
            self:markTargetPosition(abilities.defendFastSpeed.forward, enemyAthleteWithBall)
            return
        end

        if Field.isInFillInArea(enemyAthleteWithBall.position, enemyAthleteWithBall.team:getSign())
            and (enemyAthleteWithBall.closedBy and
                math.cmpf(vector2.angle(self.team.goal.center - enemyAthleteWithBall.position,
                enemyAthleteWithBall.closedBy.position - enemyAthleteWithBall.position),
                math.pi / 2) > 0)
            and ((not enemyAthleteWithBall.filledInBy
                and self.team.nearestAthleteToFillInEnemyAthleteWithBall == self)
                or (enemyAthleteWithBall.filledInBy == self
                and math.cmpf(vector2.angle(self.team.goal.center - enemyAthleteWithBall.position,
                self.position - enemyAthleteWithBall.position), math.pi / 2) <= 0)) then
            self:setFillingIn(enemyAthleteWithBall)
            self:markTargetPosition(abilities.defendFastSpeed.forward, enemyAthleteWithBall)
            return
        end
    end

    self:setClosingDown(nil)
    self:setFillingIn(nil)

    -- 盯防接球点
    local nextTask = self.match.ball.nextTask
    if nextTask and nextTask.class == Ball.Pass and Field.isInEnemyArea(nextTask.targetPosition, -self.team:getSign()) then
        local enemyAthleteToCatchBall = nextTask.receiver
        if self.team.nearestAthleteToMarkEnemyAthleteWithBall == self
            or self.match.cornerKickDefender == self
            or self.match.wingDirectFreeKickDefender == self then
            self:setMark(enemyAthleteToCatchBall)
            self:markCatchPosition(abilities.defendFastSpeed.forward, nextTask)
            return
        end
    end

    local defendArea = self.area

    -- 回防守区域
    if not AIUtils.isInArea(self.position, defendArea)
    or (self.moveStatus == AIUtils.moveStatus.backToDefendArea and math.cmpf(vector2.sqrdist(self.position, defendArea.center), 10) > 0) then
        self:setMark(nil)
        self:setMoveStatus(AIUtils.moveStatus.backToDefendArea)
        self:predictMoveDefend(defendArea.center)
        return
    end

    -- 球在后半场防守球员只执行保持阵型
    local targetPosition = vector2.clone(defendArea.center)
    if math.cmpf(self.match.ball.position.y * self.team:getSign(), Tactics.competitionMentality["defendArea"][self.team.tactics.defenseMentality]) < 0 then
        self:setMark(nil)
        self:setMoveStatus(AIUtils.moveStatus.backToDefendArea)
        self:predictMoveDefend(targetPosition)
    else
        -- 盯防无球人
        local candidateMarkTarget = nil
        local minSqrDistance = math.huge
        for i, enemy in ipairs(self.enemyTeam.athletes) do
            if not enemy:hasBall() and not enemy:isGoalkeeper() and AIUtils.isInArea(enemy.position, defendArea) then
                local minMarkedSqrDist = math.huge
                for j, markedByAthlete in ipairs(enemy.markedBy) do
                    local sqrDist = vector2.sqrdist(markedByAthlete.position, enemy.position)
                    if math.cmpf(minMarkedSqrDist, sqrDist) > 0 then
                        minMarkedSqrDist = sqrDist
                    end
                end

                local sqrDistance = vector2.sqrdist(enemy.position, self.position)
                if (enemy:isNotMarked() or math.cmpf(minMarkedSqrDist, sqrDistance) >= 0) and math.cmpf(sqrDistance, minSqrDistance) < 0 then
                    candidateMarkTarget = enemy
                    minSqrDistance = sqrDistance
                end
            end
        end

        local predictedBackLine = self.team.predictedBackLine
        if candidateMarkTarget then
            self:setMark(candidateMarkTarget)
            self:markNoBallTargetPosition(abilities.defendFastSpeed.forward, candidateMarkTarget, predictedBackLine)
            return
        end

        -- 次要盯防有持球人
        if enemyAthleteWithBall and not enemyAthleteWithBall:isGoalkeeper() then
            if AIUtils.isInArea(enemyAthleteWithBall.position, defendArea)
                and not enemyAthleteWithBall.filledInBy
                and (#enemyAthleteWithBall["markedBy"] == 0 or (#enemyAthleteWithBall["markedBy"] == 1 and enemyAthleteWithBall:isMarkedBy(self))) then
                self:setMark(enemyAthleteWithBall)
                self:assistMarkTargetPosition(abilities.defendFastSpeed.forward, enemyAthleteWithBall)
                return
            end
        end

        -- 协防
        if enemyAthleteWithBall and not enemyAthleteWithBall:isGoalkeeper() then
            if self.team.nearestAthleteToCoverEnemyAthleteWithBall == self then
                self:setCover(enemyAthleteWithBall)
                if self:isBack() then
                    self:cover(abilities.defendCoverSpeed.forward, enemyAthleteWithBall, predictedBackLine)
                else
                    self:cover(abilities.defendCoverSpeed.forward, enemyAthleteWithBall, self.area.center.y)
                end
                return
            end
        end

        self:setCover(nil)

        -- 保持阵型
        if self:isBack() then
            targetPosition.y = predictedBackLine
        end

        self:setMark(nil)
        self:setMoveStatus(AIUtils.moveStatus.defendKeepFormation)
        self:predictMoveDefend(targetPosition)
    end
end

function Athlete:setLabel(target, proactiveLabel, passiveLabel)
    if self[proactiveLabel] ~= nil then
        for i, athlete in ipairs(self[proactiveLabel][passiveLabel]) do
            if athlete == self then
                table.remove(self[proactiveLabel][passiveLabel], i)
                break
            end
        end
    end

    self[proactiveLabel] = target

    if target ~= nil then
        local labeledByMe = false
        for i, athlete in ipairs(target[passiveLabel]) do
            if athlete == self then
                labeledByMe = true
                break
            end
        end

        if not labeledByMe then
            table.insert(target[passiveLabel], self)
        end
    end
end

function Athlete:isNotLabeled(passiveLabel)
    return #self[passiveLabel] == 0
end

function Athlete:isLabeledBy(athlete, passiveLabel)
    for i, a in ipairs(self[passiveLabel]) do
        if a == athlete then
            return true
        end
    end
    return false
end

function Athlete:isOnlyLabeledBy(athlete, passiveLabel)
    return #self[passiveLabel] == 1 and self[passiveLabel][1] == athlete
end

function Athlete:setMark(target)
    self:setLabel(target, "marking", "markedBy")
end

function Athlete:isNotMarked()
    return self:isNotLabeled("markedBy")
end

function Athlete:isMarkedBy(marker)
    return self:isLabeledBy(marker, "markedBy")
end

function Athlete:isOnlyMarkedBy(marker)
    return self:isOnlyLabeledBy(marker, "markedBy")
end

function Athlete:nearestMarkDistanceExcept(marker)
    local nearestDistance = math.huge
    for i, m in ipairs(self.markedBy) do
        local distance = vector2.dist(m.position, self.position)
        if math.cmpf(nearestDistance, distance) > 0 and m ~= marker then
            nearestDistance = distance
        end
    end

    return nearestDistance
end

function Athlete:setClosingDown(target)
    if self.closing then
        self.closing.closedBy = nil
    end
    if target and target.closedBy then
        target.closedBy.closing = nil
    end
    self.closing = target
    if target then
        target.closedBy = self
    end
end

function Athlete:setFillingIn(target)
    if self.fillingIn then
        self.fillingIn.filledInBy = nil
    end
    if target and target.filledInBy then
        target.filledInBy.fillingIn = nil
    end
    self.fillingIn = target
    if target then
        target.filledInBy = self
    end
end

function Athlete:setCover(target)
    self:setLabel(target, "covering", "coveredBy")
end

function Athlete:isNotCovered()
    return self:isNotLabeled("coveredBy")
end

function Athlete:isCoveredBy(coverer)
    return self:isLabeledBy(coverer, "coveredBy")
end

function Athlete:isOnlyCoveredBy(coverer)
    return self:isOnlyLabeledBy(coverer, "coveredBy")
end
