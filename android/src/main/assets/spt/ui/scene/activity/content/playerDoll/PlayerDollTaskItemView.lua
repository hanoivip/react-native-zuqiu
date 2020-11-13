local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerDollTaskItemView = class(unity.base)

function PlayerDollTaskItemView:ctor()
--------Start_Auto_Generate--------
    self.infoTxt = self.___ex.infoTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.rewardBtn = self.___ex.rewardBtn
    self.lockGo = self.___ex.lockGo
    self.receivedGo = self.___ex.receivedGo
--------End_Auto_Generate----------
end

function PlayerDollTaskItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnClickBtn()
    end)
end

function PlayerDollTaskItemView:InitView(task, playerDollModel)
    self.playerDollModel = playerDollModel
    self.taskId = task.id
    self.taskDetail = task.reward
    local count = self.taskDetail.count
    local reward = self.taskDetail.contents
    local stage = self.playerDollModel:GetCountRewardState(self.taskId)
    self.infoTxt.text = lang.trans("timeLimit_player_doll_timesTip",count)
    self:InitReward(reward)
    self:SetState(stage)
end

function PlayerDollTaskItemView:InitReward(reward)
    res.ClearChildren(self.itemAreaTrans)
    local rewardParams = {
        parentObj = self.itemAreaTrans,
        rewardData = reward,
        isShowName = false,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function PlayerDollTaskItemView:SetState(stage)
    local canNotReceive = stage == self.playerDollModel.RewardState.CanNotReceive
    local canReceive = stage == self.playerDollModel.RewardState.CanReceive
    local received = stage == self.playerDollModel.RewardState.Received
    GameObjectHelper.FastSetActive(self.lockGo, canNotReceive)
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, canReceive)
    GameObjectHelper.FastSetActive(self.receivedGo, received)
end

function PlayerDollTaskItemView:OnClickBtn()
    local periodId = self.playerDollModel:GetPeriodId()
    self:coroutine(function ()
        local response = req.dollReceive(periodId, self.taskId)
        if api.success(response) then
            local data = response.val
            local rewards = data.contents
            CongratulationsPageCtrl.new(rewards)
            local stage = self.playerDollModel:GetCountRewardState(self.taskId)
            self:SetState(self.playerDollModel.RewardState.Received)
            self.playerDollModel:SetCountRewardFinished(self.taskId)
            EventSystem.SendEvent("PlayerDoll_Receive")
        end
    end)
end

return PlayerDollTaskItemView
