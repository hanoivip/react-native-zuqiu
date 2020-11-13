local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")
local AssetFinder = require("ui.common.AssetFinder")
local LegendRoadImproveItemView = require("ui.scene.legendRoad.ImproveDetail.LegendRoadImproveItemView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local Color = clr.UnityEngine.Color
local LegendRoadImproveItemNewSkillView = class(LegendRoadImproveItemView, "LegendRoadImproveItemNewSkillView")

local _skillItemPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/SkillItem.prefab"

-- 只有一条属性加成
function LegendRoadImproveItemNewSkillView:ctor()
    LegendRoadImproveItemNewSkillView.super.ctor(self)
    self.rctSkill = self.___ex.rctSkill
    self.skillIcon = self.___ex.skillIcon
    self.skillName = self.___ex.skillName
    self.btnSkill = self.___ex.btnSkill
    self.lock = self.___ex.lock
    self.btnSkill:regOnButtonClick(function()
        self:OnSkillClick()
    end)
end

function LegendRoadImproveItemNewSkillView:InitView(legendRoadModel, improveType, detailImprove)
    LegendRoadImproveItemNewSkillView.super.InitView(self, legendRoadModel, improveType, detailImprove)
end

function LegendRoadImproveItemNewSkillView:RefreshView()
    if not self:HasInit() then
        return
    end

    if self.improveType == ImproveType.Skill_New then -- 新技能，7
        local skillItemModel = self.legendRoadModel:GeImproveSkillItemModel(self.detailImprove)
        if skillItemModel ~= nil then
            self.isLock = tobool(self.legendRoadModel:IsLockSkill(self.detailImprove))
            self.skillItemModel = skillItemModel
            self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
            if self.isLock then
                self.skillIcon.color = Color(0.8, 0.8, 0.8)
            else
                self.skillIcon.color = Color(1, 1, 1)
            end
            self.skillName.text = skillItemModel:GetName()
            GameObjectHelper.FastSetActive(self.lock, self.isLock)
        end
    end
end

function LegendRoadImproveItemNewSkillView:OnSkillClick()
    if self.isLock then
        DialogManager.ShowToast(lang.trans("legendroad_skill_noopen"))
        return
    end
    if self.skillItemModel then
        res.PushDialog("ui.controllers.skill.LegendSkillDetailCtrl", self.skillItemModel)
    end
end

return LegendRoadImproveItemNewSkillView
