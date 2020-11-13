local ActionLayerConfig = require("coregame.actionlayer.ActionLayerConfig")
local EnumType = require("coregame.EnumType")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local BallPassType = EnumType.BallPassType
local BallFreeFlyType = EnumType.BallFreeFlyType
local ShootResult = EnumType.ShootResult
local HitPoint = EnumType.HitPoint
local PlaybackClipType = EnumType.PlaybackClipType
local MatchEventType = EnumType.MatchEventType
local BallActionType = EnumType.BallActionType
local GoalCollider = EnumType.GoalCollider

local ActionLayerUtils = {}

local function CalculateInterDribbleRotateAngle(distance)
    local minAngle = 12
    local maxAngle = 25
    local minDis = 1
    local maxDis = 5
    local value = math.clamp(distance, minDis, maxDis)
    return ((maxAngle - minAngle) * value + maxDis * minAngle - minDis * maxAngle) / (maxDis - minDis)
end

local function CalculateUniformlyRetardedMotionAcclerationDribble(distance)
    local minAcc = 0.1
    local maxAcc = 0.45
    local minDis = 1
    local maxDis = 6
    local value = math.clamp(distance, minDis, maxDis)
    return ((minAcc - maxAcc) * value + maxDis * maxAcc - minDis * minAcc) / (maxDis - minDis)
end

local function CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint, endPoint, duration, gravity)
    gravity = gravity or ActionLayerConfig.Gravity
    local projectileRetardFactor = 2
    local height = endPoint - startPoint
    return -projectileRetardFactor * gravity
         + (gravity * duration + height / projectileRetardFactor) / (1 - math.exp(-duration / projectileRetardFactor))
end

local function CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeedShoot(startPoint, endPoint, duration)
    if math.cmpf(startPoint, ActionLayerConfig.BallRadius) == 0 and math.cmpf(endPoint, ActionLayerConfig.BallRadius) == 0 then
        return 0
    else
        return CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint, endPoint, duration, ActionLayerConfig.ShootBallGravity)
    end
end

local function CalculateVariablyRetardedVerticalUpwardProjectileEndSpeedShoot(initialSpeed, duration)
    local projectileRetardFactor = 2
    local gravity = ActionLayerConfig.ShootBallGravity
    return (projectileRetardFactor * gravity + initialSpeed) * math.exp(-duration / projectileRetardFactor) - projectileRetardFactor * gravity
end

local function CalculateBezierCurve(origin, destination, rotateAxis, curveIn)
    local bezierEnd = Vector3Lua(destination.x - origin.x, 0, destination.z - origin.z)
    local bezierMid = bezierEnd * 0.6

    local offset = (bezierEnd.x ^ 2 + bezierEnd.z ^2) * 0.004
    offset = math.min(offset, 4)

    local bezierPoint
    if curveIn then
        bezierPoint = bezierMid - rotateAxis.normalized * offset
    else
        bezierPoint = bezierMid + rotateAxis.normalized * offset
    end
    return bezierPoint, bezierEnd
end

--计算变减速运动下，球第一次落地的时间
--设球弹地时的触地速度等于反弹后的离地速度，得到方程求解
--return 第一次落地时间占总时间的百分比
--author: Yi, Jin
local function CalculateVariablyRetardedVerticalBounceThreshold(startPoint, endPoint, duration)
    local windDragCoefficient = -0.65
    local p = -1 / windDragCoefficient
    local attenuationRate = 0.8 --弹地时垂直方向速度衰减系数
    local l = 0.5
    local r = 0.9

    for i = 1, 7 do
        local mid = (l + r) * 0.5
        local d1 = duration * mid
        local d2 = duration * (1 - mid)
        local v0 = -p * ActionLayerConfig.Gravity
            + (ActionLayerConfig.Gravity * d1 + (ActionLayerConfig.BallRadius - startPoint) / p) / (1 - math.exp(-d1 / p))--球出脚速度
        local v1 = -((p * ActionLayerConfig.Gravity + v0) * math.exp(-d1 / p) - p * ActionLayerConfig.Gravity)--第一次触地速度，取反
        local v2 = -p * ActionLayerConfig.Gravity
            + (ActionLayerConfig.Gravity * d2 + (endPoint - ActionLayerConfig.BallRadius) / p) / (1 - math.exp(-d2 / p))--反弹后离开地面速度

        if v1 * attenuationRate < v2 then
            l = mid
        else
            r = mid
        end
    end

    return r
