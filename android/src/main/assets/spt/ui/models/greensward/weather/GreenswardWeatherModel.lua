local WeatherType = require("ui.scene.court.technologyHall.WeatherType")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local BuildingBase = require("data.BuildingBase")
local Model = require("ui.models.Model")

local GreenswardWeatherModel = class(Model, "GreenswardWeatherModel")

-- 天气的对应model
-- 可利用InitWithId构造静态的、无效果的天气
-- 可利用InitWithProtocol构造动态、生效的天气
function GreenswardWeatherModel:ctor(id)
    GreenswardWeatherModel.super.ctor(self)
    self.id = nil -- 天气id，string
    self.staticData = nil -- 静态配置

    if id ~= nil then
        self:InitWithId(id)
    end
end

-- 利用id初始化静态数据
function GreenswardWeatherModel:InitWithId(id)
    self.id = tostring(id)
    self.staticData = self:ParseConfig(BuildingBase[self.id] or {})
end

-- 利用服务器数据初始化一个动态的、有效果的天气
function GreenswardWeatherModel:InitWithProtocol(cacheData)
    self.cacheData = self:ParseCache(cacheData or {})
end

function GreenswardWeatherModel:ParseConfig(config)
    if table.isEmpty(config) then return nil end

    return config
end

function GreenswardWeatherModel:ParseCache(cacheData)
    if table.isEmpty(cacheData) then return nil end

    return cacheData
end

-- 获得静态配置数据
function GreenswardWeatherModel:GetConfig()
    return self.staticData
end

-- 获得天气id
function GreenswardWeatherModel:GetId()
    return self.id
end

-- 获得天气名字
function GreenswardWeatherModel:GetName()
    return self.staticData.name
end

-- 获得天气的描述
function GreenswardWeatherModel:GetDesc()
    return self.staticData.functionDesc
end

-- 获得天气的图标资源
function GreenswardWeatherModel:GetIconRes()
    return CourtAssetFinder.GetTechnologyFixIcon(self:GetId())
end

-- 获得天气影响的技能id数组
function GreenswardWeatherModel:GetSkillAffect()
    return self.staticData.skillAffect
end

-- 获得天气影响的技能等级减少的参数，默认10级
function GreenswardWeatherModel:GetSkillAffectLvl()
    return 10
end

return GreenswardWeatherModel
