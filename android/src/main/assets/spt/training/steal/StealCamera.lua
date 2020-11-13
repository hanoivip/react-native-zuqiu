local StealCamera = class(unity.base)

local StealEventType = require("training.steal.StealEventType")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Time = UnityEngine.Time

local CameraMoveType = {
    CameraMoveByTarget = 1,
    CameraMoveByTransform = 2,
    CameraMoveByPosition = 3,
    CameraMoveBySpeed = 4,
    CameraMoveByDefault = 5,
}

function StealCamera:ctor()
    self.doOver = nil
    self.startTime = nil
    self.isRunning = nil
    self.startPosition = nil
    self.offsetDelta = nil
    self.lookDelta = nil
    self.runningTime = nil
    self.useTime = 0
    self.lookAtObject = nil
    self.currentType = nil
    self.startTransform = nil
    self.endTransform = nil
    self.cameraMoveType = CameraMoveType.CameraMoveByDefault
end

function StealCamera:lateUpdate()
    if (self.cameraMoveType == CameraMoveType.CameraMoveBySpeed) then
        self.runningTime = self.runningTime + Time.deltaTime
        local value = self.runningTime / self.useTime
        local endPosX = self.target.transform.position.x + self.offsetDelta.x - self.startPosition.x
        local offsetX = endPosX * (-math.pow(2, -10 * value) + 1) + self.startPosition.x
        local endPosZ = self.target.transform.position.z + self.offsetDelta.z - self.startPosition.z
        local offsetZ = endPosZ * (-math.pow(2, -10 * value) + 1) + self.startPosition.z
        if (value >= 1) then
            self.isRunning = false
            self.transform.position = Vector3(self.target.transform.position.x + self.offsetDelta.x, self.offsetDelta.y, self.target.transform.position.z + self.offsetDelta.z)
            self:EndCallBack()
            return
        else
            self.transform.position = Vector3(offsetX, self.offsetDelta.y, offsetZ)
        end
        local newLookPos = Vector3(self.target.transform.position.x + self.lookDelta.x,
                                     self.lookDelta.y,
                                     self.target.transform.position.z + self.lookDelta.z)
        self.transform:LookAt(newLookPos)
    elseif (self.cameraMoveType == CameraMoveType.CameraMoveByTarget) then
        if (self.target ~= nil and self.target ~= clr.null) then
            local newPos = Vector3(self.target.transform.position.x + self.offsetDelta.x,
                                                     self.offsetDelta.y,
                                                     self.target.transform.position.z + self.offsetDelta.z)
            self.transform.position = Vector3.Lerp(self.transform.position, newPos, (Time.time - self.startTime))   
            local newLookPos = Vector3(self.target.transform.position.x + self.lookDelta.x,
                                         self.lookDelta.y,
                                         self.target.transform.position.z + self.lookDelta.z)
            self.transform:LookAt(newLookPos)
        end
    elseif (self.cameraMoveType == CameraMoveType.CameraMoveByTransform) then
        self.transform.position = Vector3.Lerp(self.target.transform.position, self.endTransform.position, (Time.time - self.startTime) / self.useTime)
        local newLookPos = self.lookAtObject.transform.position + self.lookDelta
        self.transform:LookAt(newLookPos)
    end
end

function StealCamera:EndCallBack()
    if (self.doOver ~= nil) then
        self.doOver(self.currentType)
    end
end

function StealCamera:SetType(type)
    self.currentType = type
end

function StealCamera:InitByTarget(t, offsetVec3, lookAtObj, lookVec3)
    self.startTime = Time.time
    self.target = t
    self.startPosition = self.transform.position
    self.lookAtObject = lookAtObj
    self.offsetDelta = offsetVec3
    self.lookDelta = lookVec3
    self.cameraMoveType = CameraMoveType.CameraMoveByTarget
    dump(self.target)
end

function StealCamera:InitByTransform(selfObj, endTransf, lookObject, lookVec3, time)
    self.startTime = Time.time
    self.target = selfObj
    self.lookDelta = lookVec3
    self.lookAtObject = lookObject
    self.endTransform = endTransf
    self.useTime = time
    self.cameraMoveType = CameraMoveType.CameraMoveByTransform
end

function StealCamera:InitBySpeed(t, offsetVec3, lookAtObj, lookVec3, time)
    self.target = t
    self.runningTime = 0
    self.useTime = time
    self.startPosition = self.transform.position
    self.lookAtObject = lookAtObj
    self.offsetDelta = offsetVec3
    self.lookDelta = lookVec3
    self.isRunning = true
    self.cameraMoveType = CameraMoveType.CameraMoveBySpeed
    dump(self.target)
end

function StealCamera:Init(position, rotation)
    self.cameraMoveType = CameraMoveType.CameraMoveByDefault
    self.transform.position = position
    self.transform.rotation = rotation
end


return StealCamera