end

--author: Yi, Jin
local function CalculateWindDragMoveBounceThreshold(duration, timeThreshold)
    local windDragCoefficientBounce = -0.65
    local attenuationRate = 1 --弹地时水平方向速度衰减系数
    local e1 = math.exp(windDragCoefficientBounce * duration * timeThreshold)
    local e2 = math.exp(windDragCoefficientBounce * duration * (1 - timeThreshold))
    return (e1 - 1) / (e1 * attenuationRate * (e2 - 1) + e1 - 1)
end

local function CalculateShootBallSpeed(ballShoot, ballPosition, lastBallPosition)
    local speed = {}
    speed.x = 2 * (ballShoot.endPoint.x - ballShoot.projectedControlPoint.x)
    speed.z = 2 * (ballShoot.endPoint.z - ballShoot.projectedControlPoint.z)
    local duration = ballShoot.endTime - ballShoot.startTime
    local v0 = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeedShoot(ballShoot.startPoint.y, ballShoot.endPoint.y, duration)
    speed.y = math.cmpf(v0, 0) == 0 and 0 or CalculateVariablyRetardedVerticalUpwardProjectileEndSpeedShoot(v0, duration)
    return speed
end

local function IsShootWide(width)
    return width > ActionLayerConfig.GoalWidth or width < -ActionLayerConfig.GoalWidth
end

local function IsShootHeight(height)
    return height > ActionLayerConfig.GoalHeight
end

function ActionLayerUtils.IsInGoal(width, height)
    return not IsShootWide(width)
        and not IsShootHeight(height)
end

function ActionLayerUtils.RandomChooseOneFromTable(theTable)
    if theTable then
        local length = table.nums(theTable)
        if length == 1 then
            return theTable[1]
        else
            return theTable[math.random(1, length)]
        end
    else
        return nil
    end
end

function ActionLayerUtils.RandomChooseNFromTable(theTable, n) -- n >= 2
    if theTable then
        if n >= #theTable then
            return theTable
        else
            local pool = {}
            for i = 1, n do
                pool[i] = i
            end
            for i = n + 1, #theTable do
                local pos = math.random(1, i + 1)
                if pos <= n then
                    pool[pos] = i
                end
            end
            local ret = {}
            for i = 1, n do
                ret[i] = theTable[pool[i]]
            end
            return ret
        end
    end
    return nil
end

function ActionLayerUtils.CopyAndShuffle(data)
    local ret = {}
    if data then
        local length = #data
        if length >= 1 then
            ret[1] = data[1]
            for i = 2, length do
                local pos = math.random(1, i - 1)
                ret[i] = ret[pos]
                ret[pos] = data[i]
            end
        end
    end
    return ret
end

function ActionLayerUtils.Vector3SqrDistance(vector1, vector2)
    return (vector1.x - vector2.x) ^ 2 + (vector1.y - vector2.y) ^ 2 + (vector1.z - vector2.z) ^ 2
end

function ActionLayerUtils.Vector3DistanceOnXZ(vector1, vector2)
    return math.sqrt((vector1.x - vector2.x) ^ 2 + (vector1.z - vector2.z) ^ 2)
end

function ActionLayerUtils.Vector3SqrDistanceOnXZ(vector1, vector2)
    return (vector1.x - vector2.x) ^ 2 + (vector1.z - vector2.z) ^ 2
end

function ActionLayerUtils.GetOppositeGoalKeeperFieldId(id)
    if id < 11 then
        return 11
    else
        return 0
    end
end

