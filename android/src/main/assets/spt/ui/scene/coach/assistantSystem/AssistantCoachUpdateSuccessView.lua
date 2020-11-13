local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local AssistantCoachUpdateSuccessView = class(unity.base, "AssistantCoachUpdateSuccessView")

-- 助理教练教练头像prefab
local PortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/AssistantCoachPortrait.prefab"
-- 助理教练技能prefab
local AssistantCoachSkillPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSkillItem.prefab"

function AssistantCoachUpdateSuccessView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 助理教练头像
    self.rctPortrait = self.___ex.rctPortrait
    -- 恭喜达成等级
    self.txtCongratulation = self.___ex.txtCongratulation
    -- 属性
    self.sptAttrs = self.___ex.sptAttrs
    -- 技能
    self.txtNotHasSkill = self.___ex.txtNotHasSkill
    self.objHasSkill = self.___ex.objHasSkill
    self.rctSkill = self.___ex.rctSkill
    self.txtSkill = self.___ex.txtSkill
    -- 确认按钮
    self.btnConfirm = self.___ex.btnConfirm
end

function AssistantCoachUpdateSuccessView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirmClick()
    end)
end

function AssistantCoachUpdateSuccessView:InitView(assistantCoachModel)
    self.acModel = assistantCoachModel
    self.txtCongratulation.text = lang.trans("assistant_coach_update_success_congra", self.acModel:GetLvl())
    self:InitPortrait(assistantCoachModel)
    self:InitSkill(assistantCoachModel)
    self:InitAttrs(assistantCoachModel)
end

-- 初始化助理教练头像
function AssistantCoachUpdateSuccessView:InitPortrait(acModel)
    res.ClearChildren(self.rctPortrait)
    local portraitObj, portraitSpt = res.Instantiate(PortraitPath)
    if portraitObj ~= nil and portraitSpt ~= nil then
        portraitObj.transform:SetParent(self.rctPortrait.transform, false)
        portraitObj.transform.localScale = Vector3.one
        portraitObj.transform.localPosition = Vector3.zero
        portraitSpt:InitView(acModel)
    end
end

-- 初始化待解锁技能
function AssistantCoachUpdateSuccessView:InitSkill(acModel)
    -- 是否显示待解锁技能
    self:DisplaySkill(false)
    res.ClearChildren(self.rctSkill)
    local skills = acModel:GetSkills()
    for k, skill in pairs(skills) do
        if skill.unlockLvl == acModel:GetLvl() then
            -- 显示当前等级解锁的技能
            self:DisplaySkill(true)
            local objSkill, sptSkill = res.Instantiate(AssistantCoachSkillPath)
            objSkill.transform:SetParent(self.rctSkill, false)
            sptSkill:InitView(skill, true, true, false)
            sptSkill:SetOpenState(true)
            self.txtSkill.text = lang.trans("assistant_coach_update_success_skill_1")
            break
        elseif not skill.isOpen then
            -- 显示即将解锁的技能
            self:DisplaySkill(true)
            local objSkill, sptSkill = res.Instantiate(AssistantCoachSkillPath)
            objSkill.transform:SetParent(self.rctSkill, false)
            sptSkill:InitView(skill, true, true, false)
            sptSkill:SetOpenState(false)
            self.txtSkill.text = lang.trans("assistant_coach_update_success_skill", skill.unlockLvl)
            break
        end
    end
end

-- 是否显示待解锁技能
function AssistantCoachUpdateSuccessView:DisplaySkill(isShow)
    GameObjectHelper.FastSetActive(self.objHasSkill.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.txtNotHasSkill.gameObject, not isShow)
end

-- 属性区域
function AssistantCoachUpdateSuccessView:InitAttrs(acModel)
    local attrs = acModel:GetAttrs()
    self.sptAttrs:InitView(attrs)
end

function AssistantCoachUpdateSuccessView:OnEnterScene()
end

function AssistantCoachUpdateSuccessView:OnExitScene()
end

function AssistantCoachUpdateSuccessView:OnBtnConfirmClick()
    if self.onBtnConfirmClick and type(self.onBtnConfirmClick) == "function" then
        self.onBtnConfirmClick()
    end
end

function AssistantCoachUpdateSuccessView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return AssistantCoachUpdateSuccessView
