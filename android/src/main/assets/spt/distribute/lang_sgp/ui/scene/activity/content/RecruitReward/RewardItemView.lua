local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardItemView = class(unity.base)

function RewardItemView:ctor()
	self.content = self.___ex.content
	self.btnCollect = self.___ex.btnCollect
	self.collectedTag = self.___ex.collectedTag
	self.recruitText = self.___ex.recruitText
	self.btnDisable = self.___ex.btnDisable
	self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

	self.btnCollect:regOnButtonClick(function()
		if self.clickCollectBtn then
			self.clickCollectBtn(self.model.count)
		end
	end)
	self.model = nil
end

function RewardItemView:InitView(model, parentRect, activityState)
	self.model = model
	self:ShowCollectedTag(self.model.btnStatus == -1)
	
	res.ClearChildren(self.content)
    self.recruitText.text = lang.trans("recruitReward_activity_desc9", self.model.count)
    local rewardParams = {
        parentObj = self.content,
        rewardData = model.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentRect
    RewardDataCtrl.new(rewardParams)
end

function RewardItemView:ShowCollectedTag(isShow)
	if self.showCollectedTag then
		self.showCollectedTag(isShow)
	end
end

return RewardItemView