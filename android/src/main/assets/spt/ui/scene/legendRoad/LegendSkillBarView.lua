local AssetFinder = require("ui.common.AssetFinder")
local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local Color = clr.UnityEngine.Color
local LegendSkillBarView = class(LuaButton, "LegendSkillBarView")

function LegendSkillBarView:ctor()
    LegendSkillBarView.super.ctor(self)
    self.icon = self.___ex.icon
    self.skillName = self.___ex.skillName
    self.lock = self.___ex.lock
    self:regOnButtonClick(function()
        self:OnNodeClick()
    end)
end

function LegendSkillBarView:InitView(legendRoadModel, skillId)
    self.skillModel = legendRoadModel:GetSkillModel(skillId)
    self.icon.overrideSprite = AssetFinder.GetSkillIcon(self.skillModel:GetIconIndex())
    self.skillName.text = self.skillModel:GetName()

    self.isLock = legendRoadModel:IsLockSkillBySkillId(skillId)
    if self.isLock then
        self.icon.color = Color(0.8, 0.8, 0.8)
    else
        self.icon.color = Color(1, 1, 1)
    end
    GameObjectHelper.FastSetActive(self.lock, self.isLock)
end

function LegendSkillBarView:OnNodeClick()
    if self.isLock then
        DialogManager.ShowToast(lang.trans("legendroad_skill_noopen"))
        return
    end
    res.PushDialog("ui.controllers.skill.LegendSkillDetailCtrl", self.skillModel)
end

return LegendSkillBarView