local Model = require("ui.models.Model")
local EventSystem = require ("EventSystem")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local HonorStoreModel = class(Model, "CardPieceModel")
function HonorStoreModel:ctor()
    HonorStoreModel.super.ctor(self)
    self.playerPiecesMapModel = PlayerPiecesMapModel.new()
end

function HonorStoreModel:Init(data)
    self.data = data or {}
    self.honorDiamond = tostring(PlayerInfoModel.new():GetHonorDiamond())
end

function HonorStoreModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

--可能会排序
function HonorStoreModel:GetBoxList()
    local playerListArray = self.data.score or {}
    return playerListArray
end

function HonorStoreModel:GetHonorDiamondCount()
    return self.honorDiamond or 0
end

function HonorStoreModel:SetBoughtTimeWithId(boxId, num)
    local itemsData = self.data.score
    for k, v in pairs(itemsData) do
        if v.boxId == boxId then
            v.buyCount = v.buyCount + num
        end
    end
end

function HonorStoreModel:SetHonorDiamond( num)
    self.honorDiamond = num
end

return HonorStoreModel
