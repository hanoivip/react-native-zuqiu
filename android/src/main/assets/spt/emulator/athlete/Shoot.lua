if jit then jit.off(true, true) end

local Athlete = import("./Core")
local Actions = import("../actions/Actions")
local AIUtils = import("../AIUtils")
local Ball = import("../Ball")
local Field = import("../Field")
local selector = import("../libs/selector")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local Skills = import("../skills/Skills")

local function getCandidateShootTargets(athlete)
    local candidateShootTargets = { }
    table.insert(candidateShootTargets, { targetPosition = vector2.new((1 - 2 * math.random()) * Field.halfGoalWidth, athlete.enemyTeam.goal.center.y), score = 0.5})

    return candidateShootTargets
end

function Athlete:isInNormalShootArea()
    local vectorEnemyGoalToSelf = self.position - self.enemyTeam.goal.center

    if math.cmpf(vector2.sqrmagnitude(vectorEnemyGoalToSelf), 20 ^ 2) <= 0 then
        if math.cmpf(self.position.x, -Field.halfGoalWidth) > 0 and math.cmpf(self.position.x, Field.halfGoalWidth) < 0 then return true end
        local angleToEnemyGoalNormal = vector2.angle(vectorEnemyGoalToSelf, self.enemyTeam.goal.normal)
        return math.cmpf(angleToEnemyGoalNormal, self:getAbilities().shootAngleLimit) <= 0
    end

    return false
end

function Athlete:calculateShoot()
    local candidateActions = { }

    local enableNormalShoot = self:isInNormalShootArea()
    local forceShoot = Field.isInForceShootArea(self.position, self.team:getSign())
    local forceShootSideF = self:isSideF() and Field.isInSideFForceShootArea(self.position, self.team:getSign())

    local shootScoreFactor = (forceShoot or forceShootSideF) and 10000 or 1

    if enableNormalShoot or forceShootSideF then
        local candidateTargets = getCandidateShootTargets(self)

        for i, target in ipairs(candidateTargets) do
            table.insert(candidateActions, { key = self:getNewShootAction(target.targetPosition), weight = target.score * shootScoreFactor })
        end
    end

    self.candidateShootActions = candidateActions
end

function Athlete:getNewShootAction(targetPosition)
    local shootAction = Actions.Shoot.new()
    shootAction.targetPosition = targetPosition

    return shootAction
end

function Athlete:manualShoot()
    self:calculateShoot()
    self.chosenDPSAction = selector.max(self.candidateShootActions)
    self.manualOperateSkillId = self.manualOperateShootEnabledSkillId
end

function Athlete:calculateNoAreaConstraintShootAction()
    local candidateTargets = getCandidateShootTargets(self)
    local candidateActions = { }
    for i, target in ipairs(candidateTargets) do
        table.insert(candidateActions, { key = self:getNewShootAction(target.targetPosition), weight = target.score })
    end

    local chosenDPSAction, score = selector.max(candidateActions)
    self.chosenDPSAction = chosenDPSAction
end

function Athlete:selectShootAnimation(animationType)
    self:selectAndPushAnimation(animationType, function (animation)
        local rawData = Animations.RawData[animation.name]
        local sangle = vector2.sangle(self.bodyDirection, vector2.norm(self.chosenDPSAction.targetPosition - self.position))
        local ballOutPosition = self.position + vector2.vyrotate(animation.firstTouchBallPosition, self.bodyDirection)
        return (rawData.outAngle == nil or Animations.isInAngleRange(rawData.outAngle.Start, rawData.outAngle.End, sangle)) and Field.isInside(ballOutPosition)
    end, true, true)
end

function Athlete:hasAppropriateShootAnimation()
    local filteredShootAnimations = self:getFilteredAnimationList("NormalShoot", function(animation)
        local rawData = Animations.RawData[animation.name]
        local sangle = vector2.sangle(self.bodyDirection, vector2.norm(self.chosenDPSAction.targetPosition - self.position))
        local ballOutPosition = self.position + vector2.vyrotate(animation.firstTouchBallPosition, self.bodyDirection)
        return (rawData.outAngle == nil or Animations.isInAngleRange(rawData.outAngle.Start, rawData.outAngle.End, sangle)) and Field.isInside(ballOutPosition)
    end, false, true)

    return #filteredShootAnimations ~= 0
