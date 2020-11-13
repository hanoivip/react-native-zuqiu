local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CompeteGuessReverseRewardView = class(unity.base, "CompeteGuessReverseRewardView")

function  CompeteGuessReverseRewardView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 翻盘奖励区域
    self.objReverse = self.___ex.objReverse
    -- 翻盘奖励滑动框
    self.reverseScroll = self.___ex.reverseScroll
    -- 提示
    self.txtHead = self.___ex.txtHead
end

function CompeteGuessReverseRewardView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CompeteGuessReverseRewardView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function CompeteGuessReverseRewardView:InitView(competeGuessReverseRewardModel)
    self.model = competeGuessReverseRewardModel
    self.txtTitle.text = lang.trans("compete_guess_desc3")
    self.txtHead.text = lang.trans("compete_guess_desc11", self.model:GetJudgeStage())
    self.reverseScroll:InitView(self.model:GetReverseReward())
end

function CompeteGuessReverseRewardView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return CompeteGuessReverseRewardView
