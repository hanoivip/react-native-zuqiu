local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local PlayerGenericModel = class(Model)

function PlayerGenericModel:ctor(data)
    PlayerGenericModel.super.ctor(self)
end

function PlayerGenericModel:Init(data)
    if not data then
        data = cache.getPlayerGenericData()
    end
    self.data = data
end

-- cardBagExtend 球员扩展容量
-- leagueDiff 联赛等级
function PlayerGenericModel:InitWithProtocol(cardBagExtend, leagueDiff)
    local data = {}
    data.cardBagExtend = cardBagExtend
    data.leagueDiff = leagueDiff
    cache.setPlayerGenericData(data)
    self:Init(data)
end

function PlayerGenericModel:GetPlayerCapacity()
    return self.data.cardBagExtend or 0
end

function PlayerGenericModel:GetLeagueDiff()
    return self.data.leagueDiff or 0
end

function PlayerGenericModel:GetGenericData()
    return self.data
end

-- 球员扩展容量
function PlayerGenericModel:AddPlayerCapacity(addBagExtend)
    self.data.cardBagExtend = tonumber(self.data.cardBagExtend) + tonumber(addBagExtend)
    EventSystem.SendEvent("PlayerCapacity_Change", self.data.cardBagExtend)
end

-- 在礼包中购买的球员扩展容量包
function PlayerGenericModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if rewardTable.bagLimit and tonumber(rewardTable.bagLimit) > 0 then
        self:AddPlayerCapacity(tonumber(rewardTable.bagLimit))
    end
end

return PlayerGenericModel
