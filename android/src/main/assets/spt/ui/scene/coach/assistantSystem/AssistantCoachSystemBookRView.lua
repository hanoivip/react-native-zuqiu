local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachSystemBookRView = class(unity.base, "AssistantCoachSystemBookRView")

-- 助理教练技能prefab
local AssistantCoachSkillPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSkillItem.prefab"

function AssistantCoachSystemBookRView:ctor()
    -- 属性
    self.sptAttrs = self.___ex.sptAttrs
    self.txtAttrNone = self.___ex.txtAttrNone
    -- 属性成长
    self.sptGrowthes = self.___ex.sptGrowthes
    -- 技能
    self.skillScrollView = self.___ex.skillScrollView
    self.txtSkillNone = self.___ex.txtSkillNone
    self.btnLeft = self.___ex.btnLeft
    self.btnRight = self.___ex.btnRight

    -- 助理教练Model
    self.acModel = nil
    -- 父界面使用Model，AssistantCoachSystemModel
    self.parentModel = nil
    -- 是否上阵助教
    self.hasAC = false
end

function AssistantCoachSystemBookRView:start()
    self:RegBtnEvent()
end

function AssistantCoachSystemBookRView:RegBtnEvent()
end

function AssistantCoachSystemBookRView:InitView(assistantCoachModel, assistantCoachSystemModel, isReadOnly)
    self.acModel = assistantCoachModel
    self.parentModel = assistantCoachSystemModel
    self.hasAC = tobool(self.acModel ~= nil)
    self.isReadOnly = isReadOnly

    self:DisplayArea(self.hasAC)
    if self.hasAC then
        self:RefreshView()
    end
end

function AssistantCoachSystemBookRView:RefreshView()
    -- 属性
    local attrs = self.acModel:GetAttrs()
    self.sptAttrs:InitView(attrs)
    -- 属性成长
    self.sptGrowthes:InitView(attrs)
    -- 技能
    local skills = self.acModel:GetSkills()
    self.skillNum = table.nums(skills)
    self.skillScrollView:regOnItemIndexChanged(function(idx)
        self:OnSkillScrollIndexChanged(idx)
    end)
    self.skillScrollView:InitView(skills)
end

function AssistantCoachSystemBookRView:DisplayArea(hasAC)
    GameObjectHelper.FastSetActive(self.skillScrollView.gameObject, hasAC)
    GameObjectHelper.FastSetActive(self.txtSkillNone.gameObject, not hasAC)
    GameObjectHelper.FastSetActive(self.sptAttrs.gameObject, hasAC)
    GameObjectHelper.FastSetActive(self.sptGrowthes.gameObject, hasAC)
    GameObjectHelper.FastSetActive(self.btnLeft.gameObject, hasAC)
    GameObjectHelper.FastSetActive(self.btnRight.gameObject, hasAC)
    GameObjectHelper.FastSetActive(self.txtAttrNone.gameObject, not hasAC)
end

function AssistantCoachSystemBookRView:OnSkillScrollIndexChanged(idx)
    if not self.skillNum then
        if self.acModel then
            self.skillNum = table.nums(self.acModel:GetSkills())
        else
            self.skillNum = 0
        end
    end
    GameObjectHelper.FastSetActive(self.btnLeft.gameObject, idx > 1)
    GameObjectHelper.FastSetActive(self.btnRight.gameObject, idx <= self.skillNum - 3)
end

function AssistantCoachSystemBookRView:GetTeamIdx()
    return self.hasAC and self.acModel:GetTeamIdx() or 0
end

return AssistantCoachSystemBookRView
