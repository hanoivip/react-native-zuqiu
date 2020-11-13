local AssetFinder = require("ui.common.AssetFinder")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardPiece = require("data.CardPiece")
local Card = require("data.Card")
local Model = require("ui.models.Model")
local CardPieceModel = class(Model, "CardPieceModel")

function CardPieceModel:ctor()
    CardPieceModel.super.ctor(self)
    self.isPlayerPiece = false
end

function CardPieceModel:InitWithCache(cache)
    self.cacheData = cache
    self.cid = self.cacheData.cid
    self:AllotPieceData()
end

function CardPieceModel:InitWithStatic(id, num)
    local newData = {cid = id, add = num}
    self:InitWithCache(newData)
end

function CardPieceModel:AllotPieceData()
    if CardPiece[self.cid] then
        self.staticData = CardPiece[self.cid]
    elseif Card[self.cid] then 
        self.staticData = Card[self.cid]
        self.isPlayerPiece = true
    else
        self.staticData = {}
    end
end

function CardPieceModel:GetId()
    return self.cid
end

function CardPieceModel:GetData()
    return self.cacheData
end

function CardPieceModel:GetAddNum()
    return self.cacheData.add or 1
end

function CardPieceModel:GetNum()
    return self.cacheData.num or 1
end

local GeneralPieceType = 1
local RedGeneralPieceType = 2
local YearGeneralPieceType = 3
local LegendGeneralPieceType = 4
local LegendPieceType = 5
local CoachIntelligencePieceType = 6
function CardPieceModel:IsUniversalPiece()
    return tobool(tonumber(self.staticData.type) == GeneralPieceType) or
            tobool(tonumber(self.staticData.type) == RedGeneralPieceType) or
            tobool(tonumber(self.staticData.type) == YearGeneralPieceType) or
            tobool(tonumber(self.staticData.type) == LegendGeneralPieceType)
end

--是否为传奇碎片
function CardPieceModel:IsLegendPiece()
    return tobool(tonumber(self.staticData.type) == LegendPieceType)
end

--是否为教练情报碎片
function CardPieceModel:IsCoachIntelligencePiece()
    return tobool(tonumber(self.staticData.type) == CoachIntelligencePieceType)
end

--是否为球员碎片
function CardPieceModel:IsPlayerPiece()
    return tobool(self.isPlayerPiece)
end

function CardPieceModel:GetName()
    local isUniversalPiece = self:IsUniversalPiece()
    local isCoachIntelligencePiece = self:IsCoachIntelligencePiece()
    if isUniversalPiece then 
        return lang.transstr("universal_piece")
    elseif isCoachIntelligencePiece then
        return self.staticData.name
    else
        return self.staticData.name2
    end
end

function CardPieceModel:GetPieceIndex()
    return self.staticData.picIndex
end

function CardPieceModel:GetPiecePath()
    local picIndex = self:GetPieceIndex()
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/" .. picIndex .. ".png"
    return path
end

function CardPieceModel:GetOriginName()
    return self.staticData.name
end

function CardPieceModel:GetPieceName()
    local isUniversalPiece = self:IsUniversalPiece()
    if isUniversalPiece then 
        return lang.transstr("universal_piece") 
    else
		local pieceName = self.staticData.name2 .. lang.transstr("piece")
        return pieceName
    end
end

-- 万能碎片品质以最大计算
local UniversalQualitySort = 100
local LegendQualitySort = 90
local CoachIntelligenceQualitySort = 80
function CardPieceModel:GetQuality()
    local isUniversalPiece = self:IsUniversalPiece()
    local isLegendPiece = self:IsLegendPiece()
    local isCoachIntelligencePiece = self:IsCoachIntelligencePiece()
    if isUniversalPiece then
        return UniversalQualitySort
    elseif isLegendPiece then
        return LegendQualitySort
    elseif isCoachIntelligencePiece then
        return CoachIntelligenceQualitySort
    else
        return self.staticData.quality
    end
end

function CardPieceModel:GetQualitySpecial()
    return self.staticData.qualitySpecial or 0
end

function CardPieceModel:IsPlusCard()
    local isUniversalPiece = self:IsUniversalPiece()
    if isUniversalPiece then 
        return false
    else
        return tobool(self:GetQualitySpecial() == 1)
    end
end

-- 是否是周年纪念卡
function CardPieceModel:IsAnnualCard()
    local isUniversalPiece = self:IsUniversalPiece()
    if isUniversalPiece then 
        return false
    else
        return tobool(self:GetQualitySpecial() == 2)
    end
