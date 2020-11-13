local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local PasterPieceFrameView = class(unity.base)

function PasterPieceFrameView:ctor()
    self.pasterCard = self.___ex.pasterCard
    self.btnPaster = self.___ex.btnPaster
    self.btnBuy = self.___ex.btnBuy
    self.pieceImage = self.___ex.pieceImage
    self.cost = self.___ex.cost
    self.symbol = self.___ex.symbol
end

function PasterPieceFrameView:start()
    self.btnPaster:regOnButtonClick(function()
        if type(self.clickPaster) == "function" then
            self.clickPaster(self.pasterModel)
        end
    end)
    self.btnBuy:regOnButtonClick(function()
        if type(self.clickBuy) == "function" then
            self.clickBuy(self.pasterModel)
        end
    end)
    EventSystem.AddEvent("PasterPieceExchange", self, self.PasterPieceExchange)
end

function PasterPieceFrameView:onDestroy()
    EventSystem.RemoveEvent("PasterPieceExchange", self, self.PasterPieceExchange)
end

function PasterPieceFrameView:PasterPieceExchange(selectPasterId)
    if tostring(selectPasterId) == self.pasterModel:GetPasterId() then 
        GameObjectHelper.FastSetActive(self.symbol, true)
    end
end

function PasterPieceFrameView:InitView(pasterModel, index, cardResourceCache, pasterRes, cardPastersMapModel)
    -- paster
    self.index = index
    self.pasterModel = pasterModel
    self.pasterCard:InitView(pasterModel, cardResourceCache, pasterRes)
    self.cost.text = "x" .. pasterModel:GetComposePieceNeed()
    local pasterType = pasterModel:GetPasterType()
    self.pieceImage.overrideSprite = AssetFinder.GetPasterPiece(pasterType)
    local hasSamePaster = cardPastersMapModel:HasSamePaster(pasterModel)
    GameObjectHelper.FastSetActive(self.symbol, hasSamePaster)
end

return PasterPieceFrameView
