local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local OptionRewardItemView = class(unity.base)

function OptionRewardItemView:ctor()
    self.itemArea = self.___ex.itemArea
    self.selectBtn = self.___ex.selectBtn
end

function OptionRewardItemView:InitView(data)
    res.ClearChildren(self.itemArea)
    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = data.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        itemParams = {
            -- 名称颜色
            nameColor = Color.white,
            -- 名称阴影颜色
            nameShadowColor = Color.black,
            -- 个数字号
            numFont = 14,
        },
    }
    RewardDataCtrl.new(rewardParams)

    self.selectBtn:regOnButtonClick(function ()
        if self.onClickSelectBtn then
            self.onClickSelectBtn()
        end
    end)
end

return OptionRewardItemView