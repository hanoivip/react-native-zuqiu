if jit then jit.off(true, true) end

local selector = import("../libs/selector")
local vector2 = import("../libs/vector")
local Athlete = import("./Core")
local Animations = import("../animations/Animations")
local Field = import("../Field")
local AIUtils = import("../AIUtils")
local Ball = import("../Ball")

local cmpf = math.cmpf

-- [required number] totalDuration
-- [required vector2] targetPosition
function Athlete:predictMoveTo(totalDuration, targetPosition, passPrepareTime, interceptMoveToSpeed)
    local startInterceptPosition = self.position
    if self.lastMoveDirection and self.currentAnimation and self.currentAnimation.speed then
        startInterceptPosition = self.position + self.lastMoveDirection * (self.currentAnimation.speed * passPrepareTime)
    end

    local dist = vector2.dist(startInterceptPosition, targetPosition)
    return cmpf(dist / interceptMoveToSpeed, totalDuration) <= 0
end

function Athlete:playAnimation()
    if self.currentAnimation then
        self:logAssert(self.currentAnimation.transitionDuration ~= nil, "self.currentAnimation.transitionDuration should not be nil")

        if cmpf(self:playCurrentAnimation(), 1) == 0 then
            -- Additional rotation
            local additionalRotation = self.currentAnimation.animationInfo.additionalRotation
            if additionalRotation then
                self.bodyDirection = vector2.rotate(self.bodyDirection, additionalRotation)
                self.direction = self.bodyDirection
            end

            if #self.animationQueue > 0 then
                table.remove(self.animationQueue, 1)
            end
        end
    end
end

if jit then jit.on(Athlete.playAnimation, true) end

local function isForwardAnimation(moveType)
    return moveType == Animations.MoveType.NON_TURN_FORWARD
end

local function isBackwardAnimation(moveType)
    return moveType == Animations.MoveType.NON_TURN_BACKWARD_LEFT_135 or
        moveType == Animations.MoveType.NON_TURN_BACKWARD_RIGHT_135 or
        moveType == Animations.MoveType.NON_TURN_BACKWARD_180
end

function Athlete:isStayAnimationName(animationName)
    if animationName == 'P3_5' or string.find(animationName, 'A05') then
        return true
    end
    return false
end

local function isTurnAnimation(moveType)
    return moveType == Animations.MoveType.TURN_LEFT_90 or
        moveType == Animations.MoveType.TURN_RIGHT_90 or
        moveType == Animations.MoveType.TURN_LEFT_180 or
        moveType == Animations.MoveType.TURN_RIGHT_180
end

function Athlete:isNonTurnAnimation(moveType)
    return moveType == nil or
        moveType == Animations.MoveType.NON_TURN_FORWARD or
        moveType == Animations.MoveType.NON_TURN_LEFT or
        moveType == Animations.MoveType.NON_TURN_RIGHT or
        moveType == Animations.MoveType.NON_TURN_BACKWARD_LEFT_135 or
        moveType == Animations.MoveType.NON_TURN_BACKWARD_RIGHT_135 or
        moveType == Animations.MoveType.NON_TURN_BACKWARD_180 or
        moveType == Animations.MoveType.NON_TURN_ACCELERATE or
        moveType == Animations.MoveType.NON_TURN_DECELERATE
end

function Athlete:isAccelerateOrDecelerateAnimation(moveType)
    return moveType == Animations.MoveType.NON_TURN_ACCELERATE or
        moveType == Animations.MoveType.NON_TURN_DECELERATE
end

function Athlete:rotate(animationPlayedTime)
    if isTurnAnimation(self.currentAnimation.moveType) then
        self:rotateInTurnAnimation(animationPlayedTime)
    else
        self:rotateInForwardAnimation(animationPlayedTime)
    end
end

local ROTATE_TIME = 0.4
function Athlete:rotateInTurnAnimation(animationPlayedTime)
    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID and 0 <= cmpf(self.match.currentTime, 0) then
        local a = 3
    end

    --[[
    if math.cmpf(vector2.sqrdist(self.targetPosition, self.towardPosition), 0.1) <= 0 and
        math.cmpf(vector2.sqrdist(self.position, self.targetPosition), 0.25) <= 0 then --and
        --self:isNonTurnAnimation(self.currentAnimation.animationInfo.name) then
        --如果离目标点距离在0.5m内，并且运动目标点和朝向点相同，直接返回
        return
    end
    ]]
    local TRANSITION_TIME = 0.2
    if cmpf(animationPlayedTime, TRANSITION_TIME) <= 0 then
        --前0.2s，微调动作本身转向外的角度偏差
        if cmpf(self.currentAnimation.remainAngleDiff, -0.1) <= 0 or 0 <= cmpf(self.currentAnimation.remainAngleDiff, 0.1) then
            local angleDiffDelta = self.currentAnimation.originalAngleDiff / (TRANSITION_TIME / TIME_STEP)
            self.bodyDirection = vector2.rotate(self.bodyDirection, angleDiffDelta)
            self.currentAnimation.remainAngleDiff = self.currentAnimation.remainAngleDiff - angleDiffDelta
        end
    end
    if cmpf(animationPlayedTime, ROTATE_TIME) <= 0 then
        --动作前0.4s，旋转身体朝向
        local angleDelta = self.currentAnimation.animationAngle / (ROTATE_TIME / TIME_STEP)
        self.bodyDirection = vector2.rotate(self.bodyDirection, angleDelta)
        self.direction = self.bodyDirection
    end

    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
        local moveDirection = self.targetPosition - self.position;
        local angleDiff = vector2.sangle(self.bodyDirection, moveDirection)
        self:logInfo("current angleDiff: " .. angleDiff .. ", originalAngleDiff: " .. self.currentAnimation.originalAngleDiff ..
            ", remainAngleDiff: " .. self.currentAnimation.remainAngleDiff .. ', animationAngle: ' .. self.currentAnimation.animationAngle ..
            ', towardDirection: ' .. tostring(self.towardDirection) .. ', targetPosition: ' .. tostring(self.targetPosition) ..
            ', bodyDirection: ' .. tostring(self.bodyDirection))
    end
