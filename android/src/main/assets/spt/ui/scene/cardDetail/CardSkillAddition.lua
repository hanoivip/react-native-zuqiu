local AssetFinder = require("ui.common.AssetFinder")
local CardSkillAddition = class(unity.base)

function CardSkillAddition:ctor()
    self.skillName = self.___ex.skillName
    self.levelObj = self.___ex.levelObj
    self.level = self.___ex.level
    self.skill = self.___ex.skill
	self.skillPlus = self.___ex.skillPlus
end

function CardSkillAddition:InitView(skillItemModel)
    self.skillName.text = skillItemModel:GetName()
	local skillLevel = skillItemModel:GetAdditionLevel()
	self.level.text = "Lv." .. tostring(skillLevel)
	self.skillPlus.text = "Lv + " .. tostring(skillLevel)
    self.skill.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
end

return CardSkillAddition