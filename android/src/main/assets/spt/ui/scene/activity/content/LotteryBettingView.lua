local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local QuizLotteryLimit = require("data.QuizLotteryLimit")

local LotteryBettingView = class(unity.base)

function LotteryBettingView:ctor()
    self.currentInvestNumber = self.___ex.currentInvestNumber
    self.totalInvestNumber = self.___ex.totalInvestNumber
    self.oddsNumber = self.___ex.oddsNumber
    self.incomeNumber = self.___ex.incomeNumber
    self.closeButton = self.___ex.closeButton
    self.confirmButton = self.___ex.confirmButton
    self.addButton = self.___ex.addButton
    self.confirmButtonUI = self.___ex.confirmButtonUI
    self.minusButtonEnabled = self.___ex.minusButtonEnabled
    self.addButtonEnabled = self.___ex.addButtonEnabled
    self.minusButton = self.___ex.minusButton
    self.minusButtonDisabled = self.___ex.minusButtonDisabled
    self.addButtonDisabled = self.___ex.addButtonDisabled
    self.limitText = self.___ex.limitText
    self.helpButton = self.___ex.helpButton

    DialogAnimation.Appear(self.transform, nil)
end

function LotteryBettingView:InitView(model, matchResult)
    self.model = model
    self.matchResult = matchResult
    self.stakeNumber = 0

    self.closeButton:regOnButtonClick(
        function()
            self:Close()
        end
    )

    local pressAddData = {
        acceleration = 1,
        clickCallback = function()
            self:OnAddClick()
        end,
        durationCallback = function(count)
            self:OnAddClick()
        end
    }

    local pressMinusData = {
        acceleration = 1,
        clickCallback = function()
            self:OnMinusClick()
        end,
        durationCallback = function(count)
            self:OnMinusClick()
        end
    }

    self.minusButton:regOnButtonPressing(pressMinusData)
    self.addButton:regOnButtonPressing(pressAddData)

    self.confirmButton:regOnButtonClick(
        function()
            if self.confirmButtonUI.interactable then
                self:OnConfirmClick()
            end
        end
    )
    self:OnRefresh()
end

function LotteryBettingView:OnEnterScene()
end

function LotteryBettingView:OnExitScene()
end

function LotteryBettingView:OnRefresh()
    local odds = self.model.globalStakeInfo.odds[tostring(self.matchResult)]
    local playerInfoModel = PlayerInfoModel.new()
    local money = playerInfoModel:GetMoney()
    local level = playerInfoModel:GetLevel()
    local vip = playerInfoModel:GetVipLevel()

    local limit1 = 0
    local limit2 = 0
    for k, v in pairs(QuizLotteryLimit) do
        if level >= tonumber(v.teamLevelLimit[1]) and level <= tonumber(v.teamLevelLimit[2]) then
            limit1 = v.quizPrice
        end
        if vip >= tonumber(v.vipLevelLimit[1]) and vip <= tonumber(v.vipLevelLimit[2]) then
            limit2 = v.quizPrice
        end
    end

    local limit = math.max(limit1, limit2)
    self.limitText.text = lang.trans("lottery_disclaimer_limit", string.formatIntWithTenThousands(limit))

    local totalStake = self.stakeNumber
    if self.model.selfStakeInfo and self.model.selfStakeInfo.stake[tostring(self.matchResult)] then
        totalStake = totalStake + self.model.selfStakeInfo.stake[tostring(self.matchResult)].stakeNumber
    end

    local matchStake = self.stakeNumber

    if self.model.selfStakeInfo then
        for k, v in pairs(self.model.selfStakeInfo.stake) do
            matchStake = matchStake + v.stakeNumber
        end
    end

    self.currentInvestNumber.text = tostring(self.stakeNumber * 100)
    self.totalInvestNumber.text = string.format(lang.transstr("betting_amount"), totalStake * 100)
    self.oddsNumber.text = string.format("%.2f", odds)
    self.incomeNumber.text = string.format(lang.transstr("betting_amount"), totalStake * 100 * odds)

    local canMinus = (self.stakeNumber > 0)
    self.minusButtonEnabled:SetActive(canMinus)
    self.minusButtonDisabled:SetActive(not canMinus)

    local canAdd = (money >= (self.stakeNumber + 1) * 100 * 10000)
    canAdd = canAdd and (limit >= (matchStake + 1) * 100 * 10000)

    self.addButtonEnabled:SetActive(canAdd)
    self.addButtonDisabled:SetActive(not canAdd)

    self.confirmButtonUI.interactable = (self.stakeNumber > 0 and money >= self.stakeNumber * 100 * 10000)
end

function LotteryBettingView:OnAddClick()
    self.stakeNumber = self.stakeNumber + 1
    self:OnRefresh()
end

function LotteryBettingView:OnMinusClick()
    self.stakeNumber = self.stakeNumber - 1
    self:OnRefresh()
end

function LotteryBettingView:OnConfirmClick()
    if self.onConfirmClick then
        self.onConfirmClick(self.model.matchId, self.stakeNumber, self.matchResult)
    end
end

function LotteryBettingView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(
            self.transform,
            nil,
            function()
                self.closeDialog()
            end
        )
    end
end

return LotteryBettingView
