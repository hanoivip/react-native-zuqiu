local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local MarblesCountRewardModel = require("ui.models.activity.marbles.MarblesCountRewardModel")
local MarblesCountRewardItemView = class(unity.base)
local RewardState = MarblesCountRewardModel.RewardState

function MarblesCountRewardItemView:ctor()
--------Start_Auto_Generate--------
    self.receiveCountTxt = self.___ex.receiveCountTxt
    self.exchangeTrans = self.___ex.exchangeTrans
    self.exchangeBtn = self.___ex.exchangeBtn
    self.buyLimitTxt = self.___ex.buyLimitTxt
    self.soldOutGo = self.___ex.soldOutGo
    self.disableGo = self.___ex.disableGo
--------End_Auto_Generate----------
    self.gradientTxt = self.___ex.gradientTxt
end

function MarblesCountRewardItemView:start()
    self.exchangeBtn:regOnButtonClick(function()
        self:OnClickBtn()
    end)
end

function MarblesCountRewardItemView:InitView(rewardDataData, receiveCallBack)
    self.exchangeData = rewardDataData
    self.clickReceive = receiveCallBack
    self.rewardID = rewardDataData.subID
    local rewardParams = {
        parentObj = self.exchangeTrans,
        rewardData = rewardDataData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    res.ClearChildren(self.exchangeTrans)
    RewardDataCtrl.new(rewardParams)
    self:SetButtonState(rewardDataData.rewardState)
    self.receiveCountTxt.text = lang.trans("marbles_count_content", rewardDataData.count)
end

function MarblesCountRewardItemView:SetButtonState(rewardState)
    GameObjectHelper.FastSetActive(self.soldOutGo, rewardState == RewardState.Received)
    GameObjectHelper.FastSetActive(self.exchangeBtn.gameObject, rewardState == RewardState.Enable)
    GameObjectHelper.FastSetActive(self.disableGo, rewardState == RewardState.Disable)
end

function MarblesCountRewardItemView:OnClickBtn()
    self.clickReceive(self.rewardID)
end

return MarblesCountRewardItemView
