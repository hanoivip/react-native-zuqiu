local BaseCtrl = require("ui.controllers.BaseCtrl")
local AuctionRankModel = require("ui.models.auction.rank.AuctionRankModel")

local AuctionRankCtrl = class(BaseCtrl, "AuctionRankCtrl")

AuctionRankCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Auction/Rank/prefabs/AuctionRank.prefab"

AuctionRankCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AuctionRankCtrl:ctor()
    AuctionRankCtrl.super.ctor(self)
end

function AuctionRankCtrl:Init(id, subeID)
end

function AuctionRankCtrl:Refresh(id, subID)
    AuctionRankCtrl.super.Refresh(self)
    clr.coroutine(function()
        local response = req.auctionRank(id, subID)
        if api.success(response) then
            local data = response.val
            if not self.model then
                self.model = AuctionRankModel.new()
            end
            self.model:InitWithProtocol(data)
            self.view:InitView(self.model)
        end
    end)
end

return AuctionRankCtrl