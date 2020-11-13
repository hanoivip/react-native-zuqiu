local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CompeteGuessMyItemView = require("ui.scene.compete.guess.CompeteGuessMyItemView")

local CompeteGuessMyItemReverseView = class(CompeteGuessMyItemView, "CompeteGuessMyItemReverseView")

function CompeteGuessMyItemReverseView:ctor()
    CompeteGuessMyItemReverseView.super.ctor(self)
    -- 竞猜金额
    self.txtMoney = self.___ex.txtMoney
    -- 竞猜奖励区域
    self.rctStageRewardLayout = self.___ex.rctStageRewardLayout
    -- 倍率
    self.txtMultiple = self.___ex.txtMultiple
    -- 竞猜奖励领取按钮
    self.btnRecive = self.___ex.btnRecive
    -- 竞猜奖励已领取
    self.imgReceived = self.___ex.imgReceived
    -- 翻盘奖励区域
    self.rctReverseRewardLayout = self.___ex.rctReverseRewardLayout
    -- 翻盘奖励id
    self.txtReverseReward = self.___ex.txtReverseReward

    self.stageReward = nil
    self.reverseReward = nil
end

function CompeteGuessMyItemReverseView:start()
    self:RegBtnEvent()
end

function CompeteGuessMyItemReverseView:InitView(data, competeGuessModel)
    CompeteGuessMyItemReverseView.super.InitView(self, data, competeGuessModel)
    self.stageReward = self.competeGuessModel:GetStageRewardByStage(data.stage) or {}
    self.reverseReward = self.competeGuessModel:GetReverseRewardByRatio(self.matchData.guessRatio)

    GameObjectHelper.FastSetActive(self.imgSuccess.gameObject, true)
    GameObjectHelper.FastSetActive(self.imgFailed.gameObject, false)

    local money = self.competeGuessModel:GetGuessMoney(data.guessStage)
    self.txtMoney.text = "X" .. string.formatNumWithUnit(money)
    assert(self.stageReward.contents, "stage reward data.contents is nil")

    res.ClearChildren(self.rctStageRewardLayout)
    local rewardParams = {
        parentObj = self.rctStageRewardLayout,
        rewardData = self.stageReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    -- 翻盘奖励
    self.txtReverseReward.text = lang.trans("compete_guess_reward_4", self.reverseReward.idx)
    assert(self.reverseReward.contents, "reverse reward data.contents is nil")

    res.ClearChildren(self.rctReverseRewardLayout)
    local rewardParams = {
        parentObj = self.rctReverseRewardLayout,
        rewardData = self.reverseReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    -- 是否已领取
    if data.redeemed then
        GameObjectHelper.FastSetActive(self.btnRecive.gameObject, false)
        GameObjectHelper.FastSetActive(self.imgReceived.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.btnRecive.gameObject, true)
        GameObjectHelper.FastSetActive(self.imgReceived.gameObject, false)
        local guessRatio = tonumber(string.format("%.2f", data.match.guessRatio or 0))
        GameObjectHelper.FastSetActive(self.txtMultiple.gameObject, guessRatio > 1)
        self.txtMultiple.text = lang.trans("compete_guess_desc4", guessRatio)
    end
end

function CompeteGuessMyItemReverseView:RegBtnEvent()
    CompeteGuessMyItemReverseView.super.RegBtnEvent(self)
    self.btnRecive:regOnButtonClick(function()
        if self.onRewardReceive then
            self.onRewardReceive(self.data.season, self.data.round, self.data.matchType, self.data.combatIndex, self.data.idx)
        end
    end)
end

return CompeteGuessMyItemReverseView