function ActionLayerUtils.CalculateInitialVerticalSpeed(startPoint, endPoint, duration)
    if startPoint == ActionLayerConfig.BallRadius and endPoint == ActionLayerConfig.BallRadius then
        return 0
    else
        local height = endPoint - startPoint
        return height / duration + 0.5 * ActionLayerConfig.Gravity * duration
    end
end

function ActionLayerUtils.FixedVerticalUpwardProjectile(startPoint, endPoint, initialVerticalSpeed, time)
    return math.max(0.1, initialVerticalSpeed * time - 0.5 * ActionLayerConfig.Gravity * time * time + startPoint)
end

function ActionLayerUtils.BezierCurve(startPoint, controlPoint, endPoint, percent)
    local leftPercent = 1 - percent
    return leftPercent * leftPercent * startPoint + 2 * percent * leftPercent * controlPoint + percent * percent * endPoint
end

function ActionLayerUtils.DecideInterDribblePassType(currentLastBallPos, nextFirstBallPos)
    if currentLastBallPos.y - nextFirstBallPos.y >= 0.1 then
        return BallPassType.UnloadBall
    elseif nextFirstBallPos.y - currentLastBallPos.y >= 0.2 then
        return BallPassType.Lob
    else
        return BallPassType.PassSimulatedDribble
    end
end

function ActionLayerUtils.IsRunningForward(nameHash)
    return nameHash == -2116687635 --'B_R001'
         or nameHash == 1747268960 --'B_R001_1'
         or nameHash == -248748838 --'B_R001_2'
         or nameHash == -2043980724 --'B_R001_3'
         or nameHash == 407880175 --'B_R001_4'
         or nameHash == 1867051385 --'B_R001_5'
         or nameHash == -163471165 --'B_R001_6'
         or nameHash == -2126081963 --'B_R001_7'
         or nameHash == 301567428 --'B_R001_8'
         or nameHash == 1727970642 --'B_R001_9'
end

function ActionLayerUtils.IsRunningLeftward(nameHash)
    return nameHash == 1756777944 --'B_R007'
        or nameHash == 1822968274 --'B_R007_1'
        or nameHash == -2103039746 --'B_R007_3'
        or nameHash == -1894883105 --'B_R009'
        or nameHash == 1714840792 --'B_R009_1'
        or nameHash == -12634782 --'B_R009_2'
        or nameHash == -1066777678 --'B_R022_1'
        or nameHash == 1575907002 --'B_R024_2'
        or nameHash == -1265742218 --'B_R025'
        or nameHash == 1546388621 --'B_R025_2'
        or nameHash == -627945567 --'B_R034'
end

function ActionLayerUtils.IsRunningRightward(nameHash)
    return nameHash == 531725646 --'B_R006'
        or nameHash == 1835672549 --'B_R006_1'
        or nameHash == -2090581303 --'B_R006_3'
        or nameHash == -133607351 --'B_R008'
        or nameHash == 1744047855 --'B_R008_1'
        or nameHash == -16949419 --'B_R008_2'
        or nameHash == -1045943931 --'B_R023_1'
        or nameHash == 763830220 --'B_R026'
        or nameHash == 1584052948 --'B_R026_2'
        or nameHash == 1518350170 --'B_R027'
        or nameHash == -1382711497 --'B_R035'
end

function ActionLayerUtils.IsRival(playerId, targetId)
    return (playerId <= 10 and targetId > 10) or (playerId > 10 and targetId <= 10)
end

function ActionLayerUtils.IsGoalKeeper(playerId)
    return i == 0 or i == 11
end

function ActionLayerUtils.OnSaveBounceFreeFly(gkPosition, saveAction, ballPosition)
    local targetX = 6.5 * math.sign(gkPosition.x - saveAction.actionStartFrame.position.x)
    local targetZ = ActionLayerConfig.GoalPositionZ * math.sign(gkPosition.z)
    local direction = Vector2Lua(targetX - gkPosition.x, targetZ - gkPosition.z):Normalize():Mul(25)
    local speed = {}
    speed.x = direction.x
    speed.y = 0
    speed.z = direction.y
    BallActionExecutorWrap.InvokeFreeFly(speed, false)

    if MatchInfoModel.GetInstance():IsDemoMatch() and PlaybackCenterWrap.InPlaybackMode() == true then
        ___playbackManager:StopPlayback()
    end
