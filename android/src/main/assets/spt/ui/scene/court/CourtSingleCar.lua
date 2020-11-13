local CourtSingleCar = class(unity.base)
local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion

function CourtSingleCar:ctor()
    self.destPos = nil
    self.startPos = nil
    self.direction = nil
    self.minCD = 2
    self.maxCD = 10

    self.halfSingleLaneWidth = 12
    self.halfCarLength = 2

    self.minSpeedPerSecond = 100
    self.turning = nil

    

    self.actionTime = 0
    self.passedTime = 0

    self.moveStart = nil
    self.moveEnd = nil

    self.directionVectorMap = {}
    self.directionVectorMap[1] = {0, 1}
    self.directionVectorMap[2] = {1, 0}
    self.directionVectorMap[3] = {0, -1}
    self.directionVectorMap[4] = {-1, 0}
end

function CourtSingleCar:Run(positions, cameraTransform, staticTransformTable, modelTransform)
    self:MoveAway()
    self.timeBeforeNextBorn = math.randomInRange(self.minCD, self.maxCD)
    self.positions = positions
    self.cameraTransform = cameraTransform
    self.offset = Vector3Lua(modelTransform.localPosition.x, modelTransform.localPosition.y, modelTransform.localPosition.z)
    self.staticTransformTable = staticTransformTable
    self:coroutine(function()
        while true do
            local usdt = Time.unscaledDeltaTime
            if self.timeBeforeNextBorn ~= 0 then
                self.timeBeforeNextBorn = math.max(self.timeBeforeNextBorn - usdt, 0)
                if self.timeBeforeNextBorn == 0 then
                    self:RandomBorn()
                end
            else
                self.passedTime = self.passedTime + usdt
                self:UpdateTransform()
            end
            coroutine.yield()
        end
    end)
end

