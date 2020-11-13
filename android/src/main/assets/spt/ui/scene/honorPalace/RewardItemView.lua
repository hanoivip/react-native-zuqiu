local AssetFinder = require("ui.common.AssetFinder")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local RewardItemView = class(unity.base)

function RewardItemView:ctor()
    self.levelTxt = self.___ex.levelTxt
    self.contentRect =self.___ex.contentRect
    self.disableBtn = self.___ex.disableBtn
    self.rewardBtn = self.___ex.rewardBtn
    self.finish = self.___ex.finish
    self.bgImg = self.___ex.bgImg
    self.childScrollContentDragSpt = self.___ex.childScrollContentDragSpt
end

function RewardItemView:start()
    self.rewardBtn:regOnButtonClick(function ()
        if self.onClickReceiveBtn then
            self.onClickReceiveBtn()
        end
    end)
end

function RewardItemView:InitView(data)
    res.ClearChildren(self.contentRect)
    local rewardParams = {
        parentObj = self.contentRect,
        rewardData = data.rewardData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
    self.levelTxt.text = lang.trans("honor_effort_tip", data.level)

    GameObjectHelper.FastSetActive(self.disableBtn, not data.state)
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, data.state and tonumber(data.state) == 0)
    GameObjectHelper.FastSetActive(self.finish, data.state and tonumber(data.state) == 1)
    GameObjectHelper.FastSetActive(self.bgImg.gameObject, data.bgIndex % 2 == 0)
end

return RewardItemView