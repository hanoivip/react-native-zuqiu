local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionWeatherChangeModel = class(BaseModel, "ItemActionWeatherChangeModel")

local paramsKey = {
    from = "from", -- 变换前天气
    to = "to", -- 变换后天气
}

-- 参数值
local paramsVar = {
    SunShine = "SunShine",
    Rain = "Rain",
    Snow = "Snow",
    Wind = "Wind",
    Fog = "Fog",
    Sand = "Sand",
    Heat = "Heat",
    All = "All", -- 不规定天气的种类
    Random = "Random" -- 随机一个天气
}

-- 绿茵征途使用道具，使用天气卡行为model
function ItemActionWeatherChangeModel:Init(id, greenswardItemModel, greenswardBuildModel)
    ItemActionWeatherChangeModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
end

-- 解析配置参数
function ItemActionWeatherChangeModel:ParseConfig(config)
    local actionParam = config.actionParam
    if not actionParam then return config end

    self.from = actionParam.from
    self.to = actionParam.to
    return config
end

-- 获得当前道具行为的加工后参数
function ItemActionWeatherChangeModel:GetActionCookedParam()
    return self.from, self.to
end

return ItemActionWeatherChangeModel
