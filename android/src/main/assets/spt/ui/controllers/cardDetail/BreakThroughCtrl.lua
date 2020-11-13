local BreakThroughCtrl = class()

local ItemsMapModel = require("ui.models.ItemsMapModel")
local UnsavedCardModel = require("ui.models.cardDetail.UnsavedCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local CustomEvent = require("ui.common.CustomEvent")

function BreakThroughCtrl:ctor(cardDetailModel, mountPoint)
    assert(cardDetailModel and mountPoint)
    self.cardModel = cardDetailModel:GetCardModel()
    self.itemsMapModel = ItemsMapModel.new()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.breakThroughButtonState = false

    local viewObject, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/BreakThroughJp.prefab")
    viewObject.transform:SetParent(mountPoint.transform, false)
    self.breakView = viewSpt

    self:InitView()

    self.breakView.clickBreak = function()
        if self.cardModel:GetFreeAdvance() > 0 or self.itemsMapModel:GetItemNum(1) > 0 then
            clr.coroutine(function()
                local response = req.cardAdvance(self.cardModel:GetPcid())
                if api.success(response) then
                    local data = response.val
                    if data.cost then
                        self.itemsMapModel:ResetItemNum(data.cost.id, data.cost.num)
                    end
                    if data.freeAdvance then 
                        self.cardModel:SetFreeAdvance(data.freeAdvance)
                    end
                    local unsavedCardModel = UnsavedCardModel.new(data.card)
                    self.breakView:UpdateUnsavedAdvanceResult(unsavedCardModel, self.itemsMapModel)
                end
            end)
            self.breakThroughButtonState = true
        else
            self.breakThroughButtonState = false
        end
    end
    self.breakView.clickSave = function()
        clr.coroutine(function()
            local response = req.cardAdvanceConfirm(self.cardModel:GetPcid())
            if api.success(response) then
                local data = response.val
                CustomEvent.CardPotential()
                self.playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
            end
        end)
        self.breakThroughButtonState = false
    end
    self.breakView.clickCancel = function()
        self.breakThroughButtonState = false
        self:InitView()
    end
end

function BreakThroughCtrl:InitView(cardDetailModel)
    if cardDetailModel then
        self.cardModel = cardDetailModel:GetCardModel()

        if not cardDetailModel:GetCardModel():IsTrainOpen() then
            return false
        end
    end

    self.breakView.gameObject:SetActive(true)
    self.breakView:InitView(self.cardModel, self.itemsMapModel)

    return true
end

function BreakThroughCtrl:HideView()
    self.breakView.gameObject:SetActive(false)
end

function BreakThroughCtrl:HideParticle()
    self.breakView:HideParticle()
end

function BreakThroughCtrl:GetBreakThroughButtonState()
    return self.breakThroughButtonState, self.cardModel
end

function BreakThroughCtrl:SetBreakThroughButtonState(state)
    self.breakThroughButtonState = state
end

return BreakThroughCtrl
