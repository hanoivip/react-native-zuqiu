local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterUpgradeFilterCtrl = class(BaseCtrl)

PasterUpgradeFilterCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PasterUpgrade/PasterUpgradeFilter.prefab"

function PasterUpgradeFilterCtrl:Init(pasterUpgradeFilterModel)
    self.pasterUpgradeFilterModel = pasterUpgradeFilterModel
    self.view.clickConfirm = function() self:OnBtnConfirm() end
    self.view.clickReset = function() self:OnBtnReset() end
end

function PasterUpgradeFilterCtrl:Refresh(pasterUpgradeFilterModel)
    PasterUpgradeFilterCtrl.super.Refresh(self)
    self.pasterUpgradeFilterModel = pasterUpgradeFilterModel
    self:InitView(pasterUpgradeFilterModel)
end

function PasterUpgradeFilterCtrl:OnBtnConfirm()
    local filterMap = self.pasterUpgradeFilterModel:GetFilterMap()
    EventSystem.SendEvent("PasterUpgrade_OnFilterConfirmClick", filterMap)
    self.view:Close()
end

function PasterUpgradeFilterCtrl:OnBtnReset()
    local filterMap = self.pasterUpgradeFilterModel:SetFilterMap(nil)
    EventSystem.SendEvent("PasterUpgrade_OnFilterConfirmClick", nil)
    self.view:Close()
end

function PasterUpgradeFilterCtrl:InitView()
    self.view:InitView(self.pasterUpgradeFilterModel)
end

function PasterUpgradeFilterCtrl:UpdateSelectSkill(skillData)
    local skillID = skillData and skillData.skillID
    local filterMap = self.pasterUpgradeFilterModel:GetFilterMap()
    if not filterMap then
       filterMap = {}
    end
    local isSelect = skillData.isSelect
    if isSelect then
        filterMap.skill = skillID
    else
        if filterMap.skill == skillID then
            filterMap.skill = nil
        end
    end
    self.view:UpdateSkillSelectCount()
    self.pasterUpgradeFilterModel:SetFilterMap(filterMap)
end

function PasterUpgradeFilterCtrl:GetStatusData()
    return self.pasterUpgradeFilterModel
end

function PasterUpgradeFilterCtrl:OnEnterScene()
    EventSystem.AddEvent("MedalSearchView.UpdateSelectSkill", self, self.UpdateSelectSkill)
end

function PasterUpgradeFilterCtrl:OnExitScene()
    EventSystem.RemoveEvent("MedalSearchView.UpdateSelectSkill", self, self.UpdateSelectSkill)
end

return PasterUpgradeFilterCtrl