end

--[[
1. 所有动作，前0.2s不能打断，不能更新运动方向和朝向
2. 转弯动作，前0.4s不能打断，不能更新运动方向和朝向
3. 直线跑动作，动作前半段时间并且离目标点的距离大于1m，不能打断，不能更新运动方向和朝向
4. 以上条件都满足后，对于非转身动作，可以打断，可以更新运动方向和朝向
]]
--TODO: 非转弯动作不能直接每帧调整朝向，对于直线跑这样做没问题，但是对于横向跑，当朝向和目标点不一致时（比如45度），动作的运动轨迹是朝目标点，但朝向是另一个方向
function Athlete:rotateInForwardAnimation(animationPlayedTime)
    local toDirection = self.towardDirection or self.bodyDirection
    if isForwardAnimation(self.currentAnimation.moveType) then
        --如果是直线跑，身体朝向是运动方向，通过动作来旋转上半身
        toDirection = self.targetPosition - self.position
    end

    local angle = toDirection == vector2.zero and 0 or vector2.sangle(self.bodyDirection, toDirection)
    local originalAngle = angle
    angle = angle > 0 and math.min(angle, math.pi * 2 * 0.1) or math.max(angle, - math.pi * 2 * 0.1)
    self.bodyDirection = vector2.rotate(self.bodyDirection, angle)
    self.direction = self.bodyDirection
    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
        self:logInfo('rotateInForwardAnimation, delta: ' .. angle .. ', originalAngleDiff: ' .. originalAngle)
    end
end

function Athlete:transform(animationPlayedTime)
    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID and 0 <= cmpf(self.match.currentTime, 6.5) then
        local a = 3
    end
    local BLEND_TIME = 0.2
    local ACCELERATE_TIME = 0.4
    local IN_BLENDING_SPEED_RATIO = 0.2
    local delta = nil
    local newMoveDirection = vector2.norm(self.targetPosition - self.position)
    --local savedLastMoveDirection = self.lastMoveDirection
    --local moveDirectionAngleDiff = self.lastMoveDirection and math.abs(vector2.sangle(newMoveDirection, self.lastMoveDirection)) or 0
    local isLastMoveDirection = nil
    local moveDirection
    if isTurnAnimation(self.currentAnimation.moveType) or
        (self.lastAnimation and isTurnAnimation(self.lastAnimation.moveType) and not isForwardAnimation(self.currentAnimation.moveType)) then --前一个是转身动作，当前是非直线跑（横向或倒退）
        --(self.lastMoveDirection and 0 < math.cmpf(moveDirectionAngleDiff, math.pi / 2) and self.lastAnimation and not self:isStayAnimationName(self.lastAnimation.animationInfo.name)) then
        if cmpf(animationPlayedTime, BLEND_TIME) <= 0 and self.lastMoveDirection then
            --前0.2s，继续用之前的运动方向
            moveDirection = self.lastMoveDirection
            delta = self.currentAnimation.speed * IN_BLENDING_SPEED_RATIO
            isLastMoveDirection = true
        else
            --使用新的运动方向
            moveDirection = newMoveDirection
            delta = math.lerp(self.currentAnimation.speed * IN_BLENDING_SPEED_RATIO, self.currentAnimation.speed, (animationPlayedTime - BLEND_TIME) / ACCELERATE_TIME)
            delta = math.clamp(delta, self.currentAnimation.speed, self.currentAnimation.speed)
            self.lastMoveDirection = moveDirection
            isLastMoveDirection = false
        end
        delta = delta * TIME_STEP
    else
        if self.currentAnimation.moveType == Animations.MoveType.NON_TURN_ACCELERATE then
            local lastSpeed = self.lastAnimation and self.lastAnimation.speed or 0
            delta = math.lerp(lastSpeed, self.currentAnimation.speed, math.min(animationPlayedTime / ACCELERATE_TIME, 1))
            moveDirection = newMoveDirection
            self.lastMoveDirection = moveDirection
            isLastMoveDirection = false
        elseif self.currentAnimation.moveType == Animations.MoveType.NON_TURN_DECELERATE then
            local lastSpeed = self.lastAnimation and self.lastAnimation.speed or 4
            delta = math.lerp(lastSpeed, self.currentAnimation.speed, animationPlayedTime / self.currentAnimation.animationInfo.time)
            if self.logEnabled and self.onfieldId < 12 then
                local a = 3
            end
            --减速始终用前一个运动方向，当减速动作是作为前和后动作的过渡时，使用朝后动作方向就会出错
            moveDirection = self.lastMoveDirection
            isLastMoveDirection = true
        else
            delta = self.currentAnimation.speed
            moveDirection = newMoveDirection
            self.lastMoveDirection = moveDirection
            isLastMoveDirection = false
        end
        local distance = vector2.dist(self.targetPosition, self.position)
        delta = math.min(delta * TIME_STEP, distance)
    end

    self.position = self.position + moveDirection * delta

    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
        local distance = vector2.dist(self.targetPosition, self.position)
        self:logInfo('delta: ' .. delta .. ', position: ' .. tostring(self.position) .. ', targetPosition: ' .. tostring(self.targetPosition) ..
            ', current moveDirection: ' .. tostring(moveDirection) ..
            ', newMoveDirection: ' .. tostring(newMoveDirection) ..
            --', lastMoveDirection: ' .. (savedLastMoveDirection and tostring(savedLastMoveDirection) or 'nil') ..
            --', moveDirectionAngleDiff: ' .. moveDirectionAngleDiff ..
            ', isLastMoveDirection: ' .. tostring(isLastMoveDirection) ..
            ', towardDirection: ' .. (self.towardDirection and tostring(self.towardDirection) or 0) ..
            ', animationPlayedTime: ' .. animationPlayedTime .. ', normalizedTime: ' .. (animationPlayedTime / self.currentAnimation.animationInfo.time) ..
            ', distance: ' .. distance ..
            ', animationKey: ' .. (self.currentAnimation.animationInfo.name and self.currentAnimation.animationInfo.name or 'nil')
            )
    end
