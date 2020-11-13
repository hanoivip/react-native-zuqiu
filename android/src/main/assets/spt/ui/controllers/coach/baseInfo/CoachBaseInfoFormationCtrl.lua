local BaseCtrl = require("ui.controllers.BaseCtrl")

local CoachBaseInfoFormationCtrl = class(BaseCtrl, "CoachBaseInfoFormationCtrl")

CoachBaseInfoFormationCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/BaseInfo/CoachBaseInfoFormation.prefab"

CoachBaseInfoFormationCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachBaseInfoFormationCtrl:ctor()
    CoachBaseInfoFormationCtrl.super.ctor(self)
end

function CoachBaseInfoFormationCtrl:Init(coachBaseInfoFormationModel)
    CoachBaseInfoFormationCtrl.super.Init(self)
    self.view.onClickConfirm = function() self:OnClickConfirm() end
    self.view.onItemClick = function(itemData) self:OnItemClick(itemData) end
end

function CoachBaseInfoFormationCtrl:Refresh(coachBaseInfoFormationModel)
    CoachBaseInfoFormationCtrl.super.Refresh(self)
    if not coachBaseInfoFormationModel then
        local CoachBaseInfoFormationModel = require("ui.models.coach.baseInfo.CoachBaseInfoFormationModel")
        self.model = CoachBaseInfoFormationModel.new()
    else
        self.model = coachBaseInfoFormationModel
    end
    self.view:InitView(self.model)
end

-- 点击选择阵型
function CoachBaseInfoFormationCtrl:OnItemClick(itemData)
    local oldIdx = self.model:GetCurrFormationIdx()
    local newIdx = itemData.idx
    local scrollData = self.model:GetScrollData()

    self.model:SwitchSelectedFormation(newIdx)
    if oldIdx then
        self.view.scrollView:UpdateItem(oldIdx, scrollData[oldIdx])
    end
    self.view.scrollView:UpdateItem(newIdx, scrollData[newIdx])
end

-- 点击确认
function CoachBaseInfoFormationCtrl:OnClickConfirm()
    local formationData = self.model:GetCurrSelectedFormationData()
end

return CoachBaseInfoFormationCtrl
