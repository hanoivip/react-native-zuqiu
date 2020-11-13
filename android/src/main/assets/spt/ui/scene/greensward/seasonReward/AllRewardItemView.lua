local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AdventureRewardBase = require("data.AdventureRewardBase")
local AllRewardItemView = class(unity.base)

function AllRewardItemView:ctor()
--------Start_Auto_Generate--------
    self.levelTxt = self.___ex.levelTxt
    self.rewardTrans = self.___ex.rewardTrans
    self.btnsGo = self.___ex.btnsGo
    self.boughtGo = self.___ex.boughtGo
    self.getRewardBtn = self.___ex.getRewardBtn
    self.rate1Txt = self.___ex.rate1Txt
    self.rewardDisableGo = self.___ex.rewardDisableGo
    self.rate2Txt = self.___ex.rate2Txt
    self.notInAreaGo = self.___ex.notInAreaGo
--------End_Auto_Generate----------
end

function AllRewardItemView:start()
    self.getRewardBtn:regOnButtonClick(function()
        if type(self.receiveCallBack) == "function" then
            self.receiveCallBack(self.data)
        end
    end)
    EventSystem.AddEvent("AllRewardItemView_Refresh", self, self.RefreshButtonState)
end

function AllRewardItemView:InitView(data, receiveCallBack)
    self.data = data
    self.receiveCallBack = receiveCallBack
    self.isInMyRegion = data.isInMyRegion
    self.floorID = data.floorID
    local completeData = data.completeData
    local levelData = data.fullStageReward
    local floorIDStr = tostring(self.floorID)
    self.levelTxt.text = floorIDStr

    self:RefreshButtonState(self.floorID, completeData)
    res.ClearChildren(self.rewardTrans)
    if type(levelData) ~= "table" then
        return
    end
    for i, v in pairs(levelData) do
        local contents = AdventureRewardBase[v].contents
        local rewardParams = {
            parentObj = self.rewardTrans,
            rewardData = contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            isShowSymbol = false,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function AllRewardItemView:RefreshButtonState(index, completeData)
    if tostring(self.floorID) == tostring(index) then
        GameObjectHelper.FastSetActive(self.btnsGo, self.isInMyRegion)
        GameObjectHelper.FastSetActive(self.notInAreaGo, not self.isInMyRegion)
        if self.isInMyRegion then
            completeData = completeData or {}
            local rate = completeData.rate or 0
            local st = completeData.st or 0
            local rateStr = rate .. "%"
            self.rate1Txt.text = rateStr
            self.rate2Txt.text = rateStr
            GameObjectHelper.FastSetActive(self.boughtGo, st == 1)
            GameObjectHelper.FastSetActive(self.getRewardBtn.gameObject, st == 0 and rate == 100)
            GameObjectHelper.FastSetActive(self.rewardDisableGo, st == 0 and rate < 100)
        end
    end
end

function AllRewardItemView:onDestroy()
    EventSystem.RemoveEvent("AllRewardItemView_Refresh", self, self.RefreshButtonState)
end

return AllRewardItemView
