local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local CardPieceBoxView = require("ui.common.part.CardPieceBoxView")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardTraningCardPieceView = class(CardPieceBoxView)

function CardTraningCardPieceView:ctor()
    self.countTxt = self.___ex.countTxt
    self.pic = self.___ex.pic
    self.plus = self.___ex.plus
    CardTraningCardPieceView.super.ctor(self)
end

function CardTraningCardPieceView:InitViewWithTrainingModel(cardPieceModel, isShowName, isShowAddNum, isShowDetail, cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    self:InitView(cardPieceModel, isShowName, isShowAddNum, isShowDetail)

    local isUniversalPiece = self.cardPieceModel:IsUniversalPiece()
    local isPasterPiece = self.cardPieceModel:IsPasterPiece()
    local id = cardPieceModel:GetId()
    self.id = id

    local needCount = 0
    local allCount = 0
    self.playerPiecesMapModel = PlayerPiecesMapModel.new()
    self.pasterPiecesMapModel = PasterPiecesMapModel.new()
    local hadCount = self.cardPieceModel:GetAddNum() or 0
    if isUniversalPiece then
        needCount = self.cardTrainingMainModel:GetNeedItemMaxCountByTypeAndId("cardPiece", id)
        allCount = self.playerPiecesMapModel:GetPieceNum(id)
    elseif isPasterPiece then
        needCount = self.cardTrainingMainModel:GetNeedItemMaxCountByTypeAndId("pasterPiece", id)
        allCount = self.pasterPiecesMapModel:GetPieceNum(id)
    else
        assert(nil, "This is the cardPiece, should not have it")
    end

    self.needCount = needCount
    self.countTxt.text = string.formatIntWithTenThousands(allCount) .. "-" .. string.formatIntWithTenThousands(needCount)

    if hadCount < needCount then
        for k, v in pairs(self.pic) do
            v.color = Color(0, 1, 1, 1)
        end
    else
        for k, v in pairs(self.pic) do
            v.color = Color(1, 1, 1, 1)
        end
        self.countTxt.text = "<color=#d7ff01>" .. string.formatIntWithTenThousands(hadCount) .. "-" .. string.formatIntWithTenThousands(needCount) .. "</color>"
    end
    GameObjectHelper.FastSetActive(self.plus, allCount >= needCount and hadCount < needCount)
end

function CardTraningCardPieceView:OnCardPieceBoxClick()
    local pcid = self.cardTrainingMainModel:GetPcid()
    local trainId = self.cardTrainingMainModel:GetCurrLevelSelected()
    local subId = self.cardTrainingMainModel:GetSubIdByLevel(trainId)
    local contents = {}
    
    -- 万能碎片
    local isUniversalPiece = self.cardPieceModel:IsUniversalPiece()
    local isPasterPiece = self.cardPieceModel:IsPasterPiece()

    if isUniversalPiece then
        contents.generalPiece = self.needCount
    elseif isPasterPiece then
        contents.pasterPiece = {}
        contents.pasterPiece[self.id] = self.needCount
    else
        assert(nil, "This is the cardPiece, should not have it")
    end

    self:coroutine(function ()
        local response = req.cardTrainingDemand(pcid, trainId, subId, contents)
        if api.success(response) then
            local data = response.val
            if data.cost then
                if isUniversalPiece then
                    self.playerPiecesMapModel:AddPieceNum(data.cost.id, -data.cost.num)
                    if data.cost.id and self.playerPiecesMapModel:GetPieceNum(data.cost.id) < 1 then
                        self.playerPiecesMapModel:RemovePieceData(data.cost.id)
                    end
                elseif isPasterPiece then
                    self.pasterPiecesMapModel:AddPieceNum(data.cost.pasterPiece[1]["type"], -data.cost.pasterPiece[1].reduce)
                    if data.cost.pasterPiece[1]["type"] and self.pasterPiecesMapModel:GetPieceNum(data.cost.pasterPiece[1]["type"]) < 1 then
                        self.pasterPiecesMapModel:RemovePieceData(data.cost.pasterPiece[1]["type"])
                    end
                end
            end
            EventSystem.SendEvent("CardTraining_RefreshMainView")
        end
    end)
end

return CardTraningCardPieceView