function CourtSingleCar:RandomBorn()
    self.running = true
    self.startPos = self.positions.bornPos[math.floor(math.randomInRange(1, #self.positions.bornPos + 1))]
    local posDesc = self:GetPosDesc(self.startPos)
    for k, v in pairs(posDesc) do
        self.direction = k
    end
    self.destPos = posDesc[self.direction]
    self.moveStart = self:GetOuterCornerCoordinate(self.startPos, self.direction)
    self.moveEnd = self:GetInnerCornerCoordinate(self.destPos, self.direction)
    self.actionTime = math.pow(math.pow(self.moveStart[1] - self.moveEnd[1], 2) + math.pow(self.moveStart[2] - self.moveEnd[2], 2), 1 / 2) / self.minSpeedPerSecond
    self.cameraTransform.localPosition = self:ConvertVector3(self.staticTransformTable[self.direction].position + self.offset)
    self.cameraTransform.localRotation = self.staticTransformTable[self.direction].rotation_static
end

function CourtSingleCar:RefreshDest()
    if self.destPos and self.positions.IsBornPos(self.destPos) then
        self:OnOutOfMap()
        return
    else
        local posDesc = self:GetPosDesc(self.destPos)
        local directions = {}
        if self.direction then
            for k, v in pairs(posDesc) do
                if k ~= (self.direction + 1) % 4 + 1 then
                    table.insert(directions, k)
                end
            end
        else
            dump("???????????")
        end

        local lastDirection = self.direction
        local lastDestPos = self.destPos
        self.direction = directions[math.floor(math.randomInRange(1, #directions + 1))]
        if #directions > 0 then
            if lastDirection and self.direction ~= lastDirection then
                self.destPos = posDesc[self.direction]
                self.startPos = lastDestPos
                self.moveStart = self:GetOuterCornerCoordinate(self.startPos, self.direction)
                self.moveEnd = self:GetInnerCornerCoordinate(self.destPos, self.direction)
                self.actionTime = math.pow(math.pow(self.moveStart[1] - self.moveEnd[1], 2) + math.pow(self.moveStart[2] - self.moveEnd[2], 2), 1 / 2) / self.minSpeedPerSecond
                self:InitTurnData(lastDirection)
            else            
                self.destPos = posDesc[self.direction]
                self.startPos = lastDestPos
                self.moveStart = self:GetInnerCornerCoordinate(self.startPos, lastDirection)
                self.moveEnd = self:GetInnerCornerCoordinate(self.destPos, self.direction)
                self.actionTime = math.pow(math.pow(self.moveStart[1] - self.moveEnd[1], 2) + math.pow(self.moveStart[2] - self.moveEnd[2], 2), 1 / 2) / self.minSpeedPerSecond
            end
        end
    end
end

function CourtSingleCar:GetPosDesc(pos)
    return self.positions.posDescMap[pos[1] .. "_" .. pos[2]]
end

function CourtSingleCar:OnOutOfMap()
    self.timeBeforeNextBorn = math.randomInRange(self.minCD, self.maxCD)
    self.direction = nil
    self.startPos = nil
    self.destPos = nil
end

function CourtSingleCar:UpdateTransform()
    if self.turnTime then
        if self.passedTime < self.turnTime then
            self:OnTurn()
            return
        else
            self.passedTime = self.passedTime - self.turnTime
            self:LerpAll()
            self.turnTime = nil
        end
    end
    if self.passedTime < self.actionTime then
        self:LerpAll()
    else
        self.passedTime = self.passedTime - self.actionTime
        self:RefreshDest()
        if self.timeBeforeNextBorn > 0 then
            self:MoveAway()
        else
            self:UpdateTransform()
        end
    end
end

function CourtSingleCar:LerpAll()
    self:SetAnchoredPosition(self.gameObject.transform, {math.lerp(self.moveStart[1], self.moveEnd[1], self.passedTime / self.actionTime), math.lerp(self.moveStart[2], self.moveEnd[2], self.passedTime / self.actionTime)})
end

function CourtSingleCar:GetInnerCornerCoordinate(pos, direction)
    if direction == 1 then
        return self:GetRelativityCoordinate(pos, {self.halfSingleLaneWidth, -self.halfSingleLaneWidth * 2 - self.halfCarLength})
    elseif direction == 2 then
        return self:GetRelativityCoordinate(pos, {-self.halfSingleLaneWidth * 2 - self.halfCarLength, -self.halfSingleLaneWidth})
    elseif direction == 3 then
        return self:GetRelativityCoordinate(pos, {-self.halfSingleLaneWidth, self.halfSingleLaneWidth * 2 + self.halfCarLength})--
    elseif direction == 4 then
        return self:GetRelativityCoordinate(pos, {self.halfSingleLaneWidth * 2 + self.halfCarLength, self.halfSingleLaneWidth})
    end
end

function CourtSingleCar:GetOuterCornerCoordinate(pos, direction)
    if direction == 1 then
        return self:GetRelativityCoordinate(pos, {self.halfSingleLaneWidth, self.halfSingleLaneWidth * 2 + self.halfCarLength})
    elseif direction == 2 then
        return self:GetRelativityCoordinate(pos, {self.halfSingleLaneWidth * 2 + self.halfCarLength, -self.halfSingleLaneWidth})
    elseif direction == 3 then
        return self:GetRelativityCoordinate(pos, {-self.halfSingleLaneWidth, -self.halfSingleLaneWidth * 2 - self.halfCarLength})
    elseif direction == 4 then
        return self:GetRelativityCoordinate(pos, {-self.halfSingleLaneWidth * 2 - self.halfCarLength, self.halfSingleLaneWidth}) -- -self.halfSingleLaneWidth * 2 - self.halfCarLength, self.halfSingleLaneWidth * 2 + self.halfCarLength
    end 
end

function CourtSingleCar:CalcTurnData()
    local distanceFromTurnStart
    local centerFromStartPos = self.halfSingleLaneWidth * 2 + self.halfCarLength
    local centerPos = self:GetRelativityCoordinate(self.startPos, {self.directionVectorMap[(self.turnFirstDirection + 1) % 4 + 1][1] * centerFromStartPos + self.directionVectorMap[self.turnLastDirection][1] * centerFromStartPos, self.directionVectorMap[(self.turnFirstDirection + 1) % 4 + 1][2] * centerFromStartPos + self.directionVectorMap[self.turnLastDirection][2] * centerFromStartPos})
    if (self.turnFirstDirection + 1) % 4 == self.turnLastDirection % 4 then
        distanceFromTurnStart = 18
        self.turnTime = 0.7
    else
        distanceFromTurnStart = 50
        self.turnTime = 1
    end 

    self.radius = 5 / math.pow(17 , 1 / 2) * distanceFromTurnStart
    self.turnCenter = centerPos
    self.startAngle = math.pi * 3 / 4 - math.pi / 2 * ((self.turnLastDirection + 1) % 4)
    self.endAngle = math.pi * 3 / 4 - math.pi / 2 * (self.turnFirstDirection - 1)
    self.startAngle, self.endAngle = self:GetLerpAngel(self.startAngle, self.endAngle)
end

--1   2    4->2 x
--4   3    3->1 y
function CourtSingleCar:GetRelativityCoordinate(pos, vector)
    local slope_x = 0.6
    local slope_y = -0.6
    return {pos[1] + math.pow(1 + math.pow(slope_x, 2), 1 / 2) * vector[1] - math.pow(1 + math.pow(slope_y, 2), 1 / 2) * vector[2], pos[2] + math.pow(1 + math.pow(slope_x, 2), 1 / 2) * vector[1] * slope_x - math.pow(1 + math.pow(slope_y, 2), 1 / 2) * vector[2] * slope_y}
end

function CourtSingleCar:SetCameraTransform(startTransform, endTransform, percent)
    self.cameraTransform.localPosition = self:ConvertVector3(Vector3Lua.Lerp(startTransform.position, endTransform.position, percent) + self.offset)
    self.cameraTransform.localRotation = self:ConvertQuaternion(QuaternionLua.Slerp(startTransform.rotation, endTransform.rotation, percent))
end

function CourtSingleCar:InitTurnData(lastDirection)
    self.turnStart = self:GetInnerCornerCoordinate(self.startPos, lastDirection) 
    self.turnEnd = self:GetOuterCornerCoordinate(self.startPos, self.direction)
    self.turnFirstDirection = lastDirection
    self.turnLastDirection = self.direction
    self:CalcTurnData()
end

function CourtSingleCar:OnTurn()
    local percent = self.passedTime / self.turnTime
    local angle = math.lerp(self.startAngle, self.endAngle, percent)
    self:SetAnchoredPosition(self.gameObject.transform, {self.turnCenter[1] + math.cos(angle) * self.radius, self.turnCenter[2] + math.sin(angle) * self.radius * 0.6})
    self:SetCameraTransform(self.staticTransformTable[self.turnFirstDirection], self.staticTransformTable[self.turnLastDirection], percent)
end

function CourtSingleCar:SetAnchoredPosition(transform, vector)
    transform.anchoredPosition = Vector2(vector[1], vector[2])
end

function CourtSingleCar:MoveAway()
    self.gameObject.transform.anchoredPosition = Vector2(10000, 10000)
    collectgarbage()
    clr.System.GC.Collect()
end

function CourtSingleCar:GetLerpAngel(startAngle, endAngle)
    local delta = endAngle - startAngle
    if math.abs(delta) > math.pi then
        if delta < 0 then
            endAngle = endAngle + math.pi * 2
        else
            startAngle = startAngle + math.pi * 2
        end
    end
    return startAngle, endAngle
end

function CourtSingleCar:ConvertVector3(vector)
    return Vector3(vector.x, vector.y, vector.z)
end

function CourtSingleCar:ConvertQuaternion(quat)
    return Quaternion(quat.x, quat.y, quat.z, quat.w)
end

return CourtSingleCar