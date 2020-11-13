local TrainManager = require("training.TrainManager")
local TrainData = require("training.TrainData")
local TrainType = require("training.TrainType")

local EventSystem = require("EventSystem")

local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local RectTransform = UnityEngine.RectTransform
local Vector2 = UnityEngine.Vector2
local SphereCollider = UnityEngine.SphereCollider
local Mathf = UnityEngine.Mathf
local Random = UnityEngine.Random

local TrainEntry = class(unity.newscene)

function TrainEntry:ctor()
    luaevt.trig("SetOnBackType", "forbid")

    TrainEntry.super.ctor(self)
    self.trainType = TrainData.trainType or TrainType.DEFEND
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Training/TrainingRules.prefab", "camera", true, true)
    dialogcomp.contentcomp:InitView(self.trainType, TrainData.gameID or "101")
    -- set random seed 
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end

function TrainEntry:start()
    clr.UnityEngine.RenderSettings.fog = true
    EventSystem.AddEvent("training_try_success", self, self.TrainTrySuccess)
    EventSystem.AddEvent("training_try_failed", self, self.TrainTryFailed)
    EventSystem.AddEvent("TrainEntry.InitTrainManager", self, self.InitTrainManager)

    luaevt.reg("train_start_shoot", function(trigStr, startPosition, endPosition, controlPoint, flyDuration, projectedOrigin, projectedDestination)
        self.trainManager:FingerTrigShoot(startPosition, endPosition, controlPoint, flyDuration, projectedOrigin, projectedDestination)
    end)
    
    self.trainManager = TrainManager.new()
end

function TrainEntry:TrainTrySuccess()
    print("TrainEntry:TrainTrySuccess")
    self.trainManager:TrySuccess()
end

function TrainEntry:TrainTryFailed()
    print("TrainEntry:TrainTryFailed")
    self.trainManager:TryFailed()
end

function TrainEntry:onDestroy()
    EventSystem.RemoveEvent("training_try_success", self, self.TrainTrySuccess)
    EventSystem.RemoveEvent("training_try_failed", self, self.TrainTryFailed)
    EventSystem.RemoveEvent("TrainEntry.InitTrainManager", self, self.InitTrainManager)
    luaevt.unreg("train_start_shoot")

    self.trainManager:onDestroy()
    luaevt.trig("SetOnBackType", "common")
end

function TrainEntry:InitTrainManager()
    self.trainManager.kitFontTexture = self.___ex.kitFontTexture
    self.trainManager.kitFont = self.___ex.kitFont
    self.trainManager.ball = self.___ex.ball
    self.trainManager:Init(self.___ex.trainMenuTrans, self.___ex.goalTrans)
end

return TrainEntry
