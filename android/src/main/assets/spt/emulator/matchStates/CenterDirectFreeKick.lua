if jit then jit.off(true, true) end

local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local selector = import("../libs/selector")
local AIUtils = import("../AIUtils")
local geometry = import("../libs/geometry")
local segment = import("../libs/segment")

local CenterDirectFreeKick = class(MatchState)

function CenterDirectFreeKick:ctor(match)
    CenterDirectFreeKick.super.ctor(self, match, "CenterDirectFreeKick")
end

function CenterDirectFreeKick:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "CenterDirectFreeKick"
end

function CenterDirectFreeKick:setAthleteStates(xSign, ySign)
    local freeKickName = math.cmpf(xSign * ySign, 0) > 0 and "rightCenterDirectFreeKick" or "centerDirectFreeKick"

    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        local centerDirectFreeKickAttackPosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].attack[freeKickName]
        athlete.position = ySign == 1 and vector2.new(centerDirectFreeKickAttackPosition.x, centerDirectFreeKickAttackPosition.y)
            or vector2.new(-centerDirectFreeKickAttackPosition.x, -centerDirectFreeKickAttackPosition.y)
        athlete.bodyDirection = vector2.norm(self.match.foulPosition - athlete.position)
    end

    self.match.defenseTeam.centerDirectFreeKickWall = { }
    local wall = Field.formations[self.match.defenseTeam.formation][freeKickName .. "Wall"]
    local wallAthleteNumber = math.cmpf(vector2.sqrdist(self.match.foulPosition, self.match.defenseTeam.goal.center), 25 ^ 2) <= 0 and 5 or 4
    for i, role in ipairs(wall) do
        if i <= wallAthleteNumber then
            table.insert(self.match.defenseTeam.centerDirectFreeKickWall, self.match.defenseTeam.athleteOfRole[role])
        end
    end
    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        local centerDirectFreeKickDefensePosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].defense[freeKickName]
        if centerDirectFreeKickDefensePosition then
            athlete.position = ySign == 1 and vector2.new(centerDirectFreeKickDefensePosition.x, centerDirectFreeKickDefensePosition.y)
            or vector2.new(-centerDirectFreeKickDefensePosition.x, -centerDirectFreeKickDefensePosition.y)

            if athlete:isGoalkeeper() then
                athlete.position.x = -xSign * Field.halfGoalWidth / 4
            end
        end

        athlete.bodyDirection = vector2.norm(self.match.foulPosition - athlete.position)
    end
end

function CenterDirectFreeKick:setWallAthleteStates(xSign, ySign)
    local wallPositions = self:getWallPositions(xSign, ySign)

    for i, athlete in ipairs(self.match.defenseTeam.centerDirectFreeKickWall) do
        athlete.position = wallPositions[i]
        athlete.bodyDirection = vector2.norm(self.match.foulPosition - athlete.position)
    end
end

function CenterDirectFreeKick:getWallPositions(xSign, ySign)
    local enemyGoalCenter = vector2.new(0, Field.halfLength * ySign)
    local centerGoalVector = enemyGoalCenter - self.match.foulPosition
    local unitCenterGoalVector = vector2.clamp(centerGoalVector, 1)
    local unitVerticalCenterGoalVector = vector2.rotate(unitCenterGoalVector, math.pi / 2)
    local interPoint = unitCenterGoalVector * Field.kickerWallDistance + self.match.foulPosition

    local segment1 = segment.new(interPoint + unitVerticalCenterGoalVector * 50, interPoint - unitVerticalCenterGoalVector * 50)
    local segment2 = segment.new(enemyGoalCenter + vector2.new(xSign * Field.halfGoalWidth, 0), self.match.foulPosition)
    local sign = xSign * ySign
    local sideInterPosition = geometry.intersectPoint(segment1, segment2) - unitVerticalCenterGoalVector * sign

    return {
        sideInterPosition,
        sideInterPosition + unitVerticalCenterGoalVector * (0.5 * sign),
        sideInterPosition + unitVerticalCenterGoalVector * sign,
        sideInterPosition + unitVerticalCenterGoalVector * (1.5 * sign),
        sideInterPosition + unitVerticalCenterGoalVector * (2 * sign),
    }
end

function CenterDirectFreeKick:setKickAthleteState()
    local freeKickPlayer = self.match.attackTeam.freeKickShootPlayer
    local shootAnimation = freeKickPlayer:selectAnimation("CenterDirectFreeKick", function (animation)
        local rawData = Animations.RawData[animation.name]
        return not freeKickPlayer.foot or rawData.foot == freeKickPlayer.foot end, true)
    freeKickPlayer.bodyDirection = vector2.rotate(vector2.norm(freeKickPlayer.enemyTeam.goal.center - self.match.foulPosition), -Animations.RawData[shootAnimation.name].outAngle.Start)
    freeKickPlayer.position = self.match.foulPosition - vector2.vyrotate(shootAnimation.firstTouchBallPosition, freeKickPlayer.bodyDirection)
    self.match.ball:setOwner(freeKickPlayer)
    self.match.ball.position = self.match.foulPosition
    freeKickPlayer:pushAnimation(shootAnimation, true)

    freeKickPlayer.upComingAction = "CenterDirectFreeKick"
end

function CenterDirectFreeKick:adjustAthletePosition()
    local wallCenter = (self.match.defenseTeam.centerDirectFreeKickWall[1].position +
        self.match.defenseTeam.centerDirectFreeKickWall[#self.match.defenseTeam.centerDirectFreeKickWall].position) / 2
    local ballToWallCenterNormVec = vector2.norm(wallCenter - self.match.foulPosition)
    local tmpPosition = self.match.foulPosition - ballToWallCenterNormVec * 15
    for i, athlete in self.match:allAthletes() do
        if athlete ~= self.match.attackTeam.freeKickShootPlayer and athlete.role ~= 26
        and not table.isArrayInclude(self.match.defenseTeam.centerDirectFreeKickWall, athlete) then
            if AIUtils.isInSector(athlete.position, tmpPosition ,
                ballToWallCenterNormVec, 24.5, math.pi / 4) then
                local vec = athlete.position - tmpPosition
                local sangle = vector2.sangle(ballToWallCenterNormVec, vec)
                if math.cmpf(sangle, 0) >= 0 then
                    athlete.position = tmpPosition + vector2.rotate(vec, math.pi / 6 - sangle)
                else
                    athlete.position = tmpPosition + vector2.rotate(vec, -math.pi / 6 - sangle)
                end
                athlete.bodyDirection = vector2.norm(self.match.foulPosition - athlete.position)
            end
        end
    end
end

function CenterDirectFreeKick:Execute()
    local xSign = math.sign(self.match.foulPosition.x)
    xSign = xSign == 0 and 1 or xSign
    local ySign = math.sign(self.match.foulPosition.y)

    self:setAthleteStates(xSign, ySign)
    self:setWallAthleteStates(xSign, ySign)
    self:setKickAthleteState()
    self:adjustAthletePosition()

    self.super.Execute(self)

    self.match:changeState("NormalPlayOn")
end

function CenterDirectFreeKick:Exit()

end

return CenterDirectFreeKick
