local vector2 = import("./libs/vector")
local selector = import("./libs/selector")
local Field = import("./Field")
local Animations = import("./animations/Animations")
local Skills = import("./skills/Skills")
local SkillMapById = import("./skills/SkillMapById")

AIUtils = {}

AIUtils.maxManualOperateTimes = 3
AIUtils.maxFrameInManualOperateAnimation = 5
AIUtils.firstTimeMaxFrameInManualOperateAnimation = 10
AIUtils.manualOperateCoolDown = 20
AIUtils.maxPenaltyShootOutRounds = 33

local powerRatioMap = {
    {min = 0, max = 50000, val = 1},
    {min = 50000, max = 100000, val = 1.05},
    {min = 100000, max = 200000, val = 1.1},
    {min = 200000, max = 300000, val = 1.15},
    {min = 300000, max = 400000, val = 1.2},
    {min = 400000, max = 500000, val = 1.25},
    {min = 500000, max = 650000, val = 1.3},
    {min = 650000, max = 800000, val = 1.34},
    {min = 800000, max = 1000000, val = 1.39},
    {min = 1000000, max = 1200000, val = 1.43},
    {min = 1200000, max = 1500000, val = 1.48},
    {min = 1500000, max = math.huge, val = 1.5},
}

-- 中超2战力修正数值要低一些
local zcfy2PowerRatioMap = {
    {min = 0, max = 3000, val = 1},
    {min = 3000, max = 6000, val = 1.05},
    {min = 6000, max = 10000, val = 1.1},
    {min = 10000, max = 14000, val = 1.15},
    {min = 14000, max = 18000, val = 1.2},
    {min = 18000, max = 23000, val = 1.25},
    {min = 23000, max = 28000, val = 1.3},
    {min = 28000, max = 35000, val = 1.34},
    {min = 35000, max = 45000, val = 1.39},
    {min = 45000, max = 55000, val = 1.43},
    {min = 55000, max = 65000, val = 1.43},
    {min = 65000, max = 80000, val = 1.48},
    {min = 80000, max = math.huge, val = 1.5},
}

--前插跑位时, 防守球员需要一个转身时间, 这段时间内前插球员跑动的距离
AIUtils.leadPassDefenseDistance = 3

AIUtils.avoidanceScore = {
    general = 0, --0分，如带球穿人，传球穿人
    notRecommand = -1, --不推荐，如大范围横穿，往越位处传球
    unreasonable = -2, --不合理，如带球出界
    forbidden_has_nearer_enemy = -3, --禁止, 有更近的防守球员
    forbidden_has_enemy_in_pass_line = -4, --禁止, 传球线路上有人
    forbidden_speed_not_satisfied = -5, --禁止, 速度不满足
    forbidden_ball_owner_nearer = -6, --禁止, 持球球员离目标点更近
    forbidden_y_limit = -7, --禁止, 传球y值限制
    forbidden_min_pass_distance_not_satisfied = -8, --禁止, 不满足最短传球距离
    forbidden_max_pass_distance_not_satisfied = -9, --禁止, 不满足最大传球距离
}

AIUtils.shootResult = {
    goal = 0, --进球
    catch = 1, --扑住
    saveBounce = 2, --扑出
    shootWide = 3, --射偏
}

AIUtils.penaltyShootOutKickState = {
    idle = 0,
    goal = 1,
    miss = 2,
}

AIUtils.penaltyShootOutEffectiveSkillIds = {
    "D05", "E05", "E07", "F03"
}

AIUtils.shootAnimationType = {
    normalShoot = 0, --普通射门
    header = 1, --头球
    volleyShoot = 2, --凌空
    offTheBallGround = 3, --地面球抢点
}

AIUtils.catchType = {
    VolleyShoot = 1,
    NormalVolleyShoot = 2,
    PowerfulHeader = 3,
    NormalHeader = 4,
    OffTheBall = 5,
    CatchPass = 6,
    InterceptCatchPass = 7,
    CatchCrossPass = 8,
}

AIUtils.passBodyPartType = {
    foot = 1, --脚踢球
    hand = 2, --手抛球
    head = 3, --头球
}

AIUtils.weatherEffectSkillIds = {
    SunShine = {},
    Rain = {"D01", "B01", "C04"},
    Snow = {"B02", "F02", "F03"},
    Wind = {"D05", "D06", "D07"},
    Fog = {"C01", "D02"},
    Sand = {"C02", "D04"},
    Heat = {"C03", "D03"},
}

AIUtils.weatherEffectDecrease = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

function AIUtils.initPowerRatioMap(game)
    if game == "zcfy2" then
        powerRatioMap = zcfy2PowerRatioMap
    end
end

function AIUtils.getWeatherEffect(weatherTech, weatherTechLvl)
    if weatherTechLvl == 0 then
        return {}, 0
    end

    if weatherTechLvl < 0 or weatherTechLvl > 10 then
        error("wrong level")
    end

    return AIUtils.weatherEffectSkillIds[weatherTech], AIUtils.weatherEffectDecrease[weatherTechLvl]
end

AIUtils.grassEffect = {
    Common = {
        abilityNames = {},
        decreaseRate = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    },
    Mixed = {
        abilityNames = {"dribble", "pass", "shoot", "steal", "intercept"},
        decreaseRate = {0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1},
    },
    NatureShort = {
        abilityNames = {"dribble"},
        decreaseRate = {0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5},
    },
    NatureLong = {
        abilityNames = {"pass"},
        decreaseRate = {0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5},
    },
    ArtificialShort = {
        abilityNames = {"steal"},
        decreaseRate = {0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5},
    },
    ArtificialLong = {
        abilityNames = {"intercept"},
        decreaseRate = {0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5},
    },
}

