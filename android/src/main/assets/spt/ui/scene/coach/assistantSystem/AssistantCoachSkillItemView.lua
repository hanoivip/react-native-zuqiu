local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local AssistantCoachSkillItemView = class(unity.base, "AssistantCoachSkillItemView")

function AssistantCoachSkillItemView:ctor()
    -- 点击区域
    self.btnClick = self.___ex.btnClick
    -- 图标
    self.imgIcon = self.___ex.imgIcon
    -- 技能名字
    self.txtName = self.___ex.txtName
    -- 解锁等级
    self.txtUnlockLvl = self.___ex.txtUnlockLvl

    self.interactable = true
end

function AssistantCoachSkillItemView:start()
    self.btnClick:regOnButtonClick(function()
        if self.interactable then
            self:OnSkillClick()
        end
    end)
end

function AssistantCoachSkillItemView:InitView(acSkillData, isShowName, isShowDetail, isShowUnlock)
    self.data = acSkillData
    self.isShowName = isShowName
    self.isShowDetail = isShowDetail
    self.isShowUnlock = isShowUnlock
    self.imgIcon.overrideSprite = AssetFinder.GetSkillIcon(self.data.picIndex)
    self.imgIcon.color = self.data.isOpen and Color(1, 1, 1, 1) or Color(0, 1, 1, 1)

    -- 名称，默认显示
    if isShowName == nil or isShowName == true then
        self.txtName.text = self.data.name
    else
        self.txtName.text = ""
    end
    -- 点击详情，默认显示
    if isShowDetail == nil or isShowDetail == true then
        self.clickCallback = function()
            res.PushDialog("ui.controllers.coach.assistantSystem.AssistantCoachSkillDetailCtrl", self.data)
        end
    else
        self.clickCallback = nil
    end
    -- 解锁信息
    self:UpdateUnlockInfo()
end

function AssistantCoachSkillItemView:UpdateUnlockInfo()
    -- 解锁信息，默认显示
    if not self.data.isOpen then
        if self.isShowUnlock == nil or self.isShowUnlock == true then
            GameObjectHelper.FastSetActive(self.txtUnlockLvl.gameObject, true)
            self.txtUnlockLvl.text = lang.transstr("reduce_num", self.data.unlockLvl) .. lang.transstr("unlock")
        else
            GameObjectHelper.FastSetActive(self.txtUnlockLvl.gameObject, false)
            self.txtUnlockLvl.text = ""
        end
    else
        GameObjectHelper.FastSetActive(self.txtUnlockLvl.gameObject, false)
        self.txtUnlockLvl.text = ""
    end
end

function AssistantCoachSkillItemView:SetOpenState(isOpen)
    self.imgIcon.color = isOpen and Color(1, 1, 1, 1) or Color(0, 1, 1, 1)
end

function AssistantCoachSkillItemView:SetClickState(interactable)
    self.interactable = interactable
end

function AssistantCoachSkillItemView:SetNameColor(r, g, b, a)
    self.txtName.color = Color(r, g, b, a)
end

function AssistantCoachSkillItemView:RegOnSkillClick(func)
    if self.interactable then
        if func ~= nil and type(func) == "function" then
            self.clickCallback = func
        end
    end
end

function AssistantCoachSkillItemView:OnSkillClick()
    if self.clickCallback and type(self.clickCallback) == "function" then
        self.clickCallback()
    end
end

return AssistantCoachSkillItemView