end

function Athlete:preShoot()
    self:logInfo("PreShoot")

    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        local preShootAction = Actions.PreShoot.new()
        preShootAction.targetPosition = self.chosenDPSAction.targetPosition
        preShootAction.shootAbility = self:getAbilities().shoot
        self.outputActionStatus = preShootAction
    end

    self:stopEnemyGkAnimation()

    self:makeDefenseAthletesBlock()
    self.match.noNeedJudgeBallOutOfField = true
end

function Athlete:isPreShootEndFrame(currentTime, offsetTime)
    local currentAnimation = self.animationQueue[1]
    local leftTime = currentAnimation.animationInfo.lastTouch * TIME_STEP - (currentTime - currentAnimation.startTime)
    return math.cmpf(leftTime, offsetTime or 0) == 0
end

function Athlete:evaluateShoot(targetPosition, targetPositionHeight, controlPoint, flyDuration, isShootHigh, actionType, enableAutoShootWide)
    self:logAssert(self.chosenDPSAction ~= nil and (self.chosenDPSAction.name == "Shoot" or self.chosenDPSAction.name == "PreShoot"), "chosenDPSAction should be Shoot")

    self:logInfo("targetPosition = %s, isShootHigh = %s, actionType = %s", targetPosition, isShootHigh, actionType)

    local ball = self.match.ball
    local flyStartTime = self.currentAnimation.animationInfo.lastTouch * TIME_STEP + self.currentAnimation.startTime
    local flyStartPosition = self.position
    if self.match.frozenType == "CenterDirectFreeKick" or self.match.frozenType == "PenaltyKick" then
        flyStartPosition = self.position + vector2.vyrotate(self.currentAnimation.animationInfo.lastTouchBallPosition, self.bodyDirection)
    end

    local shootSqrDist = vector2.sqrdist(self.position, self.enemyTeam.goal.center)
    local isHeaderShoot = self.catchType == AIUtils.catchType.PowerfulHeader or self.catchType == AIUtils.catchType.NormalHeader
    local shootSpeed = isHeaderShoot and math.max(-0.02 * shootSqrDist + 24, 18) or 0.01 * shootSqrDist + 24

    local prediction = ball:predictFlyTo(flyStartTime, flyStartPosition, 0, targetPosition, shootSpeed, "Ground")
    if isHeaderShoot then
        flyDuration = prediction.flyDuration
    end

    local shootAction = actionType and actionType.new() or Actions.Shoot.new()
    shootAction.startPosition = flyStartPosition
    shootAction.targetPosition = targetPosition
    shootAction.targetPositionHeight = targetPositionHeight
    shootAction.controlPoint = controlPoint
    shootAction.flyDuration = flyDuration or prediction.flyDuration
    shootAction.saveTime = prediction.flyStartTime + shootAction.flyDuration - TIME_STEP
    shootAction.savePosition = targetPosition
    shootAction.saver = self.enemyTeam.athleteOfRole[26]
    shootAction.shootAbility = self:getAbilities().shoot

    shootAction.shootAnimationType = AIUtils.shootAnimationType.normalShoot

    if isHeaderShoot then
        shootAction.shootAnimationType = AIUtils.shootAnimationType.header
    end

    if self.catchType == AIUtils.catchType.VolleyShoot or self.catchType == AIUtils.catchType.NormalVolleyShoot then
        shootAction.shootAnimationType = AIUtils.shootAnimationType.volleyShoot
    end

    if self.catchType == AIUtils.catchType.OffTheBall then
        shootAction.shootAnimationType = AIUtils.shootAnimationType.offTheBall
    end

    if not actionType then -- if second call
        local maxIncrease = math.clamp(self.chosenDPSAction.goalProbability / 20 + 0.05, 0, 0.1)
        local increase = math.random() * maxIncrease
        if math.cmpf(self.chosenDPSAction.goalProbability + increase, 0.99) > 0 then
            increase = math.max(0.99 - self.chosenDPSAction.goalProbability, 0)
        end
        shootAction.goalProbability = self.chosenDPSAction.goalProbability + increase
        shootAction.bounceProbability = self.chosenDPSAction.bounceProbability
    end

    if self.match.isInPenaltyShootOut then
        if self.match.opponentTeam.shootOutAttempts == AIUtils.maxPenaltyShootOutRounds then
            if self.match.playerTeam.shootOutAttempts < AIUtils.maxPenaltyShootOutRounds then
                shootAction.isGoal = true
                shootAction.shootResult = AIUtils.shootResult.goal
                return shootAction
            elseif self.match.playerTeam.shootOutAttempts == AIUtils.maxPenaltyShootOutRounds then
                if self.match.playerTeam.shootOutScore ~= self.match.opponentTeam.shootOutScore then
                    shootAction.isGoal = false
                    shootAction.shootResult = AIUtils.shootResult.saveBounce
                else
                    shootAction.isGoal = true
                    shootAction.shootResult = AIUtils.shootResult.goal
                end

                return shootAction
            end
        end
    end

    if isShootHigh or not Field.isInGoal(targetPosition) then
        -- shoot wide
        shootAction.isGoal = false
        shootAction.shootResult = AIUtils.shootResult.shootWide
        shootAction.isShootWide = true
        shootAction.goalProbability = 0
        return shootAction
    end

    local extraShootWideProbability = 0
    local judgeExtraShootWide = false
    if actionType then -- if first call
        local goalKeeper, goalProbability, bounceProbability, extraShootWideRate = AIUtils.getCandidateShootIntercepts(self, shootAction)
        shootAction.goalProbability = goalProbability
        shootAction.bounceProbability = bounceProbability
        extraShootWideProbability = extraShootWideRate
    end

    if math.cmpf(extraShootWideProbability, 0) > 0 then
        if selector.tossCoin(extraShootWideProbability) then
            -- extra shoot wide
            shootAction.isGoal = false
            shootAction.shootResult = AIUtils.shootResult.shootWide
            shootAction.isShootWide = true
            shootAction.goalProbability = 0
            return shootAction
        else
            judgeExtraShootWide = true
        end
    end

    if math.cmpf(prediction.flyDuration, 2 * TIME_STEP) >= 0 and not selector.tossCoin(shootAction.goalProbability) then
        shootAction.isGoal = false
        local freeKickMasterEx1Skill = self:getSkill(Skills.FreeKickMasterEx1)
        local saveBounceProbability = 1 - shootAction.goalProbability
        if judgeExtraShootWide then
            saveBounceProbability = math.min(saveBounceProbability + extraShootWideProbability, 1)
        end
        if freeKickMasterEx1Skill ~= nil then
            saveBounceProbability = math.min(saveBounceProbability + freeKickMasterEx1Skill.ex1Probability, 1)
        end
        --shoot wide
        if enableAutoShootWide and math.cmpf(vector2.sqrdist(self.position, self.enemyTeam.goal.center), 100) > 0 and selector.tossCoin(saveBounceProbability) then
            shootAction.isShootWide = true
            local bounceRangeX = math.range(Field.halfGoalWidth + 0.5, Field.halfGoalWidth + 1.5)
            local targetXSign = math.sign(self.bodyDirection.x)
            if math.cmpf(targetXSign, 0) == 0 then
                targetXSign = 1
            end
            self.chosenDPSAction.targetPosition =
                vector2.new(targetXSign * math.randomInRange(bounceRangeX.min, bounceRangeX.max), self.chosenDPSAction.targetPosition.y)
            shootAction.targetPosition = vector2.new(self.chosenDPSAction.targetPosition.x, targetPosition.y)

            local prediction1 = ball:predictFlyTo(flyStartTime, flyStartPosition, 0, shootAction.targetPosition, shootSpeed, "Ground")
            shootAction.flyDuration = prediction1.flyDuration
            shootAction.saveTime = prediction1.flyStartTime + prediction1.flyDuration - TIME_STEP
            shootAction.savePosition = shootAction.targetPosition

            shootAction.shootResult = AIUtils.shootResult.shootWide
        --save
        else
            shootAction.isSaved = true
            shootAction.isBounced = selector.tossCoin(shootAction.bounceProbability)

            if shootAction.isBounced then
                -- 扑出
                shootAction.shootResult = AIUtils.shootResult.saveBounce
            else
                -- 抱住
                shootAction.shootResult = AIUtils.shootResult.catch
                self.enemyTeam.athleteOfRole[26]:judgeHandingEx1()
            end

            self:logInfo("SaveTime=%.2f, SavePosition=%s", shootAction.saveTime, tostring(shootAction.savePosition))
            self:judgeTigerShootEx1("Save")
            self.enemyTeam.athleteOfRole[26]:judgeLegendaryGoalkeeperAEx1()
        end
        return shootAction
    end

    shootAction.isGoal = true
    shootAction.shootResult = AIUtils.shootResult.goal

    if actionType then -- if first call
        local saverX = shootAction.saver.position.x
        local shootX

        local leftIntervalStart = -Field.halfGoalWidth
        local leftIntervalEnd = math.max(math.min(saverX - 2, -Field.halfGoalWidth + 1), -Field.halfGoalWidth)
        local rightIntervalStart = math.min(math.max(saverX + 2, Field.halfGoalWidth - 1), Field.halfGoalWidth)
        local rightIntervalEnd = Field.halfGoalWidth

        local leftIntervalLength = leftIntervalEnd - leftIntervalStart
        local rightIntervalLength = rightIntervalEnd - rightIntervalStart
        local randomLength = (leftIntervalLength + rightIntervalLength) * math.random()

        shootX = math.cmpf(randomLength, leftIntervalLength) <= 0
            and leftIntervalStart + randomLength
            or rightIntervalStart + randomLength - leftIntervalLength

        shootAction.targetPosition.x = shootX
    end
    self:judgeTigerShootEx1("Goal")
    self:judgeGreatSpeedEx1("Goal")
    self:judgeHeavyGunnerPoogba()
    self:judgeMatadorExcaliburEx1()
    return shootAction