function AIUtils.getGrassEffect(grassTech, grassLv)
    if grassLv == 0 then
        return {}, 0
    end

    if grassLv < 0 or grassLv > 10 then
        error("wrong level")
    end

    return AIUtils.grassEffect[grassTech].abilityNames, AIUtils.grassEffect[grassTech].decreaseRate[grassLv]
end

AIUtils.moveStatus = {
    -- 1~100 attack
    attackKeepFormation = 1, --进攻保持阵型
    reinforce = 2, --接应跑位
    runningForward = 3, --前插跑位
    offTheBall = 4, --抢点跑位
    normalCatch = 5, --普通接球跑位
    reinforceCatch = 6, --接应接球
    runningForwardCatch = 7, --前插接球
    offTheBallCatch = 8, --抢点接球
    runningForwardAfterPass = 9, --传球后前插跑位
    counterRunningForward = 10, --断球后前插
    -- 101~200 defend
    defendKeepFormation = 101, --防守保持阵型
    markHandler = 102, --盯防持球人
    markNonHandler = 103, --盯防非持球人
    markCatcher = 104, --盯防接球人
    markHighLeadPassCatcher = 107, --盯防高球提前量接球人
    markGroundLeadPassCatcher = 108, --盯防地面球提前量接球人
    backToDefendArea = 105, --回防守区域
    assitmarkHandler = 106, --次要盯防持球人
}

-- 1 <= focusType <= 100: 球员id, 101: ball, 102: player gate, 103: opponent gate
AIUtils.focusType = {
    ball = 101,
    playerGate = 102,
    opponentGate = 103,
    earlyBall = 104,
    targetPosition = nil, --104, --目标点，也即某个球员？
}

AIUtils.movePriority = {
    toward = 1,
    speed = 2,
}

AIUtils.moveConfig = {
    [AIUtils.moveStatus.attackKeepFormation] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 1.5, 7) end },
    [AIUtils.moveStatus.reinforce] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.toward,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 5, 7) end },
    [AIUtils.moveStatus.runningForward] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2.5, 7.5) end },
    [AIUtils.moveStatus.runningForwardAfterPass] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2.5, 7.5) end },
    [AIUtils.moveStatus.counterRunningForward] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2.5, 7.5) end },
    [AIUtils.moveStatus.offTheBall] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2, 7.5) end },
    [AIUtils.moveStatus.normalCatch] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 1.5, 6.5) end },
    [AIUtils.moveStatus.reinforceCatch] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 1.5, 7) end },
    [AIUtils.moveStatus.runningForwardCatch] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.clamp(expectSpeed, 5, 7.5) end },
    [AIUtils.moveStatus.offTheBallCatch] = {focusType = AIUtils.focusType.ball, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 1.5, 7) end },
    [AIUtils.moveStatus.defendKeepFormation] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.toward,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 1.5, 7.5) end },
    [AIUtils.moveStatus.markHandler] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 5, 8.2) end },
    [AIUtils.moveStatus.markNonHandler] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 1.5, 7) end },
    [AIUtils.moveStatus.markCatcher] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2, 7.5) end },
    [AIUtils.moveStatus.markHighLeadPassCatcher] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.speed,
    speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2.5, 9) end },
    [AIUtils.moveStatus.markGroundLeadPassCatcher] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.speed,
    speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2, 7) end },
    [AIUtils.moveStatus.backToDefendArea] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 2, 8) end },
    [AIUtils.moveStatus.assitmarkHandler] = {focusType = AIUtils.focusType.earlyBall, priority = AIUtils.movePriority.speed,
        speedFun = function(targetDist, expectSpeed) return math.min(targetDist * 5, 7.5) end },
}

AIUtils.catchMoveSpeedConfig = {
    [AIUtils.moveStatus.normalCatch] = { maxSpeed = 6.5 },
    [AIUtils.moveStatus.reinforce] = { maxSpeed = 6.5 },
    [AIUtils.moveStatus.runningForwardCatch] = { minSpeed = 6, maxSpeed = 8 },
    [AIUtils.moveStatus.offTheBallCatch] = { maxSpeed = 8 },
}

function AIUtils.isInArea(position, area)
    return math.cmpf(position.x, area.minX) >= 0 and math.cmpf(position.x, area.maxX) <= 0
    and math.cmpf(position.y, area.minY) >= 0 and math.cmpf(position.y, area.maxY) <= 0
end

function AIUtils.isInCircle(position, circle)
    return math.cmpf(vector2.sqrdist(position, circle.center), circle.radius ^ 2) <= 0
end

function AIUtils.isInSector(position, circleCenter, direction, radius, angle)
    local vectorAthleteToDefenseAthlete = position - circleCenter
    return math.cmpf(vector2.sqrmagnitude(vectorAthleteToDefenseAthlete), radius ^ 2) <= 0
    and math.cmpf(vector2.angle(direction, vectorAthleteToDefenseAthlete), angle / 2) <= 0
end

function AIUtils.isInForbiddenDirectionRanges(direction, forbiddenDirectionRanges)
    for i, forbiddenDirectionRange in ipairs(forbiddenDirectionRanges) do
        if math.cmpf(vector2.sangle(forbiddenDirectionRange.startDirection, direction), 0) > 0
        and math.cmpf(vector2.sangle(direction, forbiddenDirectionRange.endDirection), 0) > 0 then
            return true
        end
    end

    return false
end

