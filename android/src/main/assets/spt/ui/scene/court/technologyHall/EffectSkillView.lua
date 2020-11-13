local Skills = require("data.Skills")
local EffectSkillView = class(unity.base)

function EffectSkillView:ctor()
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
end

function EffectSkillView:InitView(sid)
    local skillTable = Skills[tostring(sid)]
    self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/SkillIcon/" .. skillTable.picIndex .. ".png")
    self.nameTxt.text = tostring(skillTable.skillName)
end

return EffectSkillView
