local RebornCtrl = class()

local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local AscendBoxPopCtrl = require("ui.controllers.cardDetail.AscendBoxPopCtrl")
local CustomEvent = require("ui.common.CustomEvent")

local consumeCardUpgradeLimit = {0, 4, 5, 6, 7}

function RebornCtrl:ctor(cardDetailModel, mountPoint)
    assert(cardDetailModel and mountPoint)
    self.cardDetailModel = cardDetailModel
    self.cardModel = cardDetailModel:GetCardModel()
    self.playerCardsMapModel = PlayerCardsMapModel.new()

    local viewObject, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/RebornJp.prefab")
    viewObject.transform:SetParent(mountPoint.transform, false)
    self.rebornView = viewSpt

    self:InitView()

    self.rebornView.clickAddCard = function()
        res.PushDialog("ui.controllers.cardDetail.RebornPlayerChooseCtrl", self.upgradeLimit, self.cardModel:GetPcid(), self.cardDetailModel:IsAllowChangeScene())
    end
    self.rebornView.clickReborn = function()
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
                self:PopAscendInfoBox(oldCardModel, newCardModel)
            end
        end)
    end
    self.rebornView.confirmChooseCardCallBack = function(pcid)
        self:SetChoosePlayer(pcid)
    end
end

function RebornCtrl:PopAscendInfoBox(oldCardModel, newCardModel)
    AscendBoxPopCtrl.new(oldCardModel, newCardModel)
end

function RebornCtrl:InitView(cardDetailModel)
    if cardDetailModel then
        self.cardDetailModel = cardDetailModel
        self.cardModel = cardDetailModel:GetCardModel()

        if not cardDetailModel:GetCardModel():IsRebornOpen() then
            return false
        end
    end

    -- 已经满转
    if self.cardModel:GetAscend() >= self.cardModel:GetMaxAscendNum() then
        self.rebornView:InitView(self.cardModel, true)
    else
        self.upgradeLimit = consumeCardUpgradeLimit[self.cardModel:GetAscend() + 1]

        self.rebornView:InitView(self.cardModel)
        self.rebornView:SetUpgradeLimit(self.upgradeLimit)        
    end

    self.targetPcid = nil
    self.rebornView.gameObject:SetActive(true)

    self:OnLoadModule()

    return true
end

function RebornCtrl:HideView()
    self.rebornView.gameObject:SetActive(false)
end

function RebornCtrl:SetChoosePlayer(pcid)
    assert(pcid)
    self.targetPcid = pcid
    self.rebornView:SetChoosePlayer(PlayerCardModel.new(pcid))
end

function RebornCtrl:OnLoadModule()
    self.rebornView:LoadModule()
end

function RebornCtrl:OnUnloadModule()
    self.rebornView:UnloadModule()
end

return RebornCtrl