end

function ActionLayerUtils.OnHitGateFreeFly(freeFlyType, ballShoot, ballPosition)
    local duration = 2
    local initialSpeed = {}
    local acceleration = {}

    if freeFlyType == BallFreeFlyType.HitCrossBarFreeFly then
        initialSpeed.x = (ballShoot.endPoint.x - ballShoot.startPoint.x) / (ballShoot.endTime - ballShoot.startTime);
        acceleration.x = -math.sign(initialSpeed.x) * .5 * initialSpeed.x / duration;

        initialSpeed.z = (ballShoot.endPoint.z - ballShoot.startPoint.z) / (ballShoot.endTime - ballShoot.startTime);
        acceleration.z = -math.sign(initialSpeed.z) * .5 * initialSpeed.z / duration;

        initialSpeed.y = ActionLayerUtils.CalculateInitialVerticalSpeed(ballPosition.y, ActionLayerConfig.BallRadius, duration);
    else
        initialSpeed.x = math.sign(ballPosition.x) * 15;
        acceleration.x = -math.sign(ballPosition.x) * 5;

        initialSpeed.z = math.sign(ballPosition.z) * 5;
        acceleration.z = -math.sign(ballPosition.z) * 2;

        initialSpeed.y = 0;
    end

    local ret = {}
    ret.startPosition = ballPosition
    ret.startTime = TimeLineWrap.TLTime()
    ret.endTime = ret.startTime + duration
    ret.initialSpeed = initialSpeed
    ret.acceleration = acceleration
    ret.type = freeFlyType
    BallActionExecutorWrap.AddBallFreeFly(ret)
end

function ActionLayerUtils.OnShootBallEnds(ballShoot, ballPosition, lastBallPosition)
    if PlaybackCenterWrap.InPlaybackMode() == true then
        if ___deadBallTimeManager.inPenaltyShootOut then
            ___playbackManager:StopPlayback()
        else
            if ballShoot.shootResult ~= ShootResult.Catched and ballShoot.shootResult ~= ShootResult.Bounced then
                ___playbackManager:StopPlayback()
            end
        end
    end

    if ballShoot.shootResult == ShootResult.Goal or ballShoot.shootResult == ShootResult.Miss then
        local speed = CalculateShootBallSpeed(ballShoot, ballPosition, lastBallPosition)
        BallActionExecutorWrap.InvokeFreeFly(speed, ballShoot.shootResult == ShootResult.Goal)
    end

    ___upperBodyUtil:OnShootBallEnds(ballShoot)
end

function ActionLayerUtils.IsAroundRivals(playerId, distance)
    local sqrDistance = distance * distance
    local pos = GameHubWrap.GetPlayerPosition(playerId)
    local startIdx, endIdx
    if playerId <= 10 then -- player
        startIdx = 11
        endIdx = 21
    else -- opponent
        startIdx = 0
        endIdx = 10
    end
    local min = sqrDistance + 1
    local targetId = startIdx
    for i = startIdx, endIdx do
        local dis = ActionLayerUtils.Vector3SqrDistanceOnXZ(pos, GameHubWrap.GetPlayerPosition(i))
        if dis < min then
            min = dis
            targetId = i
        end
    end
    if min <= sqrDistance then
        return true, targetId
    else
        return false, nil
    end
end

