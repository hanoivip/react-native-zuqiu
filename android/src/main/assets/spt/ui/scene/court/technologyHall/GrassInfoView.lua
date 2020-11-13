local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local GrassInfoView = class(unity.base)

function GrassInfoView:ctor()
    self.icon = self.___ex.icon
    self.lvlObj = self.___ex.lvlObj
    self.lvlText = self.___ex.lvlText
    self.useText = self.___ex.useText
    self.effectText = self.___ex.effectText
    self.reduceText = self.___ex.reduceText
    self.reduceObj = self.___ex.reduceObj
end

function GrassInfoView:InitView(settingType, courtBuildModel, isMyHomeCourt)
    local grassType, grassLvl = courtBuildModel:GetDevelopSetAndLvl(settingType, TechnologyDevelopType.GrassType)
    local isDefaultGrass = tobool(grassType == CourtBuildType.GrassBuild)
    GameObjectHelper.FastSetActive(self.lvlObj, not isDefaultGrass)
    GameObjectHelper.FastSetActive(self.reduceObj, not isDefaultGrass)

    local name = courtBuildModel:GetBuildShowName(grassType)
    
    self.lvlText.text = "Lv" .. grassLvl
    self.icon.overrideSprite = CourtAssetFinder.GetTechnologyIcon(grassType)
    self.icon:SetNativeSize()
    if not isDefaultGrass then 
        local isEffectSkill, effect, point = courtBuildModel:GetEffect(grassType, grassLvl)
        local textStr = ""
        for i, attr in ipairs(effect) do
            local symbol = ""
            if i < #effect then 
                symbol = "、"
            end
            textStr = textStr .. lang.transstr(attr) .. symbol
        end
        local effectText = isMyHomeCourt and lang.trans("match_effect_desc_grass2", textStr) or lang.trans("match_effect_desc_grass1", textStr)
        self.effectText.text = effectText
        self.reduceText.text = lang.trans("reduce_point", point)
        self.useText.text = name .. lang.transstr("reduce_num", grassLvl)
    else
        self.effectText.text = lang.trans("no_effect") 
        self.useText.text = name
    end
end

return GrassInfoView
