local AssetFinder = require("ui.common.AssetFinder")
local GreenswardStarModel = require("ui.models.greensward.star.GreenswardStarModel")
local Model = require("ui.models.Model")

-- 玩法界面当前星象管理model
local GreenswardStarBuildModel = class(Model, "GreenswardStarBuildModel")

-- @param id [string]: 当前生效星象的id
function GreenswardStarBuildModel:ctor(id)
    GreenswardStarBuildModel.super.ctor(self)
    self.currStarModel = GreenswardStarModel.new(id)
end

-- 获得当前生效星象id
function GreenswardStarBuildModel:GetId()
    return self.currStarModel:GetId()
end

-- 获得当前生效星象的名称
function GreenswardStarBuildModel:GetCurrStarName()
    return self.currStarModel:GetName()
end

-- 获得当前生效星象效果的描述
function GreenswardStarBuildModel:GetCurrStarDesc()
    return self.currStarModel:GetDesc()
end

-- 获得当前生效星象的图标
function GreenswardStarBuildModel:GetCurrStarIconIndex()
    return self.currStarModel:GetIconIndex()
end

-- 切换星象
function GreenswardStarBuildModel:ChangeStar(nextStarId)
    self.currStarModel = GreenswardStarModel.new(nextStarId)
end

return GreenswardStarBuildModel
