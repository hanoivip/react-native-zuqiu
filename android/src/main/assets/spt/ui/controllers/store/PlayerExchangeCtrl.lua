local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local ExchangeModel = require("ui.models.store.ExchangeModel")

local PlayerExchangeCtrl = class(nil, "PlayerExchangeCtrl")

function PlayerExchangeCtrl:ctor(view, content)
    self:Init(content)
end

function PlayerExchangeCtrl:Init(content)
    local object, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/Exchange.prefab")
    object.transform:SetParent(content, false)
    self.view = spt
    self.view.clickTarget = function(targetPcid) self:OnClickTarget(targetPcid) end
    self.view.clickExchangePlayer1 = function(targetPcid, exchangePlayerPcid, otherExchangePcid) self:OnClickExchangePlayer(targetPcid, exchangePlayerPcid, otherExchangePcid, 1) end
    self.view.clickExchangePlayer2 = function(targetPcid, exchangePlayerPcid, otherExchangePcid) self:OnClickExchangePlayer(targetPcid, exchangePlayerPcid, otherExchangePcid, 2) end
    self.view.clickExchange = function(targetPcid, exchangePlayerPcid1, exchangePlayerPcid2) self:OnClickExchange(targetPcid, exchangePlayerPcid1, exchangePlayerPcid2) end
end

function PlayerExchangeCtrl:EnterScene()
    self.view:EnterScene()
end

function PlayerExchangeCtrl:OnClickTarget(targetPcid)
    res.PushDialog("ui.controllers.store.TargetPlayerChooseCtrl", targetPcid)
end

function PlayerExchangeCtrl:OnClickExchangePlayer(targetPcid, exchangePlayerPcid, otherExchangePcid, slot)
    if targetPcid then 
        res.PushDialog("ui.controllers.store.ExchangePlayerChooseCtrl", targetPcid, exchangePlayerPcid, otherExchangePcid, slot)
    else
        DialogManager.ShowToast(lang.trans("select_target_player2"))
    end
end

function PlayerExchangeCtrl:OnClickExchange(targetPcid, exchangePlayerPcid, otherExchangePcid)
   local isOpen = self.exchangeModel:IsOpen()
   if isOpen then
       local canExchange = self.exchangeModel:CanExchange(targetPcid)
       if not canExchange then
           local itemName = self.exchangeModel:GetNeedExchangeItemName()
           DialogManager.ShowToast(lang.trans("lack_item_tips", itemName))
           return
       end
       local hasExchangeCount = self.exchangeModel:HasExchangeCount()
       if hasExchangeCount then
           local playerCardsMapModel = PlayerCardsMapModel.new()
           local targetCid = playerCardsMapModel:GetCardData(targetPcid).cid
           local exchangePlayerCid = playerCardsMapModel:GetCardData(exchangePlayerPcid).cid
           local otherExchangeCid = playerCardsMapModel:GetCardData(otherExchangePcid).cid
           if targetCid == exchangePlayerCid or targetCid == otherExchangeCid then 
               DialogManager.ShowToast(lang.trans("mystery_tip4"))
           else
               clr.coroutine(function()
                    local response = req.cardExchange(targetPcid, exchangePlayerPcid, otherExchangePcid)
                    if api.success(response) then
                        local data = response.val
                        if next(data) then 
                            local pcids = data.delPcids
                            playerCardsMapModel:RemoveCardData(pcids)
                            CongratulationsPageCtrl.new(data.gift)
                            local cn = data.e_cnt or 0
                            local cost = data.cost or {}
                            self.exchangeModel:SetBeExchangedCount(cn)
                            self.exchangeModel:SetBeExchangedCost(cost)
                            self.view:InitView(self.exchangeModel)
                        end
                    end
               end)
           end
        else
            DialogManager.ShowToast(lang.trans("mystery_tip2"))
       end
    else
        DialogManager.ShowToast(lang.trans("mystery_tip1"))
    end
end

function PlayerExchangeCtrl:InitView()
   clr.coroutine(function()
        local response = req.cardExchangeInfo()
        if api.success(response) then
            local data = response.val
            self.exchangeModel = ExchangeModel.new()
            self.exchangeModel:InitWithProtocol(data)
            self.view:InitView(self.exchangeModel)
        end
    end)
end

function PlayerExchangeCtrl:ShowPageVisible(isShow)
    self.view:ShowPageVisible(isShow)
end

return PlayerExchangeCtrl
