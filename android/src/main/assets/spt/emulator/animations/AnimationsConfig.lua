local vector2 = import("../libs/vector")
local AnimationsDef = import("./AnimationsDef")

AnimationsDef.Pose = {
    STAND = 1,
    RUN = 2,
    DRIBBLE = 3,
}

AnimationsDef.MoveType = {
    TURN_LEFT_90 = 1,
    TURN_RIGHT_90 = 2,
    TURN_LEFT_180 = 3,
    TURN_RIGHT_180 = 4,
    NON_TURN_FORWARD = 11,
    NON_TURN_LEFT = 12,
    NON_TURN_RIGHT = 13,
    NON_TURN_BACKWARD_LEFT_135 = 14,
    NON_TURN_BACKWARD_RIGHT_135 = 15,
    NON_TURN_BACKWARD_180 = 16,
    NON_TURN_ACCELERATE = 17,
    NON_TURN_DECELERATE = 18,
    STAY = 19,
}

AnimationsDef.turnAnimationConfig = {
    { name = "B_R002", moveType = AnimationsDef.MoveType.TURN_RIGHT_90, angle = -math.pi / 2, towardAngleMin = -math.pi * 3 / 4, towardAngleMax = -math.pi * 2 / 5, moveAngleMin = -math.pi / 4, moveAngleMax = 0, speedMin = 0, speedMax = 0 }, --低速右转90
    { name = "B_R002_1", moveType = AnimationsDef.MoveType.TURN_RIGHT_90, angle = -math.pi / 2, towardAngleMin = -math.pi * 3 / 4, towardAngleMax = -math.pi * 2 / 5, moveAngleMin = -math.pi, moveAngleMax = -math.pi / 4, speedMin = 0, speedMax = 0 }, --高速右转90
    { name = "B_R003", moveType = AnimationsDef.MoveType.TURN_LEFT_90, angle = math.pi / 2, towardAngleMin = math.pi / 3, towardAngleMax = math.pi * 3 / 4, moveAngleMin = 0, moveAngleMax = math.pi / 4, speedMin = 0, speedMax = 0 }, --低速左转90
    { name = "B_R003_1", moveType = AnimationsDef.MoveType.TURN_LEFT_90, angle = math.pi / 2, towardAngleMin = math.pi / 3, towardAngleMax = math.pi * 3 / 4, moveAngleMin = math.pi / 4, moveAngleMax = math.pi, speedMin = 0, speedMax = 0 }, --高速左转90
    { name = "B_R004", moveType = AnimationsDef.MoveType.TURN_RIGHT_180, angle = -math.pi, towardAngleMin = -math.pi, towardAngleMax = -math.pi * 3 / 4, moveAngleMin = -math.pi, moveAngleMax = math.pi, speedMin = 0, speedMax = 0 }, --低速右转180
    { name = "B_R004_1", moveType = AnimationsDef.MoveType.TURN_RIGHT_180, angle = -math.pi, towardAngleMin = -math.pi, towardAngleMax = -math.pi * 3 / 4, moveAngleMin = -math.pi, moveAngleMax = math.pi, speedMin = 0, speedMax = 0 }, --高速右转180
    { name = "B_R005", moveType = AnimationsDef.MoveType.TURN_LEFT_180, angle = math.pi, towardAngleMin = math.pi * 3 / 4, towardAngleMax = math.pi, moveAngleMin = -math.pi, moveAngleMax = math.pi, speedMin = 0, speedMax = 0 }, --低速左转180
    { name = "B_R005_1", moveType = AnimationsDef.MoveType.TURN_LEFT_180, angle = math.pi, towardAngleMin = math.pi * 3 / 4, towardAngleMax = math.pi, moveAngleMin = -math.pi, moveAngleMax = math.pi, speedMin = 0, speedMax = 0 }, --高速左转180
}

