local TrainShooter = class(unity.base)

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3

function TrainShooter:start()
    self.animator = self.___ex.animator
end

function TrainShooter:update()
    local state = self.animator:GetCurrentAnimatorStateInfo(0)
    if state.normalizedTime > 1 then
        self:Idle()
    end
end

function TrainShooter:Init()
    -- int r = UnityEngine.Random.Range (0, ManagerConstants.TRAIN_SHOOT_MOTIONS.Length);
    -- motion = ManagerConstants.TRAIN_SHOOT_MOTIONS [r];
    -- var loader = ActionAttributeLoader.GetLoader ();
    -- touchDuraTime = loader.GetLastTouchBallDuration (motion);
    -- deltaPosition = loader.GetFirstTouchBallOffset (motion);

    self.motion = "129"
    self.touchDuraTime = 0.8
    self.deltaPosition = Vector3(0.1, 0.2, 3)
end

function TrainShooter:Shoot()
    self.animator:Play(self.motion)
end

function TrainShooter:Idle()
    self.animator:Play("1")
end

return TrainShooter