end

-- 是否传奇卡
function CardPieceModel:IsLegendCard()
    local isUniversalPiece = self:IsUniversalPiece()
    if isUniversalPiece then 
        return false
    else
        return tobool(self:GetQualitySpecial() == 3)
    end
end

function CardPieceModel:GetQualityName()
    local QualityKey = 0
    local isUniversalPiece = self:IsUniversalPiece()
    if isUniversalPiece then 
        QualityKey = -1
    else
        local quality = self:GetQuality()
        local qualitySpecial = self.staticData.qualitySpecial or 0
        local isPlus = tobool(qualitySpecial == 1)
        if isPlus then 
            QualityKey = quality .. "plus"
        else
            QualityKey = quality
        end
    end
    local QualityTypeName = "pieceTypeName_" .. QualityKey
    return lang.trans(QualityTypeName)
end

function CardPieceModel:GetComposeNeedPiece()
    local isCoachIntelligencePiece = self:IsCoachIntelligencePiece()
    local isPlayerPiece = self:IsPlayerPiece()
    if isPlayerPiece then
        return tonumber(self.staticData.cardPiece)
    elseif isCoachIntelligencePiece then
        return tonumber(self.staticData.composeAoumt)
    end
end

function CardPieceModel:GetAvatar()
    local isUniversalPiece = self:IsUniversalPiece()
    if not isUniversalPiece then 
        return self.staticData.pictureID
    end
end

function CardPieceModel:GetFixQuality()
    local quality = self:GetQuality()
    local fixQuality = CardHelper.GetQualityFixed(quality, self:GetQualitySpecial())
    return fixQuality
end

function CardPieceModel:GetStaticDesc()
    local isPlayerPiece = self:IsPlayerPiece()
    if isPlayerPiece then
        local composeNum = self:GetComposeNeedPiece()
        local fixQuality = self:GetFixQuality()
        local qualitySign = CardHelper.GetQualitySign(fixQuality)
        local name = self:GetName()
        -- 越南版描述要求添加空格
        local nameStr = qualitySign .. lang.transstr("itemList_quality") .. name
        if luaevt.trig("__VN__VERSION__")then
            nameStr = qualitySign .. " " .. lang.transstr("itemList_quality") .. " " .. name
        end
        return lang.trans("collect_player_piece", composeNum, nameStr) or ""
    else
        return self.staticData.desc or ""
    end
end

--hk有好几种合约 但是国服只有一个 通用
function CardPieceModel:GetDesc()
    return self.staticData.desc or ""
end

function CardPieceModel:GetContentText()
    local isPlayerPiece = self:IsPlayerPiece()
    local isUniversalPiece = self:IsUniversalPiece()
    local isCoachIntelligencePiece = self:IsCoachIntelligencePiece()
    if isUniversalPiece then
        return lang.trans("use")
    elseif isCoachIntelligencePiece then
        return lang.trans("composite")
    elseif isPlayerPiece then
        return lang.trans("composite")
    else
        return ""
    end
end

function CardPieceModel:GetTypeName()
    local isLegendPiece = self:IsLegendPiece()
    local isUniversalPiece = self:IsUniversalPiece()
    local isCoachIntelligencePiece = self:IsCoachIntelligencePiece()
    if isUniversalPiece then
        return lang.trans("piece")
    elseif isLegendPiece then
        return lang.trans("piece")
    elseif isCoachIntelligencePiece then
        return lang.trans("piece")
    else
        return ""
    end
end

function CardPieceModel:GetPieceBg(quality)
    local isUniversalPiece = self:IsUniversalPiece()
    local isCoachIntelligencePiece = self:IsCoachIntelligencePiece()
    local pieceBox = "Normal_Quality"
    if isUniversalPiece or isCoachIntelligencePiece then
        pieceBox = "Universal_Quality"
    elseif quality == "7" or quality == "7_Legend" or quality == "6_SL" or quality == "8" then
        pieceBox = "Piece_Quality_" .. quality
    end
    return pieceBox
end

function CardPieceModel:IsUniversalShow()
    local isUniversalPiece = self:IsUniversalPiece()
    local isCoachIntelligencePiece = self:IsCoachIntelligencePiece()
    if isUniversalPiece or isCoachIntelligencePiece then
        return true
    else
        return false
    end
end

function CardPieceModel:IsShowButton()
    local isLegendPiece = self:IsLegendPiece()
    if isLegendPiece then
        return false
    else
        return true
    end
end

function CardPieceModel:IsPasterPiece()
    return false
end

return CardPieceModel