end

function Athlete:playCurrentAnimation()
    if not self.currentAnimation.isAutoMotion then
        return self:playCurrentAnimationWithMotion()
    end

    local animationPlayedTime = self.match.currentTime - self.currentAnimation.startTime

    local percent = animationPlayedTime / self.currentAnimation.animationInfo.time
    if math.cmpf(animationPlayedTime * 10, self.currentAnimation.animationInfo.totalFrame) >= 0 then
        return percent
    end

    if self.currentAnimation.isSmoothMotion then
        self:playCurrentAnimationWithAutoSmoothMotion()
    else
        self:rotate(animationPlayedTime)
        self:transform(animationPlayedTime)
    end

    return percent
end

function Athlete:playCurrentAnimationWithAutoSmoothMotion()
    local currentAnimation = self.currentAnimation
    local circleCenter = currentAnimation.circleCenter
    local radius = currentAnimation.radius
    local dir
    if currentAnimation.isLeftSide then
        local t = circleCenter - self.position
        dir = vector2.rotate(t, -math.asin(math.clamp(radius / vector2.magnitude(t), -1, 1)))
    else
        local t = circleCenter - self.position
        dir = vector2.rotate(t, math.asin(math.clamp(radius / vector2.magnitude(t), -1, 1)))
    end
    local sangle = vector2.sangle(self.direction, dir)
    if sangle < -math.pi + 1e-4 then
        sangle = math.pi
    end
    sangle = sangle > 0 and math.min(sangle, math.pi * 2 * 0.1) or math.max(sangle, - math.pi * 2 * 0.1)
    self.bodyDirection = vector2.rotate(self.bodyDirection, sangle)
    self.direction = self.bodyDirection
    self.position = self.position + self.direction * self.currentAnimation.speed * TIME_STEP
end

function Athlete:playCurrentAnimationWithMotion()
    local currentTime = self.match.currentTime
    local time = self.match.currentTime - self.currentAnimation.startTime
    local position, rotation = Animations.lerpDelta(self.currentAnimation.animationInfo, time) --self.currentAnimation.animationInfo:lerp(time)
    if self.lastAnimation then
        local previousTime = self.match.currentTime - self.lastAnimation.startTime
        local transitionTime = math.round(self.lastAnimation.transitionFrame - (self.match.currentTime - self.currentAnimation.startTime) / TIME_STEP)
        -- 如果上一个动作没有去位移，则对融合部分位移取平均值
        if not self.currentAnimation.disableTransition
        and not self.lastAnimation.isAutoMotion
        and cmpf(previousTime, self.lastAnimation.animationInfo.totalFrame * TIME_STEP) <= 0
        and cmpf(transitionTime, 0) >= 0 then
            local previousPosition, previousRotation = Animations.lerpDelta(self.lastAnimation.animationInfo, previousTime)
            local weight = (2 * transitionTime + 1) / (self.lastAnimation.transitionFrame * 2)
            position = position * (1 - weight) + previousPosition * weight
            rotation = rotation * (1 - weight) + previousRotation * weight
        else
            self.lastAnimation = nil
        end
    end

    self.position = self.position + vector2.vyrotate(position, self.bodyDirection)
    self.bodyDirection = vector2.rotate(self.bodyDirection, rotation)

    self.direction = self.bodyDirection

    return time / self.currentAnimation.animationInfo.time
end

