local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local MatchConstants = require("ui.scene.match.MatchConstants")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local ShootBallEffectView = class(unity.base)

function ShootBallEffectView:ctor()
    self.fingerTest = self.___ex.fingerTest

    self.effectShoot = res.Instantiate("Assets/CapstonesRes/Game/SkillEffect/SkillCaster/EffectShoot.prefab")
    self.effectShootArea = res.Instantiate("Assets/CapstonesRes/Game/SkillEffect/SkillCaster/EffectShootArea.prefab")
    self.effectShootSelect = res.Instantiate("Assets/CapstonesRes/Game/SkillEffect/SkillCaster/EffectShootSelect.prefab")

    self.fingerTest:AddBallEffect(self.effectShoot, self.effectShootArea, self.effectShootSelect)
end

function ShootBallEffectView:InitView()
    self.fingerTest:PlayShootBallEffect()
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(2))
        self.fingerTest:InitBallEffect()
        self.gameObject:SetActive(false)
    end)
end

return ShootBallEffectView
