local Model = require("ui.models.Model")

local AuctionRankModel = class(Model, "AuctionRankModel")

function AuctionRankModel:ctor()
end

function AuctionRankModel:InitWithProtocol(data)
    self.cacheData = data
    table.sort(self.cacheData.rankData, function(a, b)
        return a.totalMoney > b.totalMoney
    end)
    for k, v in ipairs(self.cacheData.rankData) do
        v.index = k
    end
end

function AuctionRankModel:GetMyRank()
    return self.cacheData.myRank
end

function AuctionRankModel:GetScrollData()
    return self.cacheData.rankData
end

return AuctionRankModel