function Athlete:adjustBallAnimation()
    local ball = self.match.ball
    local currentAnimation = self.currentAnimation
    -- 更新球输出信息
    if currentAnimation and currentAnimation.hasBall and (self:hasBall() or ball.outputOwner == self) then
        local currentTime = self.match.currentTime
        local animation = currentAnimation.animationInfo
        local nextTask = ball.nextTask
        if ball.owner then
            ball.outputOwner = ball.owner
        end

        if cmpf(self.match.currentTime, currentAnimation.startTime + animation.lastTouch * TIME_STEP) == 0 then
            ball.position = self.position + vector2.vyrotate(animation.lastTouchBallOffset, self.bodyDirection)
            ball.height = animation.lastTouchBallHeight
            if nextTask and (nextTask.class == Ball.Pass or nextTask.class == Ball.PassAndIntercept) then
                if nextTask.type == "Ground" then
                    ball.output = "PassGround"
                elseif nextTask.type == "High" then
                    ball.output = "PassHigh"
                    ball.outputAnimation = animation
                end
            elseif nextTask and (nextTask.class == Ball.Shoot or nextTask.class == Ball.ShootAndSave) then
                ball.output = "Shoot"
                ball.outputAnimation = animation
            else
                ball.output = "Dribble"
            end
        elseif cmpf(self.match.currentTime, currentAnimation.startTime + animation.firstTouch * TIME_STEP) == 0 then
            ball.position = self.position + vector2.vyrotate(animation.firstTouchBallOffset, self.bodyDirection)
            ball.height = animation.firstTouchBallHeight
            ball.output = currentAnimation.type == "Save" and "Save" or "Internal"
        end

        if self.outputActionStatus ~= nil and self.outputActionStatus.name == "ShootPause" then
            local nextPosition = self.position + vector2.vyrotate(animation.deltaPosition[animation.lastTouch], self.bodyDirection)
            local nextDirection = vector2.rotate(self.bodyDirection, animation.deltaRotation[animation.lastTouch])
            ball.nextPosition = nextPosition + vector2.vyrotate(animation.lastTouchBallOffset, nextDirection)
            ball.nextHeight = animation.lastTouchBallHeight
            ball.nextOutput = "ShootPause"
        end
    end
end

function Athlete:adjustCurrentAnimation()
    self:adjustBallAnimation()

    if #self.animationQueue > 0 then
        local currentAnimation = self.animationQueue[1]
        local currentTime = self.match.currentTime

        if cmpf(self.match.currentTime, currentAnimation.startTime) == 0 then
            -- 这里开始新动画的播放
            self.lastAnimation = self.currentAnimation
            self.currentAnimation = currentAnimation
            self.bodyDirection = currentAnimation.startBodyDirection
            self.direction = self.bodyDirection

            local animation = currentAnimation.animationInfo

            if self.lastAnimation then
                -- 正常播放的情况，需要融合
                self.lastAnimation.transitionFrame = self.lastAnimation.animationInfo.totalFrame - self.lastAnimation.animationInfo.transition
                currentAnimation.transitionDuration = self.lastAnimation.transitionFrame / animation.totalFrame
            else
                -- 没有上一个动作的信息，不需要融合
                currentAnimation.transitionDuration = 0
            end

            -- 处理第0帧触球
            self:adjustBallAnimation()

            if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
                self:logInfo('currentAnimation : ' .. self.currentAnimation.animationInfo.name ..
                    ', transitionDuration: ' .. self.currentAnimation.transitionDuration ..
                    (', lastAnimation: ' .. (self.lastAnimation and self.lastAnimation.animationInfo.name or 'nil'))
                    )
            end
        end
        self:logAssert(self.currentAnimation, "")
    else
        if self.currentAnimation and not self.currentAnimation.ended then -- TODO: refactor here
            --self.currentAnimation = nil
        end
    end
end

local function selectTurnAnimation(angleDiff, moveAngleDiff)
    for _, data in ipairs(Animations.turnAnimationConfig) do
        if 0 <= cmpf(angleDiff, data.towardAngleMin) and cmpf(angleDiff, data.towardAngleMax) <= 0 and
            0 <= cmpf(moveAngleDiff, data.moveAngleMin) and cmpf(moveAngleDiff, data.moveAngleMax) <= 0 then
            return data.name, data.angle, data.moveType
        end
    end
end

if jit then jit.on(selectTurnAnimation, true) end

local function getAnimationConfig(animationName)
    for _, data in ipairs(Animations.turnAnimationConfig) do
        if data.name == animationName then
            return data
        end
    end
    for _, data in ipairs(Animations.nonTurnAnimationConfig) do
        if data.name == animationName then
            return data
        end
    end
    return nil
end

if jit then jit.on(getAnimationConfig, true) end

local function selectNonTurnAnimation(angleDiff, speed, priority, isDefense)
    local candidates = {}
    if isDefense then
        for _, data in ipairs(Animations.defenseAnimationConfig) do
            if 0 <= cmpf(angleDiff, data.moveAngleMin) and cmpf(angleDiff, data.moveAngleMax) <= 0 and
                0 <= cmpf(speed, data.speedMin) and cmpf(speed, data.speedMax) <= 0 then
                table.insert(candidates, data)
            end
        end
    end
    if #candidates == 0 then
        for _, data in ipairs(Animations.nonTurnAnimationConfig) do
            if 0 <= cmpf(angleDiff, data.moveAngleMin) and cmpf(angleDiff, data.moveAngleMax) <= 0 and
                0 <= cmpf(speed, data.speedMin) and cmpf(speed, data.speedMax) <= 0 then
                table.insert(candidates, data)
            end
        end
    end
    if #candidates > 0 then
        return selector.randomSelect(candidates)
    end
    --如果没有找到匹配的动作
    local ret = nil
    local delta = math.huge
    for _, data in ipairs(Animations.nonTurnAnimationConfig) do
        if priority == AIUtils.movePriority.speed then
            --速度优先
            if 0 <= cmpf(speed, data.speedMin) and cmpf(speed, data.speedMax) <= 0 then
                local currentDelta = math.min(math.abs(data.moveAngleMin - angleDiff), math.abs(data.moveAngleMax - angleDiff))
                if 0 < cmpf(delta, currentDelta) then
                    ret = data
                    delta = currentDelta
                end
            end
        else
            --默认朝向优先
            if Animations.isInAngleRange(data.moveAngleMin, data.moveAngleMax, angleDiff) then
                local currentDelta = math.min(math.abs(data.speedMin - speed), math.abs(data.speedMax - speed))
                if 0 < cmpf(delta, currentDelta) then
                    ret = data
                    delta = currentDelta
                end
            end
        end
    end
    return ret
