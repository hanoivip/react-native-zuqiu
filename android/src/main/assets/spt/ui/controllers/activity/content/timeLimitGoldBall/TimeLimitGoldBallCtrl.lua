local CurrencyType = require("ui.models.itemList.CurrencyType")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local TimeLimitGoldBallCtrl = class(ActivityContentBaseCtrl, "TimeLimitGoldBallCtrl")

function TimeLimitGoldBallCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.onBtnIntro = function() self:OnBtnIntro() end
    self.view.onChangeMissionType = function(missionType) self:OnChangeMissionType(missionType) end
    self.view.onBtnBuyAdvance = function() self:OnBtnBuyAdvance() end
    self.view.onBuyAdvanceConfirm = function() self:OnBuyAdvanceConfirm() end
    self.view.onReceiveReward = function(pos, isAdvance, itemData) self:OnReceiveReward(pos, isAdvance, itemData) end
    self.view.onReceiveMissionReward = function(itemData) self:OnReceiveMissionReward(itemData) end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.model = self.activityModel
    self.view:InitView(self.model)
    self.view:RefreshView()
end

function TimeLimitGoldBallCtrl:OnRefresh()
    self.view:RefreshView()
end

function TimeLimitGoldBallCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function TimeLimitGoldBallCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 点击玩法说明
function TimeLimitGoldBallCtrl:OnBtnIntro()
    local simpleIntroduceModel = SimpleIntroduceModel.new(self.model:GetIntro())
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

-- 更改页面显示的任务类型
function TimeLimitGoldBallCtrl:OnChangeMissionType(missionType)
    self.model:SetCurrMissionType(missionType)
    self.view:RefreshMissionView()
end

-- 购买进阶奖励资格
function TimeLimitGoldBallCtrl:OnBtnBuyAdvance()
    if not self.model:GetIsHasAdvanced() then
        -- 询问购买进阶奖励
        res.PushDialog("ui.controllers.activity.content.timeLimitGoldBall.TimeLimitGoldBallAdvanceConfirmCtrl", self.model)
    end
end

-- 确认购买进阶奖励资格
function TimeLimitGoldBallCtrl:OnBuyAdvanceConfirm()
    if self.model:GetIsHasAdvanced() then 
        DialogManager.ShowToastByLang("bought")
        res.PopScene()
        return 
    end

    local advancePrice = self.model:GetAdvancePrice()
    local advancePriceType = tostring(self.model:GetAdvancePriceType())
    local advnacePriceStr = self.model:GetAdvancePriceTypeStr()

    -- 确认购买进阶奖励
    local confirmCallback = function()
        local costCallback = function()
            self.view:coroutine(function()
                local response = req.goldBallBuyAdvance()
                if api.success(response) then
                    local data = response.val
                    if not table.isEmpty(data) then
                        -- 购买进阶奖励资格成功
                        DialogManager.ShowToastByLang("buy_item_success")
                        self:ResetCousume(function()
                            res.PopScene()
                            self.model:UpdateAfterAdvanceBought(data)
                        end)
                    end
                end
            end)
        end

        CostDiamondHelper.CostCurrency(advancePrice, self.view, costCallback, advancePriceType)
    end

    local title = lang.transstr("tips")
    local msg = lang.transstr("time_limit_gold_buyadvance_confirm_tip", advnacePriceStr, string.formatNumWithUnit(advancePrice))
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

-- 点击上方奖励领取位置奖励
function TimeLimitGoldBallCtrl:OnReceiveReward(pos, isAdvance, itemData)
    local pos = pos or -1
    local rewardType = isAdvance and self.model.RewardType.Advance or self.model.RewardType.Common
    local currState = itemData.state
    local canReceive = itemData.canReceive
    if canReceive and (not isAdvance or self.model:GetIsHasAdvanced()) then
        -- 领取位置奖励
        self.view:coroutine(function()
            local response = req.goldBallReceiveGoldBall(pos, rewardType)
            if api.success(response) then
                local data = response.val
                if not table.isEmpty(data) then
                    -- 领取位置奖励成功
                    if not table.isEmpty(data.contents) then
                        CongratulationsPageCtrl.new(data.contents)
                    end
                    self.model:UpdateAfterReceiveReward(data)
                    self.view:UpdateAfterReceiveReward(data.posId)
                end
            end
        end)
    end
end

-- 点击下方领取金球奖励
function TimeLimitGoldBallCtrl:OnReceiveMissionReward(itemData)
    local taskId = itemData.taskID
    local canReceive = itemData.canReceive
    if canReceive then
        -- 领取金球奖励
        self.view:coroutine(function()
            local response = req.goldBallReceiveTask(taskId)
            if api.success(response) then
                local data = response.val
                if not table.isEmpty(data) then
                    -- 领取奖励成功
                    self.model:UpdateAfterReceiveMissionReward(data)
                    self.view:UpdateAfterReceiveMissionReward(data.taskId)
                    DialogManager.ShowToast(lang.transstr("time_limit_gold_receive", data.addGoldBallNum or 0))
                end
            end
        end)
    end
end

return TimeLimitGoldBallCtrl
