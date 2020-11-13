local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local PlayerAvatarBoxView = require("ui.common.part.PlayerAvatarBoxView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local CardTrainingPlayerAvatorBoxView = class(PlayerAvatarBoxView)

function CardTrainingPlayerAvatorBoxView:ctor()
    self.pic = self.___ex.pic
    self.plus = self.___ex.plus
    CardTrainingPlayerAvatorBoxView.super.ctor(self)
end

function CardTrainingPlayerAvatorBoxView:InitViewWithCount(cardId, num, isShowDetail, isHideLvl, cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    self.cardId = cardId
    self:InitView(cardId, num, isShowDetail, isHideLvl)

    local isFinishCardConsume = self.cardTrainingMainModel:GetIsFinishCardConsume()
    if not isFinishCardConsume then
        for k, v in pairs(self.pic) do
            v.color = Color(0, 1, 1, 1)
        end
    else
        for k, v in pairs(self.pic) do
            v.color = Color(1, 1, 1, 1)
        end
    end
    local  plusFlag = not isFinishCardConsume
    if plusFlag then
        plusFlag = false
        local playerCardsMapModel = PlayerCardsMapModel.new()
        local pcidList = playerCardsMapModel:GetSameCardList(self.cardTrainingMainModel:GetCid())
        for k,v in pairs(pcidList) do
            local cData = playerCardsMapModel:GetCardData(k)
            if (not cData.lock or tonumber(cData.lock) == 0) and tonumber(k) ~= tonumber(self.cardTrainingMainModel:GetPcid()) then
                plusFlag = true
                break
            end
        end
    end
    GameObjectHelper.FastSetActive(self.plus, plusFlag)
end

function CardTrainingPlayerAvatorBoxView:ShowCardDetail()
    res.PushDialog("ui.controllers.cardTraining.CardTrainingPlayerListCtrl", self.cardTrainingMainModel)
end

return CardTrainingPlayerAvatorBoxView