end

if jit then jit.on(selectNonTurnAnimation, true) end

local function selectStayAnimation()
    return selector.randomSelect(Animations.Tag.Stay).name
end

local function selectSpeed(distance, maxSpeed, rate)
    rate = rate or 1
    local speed = 0
    if cmpf(distance * rate, maxSpeed) <= 0 then
        speed = distance * rate
    else
        speed = maxSpeed
    end
    return speed
end

local function selectCatchTurnAnimation(angleDiff)
    for _, data in ipairs(Animations.turnAnimationConfig) do
        if 0 <= cmpf(angleDiff, data.towardAngleMin) and cmpf(angleDiff, data.towardAngleMax) <= 0 then
            return data.name, data.angle, data.moveType
        end
    end
end

if jit then jit.on(selectCatchTurnAnimation, true) end

function Athlete:getCatchTurnTime(towardPosition)
    local targetBodyDirection = towardPosition - self.position
    local angleDiff = vector2.sangle(self.bodyDirection, targetBodyDirection)
    --先根据面朝向的角度决定是否需要转向
    local animationName = selectCatchTurnAnimation(angleDiff)

    if animationName then
        return Animations.RawData[animationName].time
    end

    return 0
end

function Athlete:canBeBroken()
    if not self:canBeInterruptible() then
        return false
    end
    if self.currentAnimation then
        if cmpf(self.match.currentTime, self.currentAnimation.startTime + 0.2) < 0 then
            return false
        end
        if isTurnAnimation(self.currentAnimation.moveType) and
            cmpf(self.match.currentTime, self.currentAnimation.startTime + ROTATE_TIME) <= 0 then
            return false
        end
    end
    return true
end

local function isSameAdequateAnimations(animationNameOld, animationNameNew, newSpeed)
    local animationConfigOld = getAnimationConfig(animationNameOld)
    local animationConfigNew = getAnimationConfig(animationNameNew)
    if animationConfigOld and animationConfigNew
        and animationConfigOld.moveType == animationConfigNew.moveType
        and 0 <= cmpf(newSpeed, animationConfigOld.speedMin) and cmpf(newSpeed, animationConfigOld.speedMax) then
        return true
    else
        return false
    end
end

