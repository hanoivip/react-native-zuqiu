local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local DialogManager = require("ui.control.manager.DialogManager")
local ItemsMapModel = require("ui.models.ItemsMapModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalAttributeBreakCtrl = class(BaseCtrl)
MedalAttributeBreakCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalAttributeBreak.prefab"
MedalAttributeBreakCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalAttributeBreakCtrl:Init()
    self.view.clickEvent = function() self:ClickEvent() end
    self.view.clickConfirm = function(medalSingleModel) self:ClickConfirm(medalSingleModel) end
end

function MedalAttributeBreakCtrl:ClickEvent()
    EventSystem.SendEvent("ShowMedalPage")
end

function MedalAttributeBreakCtrl:ClickConfirm(medalSingleModel)
    local itemsMapModel = ItemsMapModel.new()
    local medalTicket = 15
    local medalTicketCount = itemsMapModel:GetItemNum(medalTicket)
    local needItemNum = medalSingleModel:GetAttributeBreakConsume()
    local playerInfoModel = PlayerInfoModel.new()
    local _, AttrValue = next(medalSingleModel:GetExAttr())
    if tonumber(AttrValue) >= tonumber(medalSingleModel:GetBreakTroughMaxPercent()) then 
        DialogManager.ShowToast(lang.trans("breakThrough_max_tip"))
        return 
    end

    local confirmMedal = function()
        clr.coroutine(function()
            local pmid = medalSingleModel:GetPmid()
            local respone = req.medalBoostUp(pmid)
            if api.success(respone) then
                local data = respone.val
                local contents = data.contents or {}
                local newMedalModel = nil
                if contents.card and next(contents.card) then 
                    local playerCardsMapModel = PlayerCardsMapModel.new()
                    playerCardsMapModel:ResetCardData(contents.card.pcid, contents.card)
    
                    local pos = medalSingleModel:GetPos()
                    local playerCardModel = SimpleCardModel.new(contents.card.pcid)
                    playerCardModel:InitMedalModel()
                    newMedalModel = playerCardModel:GetPosMedalModel(pos)
                    -- 已装备的勋章，重置medalMap缓存
                    local newMedalCacheData
                    for k, medalData in pairs(contents.card.medals) do
                        if medalData.pmid == pmid then
                            newMedalCacheData = medalData
                            break
                        end
                    end
                    local playerMedalsMapModel = PlayerMedalsMapModel.new()
                    playerMedalsMapModel:ResetMedalData(pmid, newMedalCacheData)
                elseif contents.medal and next(contents.medal) then 
                    local playerMedalsMapModel = PlayerMedalsMapModel.new()
                    playerMedalsMapModel:ResetMedalData(contents.medal.pmid, contents.medal)
                    newMedalModel = playerMedalsMapModel:GetSingleMedalModel(contents.medal.pmid)
                end
                if data.cost and next(data.cost) then
                    itemsMapModel:UpdateFromReward(data.cost)
                end
                self.view:Close()
                res.PushDialog("ui.controllers.medal.MedalBreakThroughBoardCtrl", newMedalModel, medalSingleModel)
            end
        end)
    end
    local buyMedalTicket = function()
         res.PushScene("ui.controllers.store.StoreCtrl", "item")
    end
    if medalTicketCount > 0 then
        confirmMedal()
    else
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("medalTicketCuponNotEnoughAndBuy"), function() buyMedalTicket() end)
    end
end

function MedalAttributeBreakCtrl:Refresh(medalSingleModel, playerInfoModel)
    self.medalSingleModel = medalSingleModel
    self.playerInfoModel = playerInfoModel
    MedalAttributeBreakCtrl.super.Refresh(self)
    self.view:InitView(medalSingleModel, playerInfoModel)
end

function MedalAttributeBreakCtrl:OnBtnUpgrade()
    self.view:DisablePage()
end

function MedalAttributeBreakCtrl:OnBtnBenedictionUpgrade()
    self.view:DisablePage()
end

function MedalAttributeBreakCtrl:OnBtnBenedictionReplace()
    self.view:DisablePage()
end

function MedalAttributeBreakCtrl:GetStatusData()
    return self.medalSingleModel, self.playerInfoModel
end

return MedalAttributeBreakCtrl
