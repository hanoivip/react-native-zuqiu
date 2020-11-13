local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local CardMoreInfoLetterItemView = class(unity.base)


function CardMoreInfoLetterItemView:ctor()
    self.contentRect = self.___ex.contentRect
    self.slider = self.___ex.slider
    self.cardArea = self.___ex.cardArea
    self.progress = self.___ex.progress
end

function CardMoreInfoLetterItemView:InitView(letterPlayerData)
    self.isFinish = letterPlayerData.isFinish
    self:BuildContentCard(letterPlayerData.letterPlayer)
    self:BuildRewardCard(letterPlayerData.rewardPlayer)
end

function CardMoreInfoLetterItemView:BuildRewardCard(rewardCid)
    local playerCardStaticModel = StaticCardModel.new(rewardCid)
    local card = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    card.transform:SetParent(self.cardArea, false)
    local script = card:GetComponent(clr.CapsUnityLuaBehav)
    script:InitView(playerCardStaticModel)
end

function CardMoreInfoLetterItemView:BuildContentCard(cardList)
    local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerConditionItem.prefab")
    res.ClearChildren(self.contentRect)
    local playerNum = 0
    local finishNum = 0
    for k, cardId in pairs(cardList) do
        playerNum = playerNum + 1
        local viewObj = Object.Instantiate(obj)
        viewObj.transform:SetParent(self.contentRect, false)
        local script = viewObj:GetComponent(clr.CapsUnityLuaBehav)
        local conditionData = {}
        conditionData.id = cardId
        local isFinished = self.isFinish and self.isFinish[cardId]
        if isFinished then
            finishNum = finishNum + 1
        end
        conditionData.isFinished = isFinished
        script:InitView(conditionData)
    end

    self.slider.maxValue = playerNum
    self.slider.value = finishNum
    self.progress.text = finishNum .. "/" .. playerNum
end

return CardMoreInfoLetterItemView