--[[
1. 所有动作，前0.2s不能打断，不能更新运动方向和朝向
2. 转弯动作，前0.4s不能打断，不能更新运动方向和朝向
3. 直线跑动作，动作前半段时间并且离目标点的距离大于1m，不能更新运动方向和朝向
4. 以上条件都满足后，对于非转身动作，可以更新运动方向和朝向
]]
function Athlete:moveTo(targetPosition, towardDirection, speed, focusType, priority)
    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID and 0 <= cmpf(self.match.currentTime, 13.1) then --98.3
        local a = 3
    end
    if not self:isAnimationEnd(self.match.currentTime) and not self:canBeBroken() then
        return
    end

    --如果当前是非转弯动作，每次决策的时候都更新目标点和朝向，在播放动画的时候根据新的目标点和朝向进行旋转和移动
    if self.currentAnimation and self:isNonTurnAnimation(self.currentAnimation.moveType) then
        self.targetPosition = targetPosition
        self.towardDirection = towardDirection
        if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
            self:logInfo('update targetPosition: ' .. tostring(targetPosition) .. ', towardPosition: ' .. tostring(towardPosition))
        end
    end

    if speed == nil then
        speed = 5
    end

    local animationName = nil
    local animationAngle = 0
    local moveType = 0
    local uninterruptible = nil
    local moveDirection = targetPosition - self.position
    local angleDiff = towardDirection == vector2.zero and 0 or vector2.sangle(self.bodyDirection, towardDirection)
    local moveAngleDiff = towardDirection == vector2.zero and 0 or vector2.sangle(towardDirection, moveDirection)
    --如果moveAngleDiff大于90度，并且速度优先，找不到合适的后退动作，此时将目标朝向改成和目标位置一样
    if priority == AIUtils.movePriority.speed and 0 < cmpf(speed, 5.5) and 0 < cmpf(math.abs(moveAngleDiff), math.pi * 3 / 5) then
        towardDirection = targetPosition - self.position
        angleDiff = towardDirection == vector2.zero and 0 or vector2.sangle(self.bodyDirection, towardDirection)
        moveAngleDiff = towardDirection == vector2.zero and 0 or vector2.sangle(towardDirection, moveDirection)
    end
    --先根据面朝向的角度决定是否需要转向
    animationName, animationAngle, moveType = selectTurnAnimation(angleDiff, moveAngleDiff)

    local squareDistance = vector2.sqrdist(targetPosition, self.position)
    if animationName == nil then
        animationAngle = 0
        local animationConfig = selectNonTurnAnimation(moveAngleDiff, speed, priority, self.team:isDefendRole())
        --如果速度从高到低或者方向从前到后
        if cmpf(speed, 1) < 0 or
            (self.currentAnimation and animationConfig and
                isForwardAnimation(self.currentAnimation.moveType) and isBackwardAnimation(animationConfig.moveType)) then
            if self.currentAnimation and self.currentAnimation.speed and 0 < cmpf(self.currentAnimation.speed, 5)
			--盯持球人不需要减速
            and (self.team.enemyAthleteWithBall and self.team.enemyAthleteWithBall.closedBy and self.team.enemyAthleteWithBall.closedBy ~= self) then
                --减速
                animationName = "P_B002"
                moveType = Animations.MoveType.NON_TURN_DECELERATE
                uninterruptible = true
                speed = math.min(speed, 0.5)
            else
                animationName = selectStayAnimation()
                moveType = Animations.MoveType.STAY
            end
        elseif self.currentAnimation and self.currentAnimation.speed and 0 <= cmpf(speed, 5) and
            ((cmpf(self.currentAnimation.speed, 1) <= 0 and cmpf(math.abs(moveAngleDiff), math.pi / 3) < 0) or --限制角度的目的是防止方向从前到后时加速
            (animationConfig and isBackwardAnimation(self.currentAnimation.moveType) and isForwardAnimation(animationConfig.moveType))) then
            --如果速度从低到高或者方向从后到前
            --从<1的速度开始加速,播放加速动画,速度最多加到3
            animationName = "P_B001"
            moveType = Animations.MoveType.NON_TURN_ACCELERATE
            uninterruptible = true
            speed = math.min(speed, 3)
        else
            --如果不需要转向，再根据目标位置的方向选择运动方向
            animationName = animationConfig.name
            moveType = animationConfig.moveType
            speed = math.clamp(speed, animationConfig.speedMin, animationConfig.speedMax)
            if isForwardAnimation(moveType) then
                angleDiff = vector2.sangle(self.bodyDirection, moveDirection)
            end
        end
    end

    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
        self:logInfo('animationName: ' .. animationName ..
            ', speed: ' .. tostring(speed) ..
            ', bodyDirection: ' .. tostring(self.bodyDirection) ..
            ', original angleDiff: ' .. angleDiff ..
            ', animationAngle: ' .. animationAngle .. ', remainAngleDiff: ' .. (angleDiff - animationAngle) ..
            ', currentAnimation name: ' .. tostring(self.currentAnimation and self.currentAnimation.animationInfo.name or 'nil') ..
            ', isAnimationEnd: ' .. tostring(self:isAnimationEnd(self.match.currentTime)) ..
            ', distance: ' .. math.sqrt(squareDistance) ..
            ', moveStatus: ' .. tostring(self.moveStatus) ..
            ', focusType: ' .. tostring(focusType)
            )
    end

    local originalAngleDiff = angleDiff - animationAngle
    local remainAngleDiff = originalAngleDiff

    if not self:isAnimationEnd(self.match.currentTime) and
        (isSameAdequateAnimations(self.currentAnimation.animationInfo.name, animationName, speed) or
            (self:isStayAnimationName(animationName) and self:isStayAnimationName(self.currentAnimation.animationInfo.name))
        ) then
        if not self:isStayAnimationName(self.currentAnimation.animationInfo.name) and
            self.currentAnimation.moveType ~= Animations.MoveType.NON_TURN_DECELERATE then
            --如果当前不是原地动作和减速动作，更新速度
            self.currentAnimation.speed = speed
        end
        if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID then
            self:logInfo("Exit")
        end
        return
    end

    self.targetPosition = targetPosition
    self.focusType = focusType

    self.animationQueue = {}
    local animation = Animations.RawData[animationName]
    if self:isStayAnimationName(animationName) then
        self:pushAnimationEx(animation, nil, vector2.clone(self.bodyDirection), uninterruptible, true, originalAngleDiff, remainAngleDiff, animationAngle, 0.5)
    elseif self:isNonTurnAnimation(moveType) then
        self:pushAnimationEx(animation, nil, vector2.clone(self.bodyDirection), uninterruptible, true, originalAngleDiff, remainAngleDiff, animationAngle, speed, moveType)
    else
        self:pushAnimationEx(animation, nil, vector2.clone(self.bodyDirection), uninterruptible, true, originalAngleDiff, remainAngleDiff, animationAngle, 2, moveType)
    end
end

function Athlete:smoothMoveTo(targetPosition, towardDirection, speed)
    if not self:isAnimationEnd(self.match.currentTime) and self.currentAnimation.isSmoothMotion then
        return
    end

    speed = math.max(3, speed)

    local animationConfig = selectNonTurnAnimation(0, speed, AIUtils.movePriority.speed)
    local animation = Animations.RawData[animationConfig.name]

    self.animationQueue = {}
    self.targetPosition = targetPosition
    self.towardDirection = towardDirection

    local radius = math.clamp(vector2.dist(self.position, targetPosition) * 0.4, 2, 4)
    local c = (towardDirection.x) * (targetPosition.y - self.position.y) - (targetPosition.x - self.position.x) * (towardDirection.y)
    local isLeftSide = math.sign(c) < 0
    local circleCenter = isLeftSide
        and (targetPosition + vector2.norm(vector2.turnLeft(towardDirection)) * radius)
        or (targetPosition + vector2.norm(vector2.turnRight(towardDirection)) * radius)

    self:pushAnimationRaw({
        animationInfo = animation,
        isAutoMotion = true,
        isSmoothMotion = true,
        speed = speed,
        circleCenter = circleCenter,
        isLeftSide = isLeftSide,
        radius = radius,
    })
