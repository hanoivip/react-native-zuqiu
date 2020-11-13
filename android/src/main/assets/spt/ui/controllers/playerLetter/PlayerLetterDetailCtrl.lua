local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local FormationType = require("ui.common.enum.FormationType")
local PlayerLetterModel = require("ui.models.playerLetter.PlayerLetterModel")
local PlayerLetterDetailViewModel = require("ui.models.playerLetter.PlayerLetterDetailViewModel")
local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerLetterDetailCtrl = class(BaseCtrl)
PlayerLetterDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerLetterDetail.prefab"

function PlayerLetterDetailCtrl:ctor()
    EventSystem.SendEvent("PlayerLetter.OpenLetterDetail")
end

function PlayerLetterDetailCtrl:Refresh(letterID, playerLetterDetailViewModel)
    self.letterID = letterID
    self.playerLetterDetailViewModel = playerLetterDetailViewModel or PlayerLetterDetailViewModel.new()
    self:RegisterEvent()
    if self.waitToShowDialog then
        self.view.gameObject:SetActive(false)
        clr.coroutine(function ()
            coroutine.yield(clr.UnityEngine.WaitForSeconds(0.1))
            self.view.gameObject:SetActive(true)
        end)
    end
    self:RefreshView()
end

function PlayerLetterDetailCtrl:RequestData()
    local readState = self.playerLetterItemModel:GetReadState()
    if readState == PlayerLetterConstants.LetterReadState.UNREAD then
        clr.coroutine(function()
            local letterID = self.playerLetterItemModel:GetID()
            local response = req.playerLetterRead(letterID)
            if api.success(response) then
                EventSystem.SendEvent("PlayerLetter.ReadLetter", letterID)
            end
        end)
    end
end

function PlayerLetterDetailCtrl:RefreshView()
    local playerLetterModel = PlayerLetterModel.new()
    self.playerLetterItemModel = playerLetterModel:GetLetterItemModelByID(self.letterID)
    self.playerLetterItemModel:SetShow()
    self.playerLetterDetailViewModel:SetModel(self.playerLetterItemModel)
    self:RequestData()
    EventSystem.SendEvent("PlayerLetterDetail.InitView", self.playerLetterDetailViewModel)
    local loadType = self:GetLoadType()
    if loadType ~= res.LoadType.Pop or self.view:StateIsNotAward() then
        self.view:PlayMoveInAnim()
    end
    EventSystem.SendEvent("PlayerLetterDetail.OnEnterView")
end

function PlayerLetterDetailCtrl:RegisterEvent()
    EventSystem.AddEvent("PlayerLetterDetail.ShowCardDetail", self, self.ShowCardDetail)
    EventSystem.AddEvent("PlayerLetterDetail.Refresh", self, self.RefreshView)
end

function PlayerLetterDetailCtrl:RemoveEvent()
    EventSystem.RemoveEvent("PlayerLetterDetail.ShowCardDetail", self, self.ShowCardDetail)
    EventSystem.RemoveEvent("PlayerLetterDetail.Refresh", self, self.RefreshView)
end

--- 显示大卡
function PlayerLetterDetailCtrl:ShowCardDetail(cardStaticID)
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local isOwnCard = playerCardsMapModel:IsExistCardID(cardStaticID)
    local currentModel
    if isOwnCard then
        local pcId = playerCardsMapModel:GetPcidByCid(cardStaticID)
        currentModel = CardBuilder.GetOwnCardModel(pcId)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {pcId}, 1, currentModel)
    else
        currentModel = CardBuilder.GetBaseCardModel(cardStaticID)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cardStaticID}, 1, currentModel)
    end
end

function PlayerLetterDetailCtrl:GetStatusData()
    return self.letterID, self.playerLetterDetailViewModel
end

function PlayerLetterDetailCtrl:OnExitScene()
    EventSystem.SendEvent("PlayerLetterDetail.OnExitView")
    self:RemoveEvent()
    self.waitToShowDialog = true
    EventSystem.SendEvent("PlayerLetterDetail.OnOneExit")
end

return PlayerLetterDetailCtrl
