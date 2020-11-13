local CustomEvent = require("ui.common.CustomEvent")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local AscendPageCtrl = class(nil, "AscendPageCtrl")

local ConsumeCardUpgradeLimit = {0, 4, 5, 6, 7, -1}

function AscendPageCtrl:ctor(view, content)
    self:Init(content)
end

function AscendPageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function AscendPageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function AscendPageCtrl:Init(content)
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.legendCardsMapModel = LegendCardsMapModel.new()
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/AscendPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickAddCard = function()
        res.PushDialog("ui.controllers.cardDetail.RebornPlayerChooseCtrl", self.upgradeLimit, self.cardModel:GetPcid(), self.cardDetailModel:IsAllowChangeScene(), self.targetPcid)
    end
    self.pageView.clickAscend = function()
        if not self.targetPcid then return end

        clr.coroutine(function()
            local respone = req.cardAscend(self.cardModel:GetPcid(), self.targetPcid)
            if api.success(respone) then
                local data = respone.val
                CustomEvent.CardReincarnation()
                local oldCardModel = self.cardModel
                self.playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
                self.playerCardsMapModel:RemoveCardData({data.delCard})
                self.targetPcid = nil
                local newCardModel = self.cardDetailModel:GetCardModel()
                if newCardModel:IsOpenLegendRoad() then
                    self.legendCardsMapModel:SetLegendAscend(data.card.pcid, true)
                    self.legendCardsMapModel:BuildTeamLegendInfo(newCardModel:GetTeamModel(), newCardModel:GetCardsMapModel())
                    EventSystem.SendEvent("PlayerCardsMapModel_ResetCardModel", data.card.pcid)
                end
                self.pageView:ShowAscendEffect(newCardModel)
            end
        end)
    end
    self.pageView.confirmChooseCardCallBack = function(pcid)
        self:SetChoosePlayer(pcid)
    end
    self.pageView.onBtnLegendRoadClick = function()
        self:OnBtnLegendRoadClick()
    end
end

function AscendPageCtrl:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.cardModel = cardDetailModel:GetCardModel()
    self.upgradeLimit = ConsumeCardUpgradeLimit[self.cardModel:GetAscend() + 1]
    self.pageView:InitView(cardDetailModel)
    self.pageView:SetUpgradeLimit(self.upgradeLimit)
    self.targetPcid = nil
end

function AscendPageCtrl:SetChoosePlayer(pcid)
    assert(pcid)
    self.targetPcid = pcid
    self.pageView:SetChoosePlayer(PlayerCardModel.new(pcid))
end

function AscendPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

function AscendPageCtrl:OnBtnLegendRoadClick()
    if self.cardModel:IsOperable() then
        res.PushScene("ui.controllers.legendRoad.LegendRoadCtrl", self.cardModel, true)
    end
end

return AscendPageCtrl
