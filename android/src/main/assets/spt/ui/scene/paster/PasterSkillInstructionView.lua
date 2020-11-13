local Skills = require("data.Skills")
local PasterSkillInstructionView = class(unity.base)

function PasterSkillInstructionView:ctor()
    self.skillIcon = self.___ex.skillIcon
    self.skillName = self.___ex.skillName
    self.skillDesc = self.___ex.skillDesc
end

function PasterSkillInstructionView:InitView(cardPasterModel, bSupporter)
    local sid = cardPasterModel:GetPasterSkill()
    local skillTable = Skills[tostring(sid)]
    self.skillIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/SkillIcon/" .. skillTable.picIndex .. ".png")
    self.skillName.text = tostring(skillTable.skillName)
    local desc = skillTable.desc
    local lvl = cardPasterModel:GetPasterSkillLvl()
    if not bSupporter then
        lvl = lvl + cardPasterModel:GetLevelEx()
    end
    self.skillDesc.text = "Lv." .. lvl .. "\n" .. lang.transstr("paster_skill_effect", desc)
end

return PasterSkillInstructionView