local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local AssistCoachJoinView = class(unity.base, "AssistCoachJoinView")

-- 助理教练教练头像prefab
local PortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/AssistantCoachPortrait.prefab"

function AssistCoachJoinView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 技能列表
    self.skillScrollView = self.___ex.skillScrollView
    self.btnLeft = self.___ex.btnLeft
    self.btnRight = self.___ex.btnRight
    -- 头像
    self.rctPortrait = self.___ex.rctPortrait
    -- 确认按钮
    self.btnConfirm = self.___ex.btnConfirm
    -- 属性
    self.sptAttrs = self.___ex.sptAttrs

    -- 助理头像脚本
    self.portraitSpt = nil
end

function AssistCoachJoinView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self:RegBtnEvent()
end

function AssistCoachJoinView:InitView(acModel)
    self.acModel = acModel
    local skills = self.acModel:GetSkills()
    self.skillNum = table.nums(skills)
    self.skillScrollView:regOnItemIndexChanged(function(idx)
        self:OnSkillScrollIndexChanged(idx)
    end)
    self.skillScrollView:InitView(skills)
    self:InitPortrait(self.acModel)
    -- 属性
    local attrs = self.acModel:GetAttrs()
    self.sptAttrs:InitView(attrs)
end

-- 初始化助理教练头像
function AssistCoachJoinView:InitPortrait(acModel)
    if self.portraitSpt ~= nil then
        self:UpdatePortrait(acModel)
    else
        res.ClearChildren(self.rctPortrait)
        local portraitObj, portraitSpt = res.Instantiate(PortraitPath)
        if portraitObj ~= nil and portraitSpt ~= nil then
            self.portraitSpt = portraitSpt
            portraitObj.transform:SetParent(self.rctPortrait.transform, false)
            portraitObj.transform.localScale = Vector3.one
            portraitObj.transform.localPosition = Vector3.zero
            self:UpdatePortrait(acModel)
        end
    end
end

-- 更新助理教练教练头像显示
function AssistCoachJoinView:UpdatePortrait(acModel)
    if self.portraitSpt ~= nil then
        self.portraitSpt:InitView(acModel)
    end
end

function AssistCoachJoinView:OnEnterScene()
end

function AssistCoachJoinView:OnExitScene()
end

function AssistCoachJoinView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function AssistCoachJoinView:RegBtnEvent()
    self.btnConfirm:regOnButtonClick(function()
        self:Close()
    end)
    -- 技能向左箭头
    self.btnLeft:regOnButtonClick(function()
        self.skillScrollView:scrollToPreviousGroup()
    end)
    -- 技能向右箭头
    self.btnRight:regOnButtonClick(function()
        self.skillScrollView:scrollToNextGroup()
    end)
end

function AssistCoachJoinView:OnSkillScrollIndexChanged(idx)
    if not self.skillNum then
        if self.acModel then
            self.skillNum = table.nums(self.acModel:GetSkills())
        else
            self.skillNum = 0
        end
    end
    GameObjectHelper.FastSetActive(self.btnLeft.gameObject, idx > 1)
    GameObjectHelper.FastSetActive(self.btnRight.gameObject, idx <= self.skillNum - 4)
end

return AssistCoachJoinView
