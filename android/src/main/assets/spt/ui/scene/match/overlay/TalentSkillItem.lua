local UnityEngine = clr.UnityEngine
local Sprite = UnityEngine.Sprite
local Color = UnityEngine.Color

local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local BuffNeedShowZeroSkillID = require("ui.scene.match.overlay.BuffNeedShowZeroSkillID")

local Green = Color(144.0 / 255, 243.0 / 255, 38.0 / 255)
local Red = Color(1, 42.0 / 255, 78.0 / 255)

local TalentSkillItem = class(unity.base)

function TalentSkillItem:ctor()
    self.imageBg = self.___ex.imageBg
    self.imageSkill = self.___ex.imageSkill
end

function TalentSkillItem:init(talentSkillData)
    if not talentSkillData then
        return
    end
    local bgName = talentSkillData.picBackGround
    local skillName = talentSkillData.picIcon
    self.imageBg.overrideSprite = AssetFinder.GetCoachFeatureDecorateIcon(bgName)
    self.imageSkill.overrideSprite = AssetFinder.GetCoachFeatureSkillIcon(skillName)
end

return TalentSkillItem
