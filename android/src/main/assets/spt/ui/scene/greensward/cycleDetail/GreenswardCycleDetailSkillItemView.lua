local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local GreenswardCycleDetailSkillItemView = class(unity.base, "GreenswardCycleDetailSkillItemView")

function GreenswardCycleDetailSkillItemView:ctor()
    -- 技能图标
    self.imgIcon = self.___ex.imgIcon
    -- 技能名称
    self.txtName = self.___ex.txtName
end

function GreenswardCycleDetailSkillItemView:InitView(skillData)
    self.data = skillData
    self.imgIcon.overrideSprite = AssetFinder.GetSkillIcon(self.data.picIndex)
    self.txtName.text = tostring(self.data.skillName)
end

return GreenswardCycleDetailSkillItemView
