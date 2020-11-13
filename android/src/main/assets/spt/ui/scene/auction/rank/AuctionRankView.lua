local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")

local AuctionRankView = class(unity.base, "AuctionRankView")

function AuctionRankView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    self.scrollView = self.___ex.scrollView
    self.txtMyRank = self.___ex.txtMyRank
end

function AuctionRankView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function AuctionRankView:InitView(auctionRankModel)
    self.model = auctionRankModel
    local myRank = self.model:GetMyRank()
    if myRank == AuctionMainConstants.AuctionRank_NotOnList then
        self.txtMyRank.text = lang.trans("train_rankOut")
    else
        self.txtMyRank.text = tostring(myRank)
    end
    self.scrollView:InitView(self.model:GetScrollData())
end

function AuctionRankView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return AuctionRankView