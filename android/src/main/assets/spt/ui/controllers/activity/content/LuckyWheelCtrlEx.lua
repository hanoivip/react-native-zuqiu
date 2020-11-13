local EventSystems = clr.UnityEngine.EventSystems
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local LuckyWheelCtrl = require("ui.controllers.activity.content.LuckyWheelCtrl")
local LuckyWheelCtrlEx = class(LuckyWheelCtrl)

function LuckyWheelCtrlEx:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.onIndianaStart = function(reqStartCallback, waitAnimationCallback, indianaType)
        self:StartIndiana(reqStartCallback, waitAnimationCallback, indianaType)
    end
    self.view.openRewardBoard = function(isGetReward, rewardId)
        self:OpenRewardBoard(isGetReward, rewardId)
    end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    -- 跳过动画
    self.view.onToggleSkipAnim = function() self:OnToggleSkipAnim() end
    self.playerInfoModel = PlayerInfoModel.new()
    self.view:InitView(self.activityModel)
end

function LuckyWheelCtrlEx:StartIndiana(reqStartCallback, waitAnimationCallback, indianaType)
    local needDiamond, indianaBuyCount, ticketNum, tipContent, tipEnoughContent = 0, 1, 0
    local itemsMapModel = ItemsMapModel.new()
    if indianaType == "oneGacha" then
        needDiamond = self.activityModel:GetOneIndianaCost()
        ticketNum = itemsMapModel:GetItemNum(18)
        tipContent = lang.trans("wheel_one_tips", needDiamond, indianaBuyCount)
        tipEnoughContent = lang.trans("wheel_one_enough_tips")
    elseif indianaType == "fiveGacha" then
        needDiamond = self.activityModel:GetMoreIndianaCost()
        ticketNum = itemsMapModel:GetItemNum(19)
        indianaBuyCount = 5
        tipContent = lang.trans("wheel_ten_tips", needDiamond, indianaBuyCount)
        tipEnoughContent = lang.trans("wheel_five_enough_tips")
    end 
    local selfDiamond = self.playerInfoModel:GetDiamond()
    
    local callbackBuyDiamond = function()
        CostDiamondHelper.CostDiamond(needDiamond)
    end
    local callbackStartIndiana = function()
        local hasAnim = not self.activityModel:GetIsSkipAnim()
        if hasAnim then
            self.view:StartDial()
        end
        clr.coroutine(function()
            local response = req.snatchGacha(self.activityModel:GetPeriodID(), indianaType)
            if api.success(response) then
                local data = response.val
                local currentEventSystem = EventSystems.EventSystem.current
                currentEventSystem.enabled = false
                self.playerInfoModel:CostDetail(data.cost)
                itemsMapModel:UpdateFromReward(data.cost)
                CustomEvent.ConsumeDiamond("1", tonumber(data.cost.num))
                self.activityModel:SetCurrentRewardIds(data.gachaRewardIDs)
                self.activityModel:SetOpenCount(data.gachaCount)
                if hasAnim then
                    while waitAnimationCallback() do
                        coroutine.yield()
                    end
                end
                CongratulationsPageCtrl.new(data.gift)
                currentEventSystem.enabled = true
            else
                self.view:PlayingEnd()
            end
        end)
    end
    if ticketNum <= 0 then
        if selfDiamond >= needDiamond then
            DialogManager.ShowConfirmPop(lang.trans("tips"), tipContent, 
            function() 
                callbackStartIndiana()
            end)
        else
            DialogManager.ShowConfirmPop(lang.trans("tips"), tipContent, 
            function() 
                callbackBuyDiamond()
            end)
        end
    else
        DialogManager.ShowConfirmPop(lang.trans("tips"), tipEnoughContent, callbackStartIndiana)
    end
end

function LuckyWheelCtrlEx:OpenRewardBoard(isGetReward, rewardId)
    if isGetReward then
        clr.coroutine(function()
            local response = req.snatchReceiveReward(tostring(self.activityModel:GetPeriodID()), rewardId)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.gift)
                self.activityModel:UpdatePointRewardInfo(rewardId)
            end
        end)
    else
        res.PushDialog("ui.controllers.activity.content.TimeLimitLuckyWheelRewardCtrl", self.activityModel:GetPointRewardList(), function(isGetReward, rewardId)
            self:OpenRewardBoard(isGetReward, rewardId)
        end)
    end
end

-- 跳过动画
function LuckyWheelCtrlEx:OnToggleSkipAnim()
    self.activityModel:SetIsSkipAnim(not self.activityModel:GetIsSkipAnim())
    self.view:SwitchToggleSkipAnim(self.activityModel:GetIsSkipAnim())
end

return LuckyWheelCtrlEx