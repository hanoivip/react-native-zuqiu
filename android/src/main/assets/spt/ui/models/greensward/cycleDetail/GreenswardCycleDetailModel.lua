local GreenswardWeatherBuildModel = require("ui.models.greensward.weather.GreenswardWeatherBuildModel")
local GreenswardStarBuildModel = require("ui.models.greensward.star.GreenswardStarBuildModel")
local Skills = require("data.Skills")
local AdventureBase = require("data.AdventureBase")
local Model = require("ui.models.Model")

local GreenswardCycleDetailModel = class(Model, "GreenswardCycleDetailModel")

function GreenswardCycleDetailModel:ctor()
    GreenswardCycleDetailModel.super.ctor(self)
    self.starModels = nil
end

function GreenswardCycleDetailModel:InitWithProtocol(base, weaBuildModel, starBuildModel)
    self.base = base
    if self.base then
        self.weaBuildModel = weaBuildModel ~= nil and weaBuildModel or GreenswardWeatherBuildModel.new(self.base.wea)
        self.starBuildModel = starBuildModel ~= nil and starBuildModel or GreenswardStarBuildModel.new(self.base.star)
    end
end

-- 获得当前周期
function GreenswardCycleDetailModel:GetCurrCycle()
    return self.base.cycle
end

-- 获得当前回合
function GreenswardCycleDetailModel:GetCurrRound()
    return self.base.round
end

-- 获得当前剩余回合
function GreenswardCycleDetailModel:GetCurrLeftRound()
    return AdventureBase["1"].cycleRound - self:GetCurrRound() + 1
end

---------------------------
-- 天气                  --
---------------------------

-- 获得当前生效天气的buildModel
function GreenswardCycleDetailModel:GetCurrWeaBuildModel()
    return self.weaBuildModel
end

-- 获得当前生效天气的Icon资源
function GreenswardCycleDetailModel:GetCurrWeaIconRes()
    return self.weaBuildModel:GetCurrWeaIconRes()
end

-- 获得当前生效天气的名称
function GreenswardCycleDetailModel:GetCurrWeaName()
    return self.weaBuildModel:GetCurrWeaName()
end

-- 获得当前生效天气影响的技能id数组
function GreenswardCycleDetailModel:GetSkillAffect()
    return self.weaBuildModel:GetSkillAffect()
end

-- 获得天气影响的技能等级减少的参数，10级
function GreenswardCycleDetailModel:GetSkillAffectLvl()
    return self.weaBuildModel:GetSkillAffectLvl()
end

-- 获得当前生效天气影响的技能配置数组
function GreenswardCycleDetailModel:GetSkillAffectDatas()
    local result = nil
    local skillIds = self:GetSkillAffect()
    if type(skillIds) == "table" then
        result = {}
        for k, id in ipairs(skillIds) do
            local config = Skills[tostring(id)]
            if config then
                table.insert(result, config)
            end
        end
    end
    return result
end

---------------------------
-- 星象                  --
---------------------------

-- 获得当前生效星象的buildModel
function GreenswardCycleDetailModel:GetCurrStarBuildModel()
    return self.starBuildModel
end

-- 获得当前生效星象的Icon
function GreenswardCycleDetailModel:GetCurrStarIconIndex()
    return self.starBuildModel:GetCurrStarIconIndex()
end

-- 获得当前生效星象的名称
function GreenswardCycleDetailModel:GetCurrStarName()
    return self.starBuildModel:GetCurrStarName()
end

-- 获得当前生效星象效果的描述
function GreenswardCycleDetailModel:GetCurrStarDesc()
    return self.starBuildModel:GetCurrStarDesc()
end

return GreenswardCycleDetailModel