--找到球员前方的，左右两边最近的两名队友
function ActionLayerUtils.FindClosestTeammateAhead(playerId)
    local pos = GameHubWrap.GetPlayerPosition(playerId)
    local forward = GameHubWrap.GetPlayerForward(playerId)
    local startIdx, endIdx
    if playerId <= 10 then -- player
        startIdx = 0
        endIdx = 10
    else -- opponent
        startIdx = 11
        endIdx = 21
    end
    local leftMin = 100000
    local leftTarget = nil
    local rightMin = 100000
    local rightTarget = nil
    for i = startIdx, endIdx do
        if i ~= playerId then
            local tarPos = GameHubWrap.GetPlayerPosition(i)
            local dis = ActionLayerUtils.Vector3SqrDistanceOnXZ(pos, tarPos)
            local offset = { x = tarPos.x - pos.x, y = 0, z = tarPos.z - pos.z }
            if Vector3Lua.Dot(forward, offset) >= 0 then
                if Vector3Lua.Cross(forward, offset).y > 0 then --teammate on the right side of player
                    if dis < rightMin then
                        rightMin = dis
                        rightTarget = i
                    end
                else
                    if dis < leftMin then
                        leftMin = dis
                        leftTarget = i
                    end
                end
            end
        end
    end
    return leftTarget, leftMin, rightTarget, rightMin
end

function ActionLayerUtils.IsBallComingFromBehind(forward, passDirection)
    return Vector3Lua.Dot(forward, passDirection) >= 0
end

function ActionLayerUtils.FindClosestRivalBehind(playerId)
    local pos = GameHubWrap.GetPlayerPosition(playerId)
    local forward = GameHubWrap.GetPlayerForward(playerId)
    local startIdx, endIdx
    if playerId <= 10 then -- player
        startIdx = 11
        endIdx = 21
    else -- opponent
        startIdx = 0
        endIdx = 10
    end
    local targetId = nil
    local minDis = 100000
    for i = startIdx, endIdx do
        local tarPos = GameHubWrap.GetPlayerPosition(i)
        local dis = ActionLayerUtils.Vector3SqrDistanceOnXZ(pos, tarPos)
        local offset = { x = tarPos.x - pos.x, y = 0, z = tarPos.z - pos.z }
        if Vector3Lua.Dot(forward, offset) <= 0 then
            if dis < minDis then
                minDis = dis
                targetId = i
            end
        end
    end
    return targetId, minDis
end

