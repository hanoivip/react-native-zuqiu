local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PeakEveryTaskItemView = class(unity.base)

function PeakEveryTaskItemView:ctor()
    self.typeTxt = self.___ex.typeTxt
    self.descTxt = self.___ex.descTxt
    self.border = self.___ex.border
    self.receiveBtn = self.___ex.receiveBtn
    self.finishSlider = self.___ex.finishSlider
    self.finishTxt = self.___ex.finishTxt
    self.rewardRect = self.___ex.rewardRect
    self.receiveButton = self.___ex.receiveButton
    self.received = self.___ex.received
    self.enable = self.___ex.enable
    self.disable = self.___ex.disable
end

function PeakEveryTaskItemView:InitView(data, model)
    self.typeTxt.text = model:GetTitleById(data.ID)
    self.descTxt.text = model:GetDescById(data.ID)

    self.receiveBtn:regOnButtonClick(function ()
        if self.receiveBtnClick then
            self.receiveBtnClick()
        end
    end)
    self.receiveButton.interactable = (tonumber(data.status) == 0)
    self.receiveBtn:onPointEventHandle(tonumber(data.status) == 0)
    GameObjectHelper.FastSetActive(self.enable, tonumber(data.status) == 0)
    GameObjectHelper.FastSetActive(self.disable, tonumber(data.status) ~= 0)
    GameObjectHelper.FastSetActive(self.border, tonumber(data.status) == 0)
    local silderLoading = 0
    if data.type == 1 then
        silderLoading = model:GetChallengeTaskTime()
    elseif data.type == 2 then
        silderLoading = model:GetWinTaskTime()
    end
    local sliderMax = data.condition
    self.finishTxt.text = silderLoading .. "/" .. sliderMax
    self.finishSlider.maxValue = sliderMax
    self.finishSlider.value = silderLoading
    GameObjectHelper.FastSetActive(self.receiveBtn.gameObject, tonumber(data.status) ~= 1)
    GameObjectHelper.FastSetActive(self.received, tonumber(data.status) == 1)

    res.ClearChildren(self.rewardRect)
    local rewardParams = {
        parentObj = self.rewardRect,
        rewardData = data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

return PeakEveryTaskItemView