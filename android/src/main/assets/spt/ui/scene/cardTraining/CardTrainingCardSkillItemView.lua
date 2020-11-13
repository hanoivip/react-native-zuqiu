local CardSkillItemView = require("ui.scene.cardDetail.CardSkillItemView")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardTrainingCardSkillItemView = class(unity.base)

function CardTrainingCardSkillItemView:ctor()
    self.skill = self.___ex.skill
    self.skillName = self.___ex.skillName
    self.bg = self.___ex.bg
    self.toggle = self.___ex.toggle
    self.sbg = self.___ex.sbg
    self.lock = self.___ex.lock
    self.animMask = self.___ex.animMask

    self.selectedPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/TrueColor/SkillBg_1.png"
    self.normalPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/TrueColor/SkillBg.png"
end

function CardTrainingCardSkillItemView:InitSkillView(sid, toggleGroup, skill)
    local selectedSid
    local isLock
    for k, v in pairs(skill) do
        selectedSid = k
        isLock = v
    end
    self.toggle.group = toggleGroup
    local itemModel = SkillItemModel.new()
    itemModel:InitByID(sid)

    self.toggle.isOn = sid == selectedSid
    GameObjectHelper.FastSetActive(self.animMask, sid == selectedSid)
    self.skillName.text = itemModel:GetName()
    self.skill.overrideSprite = AssetFinder.GetSkillIcon(itemModel:GetIconIndex())

    GameObjectHelper.FastSetActive(self.sbg, self.toggle.isOn)
    GameObjectHelper.FastSetActive(self.bg, not self.toggle.isOn)
    GameObjectHelper.FastSetActive(self.lock, not isLock)

    self.toggle.onValueChanged:AddListener(function (isOn)
        GameObjectHelper.FastSetActive(self.sbg, isOn)
        GameObjectHelper.FastSetActive(self.bg, not isOn)

        if self.onSkillChanged and isOn then
            self.onSkillChanged()
        end
    end)
end

return CardTrainingCardSkillItemView
