local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time

local TeamUniformModel  = require("ui.models.common.TeamUniformModel")

local Shooter = class(unity.base)

function Shooter:ctor()
    self.animator = self.___ex.animator
    self.playerBuilder = self.___ex.playerBuilder
    self.shootCtrl = self.___ex.shootCtrl
end

function Shooter:SetShootCtrl()
    self.animator.runtimeAnimatorController = self.shootCtrl
end

function Shooter:StartAction(i)
    self.animator:SetTrigger(format("Gacha%dTrigger", i))
end

function Shooter:Shoot()
    self.animator:SetTrigger(format("ShootTrigger", i))
end

function Shooter:Pause()
    self.animator.speed = 0
end

function Shooter:Continue()
    self.animator.speed = 1
end

return Shooter
