local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local LeadIntoAidModel = require("ui.models.store.LeadIntoAidModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")

local PlayerLeadIntoAidCtrl = class(nil, "PlayerLeadIntoAidCtrl")

function PlayerLeadIntoAidCtrl:ctor(view, content)
    self:Init(content)
end

function PlayerLeadIntoAidCtrl:Init(content)
    local object, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/LeadIntoAid.prefab")
    object.transform:SetParent(content, false)
    self.view = spt
    self.view.clickCard = function(cid) self:OnClickCard(cid) end
    self.view.clickBuy = function(index) self:OnClickBuy(index) end
    self.view.clickRefresh = function() self:OnClickRefresh() end
    self.view.clickTip = function () self:OnBtnTip() end
end

function PlayerLeadIntoAidCtrl:OnClickCard(cid) 
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
    self.cacheScrollPos = self.view.scrollView:getScrollNormalizedPos()
end

function PlayerLeadIntoAidCtrl:OnBtnTip()
    DialogManager.ShowAlertAlignmentPop(lang.trans("instruction"), lang.trans("aid_content"), 3)
end

function PlayerLeadIntoAidCtrl:OnClickBuy(index) 
    local isBuy = self.leadIntoAidModel:HasCardBuy(index)
    if isBuy then return end

    local pos = index - 1
    local cards = self.leadIntoAidModel:GetAidCards()
    local cardModel = StaticCardModel.new(cards[index].cid)
    local costDiamond = "x" .. cardModel:GetMysteryPrice()
    local cardQuality =cardModel:GetCardQuality()
    local cardSpecialQuality = cardModel:GetCardQualitySpecial()
    local fixedQuality = CardHelper.GetQualityConfigFixed(cardQuality, cardSpecialQuality)
    fixedQuality = string.convertNoToQuality(fixedQuality)
    local cardName = cardModel:GetName()
    local titleText = lang.trans("buy_player")
    local contentText = lang.trans("signPlayer_tip", costDiamond, fixedQuality, cardName)

    local callback = function()
        local isOpen = self.leadIntoAidModel:IsOpen()
        if not isOpen then
            DialogManager.ShowToast(lang.trans("mystery_tip1"))
            return
        end

        CostDiamondHelper.CostDiamondNotToBuy(costDiamond, nil, function()
            clr.coroutine(function()
                local response = req.buyMystery(pos)
                if api.success(response) then
                    local data = response.val
                    if next(data) then 
                        local playerInfoModel = PlayerInfoModel.new()
                        playerInfoModel:CostDetail(data.cost)
                        CongratulationsPageCtrl.new(data.gift)
                        self.leadIntoAidModel:UpdateMystery(data.mystery)
                        self.view:InitView(self.leadIntoAidModel)
                    end
                end
            end)
        end)
    end
    self:OnMessageBox(titleText, contentText, callback) 
end

function PlayerLeadIntoAidCtrl:OnMessageBox(titleText, contentText, callback)
    local isOpen = self.leadIntoAidModel:IsOpen()
    if not isOpen then
        DialogManager.ShowToast(lang.trans("mystery_tip1"))
        return
    end
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = lang.trans("cancel")
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = function()
        callback()
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', 'overlay', true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

function PlayerLeadIntoAidCtrl:OnClickRefresh()
   local isOpen = self.leadIntoAidModel:IsOpen()
   if isOpen then 
        local cards = self.leadIntoAidModel:GetAidCards()
        if next(cards) then 
           local hasAidCount = self.leadIntoAidModel:HasAidCount()
           if hasAidCount then 
               local cost = self.leadIntoAidModel:GetRefreshCost()
               local titleText = lang.trans("transferMarket_refreshPlayer")
               local contentText = lang.trans("refresh_player_content", cost)
               local callback = function()
                   CostDiamondHelper.CostDiamondNotToBuy(cost, nil, function() 
                       clr.coroutine(function()
                           local response = req.refreshMystery()
                           if api.success(response) then
                               local data = response.val
                               local playerInfoModel = PlayerInfoModel.new()
                               playerInfoModel:CostDetail(data.cost)
                               self.leadIntoAidModel:UpdateMystery(data.mystery)
                               self.view:InitView(self.leadIntoAidModel)
                           end
                       end)
                   end)
               end
               self:OnMessageBox(titleText, contentText, callback) 
            else
                DialogManager.ShowToast(lang.trans("mystery_tip3"))
            end
        else
            DialogManager.ShowToast(lang.trans("not_sign_player"))
        end
    else
        DialogManager.ShowToast(lang.trans("mystery_tip1"))
    end
end

function PlayerLeadIntoAidCtrl:EnterScene()
    self.view:EnterScene()
end

function PlayerLeadIntoAidCtrl:InitView()
    self.view:ShowDisableArea(false)
    clr.coroutine(function()
        local response = req.mysteryInfo()
        if api.success(response) then
            local data = response.val
            self.leadIntoAidModel = LeadIntoAidModel.new()
            self.leadIntoAidModel:InitWithProtocol(data)
            self.view:InitView(self.leadIntoAidModel, self.cacheScrollPos)
            self.cacheScrollPos = nil
        end
    end)
end

function PlayerLeadIntoAidCtrl:ShowPageVisible(isShow)
    self.view:ShowPageVisible(isShow)
end

return PlayerLeadIntoAidCtrl
