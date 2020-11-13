local EventSystem = require("EventSystem")
local Model = require("ui.models.Model")

local Item = require("data.Item")
local RedPacket = require("data.RedPacket")
local CommonConstants = require("ui.common.CommonConstants")

local ItemModel = class(Model, "ItemModel")

function ItemModel:ctor()
    ItemModel.super.ctor(self)
end

function ItemModel:InitWithCache(cache)
    self.cacheData = cache
    assert(Item[tostring(self.cacheData.id)], "ID:(" .. self.cacheData.id .. ") not in Item table ... ")
    self.staticData = Item[tostring(self.cacheData.id)] or {}
end

function ItemModel:InitWithStaticId(staticId)
    assert(Item[tostring(staticId)], "ID:(" .. staticId .. ") not in Item table ... ")
    self.staticData = Item[tostring(staticId)] or {}
end

-- 红包
function ItemModel:InitWithRedPacket(cache)
    self.cacheData = {
        id = cache.id,
        add = cache.add or cache.num 
    }
    self.staticData = RedPacket[tostring(cache.id)] or {}
end

--- 使用钻石的增加数目进行初始化
function ItemModel:InitWithDiamondAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.DiamondItemId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--- 使用欧元的增加数目进行初始化
function ItemModel:InitWithMoneyAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.MoneyItemId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用梦幻币的增加数目进行初始化
function ItemModel:InitWithDreamCoinAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.DreamCoinId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用梦幻碎片的增加数目进行初始化
function ItemModel:InitWithDreamPieceAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.DreamPieceId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用巅峰币的增加数目进行初始化
function ItemModel:InitWithPeakPointAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.PeakPointId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用争霸币的增加数目进行初始化
function ItemModel:InitWithWtcAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.WtcId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用殿堂精华的增加数目进行初始化
function ItemModel:InitWithSmdAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.SmdId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用殿堂升阶证书的增加数目进行初始化
function ItemModel:InitWithSmbAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.SmbId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--- 使用吉祥物亲密度的增加数目进行初始化
function ItemModel:InitWithJxwAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.JxwId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用执教经验书的增加数目进行初始化
function ItemModel:InitWithCeAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.CeId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用教练天赋券的增加数目进行初始化
function ItemModel:InitWithCtpAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.CtpId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用助理教练经验书的增加数目进行初始化
function ItemModel:InitWithAceAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.AceId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用[绿茵征途]士气的增加数目进行初始化
function ItemModel:InitWithMoraleAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.MoraleId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 使用[绿茵征途]斗志的增加数目进行初始化
function ItemModel:InitWithFightAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.FightId,
        add = addNum
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--- 使用体力的增加数目进行初始化
function ItemModel:InitWithStrengthAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.StrengthItemId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--- 使用经验的增加数目进行初始化
function ItemModel:InitWithExpAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.ExpItemId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--- 使用卡牌上限的增加数目进行初始化
function ItemModel:InitWithBagLimitAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.BagLimitItemId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--- 使用友情点的增加数目进行初始化
function ItemModel:InitWithFriendship(addNum)
    self.cacheData = {
        id = CommonConstants.FriendshipId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

function ItemModel:InitWithCsp(addNum)
    self.cacheData = {
        id = CommonConstants.CspId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

function ItemModel:InitWithEnvelope(id)
    self.cacheData = {
        id = id,
        add = -1,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 阶梯商店购物券
function ItemModel:InitWithStageStoreTicket(sstData)
    local tData = clone(sstData)
    tData.add = tData.add or tData.num
    self.cacheData = tData
    self.staticData = Item[tostring(self.cacheData.id)]
end

--- 使用天梯荣誉的增加数目进行初始化
function ItemModel:InitWithLadderHonorAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.LadderHonorId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 星辰
function ItemModel:InitWithStardustAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.StardustId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

-- 祝福
function ItemModel:InitWithBenedictionAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.BenedictionId,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--球魂
function ItemModel:InitWithFsAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.FS,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

--梦幻卡碎片
function ItemModel:InitWithFancyPieceAddNum(addNum)
    self.cacheData = {
        id = CommonConstants.FancyPiece,
        add = addNum,
    }
    self.staticData = Item[tostring(self.cacheData.id)]
end

function ItemModel:GetID()
    return self.cacheData.id
end

function ItemModel:GetSum()
    return self.cacheData.num
end

function ItemModel:GetAddNum()
    return self.cacheData.add
end

function ItemModel:GetName()
    return self.staticData.name
end

function ItemModel:GetQuality()
    return self.staticData.quality or 0
end

function ItemModel:GetIconIndex()
    return self.staticData.picIndex
end

function ItemModel:GetDesc()
    return self.staticData.desc
end

function ItemModel:CanBeUsed()
    if self.staticData.usage == 0 then
        return false
    else
        return true
    end
end

function ItemModel:CanBeSaled()
    if self.staticData.sale == 0 then
        return false
    else
        return true
    end
end

function ItemModel:GetPrice()
    return self.staticData.price
end

-- 批量使用时最大数量限制
function ItemModel:GetUseMaxCount()
    return self.staticData.useMaxCount or 0
end

return ItemModel
