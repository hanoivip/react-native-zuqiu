local BaseCtrl = require("ui.controllers.BaseCtrl")
local AuctionIntroModel = require("ui.models.auction.intro.AuctionIntroModel")

local AuctionIntroCtrl = class(BaseCtrl, "AuctionIntroCtrl")

AuctionIntroCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Auction/Intro/Prefabs/AuctionIntro.prefab"

AuctionIntroCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AuctionIntroCtrl:ctor()
    AuctionIntroCtrl.super.ctor(self)
end

function AuctionIntroCtrl:Init()
end

function AuctionIntroCtrl:Refresh()
    AuctionIntroCtrl.super.Refresh(self)
    self.model = AuctionIntroModel.new()
    self.view:InitView(self.model)
end

return AuctionIntroCtrl