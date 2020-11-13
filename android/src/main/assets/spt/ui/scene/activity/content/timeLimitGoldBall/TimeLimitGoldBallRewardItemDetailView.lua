local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local TimeLimitGoldBallRewardItemDetailView = class(unity.base, "TimeLimitGoldBallRewardItemDetailView")

function TimeLimitGoldBallRewardItemDetailView:ctor()
    -- 背景
    self.imgBg = self.___ex.imgBg
    -- 分割条
    self.imgSplit = self.___ex.imgSplit
    -- 奖励容器
    self.rctReward = self.___ex.rctReward
    -- 已获得
    self.imgReceived = self.___ex.imgReceived
    -- 点击领取
    self.btnClick = self.___ex.btnClick
    -- 黑色遮罩
    self.imgMask = self.___ex.imgMask
    -- 禁用时背景
    self.imgDisableBg = self.___ex.imgDisableBg
	self.receiveSign = self.___ex.receiveSign

    self.pos = -1 -- 奖励位置
end

-- @param isAdvance [boolean]: 是否是进阶奖励
function TimeLimitGoldBallRewardItemDetailView:InitView(pos, itemData, isAdvance)
    if isAdvance == nil then isAdvance = false end
    self.pos = pos
    self.data = itemData
    self.isAdvance = isAdvance
    local isReceived = self.data.isReceived
    local canReceive = self.data.canReceive

    res.ClearChildren(self.rctReward)
	local hasReward = tobool(type(self.data.contents) == "table")
    if hasReward then
		local param = {
			-- 父节点
			parentObj = self.rctReward,
			-- 奖励数据
			rewardData = self.data.contents,
			-- 是否显示名称
			isShowName = false,
			-- 是否已获得
			isReceive = false,
			-- 是否显示已拥有标签
			isShowSymbol = false,
			-- 是否显示基础奖励
			isShowBaseReward = true,
			-- 是否显示卡牌奖励
			isShowCardReward = true,
			-- 是否点击显示详情
			isShowDetail = true,
			-- 是否显示右上角数字
			hideCount = false
		}
		RewardDataCtrl.new(param)
    end
	GameObjectHelper.FastSetActive(self.btnClick.gameObject, canReceive and hasReward)
	GameObjectHelper.FastSetActive(self.receiveSign.gameObject, canReceive and hasReward)
    GameObjectHelper.FastSetActive(self.imgMask.gameObject, not (isReceived or canReceive))
    GameObjectHelper.FastSetActive(self.imgDisableBg.gameObject, not (isReceived or canReceive))
    GameObjectHelper.FastSetActive(self.imgReceived.gameObject, isReceived)
end

function TimeLimitGoldBallRewardItemDetailView:start()
    self:RegBtnEvent()
end

function TimeLimitGoldBallRewardItemDetailView:RegBtnEvent()
    self.btnClick:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

-- 点击领取奖励
function TimeLimitGoldBallRewardItemDetailView:OnBtnClick()
    if self.data ~= nil then
        EventSystem.SendEvent("TimeLimit_GoldBall_ReceiveReward", self.pos, self.isAdvance, self.data)
    end
end

return TimeLimitGoldBallRewardItemDetailView
