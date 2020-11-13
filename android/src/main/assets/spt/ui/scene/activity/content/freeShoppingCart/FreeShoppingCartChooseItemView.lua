local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local FreeShoppingCartChooseItemView = class()

function FreeShoppingCartChooseItemView:ctor()
--------Start_Auto_Generate--------
    self.chooseGo = self.___ex.chooseGo
    self.rewardTrans = self.___ex.rewardTrans
    self.chooseBtn = self.___ex.chooseBtn
--------End_Auto_Generate----------
end

function FreeShoppingCartChooseItemView:start()
    self.chooseBtn:regOnButtonClick(function()
        self:ChooseClick()
    end)
end

function FreeShoppingCartChooseItemView:InitView(rewardData, chooseFunc)
    self.rewardData = rewardData
    self.chooseFunc = chooseFunc
    self:SetChooseState(false)
    GameObjectHelper.FastSetActive(self.chooseGo, false)
    local rewardParams = {
        parentObj = self.rewardTrans,
        rewardData = rewardData.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    res.ClearChildren(self.rewardTrans)
    RewardDataCtrl.new(rewardParams)
end

function FreeShoppingCartChooseItemView:ChooseClick()
    if self.chooseFunc then
        self.chooseFunc(self.rewardData)
    end
end

function FreeShoppingCartChooseItemView:SetChooseState(state)
    GameObjectHelper.FastSetActive(self.chooseGo, state)
end

return FreeShoppingCartChooseItemView
