local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Object = clr.UnityEngine.Object
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardContentScrollView = class(unity.base)

function RewardContentScrollView:ctor()
    self.contentTrans = self.___ex.contentTrans
    self.hLayout = self.___ex.hLayout
end

function RewardContentScrollView:InitView(model)
    res.ClearChildren(self.contentTrans.transform)
    self.hLayout.enabled = false
    if model then
        local rewardParams = {
            parentObj = self.contentTrans,
            rewardData = model:GetRewardContents(),
            isShowName = true,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
    self:coroutine(function()
        coroutine.yield()
        coroutine.yield()
        self.hLayout.enabled = true
    end)
end

return RewardContentScrollView