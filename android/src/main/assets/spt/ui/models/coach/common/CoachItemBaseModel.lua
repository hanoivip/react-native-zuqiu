local Model = require("ui.models.Model")
local CommonConstants = require("ui.common.CommonConstants")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local CoachItem = require("data.CoachItem")

local CoachItemBaseModel = class(Model, "CoachItemBaseModel")

function CoachItemBaseModel:ctor()
    CoachItemBaseModel.super.ctor(self)
    self.cacheData = nil -- 从奖励初始化的数据
    self.staticData = nil -- 配置的静态数据
    self.id = nil
    self.ownNum = nil -- 拥有数量
end

function CoachItemBaseModel:InitWithId(id)
    self:InitWithConfig(self:GetStaticConfig(id))
    self.id = id
end

function CoachItemBaseModel:InitWithReward(reward)
    self.cacheData = reward
    self:InitWithConfig(self:GetStaticConfig(self.cacheData.id))
    self.id = self.cacheData.id
end

function CoachItemBaseModel:InitWithConfig(config)
    self.staticData = config
    self.id = self.staticData.id
end

-- 获得物品的静态配置
-- 根据不同的教练物品类型，require策划表后重写
function CoachItemBaseModel:GetStaticConfig(id)
    return {}
end

-- 获得缓存数据
function CoachItemBaseModel:GetCacheData()
    return self.cacheData
end

-- 获得配置数据
function CoachItemBaseModel:GetStaticData()
    return self.staticData
end

function CoachItemBaseModel:GetId()
    return self.id
end

-- 获得物品数量
function CoachItemBaseModel:GetSum()
    return self:GetOwnNum()
end

-- 获取特定描述
function CoachItemBaseModel:GetPageDesc()
    return ""
end

-- 获得得到的数量，从reward初始化才有此值，否则返回总数
function CoachItemBaseModel:GetAddNum()
    if self.cacheData and self.cacheData.add then
        return self.cacheData.add
    else
        return self:GetSum()
    end
end

-- 获得减少的数量，从reward初始化才有次值
function CoachItemBaseModel:GetReduceNum()
    if self.cacheData and self.cacheData.reduce then
        return self.cacheData.reduce
    else
        return nil
    end
end

-- 获得名字
function CoachItemBaseModel:GetName()
    return self.staticData.name
end

-- 获得图标
function CoachItemBaseModel:GetIconIndex()
    return self.staticData.picIndex
end

-- 获得描述
function CoachItemBaseModel:GetDesc()
    return self.staticData.desc
end

-- 获得品质
function CoachItemBaseModel:GetQuality()
    return self.staticData.quality
end

-- 获得教练道具类型
function CoachItemBaseModel:GetCoachItemType()
    return tonumber(CoachItem[tostring(self:GetId())].type)
end

function CoachItemBaseModel:SetOwnNum(num)
    self.ownNum = num
end

function CoachItemBaseModel:GetOwnNum()
    if not self.ownNum then
        if not self.coachItemMapModel then
            self.coachItemMapModel = require("ui.models.coach.common.CoachItemMapModel").new()
        end
        self.ownNum = self.coachItemMapModel:GetCoachItemNum(self:GetId())
    end
    return self.ownNum
end

return CoachItemBaseModel
