local AssetFinder = require("ui.common.AssetFinder")
local AdventureStarEffect = require("data.AdventureStarEffect")
local Model = require("ui.models.Model")

-- 星象的对应model
-- 可利用InitWithId构造静态的、无效果的星象
-- 可利用InitWithProtocol构造动态、生效的星象
local GreenswardStarModel = class(Model, "GreenswardStarModel")

function GreenswardStarModel:ctor(id)
    GreenswardStarModel.super.ctor(self)
    self.id = nil -- 星象id，string
    self.staticData = nil -- 静态配置

    if id ~= nil then
        self:InitWithId(id)
    end
end

-- 利用id初始化静态数据
function GreenswardStarModel:InitWithId(id)
    self.id = tostring(id)
    self.staticData = self:ParseConfig(AdventureStarEffect[self.id] or {})
end

-- 利用服务器数据初始化一个动态的、有效果的星象
function GreenswardStarModel:InitWithProtocol(cacheData)
    self.cacheData = self:ParseCache(cacheData or {})
end

function GreenswardStarModel:ParseConfig(config)
    if table.isEmpty(config) then return nil end
    return config
end

function GreenswardStarModel:ParseCache(cacheData)
    if table.isEmpty(cacheData) then return nil end

    return cacheData
end

-- 获得静态配置数据
function GreenswardStarModel:GetConfig()
    return self.staticData
end

-- 获得星象id
function GreenswardStarModel:GetId()
    return self.id
end

-- 获得星象名字
function GreenswardStarModel:GetName()
    return self.staticData.name
end

-- 获得星象的描述
function GreenswardStarModel:GetDesc()
    if self.staticData.param ~= nil then
        local param = self.staticData.param / 10
        local paramAbs = tostring(math.abs(param)) -- 正负已经包含在描述中了  不需要正负号
        return string.gsub(self.staticData.desc, "{[%d]+}", tostring(paramAbs))
    else
        return self.staticData.desc
    end
end

-- 获得星象的图标
function GreenswardStarModel:GetIconIndex()
    return self.staticData.iconIndex
end

-- 获得效果类型
function GreenswardStarModel:GetType()
    return self.staticData.type
end

-- 获得效果参数
function GreenswardStarModel:GetParam()
    return self.staticData.param
end

-- 获得星象影响哪个事件(用于影响怪物属性的效果)
function GreenswardStarModel:GetEffectEvent()
    return self.staticData.effectEvent
end

-- 该事件是否受本星象效果影响
function GreenswardStarModel:CheckHasEffect(eventId)
    eventId = tostring(eventId)
    local hasEffect = false
    local effectEvent = self:GetEffectEvent()
    if type(effectEvent) == "table" and not table.isEmpty(effectEvent) then
        for i, configId in ipairs(effectEvent) do
            if eventId == tostring(configId) then
                hasEffect = true
                break
            end
        end
    end
    return hasEffect
end

return GreenswardStarModel
