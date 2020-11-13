local TrainGlove = class(unity.base)

local EventSystem = require("EventSystem")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Input = UnityEngine.Input
local TouchPhase = UnityEngine.TouchPhase
local Camera = UnityEngine.Camera
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType

function TrainGlove:ctor()
    self.missPointLeft = self.___ex.missPointLeft
    self.missPointRight = self.___ex.missPointRight
end

function TrainGlove:start()
    self.leftChild = false
    self.rightChild = false
    self.endFlag = false
    self.ball = GameObject.Find("/Ball")
    self.ballSpt = self.ball:GetComponent(CapsUnityLuaBehav)
end

function TrainGlove:update()
    local e
    if Input.touchCount > 0 and (Input.GetTouch(0).phase == TouchPhase.Moved or Input.GetTouch(0).phase == TouchPhase.Began) then
        e = Input.GetTouch(0).position
    end
    if Input.GetMouseButton(0) then
        e = Input.mousePosition
    end
    if e then
        local screenPos = Camera.main:WorldToScreenPoint(self.transform.position)
        local world = Camera.main:ScreenToWorldPoint(Vector3(e.x, e.y, screenPos.z))
        self.transform.position = Vector3(world.x, world.y < 0.3 and 0.3 or world.y, world.z)
    end

    if not self.endFlag then
        if self.leftChild or self.rightChild then
            -- TrainManager.GetInstance ().trySuccess ();
            EventSystem.SendEvent("training_try_success")
            self.endFlag = true
            self.ballSpt:EndRotate()
            if self.leftChild then
                self.ballSpt:ShootBall(self.missPointLeft.position, 0.5)
            else
                self.ballSpt:ShootBall(self.missPointRight.position, 0.5)
            end
            return
        end
        if self.ball.transform.position.x > 55.11 then
            -- TrainManager.GetInstance ().tryFailed ();
            EventSystem.SendEvent("training_try_failed")
            self.endFlag = true
            self.ballSpt:EndRotate()
            -- Camera.main.transform:GetComponent<ShakeCamera> ().startShake ();
        end
    end
end

function TrainGlove:OnTriggerEnter(selfObj, otherObj)
    self:TriggerBall(selfObj.name)
end

function TrainGlove:TriggerBall(name)
    if name == "GloveRight" then
        self.rightChild = true
    else
        self.leftChild = true
    end
    local tweener = ShortcutExtensions.DOShakePosition(self.transform, 0.2, Vector3(0.5, 0, 0), 10, 90, false, true)
end

return TrainGlove
