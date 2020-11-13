local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local WeatherInfoView = class(unity.base)

function WeatherInfoView:ctor()
    self.icon = self.___ex.icon
    self.lvlObj = self.___ex.lvlObj
    self.lvlText = self.___ex.lvlText
    self.useText = self.___ex.useText
    self.effectText = self.___ex.effectText
    self.reduceText = self.___ex.reduceText
    self.skillArea = self.___ex.skillArea
    self.reduceObj = self.___ex.reduceObj
    self.skillMap = {}
end

function WeatherInfoView:InitView(settingType, courtBuildModel)
    local weatherType, weatherLvl = courtBuildModel:GetDevelopSetAndLvl(settingType, TechnologyDevelopType.WeatherType)
    local isDefaultWeather = tobool(weatherType == CourtBuildType.SunShineBuild)
    GameObjectHelper.FastSetActive(self.lvlObj, not isDefaultWeather)
    GameObjectHelper.FastSetActive(self.reduceObj, not isDefaultWeather)

    local name = courtBuildModel:GetBuildShowName(weatherType)
    self.lvlText.text = "Lv" .. weatherLvl
    self.icon.overrideSprite = CourtAssetFinder.GetTechnologyIcon(weatherType)
    self.icon:SetNativeSize()
    if not isDefaultWeather then 
        for i, v in ipairs(self.skillMap) do
            GameObjectHelper.FastSetActive(v.gameObject, false)
        end
        
        local isEffectSkill, effect, point = courtBuildModel:GetEffect(weatherType, weatherLvl)
        for i, sid in ipairs(effect) do
            if not self.skillMap[i] then 
                local obj = Object.Instantiate(self:GetEffetSkillRes())
                obj.transform:SetParent(self.skillArea, false)
                local spt = res.GetLuaScript(obj)
                self.skillMap[i] = spt
            end
            self.skillMap[i]:InitView(sid)
            GameObjectHelper.FastSetActive(self.skillMap[i].gameObject, true)
        end
        self.reduceText.text = lang.trans("reduce_num", point)
        self.effectText.text = lang.trans("match_effect_desc_weather")
        self.useText.text = name .. lang.transstr("reduce_num", weatherLvl)
    else
        self.effectText.text = lang.trans("no_effect") 
        self.useText.text = name
    end
end

function WeatherInfoView:GetEffetSkillRes()
    if not self.skillRes then 
        self.skillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/EffectSkill.prefab")
    end

    return self.skillRes
end

function WeatherInfoView:onDestroy()
    self.skillRes = nil
end

return WeatherInfoView