function AIUtils.getLeadPassForbiddenDirectionRanges(athlete, targetAthletePosition)
    local forbiddenDirectionRanges = {}
    for i, defenseAthlete in ipairs(athlete.enemyTeam.athletes) do
        if not defenseAthlete:isGoalkeeper() then
            local baseVector = vector2.norm(defenseAthlete.position - targetAthletePosition)
            local sqrDist = vector2.sqrdist(targetAthletePosition, defenseAthlete.position)
            local coverAngle = nil
            if math.cmpf(sqrDist, AIUtils.leadPassDefenseDistance ^ 2) < 0 then
                coverAngle = math.pi / 3
            else
                coverAngle = math.clamp(-12 * vector2.dist(targetAthletePosition, defenseAthlete.position) + 180, 0, 120) / 180 * math.pi
            end
            local forbiddenDirectionRange = {
                startDirection = vector2.rotate(baseVector, -coverAngle / 2),
                endDirection = vector2.rotate(baseVector, coverAngle / 2)
            }
            table.insert(forbiddenDirectionRanges, forbiddenDirectionRange)
        end
    end

    return forbiddenDirectionRanges
end

function AIUtils.getPassForbiddenDirectionRanges(attackAthlete, passStartPosition, coverAngle)
    local forbiddenDirectionRanges = {}
    local passSqrDist = vector2.sqrdist(passStartPosition, attackAthlete.position)
    for i, defenseAthlete in ipairs(attackAthlete.enemyTeam.athletes) do
        if not defenseAthlete:isGoalkeeper() and math.cmpf(vector2.sqrdist(passStartPosition, defenseAthlete.position), passSqrDist) <= 0 then
            local baseVector = vector2.norm(defenseAthlete.position - passStartPosition)
            local forbiddenDirectionRange = {
                startDirection = vector2.rotate(baseVector, -coverAngle / 2),
                endDirection = vector2.rotate(baseVector, coverAngle / 2)
            }
            table.insert(forbiddenDirectionRanges, forbiddenDirectionRange)
        end
    end

    return forbiddenDirectionRanges
end

function AIUtils.getBestDirection(perfectDirection, forbiddenDirectionRanges)
    local bestDirection = perfectDirection
    if AIUtils.isInForbiddenDirectionRanges(bestDirection, forbiddenDirectionRanges) then
        local isCircled = true
        local minAngle = math.huge
        for i, forbiddenDirectionRange in ipairs(forbiddenDirectionRanges) do
            local startDirectionAngle = vector2.angle(perfectDirection, forbiddenDirectionRange.startDirection)
            if not AIUtils.isInForbiddenDirectionRanges(forbiddenDirectionRange.startDirection, forbiddenDirectionRanges) then
                isCircled = false
                if math.cmpf(startDirectionAngle, minAngle) < 0 then
                    minAngle = startDirectionAngle
                    bestDirection = forbiddenDirectionRange.startDirection
                end
            end

            local endDirectionAngle = vector2.angle(perfectDirection, forbiddenDirectionRange.endDirection)
            if not AIUtils.isInForbiddenDirectionRanges(forbiddenDirectionRange.endDirection, forbiddenDirectionRanges) then
                isCircled = false
                if math.cmpf(endDirectionAngle, minAngle) < 0 then
                    minAngle = endDirectionAngle
                    bestDirection = forbiddenDirectionRange.endDirection
                end
            end
        end
    end

    if isCircled then
        return nil
    else
        return bestDirection
    end
end

function AIUtils.calcDefenseSuccessProbability(defenseAttackRatio)
    if math.cmpf(defenseAttackRatio, 4) >= 0 then
        return math.clamp(0.05 * defenseAttackRatio + 0.75, 0.01, 0.99)
    elseif math.cmpf(defenseAttackRatio, 1) >= 0 then
        return math.clamp(-0.0425 * defenseAttackRatio ^ 2 + 0.4455 * defenseAttackRatio - 0.1525, 0.01, 0.99)
    end

    return math.clamp(-0.3738 * defenseAttackRatio ^ 2 + 0.7998 * defenseAttackRatio - 0.176, 0.01, 0.99)
end

local posIndex = {
    [1] = "FL",
    [2] = "FC",
    [3] = "FC",
    [4] = "FC",
    [5] = "FR",
    [6] = "FL",
    [7] = "AMC",
    [8] = "AMC",
    [9] = "AMC",
    [10] = "FR",
    [11] = "ML",
    [12] = "MC",
    [13] = "MC",
    [14] = "MC",
    [15] = "MR",
    [16] = "DL",
    [17] = "DMC",
    [18] = "DMC",
    [19] = "DMC",
    [20] = "DR",
    [21] = "DL",
    [22] = "DC",
    [23] = "DC",
    [24] = "DC",
    [25] = "DR",
    [26] = "GK",
}

function AIUtils.getPosStr(role)
    return posIndex[role]
end

function AIUtils.getSkillById(id)
    return SkillMapById[id]
end

function AIUtils.isSkillIdCorrespondSkill(skillId, skill)
    return AIUtils.getSkillById(skillId) and AIUtils.getSkillById(skillId).isSubClassOf(skill)
end

function AIUtils.isSkillIdCorrespondOneOfSkills(skillId, skillList)
    return AIUtils.isSkillTypeOfOneOfSkills(AIUtils.getSkillById(skillId), skillList)
end

function AIUtils.isSkillTypeOfOneOfSkills(skill, skillList)
    for _, skillClass in ipairs(skillList) do
        if skill and skill.isSubClassOf(skillClass) then
            return true
        end
    end
end