end

function Athlete:getMoveConfig(targetPosition, expectSpeed)
    local ball = self.match.ball
    local targetDist = vector2.dist(self.position, targetPosition)
    local towardPosition = nil
    local speed = nil
    local focusType = nil
    local priority = nil

    local config = AIUtils.moveConfig[self.moveStatus]
    if config then
        local towardVector
        if self.team:isAttackRole() then
            towardVector = vector2.norm(self.enemyTeam.goal.center - ball.position)
        else
            towardVector = vector2.norm(self.team.goal.center - ball.position)
        end
        if config.focusType == AIUtils.focusType.ball then
            towardPosition = ball.position + towardVector * 3
        elseif config.focusType == AIUtils.focusType.earlyBall then
            if ball.nextTask and ball.nextTask.class == Ball.Pass then
                towardPosition = ball.nextTask.targetPosition
            else
                towardPosition = ball.position + towardVector * 3
            end
        end
        focusType = config.focusType
        speed = config.speedFun(targetDist, expectSpeed)
        priority = config.priority
        return towardPosition, speed, focusType, priority
    end

    return towardPosition, speed, focusType, priority
end

function Athlete:predictMoveAttack(targetPosition, expectSpeed)
    local towardPosition, speed, focusType, priority = self:getMoveConfig(targetPosition, expectSpeed)
    local towardDirection = towardPosition - self.position
    self:moveTo(targetPosition, towardDirection, speed, focusType, priority)
end

function Athlete:predictMoveDefend(targetPosition, towardPosition, isMarking)
    if self.logEnabled and self.onfieldId == self.LOG_ONFIELD_ID and 0 <= cmpf(self.match.currentTime, 23.8) then
        local a = 3
    end

    local speed = 0
    local focusType = nil
    local priority = AIUtils.movePriority.speed
    if self.moveStatus ~= 0 then
        local unusedTowardPosition
        unusedTowardPosition, speed, focusType, priority = self:getMoveConfig(targetPosition)
        if not towardPosition then
            towardPosition = unusedTowardPosition
        end
    end

    local towardDirection = towardPosition - self.position
    self:moveTo(targetPosition, towardDirection, speed, focusType, priority)
end

function Athlete:predictGoalKeeperMove(targetPosition, targetBodyDirection)
    local isAnimationEnd = self:isAnimationEnd(self.match.currentTime)
    if not isAnimationEnd and not self:canBeBroken() then
        return
    end

    --如果动画的终点离目标点的距离比当前更近，则选择这个动作，否则选择原地动作
    local bestAnimationInfo = nil
    local minSqrDistance = math.huge

    self.towardDirection = targetBodyDirection

    local tags = {"ForwardGK", "LeftGK", "RightGK", "BackGK"}
    for _, tag in ipairs(tags) do
        local animationList = Animations.Tag[tag]
        for i, animation in ipairs(animationList) do
            local animationTargetPosition = self.position + vector2.vyrotate(animation.targetPosition, targetBodyDirection)
            local sqrDistance = vector2.sqrdist(animationTargetPosition, targetPosition)
            if cmpf(sqrDistance, minSqrDistance) < 0
                and Field.isInside(animationTargetPosition)
                and cmpf(math.abs(animationTargetPosition.x), Field.halfGoalWidth) <= 0 then
                minSqrDistance = sqrDistance
                bestAnimationInfo = animation
            end
        end
    end

    if cmpf(vector2.sqrdist(self.position, targetPosition), minSqrDistance) <= 0 then
        local animationList = Animations.Tag.StandGK
        bestAnimationInfo = selector.randomSelect(animationList)
    end

    if not isAnimationEnd and self.currentAnimation.animationInfo == bestAnimationInfo then
        return
    end

    self.animationQueue = { }
    self:pushAnimation(bestAnimationInfo, nil, targetBodyDirection)
end

function Athlete:frozenStay()
    if self:isGoalkeeper() and self.team:isDefendRole() then
        local targetPosition = vector2.clone(self.area.center)
        if self.match.frozenType == "CenterDirectFreeKick"
            or self.match.frozenType == "WingDirectFreeKick"
            or self.match.frozenType == "CornerKick" then
            self:pushAnimation(selector.randomSelect(Animations.Tag.StandGK))
        else
            self:predictGoalKeeperMove(targetPosition, vector2.norm(self.match.ball.position - targetPosition))
        end
    elseif self.match.frozenType == "KickOff" then
        self:pushAnimation(selector.randomSelect(Animations.Tag.OpeningStand))
    elseif not self.team:isAttackRole() then
        self:pushAnimation(selector.randomSelect(Animations.Tag.CornerStayDef))
    else
        self:pushAnimation(selector.randomSelect(Animations.Tag.CornerStay))
    end
end

