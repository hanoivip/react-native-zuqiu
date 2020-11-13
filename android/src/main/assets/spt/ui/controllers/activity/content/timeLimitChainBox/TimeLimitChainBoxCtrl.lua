local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local TimeLimitChainBoxCtrl = class(ActivityContentBaseCtrl)

function TimeLimitChainBoxCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.onBoxBtnClick = function (boxData) self:ClickBoxBtn(boxData) end
    self.view.runOutOfTime = function () self:RunOutOfTime() end
    self.view:InitView(self.activityModel)
    self.playerInfoModel = PlayerInfoModel.new()
end

function TimeLimitChainBoxCtrl:OnRefresh()
    self.view:InitView(self.activityModel)
end

function TimeLimitChainBoxCtrl:OnBuyReward(data)
    self.data = data
    CostDiamondHelper.CostCurrency(data.price, nil, function() self:Buy(data) end, data.currencyType)
end

function TimeLimitChainBoxCtrl:Buy(data, buyCount)
    local vipLevel = self.playerInfoModel:GetVipLevel()
    if vipLevel < data.minVip then
        local vipTip = lang.trans("vip_level_limit", data.minVip)
        DialogManager.ShowToast(vipTip)
        return
    end

    local msg = ""
    if data.currencyType == CurrencyType.Diamond then
        msg = lang.trans("confirm_cost_diamond", data.price * buyCount)
    elseif data.currencyType == CurrencyType.BlackDiamond then
        msg = lang.trans("confirm_cost_blackDiamond", data.price * buyCount)
    end
    DialogManager.ShowConfirmPop(lang.trans("tips"), msg, function()
        clr.coroutine(function()
            local response = req.buyChainGiftBox(data.subID, buyCount)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.gift)
                local cost = data.cost
                for k,v in pairs(cost) do
                    self.playerInfoModel:CostDetail(v)
                end
            end
        end)
    end)
end

function TimeLimitChainBoxCtrl:ClickBoxBtn(boxData)
    if self.activityModel:IsTimeInActivity() then
        res.PushDialog("ui.controllers.activity.content.timeLimitChainBox.ChainBoxBuyCtrl", boxData)
    else
        DialogManager.ShowToastByLang("visit_endInfo")
    end
end

function TimeLimitChainBoxCtrl:OnBuyReward(data, buyCount)
    self.data = data
    CostDiamondHelper.CostCurrency(data.price * buyCount, nil, function() self:Buy(data, buyCount) end, data.currencyType)
end

function TimeLimitChainBoxCtrl:RunOutOfTime()
    EventSystem.SendEvent("TimeLimitChainBox.RunOutOfTime")
    self.activityModel:SetRunOutOfTime()
end

function TimeLimitChainBoxCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("TimeLimitChainBox.OnBuyReward", self, self.OnBuyReward)
end

function TimeLimitChainBoxCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("TimeLimitChainBox.OnBuyReward", self, self.OnBuyReward)
end

return TimeLimitChainBoxCtrl