function ActionLayerUtils.InitBallAction(ballAction)
    local ballActionType = ballAction.ballActionType
    if ballActionType == BallActionType.Shoot then
        local ballShoot = ballAction.shoot
        local startPoint = ballShoot.startPoint
        local controlPoint = ballShoot.projectedControlPoint
        local endPoint = ballShoot.endPoint
        local v0 = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeedShoot(startPoint.y, endPoint.y, ballShoot.endTime - ballShoot.startTime)
        BallActionExecutorWrap.SetVerticalInitialSpeed(v0, ActionLayerConfig.ShootBallGravity)
        local rotateAngle = 32
        if math.sign(v0) > 0 then
            local x = ActionLayerUtils.BezierCurve(startPoint.x, controlPoint.x, endPoint.x, 0.5)
            local z = ActionLayerUtils.BezierCurve(startPoint.z, controlPoint.z, endPoint.z, 0.5)
            local middleX = 0.5 * (startPoint.x + endPoint.x)
            local middleY = 0.5 * (startPoint.y + endPoint.y)
            local middleZ = 0.25 * startPoint.z + 0.75 * endPoint.z
            local offsetDis = (x - middleX) ^ 2 + (z - middleZ) ^ 2
            if offsetDis > 0.04 then
                local y = ActionLayerUtils.FixedVerticalUpwardProjectile(startPoint.y, endPoint.y, v0, 0.5 * (ballShoot.endTime - ballShoot.startTime))
                local bezierOffset = Vector3Lua(x, y, z):Sub(Vector3Lua(middleX, middleY, middleZ))
                local shootDirection = endPoint:Sub(startPoint)
                local axis = Vector3Lua.Cross(bezierOffset, shootDirection)
                BallActionExecutorWrap.SetRotationAxisAndAngle(axis, 48)
                return
            else
                rotateAngle = 16
            end
        end
        local shootDirection = Vector3Lua(endPoint.x, endPoint.y, endPoint.z):Sub(startPoint)
        local axis = Vector3Lua.Cross(Vector3Lua(0, 1, 0), shootDirection)
        BallActionExecutorWrap.SetRotationAxisAndAngle(axis, rotateAngle)
    elseif ballActionType == BallActionType.Pass then
        local ballPass = ballAction.pass
        local startPoint = ballPass.startPosition
        local endPoint = ballPass.endPosition
        local startPosition = Vector3Lua(startPoint.x, startPoint.y, startPoint.z)
        local endPosition = Vector3Lua(endPoint.x, endPoint.y, endPoint.z)
        local passDirection = endPosition - startPosition

        local axis = Vector3Lua.Cross(Vector3Lua.up, passDirection)
        local rotateAngle = 53

        local passType = ballPass.passType
        if passType == BallPassType.PassSimulatedDribble then
            local distance = passDirection.magnitude
            rotateAngle = CalculateInterDribbleRotateAngle(distance)
            local acceleration = CalculateUniformlyRetardedMotionAcclerationDribble(distance)
            BallActionExecutorWrap.SetDribbleHoriziontalAccleration(acceleration)
        elseif passType == BallPassType.Lob then
            rotateAngle = rotateAngle * -0.6
        elseif passType == BallPassType.UnloadBall then
            rotateAngle = rotateAngle * -0.4
        elseif passType == BallPassType.PassAirStraight then
            rotateAngle = rotateAngle * -0.6
        elseif passType == BallPassType.PassRainbow then
            rotateAngle = rotateAngle * -1
            local verticalInitialSpeed = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint.y, endPoint.y, ballPass.endTime - ballPass.startTime)
            BallActionExecutorWrap.SetVerticalInitialSpeed(verticalInitialSpeed, ActionLayerConfig.Gravity)
        elseif passType == BallPassType.PassRainbowInCurve then
            local bezierPoint, bezierEnd = CalculateBezierCurve(startPoint, endPoint, axis, true)
            BallActionExecutorWrap.SetBezierPoint(bezierPoint, bezierEnd)
            axis = Vector3Lua.up
            local verticalInitialSpeed = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint.y, endPoint.y, ballPass.endTime - ballPass.startTime)
            BallActionExecutorWrap.SetVerticalInitialSpeed(verticalInitialSpeed, ActionLayerConfig.Gravity)
        elseif passType == BallPassType.PassRainbowOutCurve then
            local bezierPoint, bezierEnd = CalculateBezierCurve(startPoint, endPoint, axis, false)
            BallActionExecutorWrap.SetBezierPoint(bezierPoint, bezierEnd)
            axis = Vector3Lua.down
            local verticalInitialSpeed = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint.y, endPoint.y, ballPass.endTime - ballPass.startTime)
            BallActionExecutorWrap.SetVerticalInitialSpeed(verticalInitialSpeed, ActionLayerConfig.Gravity)
        elseif passType == BallPassType.PassBounceOnce then
            rotateAngle = rotateAngle * -0.8
            local duration = ballPass.endTime - ballPass.startTime
            local bounceTimeThreshold = CalculateVariablyRetardedVerticalBounceThreshold(startPoint.y, endPoint.y, duration)
            local bounceOffsetThreshold = CalculateWindDragMoveBounceThreshold(duration, bounceTimeThreshold)
            local verticalInitialSpeed = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint.y, ActionLayerConfig.BallRadius, duration * bounceTimeThreshold)
            local verticalInitialSpeedBounce = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(ActionLayerConfig.BallRadius, endPoint.y, duration * (1 - bounceTimeThreshold))
            BallActionExecutorWrap.SetBounceParams(bounceTimeThreshold, bounceOffsetThreshold, verticalInitialSpeed, verticalInitialSpeedBounce, ActionLayerConfig.Gravity)
        elseif passType == BallPassType.DoubleHandsThrow then
            rotateAngle = rotateAngle * -0.2
            local verticalInitialSpeed = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint.y, endPoint.y, ballPass.endTime - ballPass.startTime)
            BallActionExecutorWrap.SetVerticalInitialSpeed(verticalInitialSpeed, ActionLayerConfig.Gravity)
        elseif passType == BallPassType.HeaderPass then
            rotateAngle = rotateAngle * -0.8
            local verticalInitialSpeed = CalculateVariablyRetardedVerticalUpwardProjectileInitialSpeed(startPoint.y, endPoint.y, ballPass.endTime - ballPass.startTime)
            BallActionExecutorWrap.SetVerticalInitialSpeed(verticalInitialSpeed, ActionLayerConfig.Gravity)
        end
        BallActionExecutorWrap.SetRotationAxisAndAngle(axis, rotateAngle)
    end
