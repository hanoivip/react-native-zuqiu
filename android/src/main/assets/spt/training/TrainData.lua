local TrainData = class()

local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local RectTransform = UnityEngine.RectTransform
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local SphereCollider = UnityEngine.SphereCollider
local Mathf = UnityEngine.Mathf
local Random = UnityEngine.Random
local TextAsset = UnityEngine.TextAsset

local TRAIN_DRIBBLE_MAX_CLICK = 50

local TrainShootData = require("training.data.TrainShootData")
local TrainSaveData = require("training.data.TrainSaveData")
local TrainExData = require("training.data.TrainExData")

local height = 2.1
local width = 3.2

function TrainData:ctor()
   self:LoadTrainShootInfo()
   self:LoadTrainSaveInfo()
   self:LoadTrainExInfo()
end

function TrainData:LoadTrainShootInfo()
    self.trainShootInfo = {}
    for k, item in pairs(TrainShootData) do
        local info = {}
        info.lvl = item.lvl
        info.score = item.score
        info.min_distance = item.min_distance
        info.max_distance = item.max_distance
        info.angle = item.angle
        info.min_defender = item.min_defender
        info.max_defender = item.max_defender
        info.move_rate = item.move_rate
        self.trainShootInfo[tostring(info.lvl)] = info
    end
end

function TrainData:GetTrainShootInfo(lvl)
    return self.trainShootInfo[tostring(lvl)]
end

function TrainData:LoadTrainSaveInfo()
    self.trainSaveInfo = {}
    for k, item in pairs(TrainSaveData) do
        local info = {}
        info.lvl = item.lvl
        info.score = item.score 
        info.min_speed = item.min_speed
        info.max_speed = item.max_speed
        info.min_rad = item.min_rad
        info.max_rad = item.max_rad
        self.trainSaveInfo[tostring(info.lvl)] = info
    end
end

function TrainData:GetTrainSaveInfo(lvl)
    return self.trainSaveInfo[tostring(lvl)]
end

function TrainData:LoadTrainExInfo()
    self.trainExInfo = TrainExData
end

function TrainData:GetTrainExInfo(key)
    return self.trainExInfo[tostring(key)]
end

function TrainData:GetMaxGoalDistance()
    return Vector3.Distance(Vector3.zero, Vector3(width, height, 0))
end

return TrainData
