local CoachTalentCtrl = require("ui.controllers.coach.talent.CoachTalentCtrl")
local OtherCoachTalentModel = require("ui.models.coach.otherPlayer.OtherCoachTalentModel")

local OtherCoachTalentCtrl = class(CoachTalentCtrl, "OtherCoachTalentCtrl")

OtherCoachTalentCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/OtherPlayer/OtherCoachTalent.prefab"

function OtherCoachTalentCtrl:ctor(talent)
    OtherCoachTalentCtrl.super.ctor(self)
end

function OtherCoachTalentCtrl:Init(talent)
    self.view.onBtnBackClick = function() self:OnBtnBackClick() end
end

function OtherCoachTalentCtrl:Refresh(talent)
    if not self.model then
        self.model = OtherCoachTalentModel.new()
    end
    self.model:InitWithProtocol(talent)
    self.view:InitView(self.model)
    self.view:ShowDisplayArea(true)
    self.view:RefreshView()
end

function OtherCoachTalentCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function OtherCoachTalentCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function OtherCoachTalentCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 点击返回
function OtherCoachTalentCtrl:OnBtnBackClick()
    res.PopScene()
end

return OtherCoachTalentCtrl

