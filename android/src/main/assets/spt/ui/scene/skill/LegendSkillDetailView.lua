local AssetFinder = require("ui.common.AssetFinder")
local LegendSkillDetailView = class(unity.base)

function LegendSkillDetailView:ctor()
    self.improve = self.___ex.improve
    self.skillIcon = self.___ex.skillIcon
    self.normalName = self.___ex.normalName
    self.skillDesc = self.___ex.skillDesc
    self.close = self.___ex.close
    self.close:regOnButtonClick(function()
        self:Close()
    end)
end

function LegendSkillDetailView:InitView(skillItemModel)
    self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
    self.skillDesc.text = skillItemModel:GetDesc()
    self.normalName.text = skillItemModel:GetName()
    self.improve.text = skillItemModel:GetImproveTxt()
end

function LegendSkillDetailView:Close()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

return LegendSkillDetailView