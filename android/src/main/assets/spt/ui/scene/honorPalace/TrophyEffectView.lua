local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AssetFinder = require("ui.common.AssetFinder")

local TrophyEffectView = class(unity.base)

function TrophyEffectView:ctor()
    self.flashEffect = self.___ex.flashEffect
    self.animator = self.___ex.animator
    self.trophyImage = self.___ex.trophyImage
    self.leaveEffect = self.___ex.leaveEffect
end

function TrophyEffectView:InitView(trophyId)
    self.trophyImage.overrideSprite = AssetFinder.GetHonorPalaceTrophyIcon(trophyId)
    self.trophyImage:SetNativeSize()
end

function TrophyEffectView:PlayEffect()
    self.flashEffect.gameObject:SetActive(true)
end

function TrophyEffectView:PlayLeaveAnim()
    self.leaveEffect.gameObject:SetActive(true)
    EventSystem.SendEvent("HonorPalaceView.PlayTrophyLeaveAnim", self.gameObject)
end

function TrophyEffectView:PlayAppearAnim()
    self.animator.enabled = true
    self.animator:Play("MetalShowUpAnimation")
end

return TrophyEffectView