local function getCandidateStealAnimation(athlete, enemy, stealRet, sqrLimit, animationList, targetDribbleAnimationInfo)
    local candidateSteal
    local minSqrDist = math.huge

    for animationIndex, stealAnimation in ipairs(animationList) do
        local stealAnimationKey = stealAnimation.name
        local dribbleTimeBeforeStolen = math.min(stealAnimation.firstTouch * TIME_STEP, targetDribbleAnimationInfo.time)
        local position, rotation = Animations.lerp(targetDribbleAnimationInfo, dribbleTimeBeforeStolen)--athlete.animationQueue[1].animationInfo:lerp(dribbleTimeBeforeStolen)
        position = position + targetDribbleAnimationInfo.firstTouchBallPosition - Animations.getFirstTouchPosition(targetDribbleAnimationInfo)
        local targetPosition = athlete.position + vector2.vyrotate(position, athlete.bodyDirection)
        local stealPosition = enemy.position + vector2.vyrotate(stealAnimation.firstTouchBallPosition, enemy.bodyDirection)
        local sangle = vector2.sangle(stealPosition - enemy.position, targetPosition - enemy.position)
        if math.cmpf(math.abs(sangle), math.pi / 2) < 0 then
            local stealBodyDirection = vector2.rotate(enemy.bodyDirection, sangle)
            stealPosition = enemy.position + vector2.vyrotate(stealAnimation.firstTouchBallPosition, stealBodyDirection)

            local targetSqrDist = vector2.sqrdist(targetPosition, stealPosition)
            if math.cmpf(targetSqrDist, minSqrDist) < 0 then
                minSqrDist = targetSqrDist
                candidateSteal = {
                    dribbleTimeBeforeStolen = dribbleTimeBeforeStolen,
                    stealPosition = stealPosition,
                    stealAnimation = {
                        animation = stealAnimation,
                        startBodyDirection = stealBodyDirection,
                    },
                }
            end
        end
    end

    if not sqrLimit then
        sqrLimit = 1.5
    end

    if math.cmpf(minSqrDist, sqrLimit) <= 0 then
        candidateSteal.stealAthlete = enemy
        table.insert(stealRet, {
            key = candidateSteal,
        })
        return true
    end
    return false
end

local function getCandidateFoulAnimation(athlete, enemy, foulRet, animationList, targetDribbleAnimationInfo)
    local candidateFoul = { }
    for animationIndex, stealAnimation in ipairs(animationList) do
        local stealAnimationKey = stealAnimation.name
        local sqrLimit = 1

        local dribbleTimeBeforeStolen = math.min(stealAnimation.firstTouch * TIME_STEP, targetDribbleAnimationInfo.time)
        local position, rotation = Animations.lerp(targetDribbleAnimationInfo, dribbleTimeBeforeStolen)--athlete.animationQueue[1].animationInfo:lerp(dribbleTimeBeforeStolen)
        position = position + targetDribbleAnimationInfo.firstTouchBallPosition - Animations.getFirstTouchPosition(targetDribbleAnimationInfo)
        + vector2.rotate(vector2.forward * 0.5, rotation)
        local targetPosition = athlete.position + vector2.vyrotate(position, athlete.bodyDirection)
        local stealPosition = enemy.position + vector2.vyrotate(stealAnimation.firstTouchBallPosition, enemy.bodyDirection)
        local sangle = vector2.sangle(stealPosition - enemy.position, targetPosition - enemy.position)
        if math.cmpf(math.abs(sangle), math.pi / 3) < 0 then
            local stealBodyDirection = vector2.rotate(enemy.bodyDirection, sangle)
            stealPosition = enemy.position + vector2.vyrotate(stealAnimation.firstTouchBallPosition, stealBodyDirection)

            if math.cmpf(vector2.sqrdist(targetPosition, stealPosition), sqrLimit) < 0 then
                local sign = athlete.team:getSign()
                local isInCenterDirectFreeKickArea = Field.isInCenterDirectFreeKickArea(stealPosition, sign)
                local isInWingDirectFreeKickArea = Field.isInWingDirectFreeKickArea(stealPosition, sign)
                local isInPenaltyArea = Field.isInPenaltyArea(stealPosition, sign)
                if isInCenterDirectFreeKickArea or isInWingDirectFreeKickArea or isInPenaltyArea then
                    local destMatchState = isInCenterDirectFreeKickArea and "CenterDirectFreeKick" or (isInWingDirectFreeKickArea and "WingDirectFreeKick" or "PenaltyKick")
                    table.insert(candidateFoul, {
                        dribbleTimeBeforeFouled = dribbleTimeBeforeStolen,
                        foulPosition = stealPosition,
                        destMatchState = destMatchState,
                        foulAnimation = {
                            animation = stealAnimation,
                            startBodyDirection = stealBodyDirection,
                        }
                    })
                end
            end
        end
    end
    if #candidateFoul > 0 then
        local selectedFoul = selector.randomSelect(candidateFoul)
        selectedFoul.foulAthlete = enemy
        table.insert(foulRet, {
            key = selectedFoul,
            probability = 0.15,
        })
    end
end

-- [Comment]
-- return a table: key = { athleteId = ..., bounceProbability = ... }, value = steal probability
function AIUtils.getCandidateStealsAndFouls(athlete, sqrLimit, stealAnimationList, foulAnimationList)
    return AIUtils.getCandidateStealsAndFoulsWithTarget(athlete, sqrLimit, stealAnimationList, foulAnimationList, athlete.animationQueue[1].animationInfo)
end

function AIUtils.getCandidateStealsAndFoulsWithTarget(athlete, sqrLimit, stealAnimationList, foulAnimationList, targetDribbleAnimationInfo)
    local sqrDistanceLimit = 5 ^ 2
    local stealRet = {}
    local foulRet = {}

    local foulAnimations
    if foulAnimationList then
        foulAnimations = foulAnimationList
    else
        foulAnimations = Field.isInPenaltyArea(athlete.position, athlete.team:getSign()) and Animations.Tag.FoulFierce or Animations.Tag.Foul
    end

    for id, enemy in ipairs(athlete.enemyTeam.athletes) do
        local enemyAbilities = enemy:getAbilities()
        if enemy:canBeInterruptible() then
            local sqrDistance = vector2.sqrdist(enemy.position, athlete.position)
            if math.cmpf(sqrDistance, sqrDistanceLimit) <= 0 then
                local angle = vector2.angle(athlete.direction, enemy.position - athlete.position)
                if math.cmpf(angle, math.pi * 2 / 3) < 0 or math.cmpf(sqrDistance, 1) <= 0 then --避免背后抢断
                    if not getCandidateStealAnimation(athlete, enemy, stealRet, sqrLimit, stealAnimationList or Animations.Tag.Steal, targetDribbleAnimationInfo) then
                        getCandidateStealAnimation(athlete, enemy, stealRet, sqrLimit, stealAnimationList or Animations.Tag.SlidingTackle, targetDribbleAnimationInfo)
                    end

                    getCandidateFoulAnimation(athlete, enemy, foulRet, foulAnimations, targetDribbleAnimationInfo)
                end
            end
        end
    end

    return stealRet, foulRet
