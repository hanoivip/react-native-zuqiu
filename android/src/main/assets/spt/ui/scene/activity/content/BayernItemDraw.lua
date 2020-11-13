local BayernItemDrawView = class(unity.base)
local Path = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/Bayern11/%s.png"
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

function BayernItemDrawView:ctor()
    self.rewardImage = self.___ex.rewardImage
    self.partParentRect = self.___ex.partParentRect
    self.text = self.___ex.text
end

function BayernItemDrawView:start()
end

function BayernItemDrawView:InitView(data)
    self.text.text = data.rewardDesc
    if data.picIndex == "0" then
        self.rewardImage.gameObject:SetActive(false)
    else
        self.rewardImage.overrideSprite = res.LoadRes(format(Path, data.picIndex))
    end
    if next(data.contents) ~=nil then
        self:InitRewardItem(data)
    end
end

-- 初始化虚拟奖品
function BayernItemDrawView:InitRewardItem(data)
    res.ClearChildren(self.partParentRect.transform)
    local rewardParams = {
        parentObj = self.partParentRect,
        rewardData = data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

return BayernItemDrawView
