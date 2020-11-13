local AssetFinder = require("ui.common.AssetFinder")
local MenuBarView = class(unity.base)

function MenuBarView:ctor()
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
    self.desc = self.___ex.desc
end

function MenuBarView:InitView(data)
    self.nameTxt.text = data.skillName
    self.icon.overrideSprite = AssetFinder.GetSkillIcon(data.picIndex)
    self.desc.text = data.desc
end

return MenuBarView
