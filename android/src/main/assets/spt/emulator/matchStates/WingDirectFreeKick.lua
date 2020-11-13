if jit then jit.off(true, true) end

local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local selector = import("../libs/selector")
local AIUtils = import("../AIUtils")
local Skills = import("../skills/Skills")

local offTheBallNum = 4

local wingDirectFreeKickPositions = {
    {
        rank = 1,
        wingDirectFreeKick = {attack = vector2.new(4, 48), defense = vector2.new(3.5, 48.5)},
        rightWingDirectFreeKick = {attack = vector2.new(-4, 48), defense = vector2.new(-3.5, 48.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
    },
    {
        rank = 2,
        wingDirectFreeKick = {attack = vector2.new(4.5, 46), defense = vector2.new(5, 46.5)},
        rightWingDirectFreeKick = {attack = vector2.new(-4.5, 46), defense = vector2.new(-5, 46.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
    },
    {
        rank = 3,
        wingDirectFreeKick = {attack = vector2.new(8, 48), defense = vector2.new(7.5, 48.5)},
        rightWingDirectFreeKick = {attack = vector2.new(-8, 48), defense = vector2.new(-7.5, 48.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
    },
    {
        rank = 4,
        wingDirectFreeKick = {attack = vector2.new(0,36), defense = vector2.new(-1, 39)},
        rightWingDirectFreeKick = {attack = vector2.new(0,36), defense = vector2.new(1, 39)},
        isInHeaderArea = false,
        isInVolleyShootArea= true,
    },
    {
        rank = 5,
        wingDirectFreeKick = {attack = vector2.new(14,42), defense = vector2.new(11, 45)},
        rightWingDirectFreeKick = {attack = vector2.new(-14,42), defense = vector2.new(-11, 45)},
        isInHeaderArea = false,
        isInVolleyShootArea= true,
    },
    {
        rank = 6,
        wingDirectFreeKick = {attack = vector2.new(1, 44), defense = vector2.new(-1, 45.5)},
        rightWingDirectFreeKick = {attack = vector2.new(-1, 44), defense = vector2.new(1, 45.5)},
        isInHeaderArea = true,
        isInVolleyShootArea= false,
    },
    {
        rank = 7,
        wingDirectFreeKick = {attack = vector2.new(-6,44), defense = vector2.new(-7, 45)},
        rightWingDirectFreeKick = {attack = vector2.new(6,44), defense = vector2.new(7, 45)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
    {
        rank = 8,
        wingDirectFreeKick = {attack = vector2.new(-9,0), defense = vector2.new(3.5, 54.5)},
        rightWingDirectFreeKick = {attack = vector2.new(9,0), defense = vector2.new(-3.5, 54.5)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
    {
        rank = 9,
        wingDirectFreeKick = {attack = vector2.new(5,-5), defense = vector2.new(0, 8)},
        rightWingDirectFreeKick = {attack = vector2.new(-5,-5), defense = vector2.new(0, 8)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
    {
        rank = 10,
        wingDirectFreeKick = {attack = vector2.new(-35, 48), defense = vector2.new(-25, 52)},
        rightWingDirectFreeKick = {attack = vector2.new(35, 48), defense = vector2.new(25, 52)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
    {
        rank = 11,
        wingDirectFreeKick = {attack = vector2.new(0, -45), defense = vector2.new(-1.5,54.2)},
        rightWingDirectFreeKick = {attack = vector2.new(0, -45), defense = vector2.new(1.5,54.2)},
        isInHeaderArea = false,
        isInVolleyShootArea= false,
    },
}

local WingDirectFreeKick = class(MatchState)

function WingDirectFreeKick:ctor(match)
    WingDirectFreeKick.super.ctor(self, match, "WingDirectFreeKick")
end

function WingDirectFreeKick:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "WingDirectFreeKick"
end

function WingDirectFreeKick:getAttackTeamShootAbilities(freeKickPlayer)
    local attackTeamShootAbilities = {}
    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        local playerShootAbilities = {}

        local playerShootAbility = {player = athlete, shootAbility = athlete:getAbilities().shoot}
        if athlete == freeKickPlayer then
            playerShootAbility.shootAbility = 0
        end
        if athlete.role == 26 then
            playerShootAbility.shootAbility = -1
        end

        table.insert(playerShootAbilities, playerShootAbility)

        if athlete ~= freeKickPlayer and athlete.role ~= 26 then
            local powerfulHeaderSkill = athlete:getCooldownSkill(Skills.PowerfulHeader)
            if powerfulHeaderSkill then
                local shootAbilityCoe = 1
                if freeKickPlayer:getCooldownSkill(Skills.FreeKickMaster) then
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

function WingDirectFreeKick:getDefenseTeamInterceptAbilities()
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

function WingDirectFreeKick:setAthleteStates(xSign, ySign)
    local freeKickPlayer = self.match.attackTeam.freeKickPassPlayer
    local wingDirectFreeKickPosition = self.match.foulPosition
    local freeKickName = math.cmpf(xSign * ySign, 0) > 0 and "rightWingDirectFreeKick" or "wingDirectFreeKick"

    local attackTeamShootAbilities = self:getAttackTeamShootAbilities(freeKickPlayer)
    local clonedWingDirectFreeKickPositions = clone(wingDirectFreeKickPositions)
    for i, shootAbilityInfo in ipairs(attackTeamShootAbilities) do
        if not shootAbilityInfo.isInValid then
            local athlete = shootAbilityInfo.player
            for j, wingDirectFreeKickPositionInfo in ipairs(clonedWingDirectFreeKickPositions) do
                if not wingDirectFreeKickPositionInfo.isFilled then
                    local willBeFilled
                    if AIUtils.isSkillIdCorrespondSkill(shootAbilityInfo.skillId, Skills.PowerfulHeader) then
                        willBeFilled = wingDirectFreeKickPositionInfo.isInHeaderArea
                    elseif AIUtils.isSkillIdCorrespondSkill(shootAbilityInfo.skillId, Skills.VolleyShoot) then
                        willBeFilled = wingDirectFreeKickPositionInfo.isInVolleyShootArea
                    elseif AIUtils.isSkillIdCorrespondSkill(shootAbilityInfo.skillId, Skills.KnifeGuard) then
                        willBeFilled = wingDirectFreeKickPositionInfo.isInHeaderArea or wingDirectFreeKickPositionInfo.isInVolleyShootArea
                    else
                        willBeFilled = true
                    end

                    if willBeFilled then
                        local wingDirectFreeKickAttackPosition = wingDirectFreeKickPositionInfo[freeKickName].attack
                        athlete.position = ySign == 1 and vector2.new(wingDirectFreeKickAttackPosition.x, wingDirectFreeKickAttackPosition.y) or vector2.new(-wingDirectFreeKickAttackPosition.x, -wingDirectFreeKickAttackPosition.y)
                        athlete.bodyDirection = vector2.norm(wingDirectFreeKickPosition - athlete.position)
                        wingDirectFreeKickPositionInfo.filledAthlete = athlete
                        wingDirectFreeKickPositionInfo.isFilled = true
                        wingDirectFreeKickPositionInfo.shootAbility = shootAbilityInfo.shootAbility

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

    local rankedClonedWingDirectFreeKickPositions = self:getRankedWingDirectFreeKickPositionsByShootAbilities(clonedWingDirectFreeKickPositions)
    self:setCandidateWingDirectFreeKickTargets(rankedClonedWingDirectFreeKickPositions)

    local defenseTeamInterceptAbilities = self:getDefenseTeamInterceptAbilities()
    self.match.defenseTeam.wingDirectFreeKickWall = { }
    for i, wingDirectFreeKickPositionInfo in ipairs(wingDirectFreeKickPositions) do
        local athlete = defenseTeamInterceptAbilities[i].player
        local wingDirectFreeKickDefensePosition = wingDirectFreeKickPositionInfo[freeKickName].defense
        athlete.position = ySign == 1 and vector2.new(wingDirectFreeKickDefensePosition.x, wingDirectFreeKickDefensePosition.y) or vector2.new(-wingDirectFreeKickDefensePosition.x, -wingDirectFreeKickDefensePosition.y)
        athlete.bodyDirection = vector2.norm(wingDirectFreeKickPosition - athlete.position)
        if i == 9 or i == 10 then
            table.insert(self.match.defenseTeam.wingDirectFreeKickWall, athlete)
        end
    end
end

function WingDirectFreeKick:getRankedWingDirectFreeKickPositionsByShootAbilities(clonedWingDirectFreeKickPositions)
    local rankedClonedWingDirectFreeKickPositions = {}

    for i, wingDirectFreeKickPositionInfo in ipairs(clonedWingDirectFreeKickPositions) do
        table.insert(rankedClonedWingDirectFreeKickPositions, wingDirectFreeKickPositionInfo)
    end

    table.sort(rankedClonedWingDirectFreeKickPositions, function(a, b) return math.cmpf(a.shootAbility, b.shootAbility) > 0 end)

    return rankedClonedWingDirectFreeKickPositions
end

function WingDirectFreeKick:setCandidateWingDirectFreeKickTargets(rankedClonedWingDirectFreeKickPositions)
    self.match.candidateWingDirectFreeKickTargets = { }

    local candidateShootAbilitySum = 0
    for i = 1, offTheBallNum do
        candidateShootAbilitySum = candidateShootAbilitySum + rankedClonedWingDirectFreeKickPositions[i].shootAbility
    end

    for i = 1, offTheBallNum do
        table.insert(self.match.candidateWingDirectFreeKickTargets, {key = rankedClonedWingDirectFreeKickPositions[i].filledAthlete, weight = rankedClonedWingDirectFreeKickPositions[i].shootAbility / candidateShootAbilitySum})
    end
end

function WingDirectFreeKick:setWallAthleteStates(ySign)
    local wallPositions = self:getWallPositions(ySign)

    for i, athlete in ipairs(self.match.defenseTeam.wingDirectFreeKickWall) do
        athlete.position = wallPositions[i]
        athlete.bodyDirection = vector2.norm(self.match.foulPosition - athlete.position)
    end
end

function WingDirectFreeKick:getWallPositions(ySign)
    local centerGoalVector = vector2.new(0, Field.halfLength * ySign) - self.match.foulPosition
    local unitCenterGoalVector = vector2.clamp(centerGoalVector, 1)
    local unitVerticalCenterGoalVector = vector2.rotate(unitCenterGoalVector, math.pi / 2)
    local interPoint = unitCenterGoalVector * Field.kickerWallDistance + self.match.foulPosition

    return {interPoint, interPoint - unitVerticalCenterGoalVector * 0.5,
    interPoint + unitVerticalCenterGoalVector * 0.5, interPoint - unitVerticalCenterGoalVector,
    interPoint + unitVerticalCenterGoalVector}
end

function WingDirectFreeKick:setKickAthleteState()
    local freeKickPlayer = self.match.attackTeam.freeKickPassPlayer
    local passAnimation = freeKickPlayer:selectAnimation("WingDirectFreeKick", function (animation)
        local rawData = Animations.RawData[animation.name]
        return not freeKickPlayer.foot or rawData.foot == freeKickPlayer.foot end, true)
    freeKickPlayer.bodyDirection = vector2.rotate(vector2.norm(freeKickPlayer.team:getPenaltyKickPosition() - self.match.foulPosition), -Animations.RawData[passAnimation.name].outAngle.Start)
    freeKickPlayer.position = self.match.foulPosition - vector2.vyrotate(passAnimation.firstTouchBallPosition, freeKickPlayer.bodyDirection)
    self.match.ball:setOwner(freeKickPlayer)
    self.match.ball.position = self.match.foulPosition
    freeKickPlayer:pushAnimation(passAnimation, true)

    freeKickPlayer.upComingAction = "WingDirectFreeKick"
end

function WingDirectFreeKick:adjustAthletePosition()
    local ballToGoalNormVec = vector2.norm(self.match.defenseTeam.goal.center - self.match.attackTeam.freeKickPassPlayer.position)
    local tmpPosition = self.match.attackTeam.freeKickPassPlayer.position - ballToGoalNormVec * 9
    for i, athlete in self.match:allAthletes() do
        if athlete ~= self.match.attackTeam.freeKickPassPlayer and athlete.role ~= 26
        and not table.isArrayInclude(self.match.defenseTeam.wingDirectFreeKickWall, athlete) then
            if AIUtils.isInSector(athlete.position, tmpPosition ,
                ballToGoalNormVec, 18.5, math.pi / 4) then
                local vec = athlete.position - tmpPosition
                local sangle = vector2.sangle(ballToGoalNormVec, vec)
                if math.cmpf(sangle, 0) >= 0 then
                    athlete.position = tmpPosition + vector2.rotate(vec, math.pi / 8 - sangle)
                else
                    athlete.position = tmpPosition + vector2.rotate(vec, -math.pi / 8 - sangle)
                end
                athlete.bodyDirection = vector2.norm(self.match.foulPosition - athlete.position)
            end
        end
    end
end

function WingDirectFreeKick:Execute()
    local xSign = math.sign(self.match.foulPosition.x)
    local ySign = math.sign(self.match.foulPosition.y)

    self:setAthleteStates(xSign, ySign)
    self:setWallAthleteStates(ySign)
    self:setKickAthleteState()
    self:adjustAthletePosition()

    self.super.Execute(self)

    self.match:changeState("NormalPlayOn")
end

function WingDirectFreeKick:Exit()

end

return WingDirectFreeKick
