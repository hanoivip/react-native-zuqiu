local ItemModel = require("ui.models.ItemModel")
local MailRewardType = require("ui.scene.mail.MailRewardType")
local AdventureItem = require("data.AdventureItem")

local GreenswardItemModel = class(ItemModel, "GreenswardItemModel")

function GreenswardItemModel:ctor(id, num)
    GreenswardItemModel.super.ctor(self)

    self.cacheData = nil -- 从奖励初始化的数据
    self.staticData = nil -- 配置的静态数据
    self.id = id
    self.ownNum = nil -- 拥有数量

    if id then
        self:InitWithId(id)
    end

    if num then
        self:SetOwnNum(num)
    end
end

function GreenswardItemModel:InitWithStaticId(staticId)
    self:InitWithId(id)
end

function GreenswardItemModel:InitWithCache(cache)
    self:InitWithReward(cache)
end

function GreenswardItemModel:InitWithId(id)
    self.id = tostring(id)
    self:ParseConfig(self:GetStaticConfigById(id))
end

function GreenswardItemModel:InitWithReward(reward)
    self:InitWithId(reward.id)
    self:ParseReward(reward)
end

function GreenswardItemModel:ParseReward(reward)
    self.cacheData = reward
    self.ownNum = reward.num
end

function GreenswardItemModel:ParseConfig(config)
    self.staticData = config
end

function GreenswardItemModel:SetOwnNum(num)
    self.ownNum = num
end

function GreenswardItemModel:GetOwnNum()
    if not self.ownNum then
        if not self.greenswardItemMapModel then
            self.greenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel").new()
        end
        self.ownNum = self.greenswardItemMapModel:GetItemNum(self:GetId())
    end
    return self.ownNum
end

function GreenswardItemModel:GetItemNum()
    return self:GetOwnNum()
end

-- 获得物品的静态配置
function GreenswardItemModel:GetStaticConfigById(id)
    return AdventureItem[tostring(id)]
end

-- 获得缓存数据
function GreenswardItemModel:GetCacheData()
    return self.cacheData
end

-- 获得配置数据
function GreenswardItemModel:GetStaticData()
    return self.staticData
end

function GreenswardItemModel:GetId()
    return self.id
end

function GreenswardItemModel:GetID()
    return self:GetId()
end


-- 获得物品数量
function GreenswardItemModel:GetSum()
    return self:GetOwnNum()
end

-- 获得得到的数量，从reward初始化才有此值，否则返回总数
function GreenswardItemModel:GetAddNum()
    if self.cacheData and self.cacheData.add then
        return self.cacheData.add
    else
        return self:GetSum()
    end
end

-- 获得减少的数量，从reward初始化才有次值
function GreenswardItemModel:GetReduceNum()
    if self.cacheData and self.cacheData.reduce then
        return self.cacheData.reduce
    else
        return 0
    end
end

-- 获得名字
function GreenswardItemModel:GetName()
    return self.staticData.name
end

-- 获得图标
function GreenswardItemModel:GetPicIndex()
    return self.staticData.picIndex
end

function GreenswardItemModel:GetIconIndex()
    return self:GetPicIndex()
end

-- 获得描述
function GreenswardItemModel:GetDesc()
    return self.staticData.desc
end

-- 获得品质
function GreenswardItemModel:GetQuality()
    return self.staticData.quality
end

-- 获得行为id
function GreenswardItemModel:GetActionId()
    return self.staticData.actionId
end

-- 获得物品在背包中位置，参考GreenswardItemType
function GreenswardItemModel:GetItemType()
    return self.staticData.itemType
end

-- 获得使用方式分类，参考GreenswardItemUseType
function GreenswardItemModel:GetUseType()
    return self.staticData.useType
end

-- 获得物品子类型
function GreenswardItemModel:GetSubType()
    return self.staticData.subType
end

-- 获得道具类型，主要服务器使用，客户端用来辅助判断
function GreenswardItemModel:GetItemClass()
    return self.staticData.itemClass
end

-- 获得使用条件分类，参考GreenswardItemUseConType
function GreenswardItemModel:GetUseConditionType()
    return self.staticData.useConditionType
end

-- 获得使用条件具体值
function GreenswardItemModel:GetUseCondition()
    return self.staticData.useCondition
end

-- 使用条件是否满足
function GreenswardItemModel:CanUseCondifionFill(cVal)
    local conditions = self:GetUseCondition()
    for k, v in ipairs(conditions) do
        if tonumber(cVal) == tonumber(v) then
            return true
        end
    end
    return false
end

-- 获得使用条件的提示
function GreenswardItemModel:GetUseConditionTip()
    return self.staticData.useConditionTip
end

-- 获得使用后物品状态，参考GreenswardItemUseAfterType
function GreenswardItemModel:GetAfterUseType()
    return self.staticData.afterUseType
end

-- 获得使用后物品的描述
function GreenswardItemModel:GetUsedDesc()
    return self.staticData.usedDesc
end

-- 获得来源类型
-- 详见GreenswardAccessType
function GreenswardItemModel:GetAccessType()
    return self.staticData.accessAdvType
end

-- 获得来源描述
-- 为了和Item表中一致，配置改为access
function GreenswardItemModel:GetAccessDesc()
    return self:GetAccess()
end

-- 获得来源链接的详细id
function GreenswardItemModel:GetAccessId()
    return self.staticData.accessAdvID
end

function GreenswardItemModel:GetRewardType()
    return MailRewardType.AdvItem
end

---------------------------
-- 背包中所需属性

-- 是否被选中
function GreenswardItemModel:GetSelected()
    return self.isSelected
end

function GreenswardItemModel:SetSelected(isSelected)
    self.isSelected = isSelected
end

-- 背包中索引
function GreenswardItemModel:GetIdx()
    return self.idx
end

function GreenswardItemModel:SetIdx(idx)
    self.idx = idx
end

function GreenswardItemModel:GetDialogPath()
    return "ui.controllers.itemList.AdventureItemDetailCtrl"
end

return GreenswardItemModel
