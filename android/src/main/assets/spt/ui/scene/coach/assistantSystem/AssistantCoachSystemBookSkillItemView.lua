local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachSystemBookSkillItemView = class(unity.base, "AssistantCoachSystemBookSkillItemView")

local SkillPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSkillItem.prefab"

function AssistantCoachSystemBookSkillItemView:ctor()
    -- 技能容器
    self.rctSkill = self.___ex.rctSkill
end

function AssistantCoachSystemBookSkillItemView:start()
end

function AssistantCoachSystemBookSkillItemView:InitView(itemData)
    self.itemData = itemData
    self:InitSkill(itemData)
end

-- 初始化技能
function AssistantCoachSystemBookSkillItemView:InitSkill(itemData)
    res.ClearChildren(self.rctSkill)
    local obj, spt = res.Instantiate(SkillPath)
    if obj ~= nil and spt ~= nil then
        self.spt = spt
        obj.transform:SetParent(self.rctSkill.transform, false)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        self:UpdateSkillSpt(itemData)
    end
end

-- 更新技能显示
function AssistantCoachSystemBookSkillItemView:UpdateSkillSpt(itemData)
    if self.spt ~= nil then
        self.spt:InitView(itemData)
        self.spt:SetNameColor(0, 0, 0, 0.8)
    end
end

return AssistantCoachSystemBookSkillItemView
