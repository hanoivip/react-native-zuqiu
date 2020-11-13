local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = class(CardPieceModel, "CardPasterPieceModel")

function CardPasterPieceModel:ctor()
    CardPasterPieceModel.super.ctor(self)
    self.staticData = {}
end

function CardPasterPieceModel:InitWithCache(cache)
    self.cacheData = cache
    self.type = self.cacheData.type
end

function CardPasterPieceModel:GetId()
    return tostring(self.type)
end

function CardPasterPieceModel:IsPasterPiece()
    return true
end

function CardPasterPieceModel:GetQuality()
    return 1
end

function CardPasterPieceModel:InitWithStatic(id, num)
    local newData = {type = id, add = num}
    self:InitWithCache(newData)
end

function CardPasterPieceModel:GetName()
    if tonumber(self.type) == 1 then
        return lang.transstr("paster_piece_week")
    elseif tonumber(self.type) == 2 then
        return lang.transstr("paster_piece_month")
    elseif tonumber(self.type) == 3 then
        return lang.transstr("paster_piece_honor")
    elseif tonumber(self.type) == 4 then
        return lang.transstr("paster_piece_compete")
    elseif tonumber(self.type) == 5 then
        return lang.transstr("paster_piece_annual")
    end
end

function CardPasterPieceModel:GetTypeName()
    if tonumber(self.type) == 1 then
        return lang.transstr("paster_piece_simple_week")
    elseif tonumber(self.type) == 2 then
        return lang.transstr("paster_piece_simple_month")
    elseif tonumber(self.type) == 3 then
        return lang.transstr("paster_piece_simple_honor")
    elseif tonumber(self.type) == 4 then
        return lang.transstr("paster_piece_simple_compete")
    elseif tonumber(self.type) == 5 then
        return lang.transstr("paster_piece_simple_annual")
    end
end

function CardPasterPieceModel:IsUniversalPiece()
    return false
end

function CardPasterPieceModel:GetStaticDesc()
    local id = self:GetId()
    return lang.trans("paster_piece_instruction" .. id) or ""
end

function CardPasterPieceModel:GetContentText()
    return lang.trans("use")
end

function CardPasterPieceModel:IsUniversalShow()
    return true
end

function CardPasterPieceModel:GetPieceBg(quality)
    return "Universal_Quality"
end

function CardPasterPieceModel:GetPiecePath()
    local id = self:GetId()
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Piece" .. id .. ".png"
    return path
end

return CardPasterPieceModel