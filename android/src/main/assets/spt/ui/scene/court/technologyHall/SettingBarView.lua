local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local SettingBarView = class(unity.base)

function SettingBarView:ctor()
    self.title = self.___ex.title
    self.grassIconName = self.___ex.grassIconName
    self.grassLvlObj = self.___ex.grassLvlObj
    self.grassLvl = self.___ex.grassLvl
    self.grassButton = self.___ex.grassButton
    self.grassIcon = self.___ex.grassIcon
    self.grassDefaultArea = self.___ex.grassDefaultArea
    self.grassDescArea = self.___ex.grassDescArea
    self.grassReduceAttr = self.___ex.grassReduceAttr
    self.grassReduceNum = self.___ex.grassReduceNum

    self.weatherIconName = self.___ex.weatherIconName
    self.weatherLvlObj = self.___ex.weatherLvlObj
    self.weatherLvl = self.___ex.weatherLvl
    self.weatherButton = self.___ex.weatherButton
    self.weatherIcon = self.___ex.weatherIcon
    self.weatherDefaultArea = self.___ex.weatherDefaultArea
    self.weatherDescArea = self.___ex.weatherDescArea
    self.weatherSkillArea = self.___ex.weatherSkillArea
    self.weatherReduceNum = self.___ex.weatherReduceNum
    self.skillMap = {}
end

function SettingBarView:start()
    self.grassButton:regOnButtonClick(function()
        self:OnBtnGrass()
    end)
    self.weatherButton:regOnButtonClick(function()
        self:OnBtnWeather()
    end)
end

function SettingBarView:OnBtnGrass()
    if self.clickGrass then 
        self.clickGrass(self.settingType)
    end
end

function SettingBarView:OnBtnWeather()
    if self.clickWeather then 
        self.clickWeather(self.settingType)
    end
end

function SettingBarView:InitView(technologySetting, courtBuildModel)
    self.settingType = technologySetting.SettingType
    self.title.text = lang.trans(technologySetting.SettingName)
    -- 草皮
    local grassType = courtBuildModel:GetDevelopSetAndLvl(self.settingType, TechnologyDevelopType.GrassType)
    local isDefaultGrass = tobool(grassType == CourtBuildType.GrassBuild)
    GameObjectHelper.FastSetActive(self.grassDefaultArea, isDefaultGrass)
    GameObjectHelper.FastSetActive(self.grassDescArea, not isDefaultGrass)
    GameObjectHelper.FastSetActive(self.grassLvlObj, not isDefaultGrass)

    local grassLvl = courtBuildModel:GetBuildLevel(grassType)
    self.grassIconName.text = courtBuildModel:GetBuildShowName(grassType)
    self.grassLvl.text = "Lv" .. grassLvl
    self.grassIcon.overrideSprite = CourtAssetFinder.GetTechnologyIcon(grassType)
    self.grassIcon:SetNativeSize()
    if not isDefaultGrass then 
        local isEffectSkill, effect, point = courtBuildModel:GetEffect(grassType, grassLvl)
        local textStr = ''
        for i, attr in ipairs(effect) do
            local symbol = ''
            if i < #effect then 
                symbol = '、'
            end
            textStr = textStr .. lang.transstr(attr) .. symbol
        end
        self.grassReduceAttr.text = textStr
        self.grassReduceNum.text = lang.trans("reduce_point", point)
    end

    -- 天气
    local weatherType = courtBuildModel:GetDevelopSetAndLvl(self.settingType, TechnologyDevelopType.WeatherType)
    local isDefaultWeather = tobool(weatherType == CourtBuildType.SunShineBuild)
    GameObjectHelper.FastSetActive(self.weatherDefaultArea, isDefaultWeather)
    GameObjectHelper.FastSetActive(self.weatherDescArea, not isDefaultWeather)
    GameObjectHelper.FastSetActive(self.weatherLvlObj, not isDefaultWeather)
    local weatherLvl = courtBuildModel:GetBuildLevel(weatherType)
    self.weatherIconName.text = courtBuildModel:GetBuildShowName(weatherType)
    self.weatherLvl.text = "Lv" .. weatherLvl
    self.weatherIcon.overrideSprite = CourtAssetFinder.GetTechnologyIcon(weatherType)
    self.weatherIcon:SetNativeSize()
    if not isDefaultWeather then 
        for i, v in ipairs(self.skillMap) do
            GameObjectHelper.FastSetActive(v.gameObject, false)
        end
        
        local isEffectSkill, effect, point = courtBuildModel:GetEffect(weatherType, weatherLvl)
        for i, sid in ipairs(effect) do
            if not self.skillMap[i] then 
                local obj = Object.Instantiate(self:GetEffetSkillRes())
                obj.transform:SetParent(self.weatherSkillArea, false)
                local spt = res.GetLuaScript(obj)
                self.skillMap[i] = spt
            end
            self.skillMap[i]:InitView(sid)
            GameObjectHelper.FastSetActive(self.skillMap[i].gameObject, true)
        end
        self.weatherReduceNum.text = lang.trans("reduce_num", point)
    end
end

function SettingBarView:GetEffetSkillRes()
    if not self.skillRes then 
        self.skillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/EffectSkill.prefab")
    end

    return self.skillRes
end

return SettingBarView
