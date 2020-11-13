if jit then jit.off(true, true) end

local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local selector = import("../libs/selector")
local Skills = import("../skills/Skills")
local AIUtils = import("../AIUtils")

local offTheBallNum = 4

local cornerKickPositions = {
    {
        rank = 1,
        cornerKick = {attack = vector2.new(4, 48), defense = vector2.new(3.5, 48.5)},
        rightCornerKick = {attack = vector2.new(-4, 48), defense = vector2.new(-3.5, 48.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
    },
    {
        rank = 2,
        cornerKick = {attack = vector2.new(4.5, 46), defense = vector2.new(5, 46.5)},
        rightCornerKick = {attack = vector2.new(-4.5, 46), defense = vector2.new(-5, 46.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
    },
    {
        rank = 3,
        cornerKick = {attack = vector2.new(8, 48), defense = vector2.new(7.5, 48.5)},
        rightCornerKick = {attack = vector2.new(-8, 48), defense = vector2.new(-7.5, 48.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
    },
    {
        rank = 4,
        cornerKick = {attack = vector2.new(0,36), defense = vector2.new(-1, 39)},
        rightCornerKick = {attack = vector2.new(0,36), defense = vector2.new(1, 39)},
        isInHeaderArea = false,
        isInVolleyShootArea= true,
        isInShortCornerArea = false,
    },
    {
        rank = 5,
        cornerKick = {attack = vector2.new(14,42), defense = vector2.new(11, 45)},
        rightCornerKick = {attack = vector2.new(-14,42), defense = vector2.new(-11, 45)},
        isInHeaderArea = false,
        isInVolleyShootArea= true,
    },
    {
        rank = 6,
        cornerKick = {attack = vector2.new(1, 44), defense = vector2.new(-1, 45.5)},
        rightCornerKick = {attack = vector2.new(-1, 44), defense = vector2.new(1, 45.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
        isInShortCornerArea = false,
    },
    {
        rank = 7,
        cornerKick = {attack = vector2.new(-6,44), defense = vector2.new(-7, 45)},
        rightCornerKick = {attack = vector2.new(6,44), defense = vector2.new(7, 45)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
    {
        rank = 8,
        cornerKick = {attack = vector2.new(-9,0), defense = vector2.new(3.5, 54.5)},
        rightCornerKick = {attack = vector2.new(9,0), defense = vector2.new(-3.5, 54.5)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
    {
        rank = 9,
        cornerKick = {attack = vector2.new(5,-5), defense = vector2.new(0, 8)},
        rightCornerKick = {attack = vector2.new(-5,-5), defense = vector2.new(0, 8)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
        isInShortCornerArea = false,
    },
    {
        rank = 10,
        cornerKick = {attack = vector2.new(-35, 48), defense = vector2.new(-25, 52)},
        rightCornerKick = {attack = vector2.new(35, 48), defense = vector2.new(25, 52)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
    {
        rank = 11,
        cornerKick = {attack = vector2.new(0, -45), defense = vector2.new(-1.5,54.2)},
        rightCornerKick = {attack = vector2.new(0, -45), defense = vector2.new(1.5,54.2)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
}

local CornerKick = class(MatchState)

function CornerKick:ctor(match)
    CornerKick.super.ctor(self, match, "CornerKick")
end

function CornerKick:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "CornerKick"
end

function CornerKick:getCornerKickPosition()
    local xSign = math.sign(self.match.ball.outOfFieldPoint.x)
    local ySign = math.sign(self.match.ball.outOfFieldPoint.y)
    xSign = xSign == 0 and 1 or xSign
    return vector2.new(xSign * (Field.halfWidth - 0.8), ySign * (Field.halfLength - 0.5))
end

function CornerKick:getAttackTeamShootAbilities(cornerKickPlayer)
    local attackTeamShootAbilities = {}
    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        local playerShootAbilities = { }

        local playerShootAbility = {player = athlete, shootAbility = athlete:getAbilities().shoot}
        if athlete == cornerKickPlayer then
            playerShootAbility.shootAbility = 0
        end
        if athlete.role == 26 then
            playerShootAbility.shootAbility = -1
        end

        table.insert(playerShootAbilities, playerShootAbility)

        if athlete ~= cornerKickPlayer and athlete.role ~= 26 then
            local powerfulHeaderSkill = athlete:getCooldownSkill(Skills.PowerfulHeader)
            if powerfulHeaderSkill then
                local shootAbilityCoe = 1
                if cornerKickPlayer:getCooldownSkill(Skills.CornerKickMaster) then
                    shootAbilityCoe = 2
                end
                table.insert(playerShootAbilities, {
                    player = athlete,
                    shootAbility = (athlete:getAbilities().shoot + athlete.initAbilities.shoot * powerfulHeaderSkill.addShootMultiply) * shootAbilityCoe,
                    skillId = powerfulHeaderSkill.id
                })
            end

            local volleyShootSkill = athlete:getCooldownSkill(Skills.VolleyShoot)
            if volleyShootSkill then
                table.insert(playerShootAbilities, {
                    player = athlete,
                    shootAbility = athlete:getAbilities().shoot + athlete.initAbilities.shoot * volleyShootSkill.addShootMultiply,
                    skillId = volleyShootSkill.id
                })
            end

            local knifeGuardSkill = athlete:getCooldownSkill(Skills.KnifeGuard)
            if knifeGuardSkill then
                table.insert(playerShootAbilities, {
                    player = athlete,
                    shootAbility = athlete:getAbilities().shoot +
                        athlete.initAbilitiesSum * knifeGuardSkill.abilitiesSumMultiply - athlete.initAbilities.shoot,
                    skillId = knifeGuardSkill.id
                })
            end
        end

        for _, shootAbilityInfo in ipairs(playerShootAbilities) do
            table.insert(attackTeamShootAbilities, shootAbilityInfo)
        end
    end

    table.sort(attackTeamShootAbilities, function(a, b) return math.cmpf(a.shootAbility, b.shootAbility) > 0 end)

    return attackTeamShootAbilities
end

function CornerKick:getDefenseTeamInterceptAbilities()
    local defenseTeamInterceptAbilities = {}
    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        local playerInterceptAbility = {player = athlete, interceptAbility = athlete:getAbilities().intercept}

        local flakTowerSkill = athlete:getCooldownSkill(Skills.FlakTower)
        if flakTowerSkill then
            local tempAbilities = clone(athlete:getAbilities())
            flakTowerSkill.buff.abilitiesModifier(tempAbilities, athlete, athlete)
            playerInterceptAbility.interceptAbility = tempAbilities.intercept
        end

        if athlete.role == 26 then
            playerInterceptAbility.interceptAbility = -1
        end

        table.insert(defenseTeamInterceptAbilities, playerInterceptAbility)
    end

    table.sort(defenseTeamInterceptAbilities, function(a, b) return math.cmpf(a.interceptAbility, b.interceptAbility) > 0 end)

    return defenseTeamInterceptAbilities
end

function CornerKick:setAthleteStates(cornerKickPlayer, cornerKickPosition, xSign, ySign)
    local cornerKickName = math.cmpf(xSign * ySign, 0) > 0 and "rightCornerKick" or "cornerKick"

    local attackTeamShootAbilities = self:getAttackTeamShootAbilities(cornerKickPlayer)
    local clonedCornerKickPositions = clone(cornerKickPositions)
    for i, shootAbilityInfo in ipairs(attackTeamShootAbilities) do
        if not shootAbilityInfo.isInValid then
            local athlete = shootAbilityInfo.player
            for j, cornerKickPositionInfo in ipairs(clonedCornerKickPositions) do
                if not cornerKickPositionInfo.isFilled then
                    local willBeFilled
                    if AIUtils.isSkillIdCorrespondSkill(shootAbilityInfo.skillId, Skills.PowerfulHeader) then
                        willBeFilled = cornerKickPositionInfo.isInHeaderArea
                    elseif AIUtils.isSkillIdCorrespondSkill(shootAbilityInfo.skillId, Skills.VolleyShoot) then
                        willBeFilled = cornerKickPositionInfo.isInVolleyShootArea
                    elseif AIUtils.isSkillIdCorrespondSkill(shootAbilityInfo.skillId, Skills.KnifeGuard) then
                        willBeFilled = cornerKickPositionInfo.isInHeaderArea or cornerKickPositionInfo.isInVolleyShootArea
                    else
                        willBeFilled = true
                    end

                    if willBeFilled then
                        local cornerAttackPosition = cornerKickPositionInfo[cornerKickName].attack
                        athlete.position = ySign == 1 and vector2.new(cornerAttackPosition.x, cornerAttackPosition.y) or vector2.new(-cornerAttackPosition.x, -cornerAttackPosition.y)
                        athlete.bodyDirection = vector2.norm(cornerKickPosition - athlete.position)
                        cornerKickPositionInfo.filledAthlete = athlete
                        cornerKickPositionInfo.isFilled = true
                        cornerKickPositionInfo.shootAbility = shootAbilityInfo.shootAbility

                        for k, tempShootAbilityInfo in ipairs(attackTeamShootAbilities) do
                            if tempShootAbilityInfo.player == athlete then
                                tempShootAbilityInfo.isInValid = true
                            end
                        end

                        break
                    end
                end
            end
        end
    end

    local rankedClonedCornerKickPositions = self:getRankedCornerKickPositionsByShootAbilities(clonedCornerKickPositions)
    self:setCandidateCornerKickTargets(rankedClonedCornerKickPositions)

    local defenseTeamInterceptAbilities = self:getDefenseTeamInterceptAbilities()
    for i, cornerKickPositionInfo in ipairs(cornerKickPositions) do
        local athlete = defenseTeamInterceptAbilities[i].player
        local cornerDefensePosition = cornerKickPositionInfo[cornerKickName].defense
        athlete.position = ySign == 1 and vector2.new(cornerDefensePosition.x, cornerDefensePosition.y) or vector2.new(-cornerDefensePosition.x, -cornerDefensePosition.y)
        athlete.bodyDirection = vector2.norm(cornerKickPosition - athlete.position)
    end
end

function CornerKick:getRankedCornerKickPositionsByShootAbilities(clonedCornerKickPositions)
    local rankedClonedCornerKickPositions = {}

    for i, cornerKickPositionInfo in ipairs(clonedCornerKickPositions) do
        table.insert(rankedClonedCornerKickPositions, cornerKickPositionInfo)
    end

    table.sort(rankedClonedCornerKickPositions, function(a, b) return math.cmpf(a.shootAbility, b.shootAbility) > 0 end)

    return rankedClonedCornerKickPositions
end

function CornerKick:setCandidateCornerKickTargets(rankedClonedCornerKickPositions)
    self.match.candidateCornerKickTargets = { }

    local candidateShootAbilitySum = 0
    for i = 1, offTheBallNum do
        candidateShootAbilitySum = candidateShootAbilitySum + rankedClonedCornerKickPositions[i].shootAbility
    end

    for i = 1, offTheBallNum do
        table.insert(self.match.candidateCornerKickTargets, {key = rankedClonedCornerKickPositions[i].filledAthlete, weight = rankedClonedCornerKickPositions[i].shootAbility / candidateShootAbilitySum})
    end
end

function CornerKick:setKickAthleteState(cornerKickPosition, cornerKickPlayer)
    local cornerPassAnimation = cornerKickPlayer:selectAnimation("CornerPass", function (animation)
        local rawData = Animations.RawData[animation.name]
        return not cornerKickPlayer.foot or rawData.foot == cornerKickPlayer.foot end, true)
    cornerKickPlayer.bodyDirection = vector2.rotate(vector2.norm(cornerKickPlayer.team:getPenaltyKickPosition() - cornerKickPosition), -Animations.RawData[cornerPassAnimation.name].outAngle.Start)
    cornerKickPlayer.position = cornerKickPosition - vector2.vyrotate(cornerPassAnimation.firstTouchBallPosition, cornerKickPlayer.bodyDirection)
    self.match.ball:setOwner(cornerKickPlayer)
    self.match.ball.position = cornerKickPosition
    cornerKickPlayer:pushAnimation(cornerPassAnimation, true)

    cornerKickPlayer.upComingAction = "CornerKick"
end

function CornerKick:Execute()
    local cornerKickPosition = self:getCornerKickPosition()

    local xSign = math.sign(cornerKickPosition.x)
    local ySign = math.sign(cornerKickPosition.y)

    local cornerKickPlayer = xSign * ySign == 1 and self.match.attackTeam.leftFootCornerKickPlayer or self.match.attackTeam.rightFootCornerKickPlayer

    self:setAthleteStates(cornerKickPlayer, cornerKickPosition, xSign, ySign)
    self:setKickAthleteState(cornerKickPosition, cornerKickPlayer)

    self.match.attackTeam.cornerTimes = self.match.attackTeam.cornerTimes + 1

    self.super.Execute(self)

    self.match:judgeAfterShootMissSkills()

    self.match:changeState("NormalPlayOn")
end

function CornerKick:Exit()

end

return CornerKick
