local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CompeteGuessConfirmView = class(unity.base, "CompeteGuessConfirmView")

function CompeteGuessConfirmView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    self.txtHead = self.___ex.txtHead
    self.txtContent = self.___ex.txtContent
    -- 确认按钮
    self.btnConfirm = self.___ex.btnConfirm
    -- 奖励
    self.rctReward = self.___ex.rctReward
end

function CompeteGuessConfirmView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CompeteGuessConfirmView:InitView(competeGuessConfirmModel)
    self.model = competeGuessConfirmModel
    self.txtHead.text = self.model:GetHead()
    self.txtContent.text = self.model:GetContent()
    local rewards = self.model:GetRewards()

    res.ClearChildren(self.rctReward)
    local rewardParams = {
        parentObj = self.rctReward,
        rewardData = rewards.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function CompeteGuessConfirmView:RegBtnEvent()
    self.btnConfirm:regOnButtonClick(function()
        if self.onClickConfirm and type(self.onClickConfirm) == "function" then
            self.onClickConfirm()
        end
    end)
end

function CompeteGuessConfirmView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function CompeteGuessConfirmView:OnEnterScene()
    EventSystem.AddEvent("CompeteGuess_Confirm", self, self.OnToggleClick)
end

function CompeteGuessConfirmView:OnExitScene()
    EventSystem.RemoveEvent("CompeteGuess_Confirm", self, self.OnToggleClick)
end

function CompeteGuessConfirmView:OnToggleClick(label)
    if self.onToggleClick and type(self.onToggleClick) == "function" then
        self.onToggleClick(label)
    end
end

return CompeteGuessConfirmView
