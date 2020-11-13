local BaseCtrl = require("ui.controllers.BaseCtrl")

local AssistantCoachSkillDetailCtrl = class(BaseCtrl, "AssistantCoachSkillDetailCtrl")

AssistantCoachSkillDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSkillDetail.prefab"

AssistantCoachSkillDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AssistantCoachSkillDetailCtrl:ctor()
    AssistantCoachSkillDetailCtrl.super.ctor(self)
end

function AssistantCoachSkillDetailCtrl:Init(acSkillData)
    AssistantCoachSkillDetailCtrl.super.Init(self)
    self.view.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
end

-- @param [acSkillData]: 经过AssistantCoachModel解析过的助理教练技能数据
function AssistantCoachSkillDetailCtrl:Refresh(acSkillData)
    AssistantCoachSkillDetailCtrl.super.Refresh(self)
    if acSkillData then
        self.data = acSkillData
        self.view:InitView(self.data)
    end
end

function AssistantCoachSkillDetailCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistantCoachSkillDetailCtrl:OnExitScene()
    self.view:OnExitScene()
end

return AssistantCoachSkillDetailCtrl