end

local function OnHitGoalBack(ball)
    if ball.isGoal then
        local angle = Vector3Lua.Angle(ball.horizontalDirection, Vector3Lua.right)
        if angle >= 30 and angle <= 150 then--如果球直冲球网，球在0.1米水平方向到达静止
            local verticalSpeed
            if ball.verticalSpeed > 0 then
                verticalSpeed = ball.verticalSpeed * ActionLayerConfig.GOALBACK_BOUNCE_SPEED_Y_ATTENUATION_UP
            elseif ball.verticalSpeed < -1 then
                verticalSpeed = math.min(
                    math.abs(ball.horizontalSpeedMag) * ActionLayerConfig.GOALBACK_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER, 2)
            else
                verticalSpeed = math.min(
                    math.abs(ball.horizontalSpeedMag) * ActionLayerConfig.GOALBACK_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER_UP, 8)
            end
            local horizontalSpeedMag = math.sqrt(-2 * ActionLayerConfig.AIR_DRAG * ActionLayerConfig.GOALBACK_BOUNCE_HORIZONTAL_STOP_DISTANCE)
            local horizontalDirection = ball.horizontalDirection * -1
            BallActionExecutorWrap.OnFreeFlyCollision(horizontalSpeedMag, horizontalDirection, verticalSpeed)
            return
        end
    end
    --速度值衰减，Z轴速度反向，X轴速度不变
    local speedX = math.abs(ball.horizontalDirection.x * ball.horizontalSpeedMag * ActionLayerConfig.GOALBACK_BOUNCE_SPEED_X_ATTENUATION)
        * math.sign(ball.horizontalDirection.x)
    local speedZ = math.abs(ball.horizontalDirection.z * ball.horizontalSpeedMag * ActionLayerConfig.GOALBACK_BOUNCE_SPEED_Z_ATTENUATION)
        * math.sign(ball.horizontalDirection.z)
    local newHorizontalSpeed = Vector3Lua(speedX, 0, speedZ)

    local verticalSpeed
    if ball.verticalSpeed > 0 then
        verticalSpeed = ball.verticalSpeed * ActionLayerConfig.GOALBACK_BOUNCE_SPEED_Y_ATTENUATION_UP
    elseif ball.verticalSpeed > -1 then
        verticalSpeed = math.min(math.abs(ball.horizontalSpeedMag) * ActionLayerConfig.GOALBACK_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER_UP, 8)
    else
        verticalSpeed = ball.verticalSpeed * ActionLayerConfig.GOALBACK_BOUNCE_SPEED_Y_ATTENUATION
    end
    BallActionExecutorWrap.OnFreeFlyCollision(newHorizontalSpeed.magnitude, newHorizontalSpeed.normalized, verticalSpeed)
end

