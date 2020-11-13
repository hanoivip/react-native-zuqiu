local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CompeteGuessStageRewardView = class(unity.base, "CompeteGuessStageRewardView")

function  CompeteGuessStageRewardView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 竞猜奖励显示区域
    self.objStage = self.___ex.objStage
    -- 头部信息
    self.txtHead = self.___ex.txtHead
    self.rctReward = self.___ex.rctReward
    -- 支持按钮
    self.btnSupport = self.___ex.btnSupport
end

function CompeteGuessStageRewardView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CompeteGuessStageRewardView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)

    self.btnSupport:regOnButtonClick(function()
        self:OnBtnSupportClick()
    end)
end

function CompeteGuessStageRewardView:InitView(competeGuessStageRewardModel)
    self.model = competeGuessStageRewardModel
    local rewardData = self.model:GetStageReward()
    self.txtTitle.text = lang.trans("compete_guess_desc14")
    self.txtHead.text = lang.trans("compete_guess_reward_2", string.formatNumWithUnit(rewardData.mConsume))
    assert(rewardData.contents, "data.contents is nil")

    GameObjectHelper.FastSetActive(self.btnSupport.gameObject, self.model:CanSupport())

    res.ClearChildren(self.rctReward)
    local rewardParams = {
        parentObj = self.rctReward,
        rewardData = rewardData.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function CompeteGuessStageRewardView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function CompeteGuessStageRewardView:OnBtnSupportClick()
    EventSystem.SendEvent("CompeteGuess_SupportTeam", self.model:GetStageReward())
    self:Close()
end

return CompeteGuessStageRewardView