AnimationsDef.nonTurnAnimationConfig = {
    { name = "B_R001", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 4, speedMax = 5 }, --低速
    { name = "B_R001_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 7.5, speedMax = 9 }, --高速
    { name = "B_R001_2", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 3, speedMax = 4 }, --低速
    { name = "B_R001_3", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 9, speedMax = 10 }, --高速
    { name = "B_R001_4", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 5, speedMax = 6 }, --低速
    { name = "B_R001_5", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 6.5, speedMax = 8 }, --低速
    { name = "B_R001_6", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 7.5, speedMax = 9 }, --低速
    { name = "B_R001_7", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 5, speedMax = 6.5 }, --低速
    { name = "B_R001_8", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 8, speedMax = 9 }, --低速
    { name = "B_R006", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi * 3 / 4, moveAngleMax = -math.pi / 4, speedMin = 1, speedMax = 2.5 }, --低速 向右 非盯人
    { name = "B_R006_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi * 3 / 4, moveAngleMax = -math.pi / 4, speedMin = 2, speedMax = 4 }, --低速
    { name = "B_R006_2", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi / 2, moveAngleMax = -math.pi / 4, speedMin = 4, speedMax = 5 }, --中速
    { name = "B_R006_3", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi * 3 / 4, moveAngleMax = -math.pi / 4, speedMin = 2.5, speedMax = 4 }, --中速
    { name = "B_R006_4", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi / 2, moveAngleMax = -math.pi / 4, speedMin = 4, speedMax = 5 }, --中速
    { name = "B_R007", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi * 3 / 4, speedMin = 1, speedMax = 2.5 }, --低速 向左 非盯人
    { name = "B_R007_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi * 3 / 4, speedMin = 2, speedMax = 4 }, --低速
    { name = "B_R007_2", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi / 2, speedMin = 4, speedMax = 5 }, --中速
    { name = "B_R007_3", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi * 3 / 4, speedMin = 2.5, speedMax = 4 }, --中速
    { name = "B_R007_4", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi / 2, speedMin = 4, speedMax = 5 }, --中速
    { name = "B_R008", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi * 3 / 5, moveAngleMax = -math.pi * 2 / 5, speedMin = 2, speedMax = 4 }, --低速 向右 盯人
    { name = "B_R008_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi * 3 / 5, moveAngleMax = -math.pi * 2 / 5, speedMin = 3, speedMax = 4.5 }, --中速
    { name = "B_R008_2", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi * 3 / 5, moveAngleMax = -math.pi * 2 / 5, speedMin = 3.5, speedMax = 5.5 }, --中速
    --{ name = "B_R008_3", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi / 2, moveAngleMax = -math.pi / 4, speedMin = 5.5, speedMax = 7 }, --高速
    --{ name = "B_R008_4", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi / 2, moveAngleMax = -math.pi / 4, speedMin = 6.5, speedMax = 7.5 }, --高速
    { name = "B_R009", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi * 2 / 5, moveAngleMax = math.pi * 3 / 5, speedMin = 2, speedMax = 4 }, --低速 向左 盯人
    { name = "B_R009_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi * 2 / 5, moveAngleMax = math.pi * 3 / 5, speedMin = 3, speedMax = 4.5 }, --中速
    { name = "B_R009_2", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi * 2 / 5, moveAngleMax = math.pi * 3 / 5, speedMin = 3.5, speedMax = 5.5 }, --中速
    --{ name = "B_R009_3", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi / 2, speedMin = 5.5, speedMax = 7 }, --高速
    --{ name = "B_R009_4", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi / 2, speedMin = 7, speedMax = 8.5 }, --高速
    { name = "B_R010", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_RIGHT_135, moveAngleMin = -math.pi * 4 / 5, moveAngleMax = -math.pi * 3 / 5, speedMin = 2, speedMax = 3.5 }, --低速 向右后
    { name = "B_R010_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_RIGHT_135, moveAngleMin = -math.pi * 4 / 5, moveAngleMax = -math.pi * 3 / 5, speedMin = 1.5, speedMax = 3 }, --低速
    { name = "B_R010_2", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_RIGHT_135, moveAngleMin = -math.pi * 4 / 5, moveAngleMax = -math.pi * 3 / 5, speedMin = 3, speedMax = 4.5 }, --高速
    { name = "B_R010_3", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_RIGHT_135, moveAngleMin = -math.pi * 4 / 5, moveAngleMax = -math.pi * 3 / 5, speedMin = 4, speedMax = 5.5 }, --高速
    { name = "B_R011", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_LEFT_135, moveAngleMin = math.pi * 3 / 5, moveAngleMax = math.pi * 4 / 5, speedMin = 2, speedMax = 3.5 }, --低速 向左后
    { name = "B_R011_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_LEFT_135, moveAngleMin = math.pi * 3 / 5, moveAngleMax = math.pi * 4 / 5, speedMin = 1.5, speedMax = 3 }, --低速
    { name = "B_R011_2", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_LEFT_135, moveAngleMin = math.pi * 3 / 5, moveAngleMax = math.pi * 4 / 5, speedMin = 3, speedMax = 4.5 }, --高速
    { name = "B_R011_3", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_LEFT_135, moveAngleMin = math.pi * 3 / 5, moveAngleMax = math.pi * 4 / 5, speedMin = 4, speedMax = 5.5 }, --高速
    { name = "B_R017", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_180, moveAngleMin = math.pi * 3 / 4, moveAngleMax = -math.pi * 3 / 4, speedMin = 1, speedMax = 2.5 }, --高速
    { name = "B_R018", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_180, moveAngleMin = math.pi * 3 / 4, moveAngleMax = -math.pi * 3 / 4, speedMin = 3, speedMax = 4 }, --高速
    { name = "B_R019", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_180, moveAngleMin = math.pi * 3 / 4, moveAngleMax = -math.pi * 3 / 4, speedMin = 3.5, speedMax = 5.5 }, --高速
    { name = "B_R036", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_BACKWARD_180, moveAngleMin = math.pi * 3 / 4, moveAngleMax = -math.pi * 3 / 4, speedMin = 1, speedMax = 2 },
    { name = "B_R039", angle = 0, moveTye = AnimationsDef.MoveType.NON_TURN_BACKWARD_180, moveAngleMin = math.pi * 3 / 4, moveAngleMax = -math.pi * 3 / 4, speedMin = 2.5, speedMax = 4 },
    { name = "B_R040", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 2, speedMax = 3 },
    { name = "B_R041", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 1, speedMax = 2 },
    { name = "B_R042", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi * 3 / 5, moveAngleMax = -math.pi * 2 / 5, speedMin = 2, speedMax = 4 },
    { name = "B_R042_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi * 2 / 5, moveAngleMax = math.pi * 3 / 5, speedMin = 2, speedMax = 4 },
    { name = "B_R043", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi / 2, speedMin = 3, speedMax = 4 },
    { name = "B_R043_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi / 2, moveAngleMax = -math.pi / 4, speedMin = 3, speedMax = 4 },
    { name = "B_R044", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_RIGHT, moveAngleMin = -math.pi / 2, moveAngleMax = -math.pi / 4, speedMin = 4, speedMax = 5 },
    { name = "B_R044_1", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_LEFT, moveAngleMin = math.pi / 4, moveAngleMax = math.pi / 2, speedMin = 4, speedMax = 5 },
}

AnimationsDef.defenseAnimationConfig =
{
    { name = "B_R045", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 1, speedMax = 2 },
    { name = "B_R046", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 1.5, speedMax = 2.5 },
    { name = "B_R047", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 2.5, speedMax = 3.5 },
    { name = "B_R048", angle = 0, moveType = AnimationsDef.MoveType.NON_TURN_FORWARD, moveAngleMin = -math.pi / 4, moveAngleMax = math.pi / 4, speedMin = 2.5, speedMax = 4 },
}

AnimationsDef.breakThroughAnimationConfig = {
    { name = "B_F001", angleMin = -math.pi / 6, angleMax = -math.pi / 12, sqrdistMin = 1 ^ 2, sqrdistMax = 3 ^ 2, defendAnimation = AnimationsDef.RawData.D_L004, delay = 0.1 },
    { name = "B_F001", angleMin = -math.pi / 3, angleMax = -math.pi / 6, sqrdistMin = 1 ^ 2, sqrdistMax = 3 ^ 2, defendAnimation = AnimationsDef.RawData.D_L005, delay = 0.1 },
    { name = "B_F001", angleMin = -math.pi / 2, angleMax = -math.pi / 3, sqrdistMin = 1 ^ 2, sqrdistMax = 2.5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L006, delay = 0.1 },
    { name = "B_F002", angleMin = 0, angleMax = math.pi / 6, sqrdistMin = 3 ^ 2, sqrdistMax = 5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L002, delay = 0.1 },
    { name = "B_F002", angleMin = -math.pi / 6, angleMax = 0, sqrdistMin = 3 ^ 2, sqrdistMax = 5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L001, delay = 0.1 },
    { name = "B_F003", angleMin = 0, angleMax = math.pi / 9, sqrdistMin = 3 ^ 2, sqrdistMax = 5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L003, delay = 0.1 },
    { name = "B_F003", angleMin = -math.pi / 9, angleMax = 0, sqrdistMin = 3 ^ 2, sqrdistMax = 5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L001, delay = 0.1 },
    { name = "B_F004", angleMin = 0, angleMax = math.pi / 9, sqrdistMin = 2.5 ^ 2, sqrdistMax = 4.5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L004, delay = 0.1 },
    { name = "B_F004", angleMin = -math.pi / 9, angleMax = 0, sqrdistMin = 2.5 ^ 2, sqrdistMax = 4.5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L006, delay = 0.1 },
    { name = "B_F005", angleMin = -math.pi / 12, angleMax = 0, sqrdistMin = 2.5 ^ 2, sqrdistMax = 4.5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L001, delay = 0.1 },
    { name = "B_F005", angleMin = 0, angleMax = math.pi / 12, sqrdistMin = 2.5 ^ 2, sqrdistMax = 4.5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L002, delay = 0.1 },
    { name = "B_F007", angleMin = -math.pi / 3, angleMax = -math.pi / 9, sqrdistMin = 1 ^ 2, sqrdistMax = 3 ^ 2, defendAnimation = AnimationsDef.RawData.D_L002, delay = 0.2 },
    { name = "B_F008", angleMin = -math.pi / 9, angleMax = 0, sqrdistMin = 2 ^ 2, sqrdistMax = 4 ^ 2, defendAnimation = AnimationsDef.RawData.D_L002, delay = 0.1 },
    { name = "B_F008", angleMin = 0, angleMax = math.pi / 9, sqrdistMin = 2 ^ 2, sqrdistMax = 4 ^ 2, defendAnimation = AnimationsDef.RawData.D_L003, delay = 0.1 },
    { name = "B_F009", angleMin = -math.pi / 9, angleMax = 0, sqrdistMin = 3 ^ 2, sqrdistMax = 5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L002, delay = 0.1 },
    { name = "B_F009", angleMin = 0, angleMax = math.pi / 9, sqrdistMin = 3 ^ 2, sqrdistMax = 5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L001, delay = 0.1 },
    { name = "B_F010", angleMin = 0, angleMax = 0, sqrdistMin = 2.5 ^ 2, sqrdistMax = 4.5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L004, delay = 0.1 },
    { name = "B_F010", angleMin = -math.pi / 6, angleMax = 0, sqrdistMin = 2.5 ^ 2, sqrdistMax = 4.5 ^ 2, defendAnimation = AnimationsDef.RawData.D_L005, delay = 0.1 },
}

AnimationsDef.breakThroughDirectionConfig = {
    { xMin = -37, xMax = -20, yMin = 0, yMax = 55, angleMin = -90, angleMax = 0 },
    { xMin = 20, xMax = 37, yMin = 0, yMax = 55, angleMin = 0, angleMax = 90 },
    { xMin = -20, xMax = 20, yMin = 0, yMax = 45, angleMin = -45, angleMax = 45 },
    { xMin = -20, xMax = -9, yMin = 45, yMax = 50, angleMin = -90, angleMax = -45 },
    { xMin = 9, xMax = 20, yMin = 45, yMax = 50, angleMin = 45, angleMax = 90 },
    { xMin = -20, xMax = -9, yMin = 50, yMax = 55, angleMin = -135, angleMax = -90 },
    { xMin = -9, xMax = 20, yMin = 50, yMax = 55, angleMin = 90, angleMax = 135 },
}

local cmpf = math.cmpf

function AnimationsDef.isInAngleRange(a, b, t)
    if cmpf(b, a) < 0 then
        b = b + math.pi * 2
    end
    if cmpf(t, a) < 0 then
        t = t + math.pi * 2
    end
    return cmpf(a, t) <= 0 and cmpf(t, b) <= 0
end

local frameZero = { time = 0, position = vector2.new(0, 0), rotation = 0 }

function AnimationsDef.lerp(self, time)
    if cmpf(time, 0) <= 0 then
        return vector2.zero, 0
    end
    local index = math.floor(time * 10 + math.eps)
    assert(index <= self.totalFrame)
    return self.position[index], self.rotation[index]
end

function AnimationsDef.lerpDelta(self, time)
    if cmpf(time, 0) <= 0 then
        return vector2.zero, 0
    end
    local index = math.floor(time * 10 + math.eps)
    assert(index <= self.totalFrame)
    return self.deltaPosition[index], self.deltaRotation[index]
end

local function getRelativeOffset(animation, frame1, frame2)
    local rotation1 = animation.rotation[frame1]
    local rotation2 = animation.rotation[frame2]
    return vector2.rotate(animation.position[frame2] - animation.position[frame1], -rotation1), rotation2 - rotation1
end

function AnimationsDef.getTransitionAdjustment(previousAnimation, nextAnimation)
    local frameCount = previousAnimation.totalFrame - previousAnimation.transition
    local previousOffset, previousRotation = getRelativeOffset(previousAnimation, previousAnimation.transition, previousAnimation.totalFrame)
    local positionDiff = (previousOffset - nextAnimation.position[frameCount]) * 0.5
    local rotationDiff = (previousRotation - nextAnimation.rotation[frameCount]) * 0.5
    return positionDiff, rotationDiff
end

function AnimationsDef.calcTransitionTarget(previousAnimation, nextAnimation, athlete)
    local position = vector2.zero
    local rotation = 0
    local transitionFrame = previousAnimation.totalFrame - previousAnimation.transition
    for i = 1, transitionFrame do
        local previousTime = previousAnimation.transition + i
        local currentTime = i
        local weight = (2 * i - 1) / (transitionFrame * 2)
        local deltaPosition = previousAnimation.deltaPosition[previousTime] * (1 - weight) + nextAnimation.deltaPosition[i] * weight
        position = position + vector2.rotate(deltaPosition, rotation)
        rotation = rotation + previousAnimation.deltaRotation[previousTime] * (1 - weight) + nextAnimation.deltaRotation[i] * weight
    end
    position = position + vector2.rotate(nextAnimation.targetPosition - nextAnimation.position[transitionFrame], (rotation - nextAnimation.rotation[transitionFrame]))
    rotation = rotation + nextAnimation.targetRotation - nextAnimation.rotation[transitionFrame]
    return position, rotation
end

function AnimationsDef.getPosition(animation)
    return animation.position[animation.transition]
end

function AnimationsDef.getRotation(animation)
    return animation.rotation[animation.transition]
end

function AnimationsDef.getFirstTouchPosition(animation)
    return animation.position[animation.firstTouch] or vector2.zero
end

function AnimationsDef.getLastTouchPosition(animation)
    return animation.position[animation.lastTouch] or vector2.zero
end

function AnimationsDef.getFirstTouchRotation(animation)
    return animation.rotation[animation.firstTouch] or 0
end

function AnimationsDef.getLastTouchRotation(animation)
    return animation.rotation[animation.lastTouch] or 0
end

return AnimationsDef