local function OnHitGoalSide(ball)
    --速度值衰减
    local speedX = math.abs(ball.horizontalDirection.x * ball.horizontalSpeedMag * ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_X_ATTENUATION)
    local speedZ = math.abs(ball.horizontalDirection.z * ball.horizontalSpeedMag * ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_Z_ATTENUATION)
        * math.sign(ball.horizontalDirection.z)
    local newHorizontalSpeed
    if ball.isGoal then --X轴速度朝向球门内，Z轴速度不变
        newHorizontalSpeed = Vector3Lua(math.sign(ball.position.x) * -speedX, 0, speedZ)
    else --X轴速度朝向球门外，Z轴速度不变
        newHorizontalSpeed = Vector3Lua(math.sign(ball.position.x) * speedX, 0, speedZ)
    end

    local verticalSpeed
    if ball.verticalSpeed > 0 then
        verticalSpeed = ball.verticalSpeed * ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_Y_ATTENUATION_UP
    elseif ball.verticalSpeed > -1 then
        verticalSpeed = math.min(math.abs(ball.horizontalSpeedMag) * ActionLayerConfig.GOALSIDE_BOUNCE_HORIZONTAL_VERTICAL_CONVERTER, 8)
    else
        verticalSpeed = ball.verticalSpeed * ActionLayerConfig.GOALSIDE_BOUNCE_SPEED_Y_ATTENUATION
    end
    BallActionExecutorWrap.OnFreeFlyCollision(newHorizontalSpeed.magnitude, newHorizontalSpeed.normalized, verticalSpeed)
end

local function OnHitGoalUp(ball)
    local speedX = math.abs(ball.horizontalDirection.x * ball.horizontalSpeedMag * ActionLayerConfig.GOALUP_BOUNCE_SPEED_X_ATTENUATION)
        * math.sign(ball.horizontalDirection.x)
    local speedZ = math.abs(ball.horizontalDirection.z * ball.horizontalSpeedMag * ActionLayerConfig.GOALUP_BOUNCE_SPEED_Z_ATTENUATION)
        * math.sign(ball.horizontalDirection.z)
    local newHorizontalSpeed = Vector3Lua(speedX, 0, speedZ)
    local verticalSpeed = ball.isGoal and 0 or math.abs(ball.verticalSpeed * ActionLayerConfig.GOALUP_BOUNCE_SPEED_Y_ATTENUATION)
    BallActionExecutorWrap.OnFreeFlyCollision(newHorizontalSpeed.magnitude, newHorizontalSpeed.normalized, verticalSpeed)
end

local function OnHitAdBoard(ball)
    local horizontalDirection = Vector3Lua(ball.horizontalDirection.x, 0, -ball.horizontalDirection.z)
    local horizontalSpeedMag = ball.horizontalSpeedMag * ActionLayerConfig.AD_BOARD_HORIZONTAL_SPEED_ATTENUATION
    local verticalSpeed = math.clamp(math.abs(ball.verticalSpeed), ActionLayerConfig.AD_BOARD_VERTICAL_SPEED_MIN, ActionLayerConfig.AD_BOARD_VERTICAL_SPEED_MAX)
    BallActionExecutorWrap.OnFreeFlyCollision(horizontalSpeedMag, horizontalDirection, verticalSpeed)
end

function ActionLayerUtils.OnFreeFlyBallHitCollider(ball, collider)
    if collider == GoalCollider.Back then
        OnHitGoalBack(ball)
        ___matchUI:onBallHitGoalNet()
    elseif collider == GoalCollider.Side then
        OnHitGoalSide(ball)
        ___matchUI:onBallHitGoalNet()
    elseif collider == GoalCollider.Up then
        OnHitGoalUp(ball)
        ___matchUI:onBallHitGoalNet()
    elseif collider == GoalCollider.AdBoard then
        OnHitAdBoard(ball)
    end
end

function ActionLayerUtils.OnFreeFlyBallBounceOnGround(ball)
    local horizontalSpeedMag = ball.horizontalSpeedMag
    if horizontalSpeedMag > ActionLayerConfig.HORIZIONTAL_MIN_SPEED_DROP then
        horizontalSpeedMag = horizontalSpeedMag * ActionLayerConfig.GROUND_BOUNCE_HORIZIONTAL_SPEED_ATTENUATION
    end
    local verticalSpeed = ball.verticalSpeed * ActionLayerConfig.GROUND_BOUNCE_VERTICAL_SPEED_ATTENUATION
    BallActionExecutorWrap.OnFreeFlyBounceOnGround(horizontalSpeedMag, ball.horizontalDirection, verticalSpeed)
end

return ActionLayerUtils