end

function AIUtils.getStealProbability(athleteDribbleAbility, enemyStealAbility, enemy, isSideAthleteDribble)
    local calcSteal = enemyStealAbility
    if Field.isInEnemyArea(enemy.position, enemy.team:getSign()) then
        calcSteal = calcSteal * 0.8
    end

    if enemy:hasBuff(Skills.Poacher, "base") then
        local poacherSkill = enemy:getSkill(Skills.Poacher)
        if poacherSkill then
            calcSteal = calcSteal + enemy.initAbilitiesSum * poacherSkill.abilitiesStealSumMultiply - enemy.initAbilities.steal
        end
    end

    local baseStealProbability = AIUtils.calcDefenseSuccessProbability(calcSteal / athleteDribbleAbility)

    baseStealProbability = AIUtils.getModifiedProbability(athleteDribbleAbility, calcSteal, baseStealProbability)
    if isSideAthleteDribble then
        return baseStealProbability * 0.5
    end

    return baseStealProbability
end

function AIUtils.getStealBounceProbability(stealProbability)
    return 0.6 - 2 * stealProbability
end

function AIUtils.getDeceleration(passType)
    if passType == "Ground" then
        return 3
    elseif passType == "High" then
        return 1.5
    else
        error("invalid pass type")
    end
end

function AIUtils.getCandidateInterceptsForGroundPass(athlete)
    return AIUtils.getCandidateInterceptsForGroundPassWithTarget(
        athlete,
        athlete.chosenDPSAction.targetAthlete,
        athlete.chosenDPSAction.targetPosition,
        athlete.animationQueue[1].animationInfo.lastTouchBallPosition,
        athlete.animationQueue[1].animationInfo.lastTouch,
        false
        )
end

function AIUtils.getCandidateInterceptsForGroundPassWithTarget(
        athlete, targetAthlete, targetPosition, lastTouchBallPosition, lastTouch, inManualOperate)
    local passVector = targetPosition - athlete.position
    local ret = {}
    local ball = athlete.match.ball
    local passStartBallPosition = athlete.position + vector2.vyrotate(lastTouchBallPosition, athlete.bodyDirection)

    local passPrepareKeyFrame = lastTouch
    local flyToPrediction = ball:predictFlyTo(0, passStartBallPosition, AIUtils.getDeceleration("Ground"), targetPosition, ball:getPassSpeed(athlete, targetPosition, "Ground", isLeadPass), "Ground")
    local ballFlyKeyFrameNum = math.floor(flyToPrediction.flyDuration * 10 + 0.5)

    for i, enemy in ipairs(athlete.enemyTeam.athletes) do
        if not AIUtils.isInSector(enemy.position, targetPosition, passVector, 100, math.pi * 2 / 3) then
            local enemyAbilities = enemy:getAbilities()
            for x = 3, ballFlyKeyFrameNum, 1 do
                local t = x / 10
                local interceptPosition = ball.predictPosition(flyToPrediction, flyToPrediction.flyStartTime + t)
                local interceptSqrDistance = vector2.sqrdist(enemy.position, interceptPosition)
                local isOneStep = enemy:predictMoveTo(t, interceptPosition, passPrepareKeyFrame * TIME_STEP, 7.5)
                if not isOneStep and inManualOperate then
                    --如果是英雄时刻，用当前位置再计算一遍是否可以intercept
                    isOneStep = enemy:predictMoveTo(t, interceptPosition, 0, 7.5)
                end
                if isOneStep then
                    local sqrDistanceToTargetAthlete = vector2.sqrdist(enemy.position, targetAthlete.position)
                    local affectiveSqrDistance = math.min(interceptSqrDistance, sqrDistanceToTargetAthlete)

                    table.insert(ret, {key = {athlete = enemy, interceptPosition = interceptPosition}, affectiveSqrDistance = affectiveSqrDistance})
                    break
                end
            end
        end
    end

    return selector.minn(ret, 2, function(t) return t.affectiveSqrDistance end)
end

function AIUtils.getCandidateInterceptsForHighPass(athlete)
    return AIUtils.getCandidateInterceptsForHighPassWithTarget(
        athlete,
        athlete.chosenDPSAction.targetAthlete,
        athlete.chosenDPSAction.targetPosition,
        athlete.animationQueue[1].animationInfo.lastTouchBallPosition,
        athlete.animationQueue[1].animationInfo.lastTouch,
        athlete.chosenDPSAction.isCornerkick
        )
end