end

function Athlete:shootPause()
    self:logInfo("ShootPause")
    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        self.outputActionStatus = {
            name = "ShootPause",
        }
    end

    self.match.ball:setOwner(self)
end

function Athlete:judgeTigerShoot()
    local skill = self:getCooldownSkill(Skills.TigerShoot)
    if skill and selector.tossCoin(skill.probability) then
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeImpactWave()
    local skill = self:getCooldownSkill(Skills.ImpactWave)
    if skill and selector.tossCoin(skill.probability) then
        table.insert(self.toBeCastedSkills, skill.class)
    end
end

function Athlete:judgeShootMasterEx1(goalProbability)
    local skill = self:getSkill(Skills.ShootMasterEx1)
    if skill ~= nil and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
        return skill.buff.successProbilityModifier(goalProbability)
    end
    return goalProbability
end

function Athlete:judgePenaltyKickMasterEx1(goalProbability, saveProbility)
    local skill = self:getSkill(Skills.PenaltyKickMasterEx1)
    if skill ~= nil and selector.tossCoin(skill.ex1Probability) then
        return 1, 0
    end
    return goalProbability, saveProbility
end

function Athlete:shoot()
    self:logInfo("Shoot")
    self:logAssert(self.chosenDPSAction ~= nil and (self.chosenDPSAction.name == "Shoot" or self.chosenDPSAction.name == "PreShoot"), "chosenDPSAction should be Shoot")

    local ball = self.match.ball

    self.match.shootAthleteForAfterShootSkills = self
    self.match.shootAthletePosition = self.position

    if self.catchType == AIUtils.catchType.VolleyShoot
        or self.catchType == AIUtils.catchType.NormalVolleyShoot
        or self.catchType == AIUtils.catchType.PowerfulHeader
        or self.catchType == AIUtils.catchType.NormalHeader
        or self.catchType == AIUtils.catchType.OffTheBall then
        ball:setOwner(self)
    end

    local targetPosition = self.chosenDPSAction.targetPosition

    local shootAction = self.chosenDPSAction
    shootAction.name = "Shoot"
    shootAction.skill = self.catchType == AIUtils.catchType.VolleyShoot and Skills.VolleyShoot.__cname
        or self.catchType == AIUtils.catchType.PowerfulHeader and Skills.PowerfulHeader.__cname
        or self.isCalmShoot and Skills.CalmShoot.__cname
        or self.isHeavyGunner and Skills.HeavyGunner.__cname

    self:logInfo(shootAction:toString())

    self.isCalmShoot = nil
    self.catchType = nil
    self.isHeavyGunner = nil

    self.match.isGoal = shootAction.isGoal

    self.team.penaltyShootOutResultsQueue[math.min(self.team.shootOutAttempts, 5)] = shootAction.isGoal
    and AIUtils.penaltyShootOutKickState.goal or AIUtils.penaltyShootOutKickState.miss

    if not self.match.isFrozen then
        shootAction.startPosition = self.currentAnimation.startPosition
            + vector2.vyrotate(self.currentAnimation.animationInfo.firstTouchBallPosition, self.currentAnimation.startBodyDirection)
    end

    ball.nextTask = Ball.ShootAndSave.new({
        saver = shootAction.saver,
        saveTime = shootAction.saveTime,
        flyDuration = shootAction.flyDuration,
        startPosition = shootAction.startPosition,
        savePosition = shootAction.savePosition,
        isBounced = shootAction.isBounced,
        isSaved = shootAction.isSaved,
        isGoal = shootAction.isGoal,
        shootResult = shootAction.shootResult,
        shooter = self,
    })

    local goalKeeper = self.enemyTeam.athleteOfRole[26]
    if goalKeeper then
        goalKeeper:stopAnimation(true)
        goalKeeper:selectSaveAnimation(shootAction.startPosition, self.currentAnimation.animationInfo.lastTouchBallHeight, shootAction.controlPoint,
            shootAction.targetPosition, shootAction.targetPositionHeight, shootAction.flyDuration, shootAction.shootResult)
    end

    shootAction.savePosition = ball.nextTask.savePosition
    shootAction.flyDuration = ball.nextTask.outputFlyDuration
    if shootAction.shootResult == AIUtils.shootResult.goal or shootAction.shootResult == AIUtils.shootResult.shootWide then
        local shootBallSpeed = Ball.predictPassSpeed(ball.nextTask.outputFlyDuration, 0, vector2.dist(ball.nextTask.startPosition, shootAction.targetPosition))
        self.match.ball:flyTo(self.match.currentTime, ball.nextTask.startPosition, 0, shootAction.targetPosition, shootBallSpeed, "Ground", "Shoot")
    else
        local shootBallSpeed = Ball.predictPassSpeed(ball.nextTask.flyDuration, 0, vector2.dist(ball.nextTask.startPosition, shootAction.savePosition))
        self.match.ball:flyTo(self.match.currentTime, ball.nextTask.startPosition, 0, shootAction.savePosition, shootBallSpeed, "Ground", "Shoot")
    end

    if not self.match.isInPenaltyShootOut then
        self.team.shootTimes = self.team.shootTimes + 1

        if ball.nextTask.isBounced or ball.nextTask.isSaved or ball.nextTask.isGoal then
            self.team.shootOnGoalTimes = self.team.shootOnGoalTimes + 1
        end
    end

    self.team.continuousCatchPassCount = 0

    if self.match.isFrozen then
        shootAction.reason = self.match.frozenType
        local excludeAttackAthletes = {self}
        local excludeDefendAthletes = {self.enemyTeam.athleteOfRole[26]}

        self.match:unfreeze(excludeAttackAthletes, excludeDefendAthletes)
    end

    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        shootAction.controlPosition = ball.nextTask.controlPosition
        shootAction.targetPositionHeight = ball.nextTask.targetPositionHeight
        self.outputActionStatus = shootAction
    end

    self.lastShootAction = shootAction
    self.match.noNeedJudgeBallOutOfField = false
end

function Athlete:makeDefenseAthletesBlock()
    self.enemyTeam.blockAthletes = { }

    if self.match.frozenType == "CenterDirectFreeKick" or self.match.frozenType == "PenaltyKick" then
        return
    end

    --射门球员与球门中点连线两侧各45度半径3m范围内防守球员做阻挡动作
    local defenseAthletes = nil
    if self.catchType == AIUtils.catchType.NormalHeader or self.catchType == AIUtils.catchType.PowerfulHeader then
        defenseAthletes = self:findEnemyAthletesInCircle(self.position, 3)
    else
        defenseAthletes = self:findEnemyAthletesInCircle(self.position, 3)
    end

    for _, defenseAthlete in ipairs(defenseAthletes) do
        if not defenseAthlete:isGoalkeeper() and defenseAthlete:canBeInterruptible() then
            defenseAthlete.shouldBlock = true
            defenseAthlete.blockEnemy = self
            defenseAthlete:stopAnimation()

            table.insert(self.enemyTeam.blockAthletes, defenseAthlete)
        end
    end
end