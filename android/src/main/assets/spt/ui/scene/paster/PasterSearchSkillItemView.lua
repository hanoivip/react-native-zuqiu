local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local LuaButton = require("ui.control.button.LuaButton")

local PasterSearchSkillItemView = class(LuaButton, "LuaButton")

function PasterSearchSkillItemView:ctor()
    PasterSearchSkillItemView.super.ctor(self)
--------Start_Auto_Generate--------
    self.skillIconImg = self.___ex.skillIconImg
    self.nameTxt = self.___ex.nameTxt
--------End_Auto_Generate----------
end

function PasterSearchSkillItemView:InitView(skillData)
    self.skillIconImg.overrideSprite = AssetFinder.GetSkillIcon(skillData.picIndex)
    self.nameTxt.text = tostring(skillData.name)
end

return PasterSearchSkillItemView