function AIUtils.getCandidateInterceptsForHighPassWithTarget(athlete, targetAthlete, targetPosition, lastTouchBallPosition, lastTouch, isCornerkick)
    local sign = athlete.team:getSign()
    local ret = {}
    local ball = athlete.match.ball
    local passStartBallPosition = athlete.position + vector2.vyrotate(lastTouchBallPosition, athlete.bodyDirection)

    local passPrepareKeyFrame = lastTouch
    local flyToPrediction = ball:predictFlyTo(0, passStartBallPosition, AIUtils.getDeceleration("High"), targetPosition, ball:getPassSpeed(athlete, targetPosition, "High", isLeadPass), "High")

    local isCrossLow = athlete:isNormalCrossLow(targetPosition)

    for i, enemy in ipairs(athlete.enemyTeam.athletes) do
        local interceptSqrDistance = vector2.sqrdist(enemy.position, targetPosition)
        local isOneStep = enemy:predictMoveTo(flyToPrediction.flyDuration, targetPosition, passPrepareKeyFrame * TIME_STEP, 10)

        if isOneStep and (enemy.role ~= 26 or Field.isInGkHighInterceptArea(targetPosition, sign)) then
            local sqrDistanceToTargetAthlete = vector2.sqrdist(enemy.position, targetAthlete.position)
            local affectiveSqrDistance = math.min(interceptSqrDistance, sqrDistanceToTargetAthlete)

            if enemy.role == 26 and math.cmpf(affectiveSqrDistance, 196) <= 0 then
                affectiveSqrDistance = 0
            end

            if math.cmpf(affectiveSqrDistance, 64) <= 0 then
                table.insert(ret, {key = {athlete = enemy, interceptPosition = targetPosition, isCornerkick = isCornerkick, isCrossLow = isCrossLow}, affectiveSqrDistance = affectiveSqrDistance})
            end
        end
    end

    return selector.minn(ret, 2, function(t) return t.affectiveSqrDistance end)
end

function AIUtils.getInterceptProbability(enemy, passAbility, isCornerkick, isCrossLow, isPassToSideAthlete)
    local calcIntercept = enemy:isGoalkeeper() and enemy:getAbilitiesSum() / 5 + 0.8 * enemy:getAbilities().anticipation or enemy:getAbilities().intercept
    if Field.isInEnemyArea(enemy.position, enemy.team:getSign()) then
        calcIntercept = calcIntercept * 0.8
    end

    if enemy:hasBuff(Skills.Poacher, "base") then
        local poacherSkill = enemy:getSkill(Skills.Poacher)
        if poacherSkill then
            calcIntercept = calcIntercept + enemy.initAbilitiesSum * poacherSkill.abilitiesInterceptSumMultiply - enemy.initAbilities.intercept
        end
    end

    local baseInterceptProbability = AIUtils.calcDefenseSuccessProbability(calcIntercept / passAbility)
    baseInterceptProbability = AIUtils.getModifiedProbability(passAbility, calcIntercept, baseInterceptProbability)
    if isCornerkick then
        return baseInterceptProbability * 0.8
    end

    if isCrossLow or isPassToSideAthlete then
        return baseInterceptProbability * 0.5
    end

    return baseInterceptProbability
end

function AIUtils.getInterceptBounceProbability()
    return 0.5
end

