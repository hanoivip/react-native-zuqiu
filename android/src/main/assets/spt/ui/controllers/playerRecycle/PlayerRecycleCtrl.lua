local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerRecycleModel = require("ui.models.playerRecycle.PlayerRecycleModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local PlayerRecycleCtrl = class(BaseCtrl, "PlayerRecycleCtrl")

PlayerRecycleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerRecycle/PlayerRecycleBoard.prefab"

PlayerRecycleCtrl.CostTypeTrans = 
{
    m = "goldCoin",
    d = "diamond",
    bkd = "pasterSplit_activity_coin",
}

function PlayerRecycleCtrl:Init(playerRecycleModel)
    self.playerRecycleModel = playerRecycleModel
end

function PlayerRecycleCtrl:Refresh(playerRecycleModel)
    if playerRecycleModel then
        self.playerRecycleModel = playerRecycleModel
    end
    self.view:InitView(playerRecycleModel)
    self.view.clickRecycle = function() self:OnRecycleClick() end
    self.view.clickHelp = function() self:OnHelpClick() end
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.legendCardsMapModel = LegendCardsMapModel.new()
    self:InitInfoBar()
end

function PlayerRecycleCtrl:InitInfoBar()
    InfoBarCtrl.new(self.view.infobarView, self, false, false, true)
end

function PlayerRecycleCtrl:OnRecycleClick()
    local supporterMessage = self.playerRecycleModel:GetClosedBySupporterMessage()
    if supporterMessage then
        DialogManager.ShowToast(supporterMessage)
        return
    end
    local tag = self.playerRecycleModel:GetCurrentTag()
    if tag == "ascend" then
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("recycle_asend"), function() self:Recycle() end)
    else
        self:Recycle()
    end
end

function PlayerRecycleCtrl:Recycle()
    local pcid = self.playerRecycleModel:GetPcid()
    local costType = self.playerRecycleModel:GetCurrentCostType()
    local tag = self.playerRecycleModel:GetCurrentTag()
    local m, d, bkd = self.playerRecycleModel:GetPrice(tag)
    local nowCost = self.playerRecycleModel:GetNowCost(tag, costType) or 0
    if nowCost < 0 then
        DialogManager.ShowToastByLang("recycle_none_tips")
        return
    elseif nowCost == 0 then
        self:ShowChargeConfirmPop(costType)
        return
    end

    local confirmFunc = function()
        clr.coroutine(function()
            local respone = req.RecycleRequest(pcid, costType, tag)
            if api.success(respone) then
                local data = respone.val
                self.playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
                if tag == "ascend" then
                    self.legendCardsMapModel:SetLegendAscend(data.card.pcid, false)
                end
                local playerInfoModel = PlayerInfoModel.new()
                playerInfoModel:CostDetail(data.cost)
                local recycleTag = self.playerRecycleModel:GetRecycleTag()
                if recycleTag then
                    local cardModel = self.playerRecycleModel:GetCarModel()
                    self.legendCardsMapModel:BuildTeamLegendInfo(cardModel:GetTeamModel(), cardModel:GetCardsMapModel())
                    EventSystem.SendEvent("PlayerCardsMapModel_ResetCardModel", data.card.pcid)
                    self.playerRecycleModel:SetDefaultTag(recycleTag)
                    self.view:InitView(self.playerRecycleModel)
                else
                    self.view.closeDialog()
                end
                CongratulationsPageCtrl.new(data.contents)
            end
        end)
    end
    if pcid and costType and tag then
        local title = lang.trans("tips")
        local costTypeTrans = PlayerRecycleCtrl.CostTypeTrans[costType]
        costTypeTrans = lang.transstr(costTypeTrans)
        local nowCostStr = nowCost
        if costType == "m" then
            nowCostStr = string.formatIntWithTenThousands(nowCost)
        end
        costTypeTrans = nowCostStr .. " " .. costTypeTrans
        local lableName = self:GetLableNameRed(tag)
        lableName = lang.transstr(lableName)
        local msg = lang.trans("recycle_tips", costTypeTrans, lableName)
        DialogManager.ShowConfirmPop(title, msg, confirmFunc)
    else
        DialogManager.ShowToastByLang("please_choose")
    end
end

function PlayerRecycleCtrl:ShowChargeConfirmPop(costType)
    local tips = lang.trans("tips")
    local confirmFunc, content
    if costType == "m" then
        confirmFunc = function()
            res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM) 
        end
        content = lang.trans("goldCoinNotEnoughAndBuy")
    elseif costType == "d" then
        confirmFunc = function()
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
        end
        content = lang.trans("diamondNotEnoughAndBuy")
    elseif costType == "bkd" then
        confirmFunc = function()
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
        end
        content = lang.trans("store_gacha_tip_3")
    end
    DialogManager.ShowConfirmPop(tips, content, confirmFunc)
end

function PlayerRecycleCtrl:OnHelpClick()
    DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("recycle_help"))
end

function PlayerRecycleCtrl:GetLableName(tag)
    for i,v in ipairs(PlayerRecycleModel.RecycleLable) do
        if v.tag == tag then
            return v.labelName
        end
    end
end

function PlayerRecycleCtrl:GetLableNameRed(tag)
    for i,v in ipairs(PlayerRecycleModel.RecycleLableRed) do
        if v.tag == tag then
            return v.labelName
        end
    end
end

function PlayerRecycleCtrl:GetStatusData()
    return self.playerRecycleModel
end

return PlayerRecycleCtrl