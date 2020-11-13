local BuildingBase = require("data.BuildingBase")
local Model = require("ui.models.Model")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local MySceneModel = class(Model)

function MySceneModel:ctor()
    MySceneModel.super.ctor(self)
end

function MySceneModel:Init()
    self:Get()
end

function MySceneModel:InitWithProtocol(data)
    if self.data == nil then
        self.data = {}
    end
    self.data.data = data or {}
    self:Save()
end

function MySceneModel:InitData()
    self.data.staticData = {}
    local staticData = self.data.staticData
    staticData.weather = require("ui.models.myscene.MySceneListModel").new(lang.trans("myscene_weather"), FeatureSkillEnum.WeatherCategoryType)
    staticData.grass = require("ui.models.myscene.MySceneListModel").new(lang.trans("myscene_grass"), FeatureSkillEnum.GrassCategoryType)
    staticData.home = require("ui.models.myscene.MySceneListModel").new(lang.trans("myscene_homeaway"), FeatureSkillEnum.TeamCategoryType)
    self:SetSelect()
end

function MySceneModel:SetSelect()
    local data = self.data.data
    local staticData = self:GetStaticData()
    staticData.weather:SetSelect(data.weather)
    staticData.grass:SetSelect(data.grass)
    staticData.home:SetSelect(data.home)
end

function MySceneModel:Save()
    cache.SetMySceneInfo(self.data)
end

function MySceneModel:Get()
    self.data = cache.GetMySceneInfo()
end

function MySceneModel:GetStaticData()
    if not self.data.staticData then
        self:InitData()
    end
    return self.data.staticData
end

function MySceneModel:GetData()
    return self.data.data
end

function MySceneModel:GetWeather()
    return self.data.data.weather or "SunShine"
end

function MySceneModel:GetHome()
    return self.data.data.home or "home"
end

function MySceneModel:IsHome()
    return self.data.data.home == FeatureSkillEnum.DefaultTeam
end

function MySceneModel:GetStartersCategory()
    return "all"
end

function MySceneModel:GetGrass()
    return self.data.data.grass or "Common"
end

return MySceneModel
