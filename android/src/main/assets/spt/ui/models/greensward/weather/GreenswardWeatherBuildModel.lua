local AssetFinder = require("ui.common.AssetFinder")
local GreenswardWeatherModel = require("ui.models.greensward.weather.GreenswardWeatherModel")
local Model = require("ui.models.Model")

-- 玩法界面当前天气管理model
local GreenswardWeatherBuildModel = class(Model, "GreenswardWeatherBuildModel")

-- @param id [string]: 当前生效天气的id
function GreenswardWeatherBuildModel:ctor(id)
    GreenswardWeatherBuildModel.super.ctor(self)
    self.currWeaModel = GreenswardWeatherModel.new(id)
end

-- 获得当前生效天气id
function GreenswardWeatherBuildModel:GetId()
    return self.currWeaModel:GetId()
end

-- 获得当前生效天气的名称
function GreenswardWeatherBuildModel:GetCurrWeaName()
    return self.currWeaModel:GetName()
end

-- 获得当前生效天气效果的描述
function GreenswardWeatherBuildModel:GetCurrWeaDesc()
    return self.currWeaModel:GetDesc()
end

-- 获得当前生效天气的图标资源
function GreenswardWeatherBuildModel:GetCurrWeaIconRes()
    return self.currWeaModel:GetIconRes()
end

-- 获得当前生效天气影响的技能id数组
function GreenswardWeatherBuildModel:GetSkillAffect()
    return self.currWeaModel:GetSkillAffect()
end

-- 获得天气影响的技能等级减少的参数，10级
function GreenswardWeatherBuildModel:GetSkillAffectLvl()
    return self.currWeaModel:GetSkillAffectLvl()
end

-- 切换天气
function GreenswardWeatherBuildModel:ChangeWeather(nextWeaId)
    self.currWeaModel = GreenswardWeatherModel.new(nextWeaId)
end

return GreenswardWeatherBuildModel
