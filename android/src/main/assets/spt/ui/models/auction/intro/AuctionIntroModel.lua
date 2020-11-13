local Model = require("ui.models.Model")

local AuctionIntroModel = class(Model, "AuctionIntroModel")

function AuctionIntroModel:ctor()
end

function AuctionIntroModel:GetIntro()
    return lang.trans("auction_intro")
end

return AuctionIntroModel