--[Comment]
--return a table: key = { athleteId = ..., bounceProbability = ... }, value = shoot intercept/save probability
function AIUtils.getCandidateShootIntercepts(athlete, shootAction)
    local isNonFreeKickShoot = athlete.match.frozenType ~= "CenterDirectFreeKick" and athlete.match.frozenType ~= "PenaltyKick"

    local enemyGk = athlete.enemyTeam.athleteOfRole[26]

    local addSaveAbilityForBounce = 0
    local handingSkill = enemyGk:getSkill(Skills.Handing)
    if handingSkill and selector.tossCoin(handingSkill.probability) and isNonFreeKickShoot then
        table.insert(enemyGk.toBeCastedSkills, handingSkill.class)
        addSaveAbilityForBounce = enemyGk.initAbilities.goalkeeping * handingSkill.addSaveConfig
    end

    local effectEnemyGkSave = enemyGk:getAbilitiesSum() * 0.4

    local zeroErrorSkill = enemyGk:getSkill(Skills.ZeroError)
    if zeroErrorSkill and selector.tossCoin(zeroErrorSkill.probability)
        and athlete.catchType == AIUtils.catchType.OffTheBall
        and isNonFreeKickShoot then
        table.insert(enemyGk.toBeCastedSkills, zeroErrorSkill.class)
        effectEnemyGkSave = effectEnemyGkSave + enemyGk.initAbilities.goalkeeping * zeroErrorSkill.addSaveMultiply
    end

    local godReactionSkill = enemyGk:getSkill(Skills.GodReaction)
    if godReactionSkill and selector.tossCoin(godReactionSkill.probability)
        and (athlete.catchType == AIUtils.catchType.PowerfulHeader or athlete.catchType == AIUtils.catchType.NormalHeader)
        and isNonFreeKickShoot then
        table.insert(enemyGk.toBeCastedSkills, godReactionSkill.class)
        effectEnemyGkSave = effectEnemyGkSave + enemyGk.initAbilities.anticipation * godReactionSkill.addAnticipationMultiply
    end

    local legendaryGoalkeeperSkill = enemyGk:getSkill(Skills.LegendaryGoalkeeper)
    if legendaryGoalkeeperSkill and selector.tossCoin(legendaryGoalkeeperSkill.probability)
        and (athlete.catchType == AIUtils.catchType.VolleyShoot or athlete.catchType == AIUtils.catchType.NormalVolleyShoot)
        and isNonFreeKickShoot then
        table.insert(enemyGk.toBeCastedSkills, legendaryGoalkeeperSkill.class)
        effectEnemyGkSave = effectEnemyGkSave + enemyGk.initAbilities.composure * legendaryGoalkeeperSkill.addComposureMultiply
    end

    local organizeWallSkill = enemyGk:getSkill(Skills.OrganizeWall)
    if organizeWallSkill and enemyGk:hasBuff(Skills.OrganizeWall) then
        effectEnemyGkSave = effectEnemyGkSave + enemyGk.initAbilities.commanding * organizeWallSkill.addCommandingConfig
    end

    local penaltyKickKillerSkill = enemyGk:getSkill(Skills.PenaltyKickKiller)
    if penaltyKickKillerSkill and enemyGk:hasBuff(Skills.PenaltyKickKiller) then
        effectEnemyGkSave = effectEnemyGkSave + enemyGk.initAbilities.composure * penaltyKickKillerSkill.addComposureConfig
    end

    if athlete:hasBuff(Skills.HeavyGunner) or athlete:hasBuff(Skills.FreeKickMaster) then
        athlete.team:judgeBrazilianHeavyGunner(athlete)
    end

    local isHeavyGunnerPoogba = nil
    local heavyGunnerPoogbaSkill = athlete:getSkill(Skills.HeavyGunnerPoogba)
    if heavyGunnerPoogbaSkill and heavyGunnerPoogbaSkill:isTypeOf(Skills.HeavyGunnerPoogba) and selector.tossCoin(heavyGunnerPoogbaSkill.probability) then
        athlete:addBuff(heavyGunnerPoogbaSkill.buff, athlete)
        isHeavyGunnerPoogba = true
    end

    local shootAbility = athlete:getAbilities().shoot

    local addShootAbilityForGoal = 0
    local addShootAbilityForBounce = 0
    local addKnifeGuardShootAbilityForGoal = 0
    local influenceDecreaseRate = 0

    if athlete:hasBuff(Skills.FreeKickMaster) then
        addShootAbilityForGoal = athlete.maxInitAbility * athlete:getSkill(Skills.FreeKickMaster).maxAbilityMultiply - athlete.initAbilities.shoot
    elseif athlete:hasBuff(Skills.PenaltyKickMaster) then
        addShootAbilityForGoal = athlete.maxInitAbility * athlete:getSkill(Skills.PenaltyKickMaster).maxAbilityMultiply - athlete.initAbilities.shoot
    elseif athlete:hasBuff(Skills.KnifeGuard) then
        addKnifeGuardShootAbilityForGoal = athlete.initAbilitiesSum * athlete:getSkill(Skills.KnifeGuard).abilitiesSumMultiply - athlete.initAbilities.shoot
        addShootAbilityForGoal = addKnifeGuardShootAbilityForGoal
    elseif athlete:hasBuff(Skills.CalmShoot) then
        addShootAbilityForGoal = (athlete.initAbilities.dribble + athlete.initAbilities.shoot) * athlete:getSkill(Skills.CalmShoot).addShootMultiply - athlete.initAbilities.shoot
    elseif athlete:hasBuff(Skills.HeavyGunner, "baseBuff") then
        if athlete.heavyGunnerEx1BuffCount > 0 then
            local ex1Skill = athlete:getSkill(Skills.HeavyGunnerEx1)
            addShootAbilityForGoal = athlete.initAbilitiesSum * ex1Skill.abilitiesSumMultiply + athlete.heavyGunnerEx1BuffCount * ex1Skill.extraAbilitiesSumAddRatio - athlete.initAbilities.shoot
            if ex1Skill.class:isTypeOf(Skills.MarsAreaEx1) then
                influenceDecreaseRate = influenceDecreaseRate + ex1Skill.exa1InfluenceDecreaseRate
            end
        elseif not isHeavyGunnerPoogba then
            addShootAbilityForGoal = athlete.initAbilitiesSum * athlete:getSkill(Skills.HeavyGunner).abilitiesSumMultiply - athlete.initAbilities.shoot
        end
        athlete.team:clearHeavyGunnerEx1Count()
    elseif athlete:hasBuff(Skills.FoxInTheBox) then
        local enemyGkSkill = enemyGk:getSkill(Skills.ZeroErrorEx1)
        if enemyGkSkill and selector.tossCoin(enemyGkSkill.ex1Probability) then
            enemyGk:castSkill(enemyGkSkill.class)
        else
            addShootAbilityForGoal = athlete.initAbilities.shoot * athlete:getSkill(Skills.FoxInTheBox).addShootMultiply
        end
    elseif athlete:hasBuff(Skills.PowerfulHeader) then
        local enemyGkSkill = enemyGk:getSkill(Skills.GodReactionEx1)
        if enemyGkSkill and selector.tossCoin(enemyGkSkill.ex1Probability) then
            enemyGk:castSkill(enemyGkSkill.class)
        else
            addShootAbilityForGoal = athlete.initAbilities.shoot * athlete:getSkill(Skills.PowerfulHeader).addShootMultiply
        end
    elseif athlete:hasBuff(Skills.VolleyShoot) then
        local enemyGkSkill = enemyGk:getSkill(Skills.LegendaryGoalkeeperEx1)
        if enemyGkSkill and selector.tossCoin(enemyGkSkill.ex1Probability) then
            enemyGk:castSkill(enemyGkSkill.class)
        else
            addShootAbilityForGoal = athlete.initAbilities.shoot * athlete:getSkill(Skills.VolleyShoot).addShootMultiply
        end
    end

    local tigerShootSkill = athlete:getFirstBuffSkill(Skills.TigerShoot)
    if tigerShootSkill ~= nil then
        table.insert(athlete.toBeCastedSkills, tigerShootSkill.class)
        addShootAbilityForBounce = athlete.initAbilities.shoot * tigerShootSkill.bounceShootMuliply
    end

    local goalProbability = 1
    local extraShootWideProbability = 0

    if isNonFreeKickShoot then
        --射门球员与球门中点连线两侧各45度半径3m范围内防守球员[拦+抢]的20%计入门将扑救
        local defenseAthletes = athlete:findEnemyAthletesInCircle(athlete.position, 3)

        local enemyGkDefenseCommandorSkill = enemyGk:getSkill(Skills.DefenseCommandor)
        local defenseCommandorAbility = 0
        if enemyGkDefenseCommandorSkill and selector.tossCoin(enemyGkDefenseCommandorSkill.probability)
            and isNonFreeKickShoot and #defenseAthletes > 0 then
            enemyGk:castSkill(enemyGkDefenseCommandorSkill.class)
            defenseCommandorAbility = enemyGk.initAbilities.commanding * enemyGkDefenseCommandorSkill.addCommandingMultiply
        end

        local flakTowerEx1Count = 0
        local influenceCount = 0
        for index, defenseAthlete in ipairs(defenseAthletes) do
            -- 1.combo 不吃封堵 2.防空塔ex必定封堵
            if (not athlete:getAbilities().isBlockedDisabled or defenseAthlete:getCooldownSkill(Skills.FlakTowerEx1)) and defenseAthlete ~= enemyGk then
                local defenseAbilities = defenseAthlete:getAbilities()

                local blockAddAbility = 0
                local blockSkill = defenseAthlete:getSkill(Skills.Block)
                local hasEnableBlockSkill = not athlete:getAbilities().isBlockedDisabled and not defenseAthlete:isDivingEx1Blocked() and blockSkill
                if hasEnableBlockSkill then
                    blockAddAbility = (defenseAthlete.initAbilities.intercept + defenseAthlete.initAbilities.steal) * blockSkill.interceptAndStealAddConfig
                end

                -- 带刀侍卫Ex只生效一个技能
                local multiplyDefenseCommandorAbility = (hasEnableBlockSkill and athlete:hasBuff(Skills.KnifeGuardEx1)) and 0 or defenseCommandorAbility
                local defense = (defenseAbilities.steal + defenseAbilities.intercept) * 0.25 + multiplyDefenseCommandorAbility + blockAddAbility
                local influence = AIUtils.calcDefenseSuccessProbability(defense / (shootAbility + 0.3 * addKnifeGuardShootAbilityForGoal))

                local shootType = shootAction.shootAnimationType
                if shootAction ~= nil and (shootType == AIUtils.shootAnimationType.volleyShoot or shootType == AIUtils.shootAnimationType.header) then
                    local extraInfluence = 0
                    extraInfluence, flakTowerEx1Count = defenseAthlete:judgeFlakTowerEx1(athlete, shootType, flakTowerEx1Count)
                    influence = influence + extraInfluence
                end
                defenseAthlete.influenceRate = influence
                -- 带刀侍卫Ex只生效一个技能
                if athlete:hasBuff(Skills.KnifeGuardEx1) then
                    influenceCount = influenceCount + 1
                    if influenceCount > 1 then
                        defenseAthlete.influenceRate = nil
                    end
                end

                local calmShootEx1 = athlete:getSkill(Skills.CalmShootEx1)
                if hasEnableBlockSkill and athlete:hasBuff(Skills.CalmShoot) and calmShootEx1 and selector.tossCoin(calmShootEx1.ex1Probability) then
                    blockAddAbility = blockAddAbility * (1 - calmShootEx1.ex1EffectRatio)
                    influence = influence * (1 - calmShootEx1.ex1EffectRatio)
                    athlete:castSkill(calmShootEx1.class)
                end

                influence = influence + defenseAthlete:judgeTopStudentOnFieldEffect(athlete)

                if hasEnableBlockSkill then
                    defenseAthlete:castSkill(blockSkill.class, influence)
                    extraShootWideProbability = extraShootWideProbability + defenseAthlete:judgeBlockEx1()
                end

                influence = influence * (1 + influenceDecreaseRate)-- influenceDecreaseRate是负数
                influence = math.min(influence, 0.99)
                if defenseAthlete:isDivingEx1Blocked() then
                    influence = 0
                end
                goalProbability = goalProbability * (1 - influence)
            end
        end

        extraShootWideProbability = math.min(extraShootWideProbability, 0.99)
    end

    local saveProbability = athlete.match.isInPenaltyShootOut
        and (effectEnemyGkSave / (shootAbility + addShootAbilityForGoal + effectEnemyGkSave)) * (effectEnemyGkSave / (shootAbility + addShootAbilityForGoal + effectEnemyGkSave))
        or AIUtils.calcDefenseSuccessProbability((effectEnemyGkSave) / (shootAbility + addShootAbilityForGoal))
    local bounceProbability = 1 - AIUtils.calcDefenseSuccessProbability((effectEnemyGkSave + addSaveAbilityForBounce) / (shootAbility + addShootAbilityForBounce))

    -- 扑救大师Ex1 粗暴增加扑救率
    saveProbability = math.min(enemyGk:judgeSaveMasterEx1(saveProbability), 1)
    enemyGk.saveRate = saveProbability

    --原进球率乘距离因子a，得到实际进球率
    local distanceFactor = math.min(vector2.dist(athlete.position, athlete.enemyTeam.goal.center) * -0.02 + 1.3, 1)

    -- 射门大师Ex1 粗暴增加进球率
    goalProbability = athlete:judgeShootMasterEx1(goalProbability)

    -- 小动作Ex1 降低进球率(变相修复buff)
    goalProbability = athlete:judgeGamesmanshipEx1GoalProbability(goalProbability)

    -- 点球大师 粗暴进球
    -- TODO:enemyGK无脑扑错动画
    if athlete:hasBuff(Skills.PenaltyKickMasterEx1) then
        goalProbability, enemyGk.saveRate = athlete:judgePenaltyKickMasterEx1(goalProbability, enemyGk.saveRate)
    end

    goalProbability = math.max(goalProbability * (1 - saveProbability) * distanceFactor, 0.01)
    goalProbability = math.min(goalProbability, 0.99)
    return enemyGk, goalProbability, bounceProbability, extraShootWideProbability
end

function AIUtils.getModifiedProbability(attackPower, defendPower, baseProbability)
    local maxPower = math.max(attackPower, defendPower)
    local powerRatio = 1
    local result = baseProbability
    for i, item in ipairs(powerRatioMap) do
        if math.cmpf(maxPower, item.min) > 0 and math.cmpf(maxPower, item.max) <=0 then
            powerRatio = item.val
        end
    end
    if attackPower > defendPower then
        result = result * powerRatio
    else
        result = result / powerRatio
    end
    return math.min(math.max(0.01, result), 0.99)
end


return AIUtils
