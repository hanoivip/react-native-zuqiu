local AssetFinder = require("ui.common.AssetFinder")

local MedalSkillItemView = class(unity.base)

function MedalSkillItemView:ctor()
    self.skill = self.___ex.skill
    self.skillName = self.___ex.skillName
    self.level = self.___ex.level
    self.btnDetail = self.___ex.btnDetail
end

function MedalSkillItemView:InitView(skillItemModel)
    local skillID = skillItemModel:GetSkillID()
    local isMedalSkill = string.sub(skillID, 1, 1) == "M"
    local skillLevel = skillItemModel:GetLevel()
    self.btnDetail:regOnButtonClick(function()
        if isMedalSkill then
            res.PushDialog("ui.controllers.skill.ExSkillDetailCtrl", skillItemModel)
        end
    end)

    self.skillName.text = skillItemModel:GetName()
    self.skill.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
    self.level.text = "Lv." .. tostring(skillLevel)
end

return MedalSkillItemView