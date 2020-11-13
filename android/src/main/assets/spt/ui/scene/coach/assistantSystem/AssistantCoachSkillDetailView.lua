local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local AssistantCoachSkillDetailView = class(unity.base, "AssistantCoachSkillDetailView")

local SkillPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSkillItem.prefab"

function AssistantCoachSkillDetailView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    self.txtTitleRef = self.___ex.txtTitleRef
    self.rctSkill = self.___ex.rctSkill
    self.txtName = self.___ex.txtName
    self.txtDesc = self.___ex.txtDesc
end

function AssistantCoachSkillDetailView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function AssistantCoachSkillDetailView:InitView(acSkillData)
    self.data = acSkillData
    local title = lang.transstr("detail")
    self.txtTitle.text = title
    self.txtTitleRef.text = title
    res.ClearChildren(self.rctSkill)
    local obj, spt = res.Instantiate(SkillPath)
    if obj ~= nil and spt ~= nil then
        obj.transform:SetParent(self.rctSkill.transform, false)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        spt:InitView(self.data, false, false, false)
        spt:SetOpenState(true)
    end
    self.txtName.text = self.data.name
    self.txtDesc.text = self.data.desc
end

function AssistantCoachSkillDetailView:OnEnterScene()
end

function AssistantCoachSkillDetailView:OnExitScene()
end

function AssistantCoachSkillDetailView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return AssistantCoachSkillDetailView
