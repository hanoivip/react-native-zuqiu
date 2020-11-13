local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TreasureCountRewardItemView = class(unity.base)

function TreasureCountRewardItemView:ctor()
    self.content = self.___ex.content
    self.btnCollect = self.___ex.btnCollect
    self.collectedTag = self.___ex.collectedTag
    self.recruitText = self.___ex.recruitText
    self.btnDisable = self.___ex.btnDisable
    self.effectGo = self.___ex.effectGo
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

    self.btnCollect:regOnButtonClick(function()
        if self.collectCallBack then
            self.collectCallBack(self.count)
        end
    end)
end

function TreasureCountRewardItemView:InitView(countData, collectCallBack)
    self.count = countData.count
    self.status = countData.status
    self.collectCallBack = collectCallBack
    GameObjectHelper.FastSetActive(self.btnDisable, self.status == -1)
    GameObjectHelper.FastSetActive(self.collectedTag, self.status == 1)
    GameObjectHelper.FastSetActive(self.btnCollect.gameObject, self.status == 0)
    -- GameObjectHelper.FastSetActive(self.effectGo, self.status == 0)
    res.ClearChildren(self.content)
    self.recruitText.text = lang.trans("player_treasure_count_content", self.count)
    local rewardParams = {
        parentObj = self.content,
        rewardData = countData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = self.scrollRect
    RewardDataCtrl.new(rewardParams)
end

return TreasureCountRewardItemView