function Athlete:wallStand()
    local animationList = Animations.Tag.WallStand
    local animation = selector.randomSelect(animationList)
    self:pushAnimation(animation)
end

function Athlete:openingStandAfterBallOut()
    local selectedAnimation

    if self.currentAnimation
        and self.currentAnimation.animationInfo.name ~= "P3_1"
        and self.currentAnimation.speed
        and math.cmpf(self.currentAnimation.speed, 5) > 0
        and self.currentAnimation.moveType == Animations.MoveType.NON_TURN_FORWARD then
        selectedAnimation = Animations.RawData.P3_1
    else
        selectedAnimation = selector.randomSelect(Animations.Tag.OpeningStand)
    end

    self:pushAnimation(selectedAnimation)
end

function Athlete:stayCelebrateAfterGoal()
    self:pushAnimation(selector.randomSelect(Animations.Tag.StayCelebrate))
end

function Athlete:predictMoveDefendOfBlock()
    if self.blockEnemy.catchType == AIUtils.catchType.NormalHeader
        or self.blockEnemy.catchType == AIUtils.catchType.PowerfulHeader then
        self:predictMoveDefendOfHighBlock()
    else
        self:predictMoveDefendOfCommonBlock()
    end
end

function Athlete:predictMoveDefendOfCommonBlock()
    local tag = Animations.Tag.Block

    --从所有阻挡动作中找到最佳动作
    local minSquareDistance = math.huge
    local bestAnimationInfo = nil
    --决策的时候还没有播放射门动作，射门动作的信息在animationQueue中
    local blockPosition = self.blockEnemy.targetPosition
    if self.blockEnemy.animationQueue[1] then
        blockPosition = self.blockEnemy.animationQueue[1].startPosition +
            vector2.vyrotate(Animations.getLastTouchPosition(self.blockEnemy.animationQueue[1].animationInfo), self.blockEnemy.animationQueue[1].startBodyDirection)
    end
    --往球门方向再后退2m
    local directionToGoal = vector2.norm(self.team.goal.center - blockPosition)
    blockPosition = blockPosition + directionToGoal * 1.5
    for _, animation in ipairs(tag) do
        local targetPosition = self.position + vector2.vyrotate(animation.targetPosition, self.bodyDirection)
        local squareDistance = vector2.sqrdist(blockPosition, targetPosition)
        if cmpf(squareDistance, minSquareDistance) <= 0 then
            minSquareDistance = squareDistance
            bestAnimationInfo = animation
        end
    end

    self:pushAnimation(bestAnimationInfo, nil, nil, true)
end

function Athlete:predictMoveDefendOfHighBlock()
    local tag = Animations.Tag.HighBlock

    --从所有阻挡动作中找到最佳动作
    local minSquareDistance = math.huge
    local bestAnimationInfo = nil
    --决策的时候还没有播放射门动作，射门动作的信息在animationQueue中
    local blockPosition = self.blockEnemy.targetPosition
    if self.blockEnemy.animationQueue[1] then
        blockPosition = self.blockEnemy.animationQueue[1].startPosition +
            vector2.vyrotate(Animations.getLastTouchPosition(self.blockEnemy.animationQueue[1].animationInfo), self.blockEnemy.animationQueue[1].startBodyDirection)
    end
    for _, animation in ipairs(tag) do
        local targetPosition = self.position + vector2.vyrotate(animation.targetPosition, self.bodyDirection)
        local squareDistance = vector2.sqrdist(blockPosition, targetPosition)
        if cmpf(squareDistance, minSquareDistance) <= 0 then
            minSquareDistance = squareDistance
            bestAnimationInfo = animation
        end
    end

    self:pushAnimation(bestAnimationInfo, nil, nil, true)
end

function Athlete:selectHeadingDualAnimation()
    local tag = Animations.Tag.HighBlock

    --从所有阻挡动作中找到最佳动作
    local minSquareDistance = math.huge
    local bestAnimationInfo = nil
    --决策的时候还没有播放射门动作，射门动作的信息在animationQueue中
    local headingDualPosition = self.match.ball.nextTask.interceptor.position
    for _, animation in ipairs(tag) do
        local targetPosition = self.position + vector2.vyrotate(animation.targetPosition, self.bodyDirection)
        local squareDistance = vector2.sqrdist(headingDualPosition, targetPosition)
        if cmpf(squareDistance, minSquareDistance) <= 0 then
            minSquareDistance = squareDistance
            bestAnimationInfo = animation
        end
    end

    self:pushAnimation(bestAnimationInfo, nil, nil, true)
end

function Athlete:breakThroughDefendStay(targetDirection, duration)
    local direction = targetDirection or self.bodyDirection

    -- 这里不适合选Crouch中的P3_5
    local stayAnimation = selector.tossCoin(0.5) and Animations.RawData.A02 or Animations.RawData.P1_2

    if duration then
        stayAnimation = clone(stayAnimation)
        stayAnimation.time = duration
    end

    self:pushAnimation(stayAnimation, nil, direction)
end

-- 使用前确保 self.breakThroughDefendInfo ~= nil
function Athlete:breakThroughDefend()
    local defendAnimation = self.breakThroughDefendInfo.defendAnimation
    local defendTargetDirection = vector2.norm(self.breakThroughDefendInfo.targetAthlete.position - self.position)

    self:pushAnimation(defendAnimation, nil, defendTargetDirection, true)
end
