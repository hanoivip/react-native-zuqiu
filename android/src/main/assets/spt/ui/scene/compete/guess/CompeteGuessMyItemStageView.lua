local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CompeteGuessMyItemView = require("ui.scene.compete.guess.CompeteGuessMyItemView")

local CompeteGuessMyItemStageView = class(CompeteGuessMyItemView, "CompeteGuessMyItemStageView")

function CompeteGuessMyItemStageView:ctor()
    CompeteGuessMyItemStageView.super.ctor(self)
    -- 竞猜金额
    self.txtMoney = self.___ex.txtMoney
    -- 奖励区域
    self.rctReward = self.___ex.rctReward
    -- 领取按钮
    self.btnReceive = self.___ex.btnReceive
    -- 倍率
    self.txtMultiple = self.___ex.txtMultiple
    -- 已领取
    self.imgReceived = self.___ex.imgReceived

    self.stageReward = nil
end

function CompeteGuessMyItemStageView:start()
    self:RegBtnEvent()
end

function CompeteGuessMyItemStageView:InitView(data, competeGuessModel)
    CompeteGuessMyItemStageView.super.InitView(self, data, competeGuessModel)
    self.stageReward = self.competeGuessModel:GetStageRewardByStage(data.stage) or {}

    GameObjectHelper.FastSetActive(self.imgSuccess.gameObject, true)
    GameObjectHelper.FastSetActive(self.imgFailed.gameObject, false)

    local money = self.competeGuessModel:GetGuessMoney(data.guessStage)
    self.txtMoney.text = "X" .. string.formatNumWithUnit(money)
    assert(self.stageReward.contents, "stage reward data.contents is nil")

    res.ClearChildren(self.rctReward)
    local rewardParams = {
        parentObj = self.rctReward,
        rewardData = self.stageReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    -- 是否已领取
    if data.redeemed then
        GameObjectHelper.FastSetActive(self.btnReceive.gameObject, false)
        GameObjectHelper.FastSetActive(self.imgReceived.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.btnReceive.gameObject, true)
        GameObjectHelper.FastSetActive(self.imgReceived.gameObject, false)
        local guessRatio = tonumber(string.format("%.2f", data.match.guessRatio or 0))
        GameObjectHelper.FastSetActive(self.txtMultiple.gameObject, guessRatio > 1)
        self.txtMultiple.text = lang.trans("compete_guess_desc4", guessRatio)
    end
end

function CompeteGuessMyItemStageView:RegBtnEvent()
    CompeteGuessMyItemStageView.super.RegBtnEvent(self)
    self.btnReceive:regOnButtonClick(function()
        if self.onRewardReceive then
            self.onRewardReceive(self.data.season, self.data.round, self.data.matchType, self.data.combatIndex, self.data.idx)
        end
    end)
end

return CompeteGuessMyItemStageView
